/* Because minimum latency is a key issue, the fifo empty flag is monitored and 
   data transferred whenever the buffer has data.
*/

module Cfg_Ctrl  #(parameter DW=32,AW=32)
(// configuration interface(CFG) for user to inspect
                	output[DW-1:0] cfg_data_o,
						output cfg_int_o,          // interrupt the user application
						output cfg_wrbusy_o,       //	configuration write in progress
						output[AW-1:0] cfg_int_addr, 
						input [AW-1:0] cfg_addr_i,
						//input [DW-1:0] cfg_data_i,      //reserved
						//input [] cfg_ben_i,             //configuration byte enable
						//input cfg_wren_i,               //reserved
						         
					 );



//N-Chars from one packet shall not be interleaved with N-Chars from another packet(but FCTs,NULL,TimeCodes).



//When EOP marker seen, router terminates connection and frees output port


//An EEP received by a routing switch shall be transferred through the routing switch in the same way as an EOP



//The first data character following either EOP or EEP shall be taken as the first character of the next packet


//An EOP or EEP received immediately after an EOP or EEP represents an empty packet



endmodule
