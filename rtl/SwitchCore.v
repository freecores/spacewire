//File name=Module=SwitchCore    2005-3-18      btltz@mail.china.com    btltz from CASIC  
//Description:   The SpaceWire Routing Switch core(routing matrix).
//               Can be used as a standalone module or connected to the CODEC Core to 
//               form a complete SpaceWire Routing Switch (Router).
//Origin:        SpaceWire Std - Draft-1(Clause 9/10) of ECSS(European Cooperation for Space Standardization),ESTEC,ESA.
//               SpaceWire Router Requirements Specification Issue 1 Rev 5. Astrium & University of Dundee 
//--     TODO:   make the rtl faster
////////////////////////////////////////////////////////////////////////////////////
//
/*synthesis translate off*/
`timescale 1ns/10ps
/*synthesis translate on */
`define reset  1	        // WISHBONE standard reset

module SwitchCore  //#(parameter DW=8,PortNUM=16,GPIO_NUM=2)
            ( //input data interface
                   output[PortNUM-1:0] full_o
                   input[DW-1:0] din [PortNUM-1:0] ,
                   input [PortNUM-1:0] wr_i,

             //output data interface 
                  output [DW-1:0] dout [PortNUM-1:0],
                  output [PortNum-1:0] empty_o,
                  input rd_i,
                  input active_i,
             //GPIO ports
                  inout [GPIO_NUM-1:0] GPIO;
             //global signal input 
               input reset, gclk	  // approximate 120Mhz, could also drive Xilinx gigabit transceiver.
               );
     
         //  parameter        ;


Cfg_Ctrl inst_CC (
                     );
SwitchMatrix inst_SwitchMatrix (
                                  );
Timer inst_Timer(
                    );

endmodule