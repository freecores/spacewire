//File name=Module name=SWR_vlogcore  2005-03-23      btltz@mail.china.com    btltz from CASIC  
//Description:   The SpaceWire Router top module. 
//Abbreviations:       
//Area:  
//Origin:    SpaceWire Std - Draft-1(Clause 9/10)of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//           SpaceWire Router Requirements Specification Issue 1 Rev 5. Astrium & University of Dundee 
//--     TODO:
////////////////////////////////////////////////////////////////////////////////////
//
//
/*synthesis translate off*/
`timescale 1ns/10ps
/*synthesis translate on */
//`include "defines.v"
`define reset  1
module SWR_vlogcore   //#(parameter DW=8,PortNUM=8,EXPortNUM=2)  //there should be sufficient ports
                ( 
                 output reg [3:0] gpio,
					  input reset, gclk
					  );
           
//////////////////
// Instantiations
SwitchCore  inst_RoutingMatrix ();
         //parameterized inst
generate
begin:IO_PORTS
 genvar i;
 for (i=0; i<=PortNUM; i=i+1)
 begin:inst
  SPW_CODEC  inst_Link_I_n();
 end
end
endgenerate  //end Link Interface  1 -> PortNUM



endmodule