SpaceWire (SpW) for What?
     "Spw grown organically from the needs of on-board processing applications.
      (SpW is a network with Routers)
      This Standard addresses the handling of payload data and control information on
board a spacecraft. It is a standard for a high speed data link, which is intended
to meet the needs of future, high capability, remote sensing instruments and
other space missions...
      Processing units, mass-memory units and down-link telemetry systems devel-
oped for one mission can be readily used on another mission, reducing the cost of
development, improving reliability and most importantly increasing the amount
of scientific work that can be achieved within a limited budget.
      (SpW is currently being installed on several NASA and European Space Agency (ESA) 
       spaceships to support onboard communications during space missions.---27 January 2003)
      SpaceWire has taken into consideration two existing standards, IEEE 1355-1995
and ANSI/TIA/EIA-644.
      "Point-to-point serial links with LVDS. The maximum data signalling rate that can be 
achieved is different from one system to another, depending on several factors such as:
1)cable length, 2)driver-receiver technology, and 3)encoder-decoder design, and is limited by 4)skew and jitter."






Diff & Relation  with IEE1355 device(eg. Atmel.Inc "TSS901E" which also called "SMCS332")
"The SMCS devices implement revision A of the standard, which is based on IEEE1355. They do not implement 
the current version of SpaceWire. However, the current version of SpaceWire is backwards compatible with the earlier revision."

//////////////////////////////////////////////////////////////////////////////////////





This Core?
  - CODEC
    -  A pure synchronous design(so it can works well in fpga) written in verilog, completely open.
    -  Annother high speed CODEC use PLL and clock recovery/lock circuit.
  -SWR
    -  ...Synchronously Clocked Crosspoint...(Switch Latency...)
    -  ... buffered crossbar...distributed scheduling(effective and simple). 16x16 now may be enough.

  *  Due to the SpaceWire protocol,the file/module "SPW_CODEC.v" could be used as a core's top module (as a "channel")
       to be integrated with a "routing matrix" to form a router which is a Routing Switch in the SpaceWire network.
     Sometimes the CODEC is also called a "interface" or "input/output ports" of the router or a node device.
     See the scheme.
  *  The file/module "SPW_I_vlogcore.v" is 3 CODEC with glue logic and Wishbone interface(COMI/HOCI) could be used as top module(a interface of the host to the SpW network) and be integrated into node devices.
      ("SpaceWire nodes are the sources and destinations of packets in a SpaceWire network.").
  *  The file/module "SWR_vlogcore.v" is a top module of Spacewire Router which integrates some interfaces and a 
     Routing Matrix "SwitchCore.v" and a little other logic. This core is so rough now. 
  *  Had use some ip on the opencores.org such as a fifo(i have consulted the     "plesiochronous_fifo.v" for the 
     Receiver. For the transmitter which only need a synchronous fifo for internal usage,so i write a synfifo which was similar to Xilinx ip for less complexity.) and a CRC. 
  *  Note the LVDS driver and receiver is not contain in modules. 
  *  Triple Modulo Redundant (TMR).








A little specs:
-INTERFACE
   - The block "Timer" in the scheme of the draft-1 is merged into the "SPW_FSM".

   -[Clock]
     -Clock : Synchronous method   
       - The block "Receiver's clock recovery" in the scheme of the draft-1 is merged into the          "Receiver".
       - The block "Transmitter clock generator" in the scheme of the draft-1 is merged into the          "Transmitter". 
     -Clock : High speed method
       -The wide -> narrow process unit could be found in Transmitter and PPU.
       -

   - The credit count keeped in "crd_cnt" which indicates the buffer space of the opposite Rx      bufer is in the transmitter; at the same time the outstanding count keeped in "osd_cnt"      which indicates the buffer data of the opposite Tx is in the receiver. 
   - Notice that according to the custom of circuit operation,some name near the interface      between the Tx/Rx and the fifo may be a little different from the standard      document.(eg."TX_READY, TX_WRITE" may only present as a output pulse signal "rdbuf_o" to      just read that mem.
   - Note that the Receiver do not generate local EEP to the host. It receive remote EEP, and if      a error occurs when PPU is in Run state, a Link error output then will be asserted by the      PPU.      Then the EEP may be written to the transmitter by the host(the user's application software).
   - "crc32_lib.v" on OC has been tailored to fit this pjt. It is optional.
   - Not like the Atmel's "TSS901E"(or called "SMCS332"),this ip core dosen't use a
     "clk10" but only a global clock "gclk".The "clk10" is not indispensable according 
     to the SpaceWire standard and this may also be convenient. 
     Note that not like TSS901E,the node channels doesn't support wormhole routing.
     All routing function is performed by Routers.   






-ROUTER
   - bufferd switch
   - ... minimum switching latency and lowest propagation delay ...
   -  ... ...
   -  ...operate directly on variable-size packets,...no packet 
     segmentation and no scheduler(distributed scheduling decisions)
   - "sop_ack_o" is a sychrnous acknowledge signal indicate that the cell which a package want to      be loaded has space to load. If it's true, after 1 clock, the controller will load data to      that cell. 
   

*********************************************************
- +Conformity Limitations:
  |-- Link Interfaces --+
  |                     |-
  +-- Router --+
               |-



TODO:   the "Router" and various interface to other bus.
*************************************************************

/////////////////////////////////////////////////////////////////////////////////







Some interesting topics:
1)Open or close?
In the "SpaceWire Router Requirements Specification(Issue:1 Rev: 5 Date:28.02.2003)" clause 4.1 has some words about 
this question:
"Open VHDL Core
The SpaceWire input/output ports shall be implemented with the Open VHDL core developed in the ESM006 contract for ESA [AD2].
Rationale: It will minimise design effort and help to validate the VHDL core."
It did not refer to open the Router's IP,besides i have not found free "IO ports" core available on internet.

2)Active things:(observe at 03-26-2005)
  If someone has deep interest,you could pay attention to a conference "DASIA(DAta Systems In Aerospace) 2005" in 
  Sheraton Grand Hotel, Edinburgh, Scotland during 30th May and 2nd June 2005.

    Tuesday 31st May 2005(SESSION 4B ON BOARD BUSES AND COMMUNICATION)
    [Chairperson: P. Plancke, ESA/ESTEC, The Netherlands]
    09:00 Quality from SpaceWire and Quality into SpaceWire Systems B.M. Cook, P.H. Walker - 4Links, UK
    09:30 SpaceWire Remote Memory Access Protocol S. Parkes, C. McClements - University of Dundee, UK
    10:00 SpaceWire Internet Tunnel S. Mills, S. Parkes - University of Dundee, UK









//////////////////////////////////////////////////////////////////////////////
Annex  A:

Industry info and some Web site could be accessed for a further reference::

1) "SpaceWire UK are specialist providers of VHDL Intellectual Property & Design Services for the Space Industry".
    The SpaceWire UK has developed a CODEC and SpaceWire Switch Core (Router)  in VHDL for business. (I am sure i 
    don't want to disturb this new ip vendor and I also had consulted their ip schemes.My try is just a hobby and
    have a heart to contribute to promoting the SpW standard.)
               www.spacewire.co.uk

2) The EADS Astrium GmbH (formed in May 2000 by the merger of Matra Marconi Space (France/UK) and the space division 
  of DaimlerChrysler Aerospace (Germany)) is well known as the author of the "Router requirements spec" 
  (Steve Parkes, University of Dundee).
   " ETD-031 'SpaceWire Router Development, Coordination and Validation' was Kicked-Off with Astrium the 2nd
     January 2002. " And the issue 1 rev 5 had been published on 28.02.2003.
     They described a router ASIC with internal configuration port,external pins for status/error monitoring
     (with status/error registers and control registers) in Feb,2004.It had been implemented in an Atmel MH1RT 
      gate array.
               www.astrium.eads.net

3) Austrian Aerospace (AAE) has a switch ASIC, the Dynamic Switch Matrix (DSM), built in Atmel.
   " ESM-006 'SpaceWire Router ASIC development' is an ETD-031 sub-contract with Austrian Aerospace concerning 
     the SpaceWire CODEC VHDL, router FPGA and router ASIC. "
               www.space.at

4) 4links derives from University of Dundee is a company that specializes in SpaceWire / IEEE1355 &Ethernet.
   They have some products such as EtherSpaceLink, SpaceWire-cPCI,SpaceWire-PCI,SpaceWire-Cables,and    
   IPs which are relative to these products.    They use Xilinx fpga implement routers with a performance
   well above 200 Mbit/s. 
               www.4links.co.uk/index.htm

5) Webs of Chinese laboratory  of avionics(for space use) say they are developing a SpW network system.
               www.spacee.net

6) Atmel offer SMCS332,SMCS Lite,and said their "potential future Standard ASICs & IPs include:SMCS Lite,    
  SpaceWire Router(2004),SpaceWire Rx/Tx" in 2002. 
               www.atmel.com
   
7) STAR-Dundee Ltd is a spin-out company of the University of Dundee set up specifically to support users 
     of SpaceWire(fund from the Scottish Executive). Dr Steve Parkes was the Managing Director of STAR-Dundee,
     also the author of the SpaceWire standard document. "STAR-Dundee Ltd aims to fill the emerging market
     niche for research and development, debug and support tools for SpaceWire."

Dr Steve Parkes: sparkes@computing.dundee.ac.uk
Press Officer: j.m.marra@dundee.ac.uk

               www.dundee.ac.uk

8) Institute of Microelectronics, Micromechanics and Microoptics
Hochschule Bremen ,University of Applied Sciences,Germany
Spacewire interface (IP-Core)  
      http://www.i3m.hs-bremen.de/internet/structure/elis/

9)  :->  Ask Google for more and fresh news. 





