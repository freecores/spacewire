//File name=Module name=COMI_HOCI   2005-3-18      btltz@mail.china.com      btltz from CASIC,China  
//Description:   SpaceWire WISHBONE interface for communication mem(COMI) and Host control(HOCI)    
//Origin:        WISHBONE Specification Revision B.3, SpaceWire Std - Draft-1 of ESTEC,ESA
//--     TODO:
////////////////////////////////////////////////////////////////////////////////////
//
/*synthesis translate off*/
`timescale 1ns/100ps
/*synthesis translate on */

module WB_COMI_HOCI #(parameter CM_AW=16,CM_DW=32,H_DW=32,H_AW=8,BUF_DW=8)
                 ( // COMI interface(WISHBONE MASTER interface)to a "communication memory",a dpRAM
					    output  [CM_DW-1:0] CM_DAT_o, //because some FPGA and ASIC devices do not support bi-directional signals so have not use "inout" 
                   input  [CM_DW-1:0] CM_DAT_i, 
						 output CM_SEL0_o,
						 output CM_SEL1_o,							
						 output CM_WE_o,
						 output CM_STB_o,				
						 output [CM_AW-1:0] CM_ADR_o,	 					
						 input CM_ACK_i,		//note that memory circuit does not have a reset input.				 						 
						 // HOCI interface(WISHBONE SLAVE interface) to host such as a uP
						 output [H_DW-1:0] H_DAT_o, 					
						 input [H_DW-1:0] H_DAT_i,
						 input H_WE_i,		
						 input H_SEL_i,								
						 input H_STB_i, 
						 output H_ACK_o, 							
						 input H_CYC_i,  						 
						 input [H_AW-1:0] H_ADR_i,

						 output H_INT_o, //TAG. interrupt request line

// interface to 3 channels( CODEC + Glue Logic ) 
                   output wr_txbuf_o,
						 output [BUF_DW-1:0] txbuf_data_o,
						 input txbuf_full_i,

						 output rd_rxbuf_o,
						 input [BUF_DW-1:0] rxbuf_data_i,
						 input rxbuf_empty_i,
// global input signals
                   input RST_i, CLK_i
						 );

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//WISHBONE memory interface form "COMI"( COmmunication Memory Interface ).
//The mem may be a dpMEM which could be considered as "FASM":FPGA and ASIC Subset Model(asynchronous read).
//



//COMI autonomous accesses to the communication memory or	read data to be transmitted 



endmodule