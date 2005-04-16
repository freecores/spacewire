//File name=Module=SwitchMatrix  2005-04-10      btltz@mail.china.com    btltz from CASIC  
//Description:     buffered digital SwitchMatrix  
//                 * 16 x 16 switch connecting sixteen 9-bit FIFO I/O ports to 
//                      sixteen 9-bit output ports with  16 x 16 x ?? = 256 syn buffers. buffered each point
//Abbreviations: 	 crd  --- credit
//						 alw  --- allow
//Origin:  SpaceWire Std - Draft-1(Clause 8)of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//         SpaceWire Router Requirements Specification Issue 1 Rev 5. Astrium & University of Dundee 
//TODO:	  make rtl faster
////////////////////////////////////////////////////////////////////////////////////
//
/*synthesis translate off*/
`timescale 1ns/100ps
/*synthesis translate on */
`define reset  1	        // WISHBONE standard reset
										 
module SwitchMatrix #(parameter BW=10, PORTNUM=16, AW=4,  // (1byte + 1)Byte-WIDTH 16x16 crossbar swith
                                CellDepth =255,           // 16x16 beffers x (255Byte x 10-bit / Cell) 
										  WCCNT = (CellDepth ==255 ? 8 :
										           (CellDepth ==511 ? 9  :
													   (CellDepth == 1023 ? 10 : 'bx  )) ),
										  WIDTH_CRD = (CellDepth ==255 && PORTNUM ==16) ? 12 :  //255depth x16ports = 4080 Bbytes/column
						    							  ((CellDepth ==511 && PORTNUM ==16) ? 13 : //511depth x 16ports = 8176	Bbytes/column
															((CellDepth == 1023 && PORTNUM == 16) ? 14 :
                                            ((CellDepth ==255 && PORTNUM ==8) ? 11 :
														   ((CellDepth ==511 && PORTNUM ==8) ? 12 :
															 ((CellDepth ==1023 && PORTNUM ==8) ? 13 :'bx )))))
							 ) 						
		( // Byte width data input(output) from(to) FIFO
							    output reg [BW-1:0] do [0:PORTNUM-1],
							    input  [BW-1:0] di [0:PORTNUM-1],
								 
								 output [PORTNUM-1:0] PHasData_o,   //a output port has data to transmit
					// Configuration Port
		                  //output [WIDTH_CRD-1:0] crd_o [0:PORTNUM-1], // credit output back to each in line
		                   output reg [PORTNUM-1:0]	sop_ack_o,       //level
								 input [PORTNUM-1:0] sop_req_i,       //pulse 								
								 input [PORTNUM-1:0]	eop_i,		     //pulse	 		   				
								 input [AW-1:0] out_addr_i [0:PORTNUM],	//select output column 
							    //input [PORTNUM-1:0] ld_inaddr_i, ld_outaddr_i,
        //System interface
								 input reset, gclk
							  );

parameter True  = 1;
parameter False = 0;

// unsuported ports array declaration
input [BW-1:0] do [0:PORTNUM-1];
wire [BW-1:0] di [0:PORTNUM-1];

// Register to provide address when write(read) line(column).
// Each output port = 1 column
reg [AW-1:0] SelColumn [0:PORTNUM-1];       // for line cells selection//bit width ,depth
reg [AW-1:0] SelColine [0:PORTNUM-1];	     // for MUXes	 select lines in a column 
wire [PORTNUM-1:0] ld_SelColumn = sop_req_i;            
wire [PORTNUM-1:0] ld_SelColine;             // load select lines in a column

wire [AW1:0] ScheOut;  //output from the schedule.Determine which line in a column has priority 

							  //opposite line| each column
wire [BW-1:0] CellOut    [0:PORTNUM]    [0:PORTNUM];	 //16x16 *9 from cell fifo to MUXes	                      
wire [WCCNT-1:0] CellCnt [0:PORTNUM]    [0:PORTNUM];  //data num(vectors) in each switch cell     
// Cell Control Lines
reg [PORTNUM-1:0] wr_en  [0:PORTNUM-1];
reg [PORTNUM-1:0] rd_en  [0:PORTNUM-1];
wire [PORTNUM-1:0] clrCell[0:PORTNUM]; 
wire [PORTNUM-1:0] CellEmpty [0:PORTNUM];
wire [PORTNUM-1:0] CellFull  [0:PORTNUM];	
wire [PORTNUM-1:0] CellAfull  [0:PORTNUM];                    // buffer cell almost full 
wire [PORTNUM-1:0] CellAempty  [0:PORTNUM];						  // buffer cell almost empty

wire [PORTNUM-1:0] CellHasData [0:PORTNUM] = ~CellEmpty;      //? is the syntax right ?	
wire [PORTNUM-1:0] CellHasSpc  [0:PORTNUM] = ~CellFull;  


// signal for Matrix Output management
reg [PORTNUM-1:0] columnHasData;
wire [PORTNUM-1:0] ColumnOE = columnHasData;
assign PHasData_o           = columnHasData; //Port Has Data.Synchronous output to write Tx FIFO
  
// reg [WIDTH_CRD-1:0] crdcnt [0:PORTNUM-1];//credit counter
// assign crd_o = crdcnt;

/////////////////////////////////////
// Config input/output address REGs
//  
always @(posedge gclk)
begin
integer i=0;
if(reset)
     begin
     SelColumn <= 0;
     SelLine <= 0;
     end
else begin
     for (i=0; i<PORTNUM; i=i+1 )
       begin 
		 if( ld_SelColumn[i] == True )	    // ld_SelColumn = sop_req_i; Note taht the addr must be valid.
	      SelColumn[i] <= out_addr_i[i];	 //   Address Vector load
	    if( ld_SelColine[i] == True )	    // if the scheduler load output address.
	      SelColine[i] <= ScheOut [i];	    //   Address Vector load
	    end
     end
end

///////////////////////
// Matrix Cell buffers
//
// note: should select devices that have true dual port RAM	  

generate
begin:GEN_Cell
genvar i,k;
for (i=0; i<PORTNUM; i=i+1)       // i : each column
begin
   for (k=0; k<PORTNUM; k=k+1)	 // k : in a column(sel line)
	begin
	eth_fifo  #(parameter DATA_WIDTH=BW, DEPTH=CellDepth)	  // byte width=9, depth=? undetermined
	         Cell_Fifo_Array
	         (.data_in ( di[k] ),	       // different colum has same data input line
				 .data_out( CellOut[i][k] ),// k assign to 1 column,i assign to n columns.L<-R			 
				 .write   ( wr_en[i][k] ), 
				 .read    ( rd_en[i][k] ),
				 .clear   ( clrCell[i][k] ), 
				 .almost_full ( CellAfull[i][k] ), 
				 .full        ( CellFull[i][k] ), 
				 .almost_empty( CellAempty[i][k] ), 
				 .empty       ( CellEmpty[i][k] ), 
				 .gclk  ( gclk ), 
				 .reset( reset ),
				 .cnt( CellCnt[i][k] )      //may be usable
				 );
    end  //end 1 column (16x1 )
end	   //end 1 array  (16x16) 
end      //end GEN_Cell 



/////////////////////////////////////////
// Distribute lines data 
//     to the Matrix Cell	
reg [PORTNUM-1:0] wpen ;     // Write Packages Enable

//register sop_req_i or eop_i pulse
always @(posedge gclk)
begin
integer k;
if(reset==`reset)
  wpen <= 0;
else begin
     for(k=0; k<PORTNUM; k=k+1)
   	  begin
	      if(eop_i[k])
	  	     wpen[k] <= 1'b0;
         else if(sop_req_i[k])
		     wpen[k] <= 1'b1;
        end
	   end
end

reg [PORTNUM-1:0] wr__;		  // level signal

always @(*)
begin
 for (k =0; k <PORTNUM; k =k+1)
  wr__[k] =  ( wpen[k] ==False || eop_i[k])  ?   0   :
             ( ( wpen[k] ==True && eop_i[k] ==False )  ?   1'b1 : 'bx	    );       
end 			

//decode config addr according to the external controller
//(and the package addr head). Generate cell "we" signals array.
always @(*)
begin
integer i,k;
  for (i=0; i<PORTNUM; i=i+1)       // i : each column
  begin
    for (k=0; k<PORTNUM; k=k+1)	   // k : lines in a column(sel line)
	 begin
      wr_en[i][k] = ( wr__[i]                     // write to x column 
		                &&  SelColine[i] ==k    	  // select a line in a column
							 &&  CellHasSpc[i][k] ==True // that cell is not full
						   )					        
							   ?   1'b1  :  1'b0;
     sop_ack_o[i] = (SelColine[i] ==k    	        // "select a line" must has been configed
							 &&  CellHasSpc[i][k] ==True // that cell is not full
							)
							   ?   1'b1  :  1'b0;         
	 end
  end
end 


/////////////////////////
// Read enable to Tx Fifo
//
////////////////////
// Credit collecting credit information to The Input Line
// Output Schedulers	are responsible for selecting eligible 

always @ (*)
begin
integer m;
  for(m=0; m<PORTNUM; m=m+1)
  	columnHasData[m] = | celHasData[m];           
	// cellHasData[m][0] || cellHasData[m][1] || ...|| cellHasData[m][15] 	  					
end

//////////////////////////////
// 16 Output column Schedulers 
//
//////////////////////////////
// 1 scheduler is responsible to 32 cell in a column

generate
begin:GEN_Schedulers
 for (i=0; i<PORTNUM; i=i+1)       // i : each column
 begin
   for (k=0; k<PORTNUM; k=k+1)	  // k : in a column(sel line)
	begin
     CSer  #()  inst_CSer
	             ( .ld_SelCoLine_o( ld_SelColine ),
					   .empty_i(CellEmpty[i][k] ),      // one-hot input
						.Aempty_i(CellAfull[i][k]),		// one-hot
					   .addr_o( ScheOut[i] ),						
						.reset(reset)
						.gclk(gclk)						 
					  );
   end  // end lines in a column
 end    // end columns
end
endgenerate

////////////////////////////
//	16 outputs
// 
always @(*)
begin
integer n;
 for (n=0; n<PORTNUM; n=n+1) 
    begin
	 if(columOE)
	 do[n] = CellOut[SelLine][n];	  // n : (port0 -> port15)
	 else 
	 do[n] = 'b0;                   //       10'b p0_0000_0000  
    end									  // EOP = 10'b p1_0000_0000
end


/*///////////////
// Functions
//
function [15:0] greyiDEC4_16;  //Grey code input decoder
input [3:0] in;
begin
case (in)
	4'b0000 : greyiDEC4_16 = 16'h1;
	4'b0001 : greyiDEC4_16 = 16'h2;
	4'b0011 : greyiDEC4_16 = 16'h4;
	4'b0010 : greyiDEC4_16 = 16'h8;
	4'b0110 : greyiDEC4_16 = 16'h10;
	4'b0111 : greyiDEC4_16 = 16'h20;
	4'b0101 : greyiDEC4_16 = 16'h40;
	4'b0100 : greyiDEC4_16 = 16'h80;
	4'b1100 : greyiDEC4_16 = 16'h100;
	4'b1101 : greyiDEC4_16 = 16'h200;
	4'b1111 : greyiDEC4_16 = 16'h400;
	4'b1110 : greyiDEC4_16 = 16'h800;
	4'b1010 : greyiDEC4_16 = 16'h1000;
	4'b1011 : greyiDEC4_16 = 16'h2000;
	4'b1001 : greyiDEC4_16 = 16'h4000;
	4'b1000 : greyiDEC4_16 = 16'h8000;
	default : greyiDEC4_16 = 'bx;	
endcase
end
endfunction	*/

endmodule

`undef reset
