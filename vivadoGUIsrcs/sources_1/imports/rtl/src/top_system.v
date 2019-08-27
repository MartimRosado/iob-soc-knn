
`timescale 1ns / 1ps

`include "system.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2019 03:48:19 PM
// Design Name: 
// Module Name: top_system_test_Icarus
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top Environment to test AXI - MEM - interface, to later be used for DDR4
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_system(
	          input 	   C0_SYS_CLK_clk_p, C0_SYS_CLK_clk_n, 
	          //input      clk,
	          input 	   reset,
	          output reg [6:0] led,
	          output 	   ser_tx,
	          input 	   ser_rx,
`ifdef DDR
	          //   ///////////////////////////////////////////////////////////            
		  //   ////////////// MIG - DDR4 inputs and outputs //////////////
		  //   ///////////////////////////////////////////////////////////
                  input 	   sys_rst, 
                  output 	   c0_ddr4_act_n,
                  output [16:0]    c0_ddr4_adr,
                  output [1:0] 	   c0_ddr4_ba,
                  output [0:0] 	   c0_ddr4_bg,
                  output [0:0] 	   c0_ddr4_cke,
                  output [0:0] 	   c0_ddr4_odt,
                  output [0:0] 	   c0_ddr4_cs_n,
                  output [0:0] 	   c0_ddr4_ck_t,
                  output [0:0] 	   c0_ddr4_ck_c,
                  output 	   c0_ddr4_reset_n,
                  inout [3:0] 	   c0_ddr4_dm_dbi_n,
                  inout [31:0] 	   c0_ddr4_dq,
                  inout [3:0] 	   c0_ddr4_dqs_c,
                  inout [3:0] 	   c0_ddr4_dqs_t, 
`endif                  
		  output 	   trap

		  );

   // parameter MAIN_MEM_ADDR_W = 14; // 14 = 32 bits (4) * 2**12 (4096) depth


   parameter DDR_ADDR_W = 20;
   
   
   ////////////single ended clock
  
   wire 			   clk;
   wire                sysclk;
   /*       wire 		  clk_ibufg;
    
    IBUFGDS ibufg_inst (.I(C0_SYS_CLK_clk_p), .IB(C0_SYS_CLK_clk_n), .O(clk_ibufg));
    BUFG bufg_inst     (.I(clk_ibufg), .O(clk));
    */
`ifndef DDR
 `ifdef CLK_200MHZ
   clk_wiz_200 clk_250_to_200_MHz(
				  .clk_in1_p(C0_SYS_CLK_clk_p),
				  .clk_in1_n(C0_SYS_CLK_clk_n),
				  .clk_out1(clk)
				  );
 `else
   clk_wiz_100 clk_250_to_100_MHz(
				  .clk_in1_p(C0_SYS_CLK_clk_p),
				  .clk_in1_n(C0_SYS_CLK_clk_n),
				  .clk_out1(clk)
				  );
 `endif                
`endif    
   
   wire 			   wire_axi_awvalid;
   wire 			   wire_axi_awready;
   wire [31:0] 			   wire_axi_awaddr;
   wire [ 2:0] 			   wire_axi_awprot;
   
   wire 			   wire_axi_wvalid;
   wire 			   wire_axi_wready;
   wire [31:0] 			   wire_axi_wdata;
   wire [ 3:0] 			   wire_axi_wstrb;
   
   wire 			   wire_axi_bvalid;
   wire 			   wire_axi_bready;
   
   wire 			   wire_axi_arvalid;
   wire 			   wire_axi_arready;
   wire [31:0] 			   wire_axi_araddr;
   wire [ 2:0] 			   wire_axi_arprot;
   
   wire 			   wire_axi_rvalid;
   wire 			   wire_axi_rready;
   wire [31:0] 			   wire_axi_rdata;
   
   // AXI-full extra wires
   wire 			   wire_axi_rlast;
   wire [1:0] 			   wire_axi_bresp;
   wire [7:0] 			   wire_axi_arlen;
   wire [2:0] 			   wire_axi_arsize;
   wire [1:0] 			   wire_axi_arburst;
   wire [7:0] 			   wire_axi_awlen;
   wire [2:0] 			   wire_axi_awsize;
   wire [1:0] 			   wire_axi_awburst;

   ////////////////////////////
   wire [31:0] 			   wire_addr;
   wire [31:0] 			   wire_wdata; 
   wire [3:0] 			   wire_wstrb;
   wire [31:0] 			   wire_rdata;
   wire 			   wire_valid;
   wire 			   wire_ready;

   wire [1:0] 			   slave_select;
   wire 			   mem_sel;
   wire 			   init_calib_complete;
   reg [6:0] 			   led_reg;
   wire 			   wire_resetn_int;
   
   
  wire [0:0]wire_ddr_awid;
  wire [31:0] wire_ddr_awaddr;
  wire [7:0] wire_ddr_awlen;
  wire [2:0]wire_ddr_awsize;
  wire [1:0]wire_ddr_awburst;
  wire wire_ddr_awlock;
  wire [3:0]wire_ddr_awcache;
  wire [2:0]wire_ddr_awprot;
  wire [3:0]wire_ddr_awqos;
  wire wire_ddr_awvalid;
  wire wire_ddr_awready;
  wire [31:0]wire_ddr_wdata;
  wire [3:0]wire_ddr_wstrb;
  wire wire_ddr_wlast;
  wire wire_ddr_wvalid;
  wire wire_ddr_wready;
  wire [0:0]wire_ddr_bid;
  wire [1:0]wire_ddr_bresp;
  wire wire_ddr_bvalid;
  wire wire_ddr_bready;
  wire [0:0]wire_ddr_arid;
  wire [31:0]wire_ddr_araddr;
  wire [7:0]wire_ddr_arlen;
  wire [2:0]wire_ddr_arsize;
  wire [1:0]wire_ddr_arburst;
  wire wire_ddr_arlock;
  wire [3:0]wire_ddr_arcache;
  wire [2:0]wire_ddr_arprot;
  wire [3:0]wire_ddr_arqos;
  wire wire_ddr_arvalid;
  wire wire_ddr_arready;
  wire [0:0]wire_ddr_rid;
  wire [31:0]wire_ddr_rdata;
  wire [1:0]wire_ddr_rresp;
  wire wire_ddr_rlast;
  wire wire_ddr_rvalid;
  wire wire_ddr_rready;
   
   // LEDs will put WNS negative, but it will still work (since delays on LEDs have no influence in the overall system, only for debug
   /*  
    always @(posedge clk) begin 
    led_reg[0] <= (wire_resetn_int); 
    led_reg[6] <= slave_select[1];
    led_reg[5] <= slave_select[0];
    led_reg[2] <= mem_sel;
    `ifdef DDR
    led_reg[1] <= init_calib_complete;
    `endif
    led [6:0] <= led_reg [6:0];
    end    
    */
   
   system system (
        	  .clk        (sysclk       ),
        	  //.cache_clk (cache_clk),
`ifdef DDR
		  .reset (reset || ~(init_calib_complete)),
`else
		  .reset      (reset   ),
`endif
		  .ser_tx     (ser_tx    ),
		  .ser_rx     (ser_rx),
		  .trap       (trap     ),
		  .sys_mem_sel (mem_sel),
		  .s_sel      (slave_select),
		  //// Address-Write
		  .resetn_int_sys    (wire_resetn_int),
		  .sys_s_axi_awvalid (wire_axi_awvalid),
		  .sys_s_axi_awready (wire_axi_awready),
		  .sys_s_axi_awaddr  (wire_axi_awaddr ),
		  //// Data-Write  
		  .sys_s_axi_wvalid  (wire_axi_wvalid ),
		  .sys_s_axi_wready  (wire_axi_wready ),
		  .sys_s_axi_wdata   (wire_axi_wdata  ),
		  .sys_s_axi_wstrb   (wire_axi_wstrb  ),
		  //// Response    
		  .sys_s_axi_bvalid  (wire_axi_bvalid ),
		  .sys_s_axi_bready  (wire_axi_bready ),
		  //// Address-Read
		  .sys_s_axi_arvalid (wire_axi_arvalid),
		  .sys_s_axi_arready (wire_axi_arready),
		  .sys_s_axi_araddr  (wire_axi_araddr ),
		  .sys_s_axi_arlen   (wire_axi_arlen),
		  .sys_s_axi_arburst (wire_axi_arburst),
		  .sys_s_axi_arsize  (wire_axi_arsize),
		  //// Data-Read   
		  .sys_s_axi_rvalid  (wire_axi_rvalid ),
		  .sys_s_axi_rready  (wire_axi_rready ),
		  .sys_s_axi_rdata   (wire_axi_rdata  ),
		  .sys_s_axi_rlast   (wire_axi_rlast)
		  ///////// AXI_Full signals
		  //// Read         
		  //                   .sys_s_axi_arlen   (8'd0              ), 
		  //                   .sys_s_axi_arsize  (3'b010            ),     
		  //                   .sys_s_axi_arburst (2'b00             ),
		  //                   .sys_s_axi_rlast   (wire_axi_rlast  ),
		  //// Write        
		  //                   .sys_s_axi_awlen   (8'd0              ),
		  //                   .sys_s_axi_awsize  (3'b010            ),
		  //                   .sys_s_axi_awburst (2'b00             ),
		  //                   .sys_s_axi_wlast   (|wire_axi_wstrb ),
		  //                   .sys_s_axi_bresp   (wire_axi_bresp  )
		  
		  );

   

   /////////////////////////////////////////////////////////
     /////// Open source RAM with AXI memory instance ///////
     ///////////////////////////////////////////////////////
     
   //        ddr_memory  #(.ADDR_W(DDR_ADDR_W) ) ddr_memory (
   //                    .clk                (clk                        ),
   //                    .main_mem_write_data(wire_wdata                 ),
   //                    .main_mem_addr      (wire_addr[DDR_ADDR_W-1:2]),
   //                    .main_mem_en        (wire_wstrb                 ),
   //                    .main_mem_read_data (wire_rdata                 )                            
   //                        );

   //   reg 	   ddr_mem_ready, ddr_mem_ready_2, ddr_mem_ready_1, ddr_mem_ready_0;
   //   assign wire_ready = ddr_mem_ready;
   
   //   always @(posedge clk) begin
   //      ddr_mem_ready <= wire_valid;    
   //   end   
   
   // //  always @(posedge clk) begin
   // //     ddr_mem_ready_0 <= wire_valid; 
   // //     ddr_mem_ready_1 <= ddr_mem_ready_0;
   // //     ddr_mem_ready_2 <= ddr_mem_ready_1;
   // //     ddr_mem_ready   <= ddr_mem_ready_2;
   // //  end         
   ////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////  

`ifdef DDR

   ddr4_0 ddr4_ram (
                    .c0_sys_clk_p        (C0_SYS_CLK_clk_p),
                    .c0_sys_clk_n        (C0_SYS_CLK_clk_n),
                    .c0_ddr4_ui_clk          (clk), 
		             //        .c0_sys_clk_i          (clk),
                     .addn_ui_clkout1     (sysclk             ), // 250MHz
                    //   .addn_ui_clkout2     (   clk             ), // 100MHz
                    //.addn_ui_clkout3     (               ), // 25MHz
                    //.addn_ui_clkout4     (                ), // 10MHz
                    .c0_init_calib_complete (init_calib_complete),                  
                    .c0_ddr4_aresetn       (wire_resetn_int ),
     		        .c0_ddr4_s_axi_awvalid (wire_ddr_awvalid),
		    .c0_ddr4_s_axi_awready (wire_ddr_awready),
		    .c0_ddr4_s_axi_awaddr  (wire_ddr_awaddr[29:0]),
		    .c0_ddr4_s_axi_awcache (4'b0011), //recommended value
		    //// Data-Write  
		    .c0_ddr4_s_axi_wvalid  (wire_ddr_wvalid ),
		    .c0_ddr4_s_axi_wready  (wire_ddr_wready ),
		    .c0_ddr4_s_axi_wdata   (wire_ddr_wdata  ),
		    .c0_ddr4_s_axi_wstrb   (wire_ddr_wstrb  ),
		    //// Response   
		    .c0_ddr4_s_axi_bvalid  (wire_ddr_bvalid ),
		    .c0_ddr4_s_axi_bready  (wire_ddr_bready ),
		    //// Address-Read
		    .c0_ddr4_s_axi_arvalid (wire_ddr_arvalid),
		    .c0_ddr4_s_axi_arready (wire_ddr_arready),
		    .c0_ddr4_s_axi_araddr  (wire_ddr_araddr[29:0]),
		    .c0_ddr4_s_axi_arcache (4'b0011), //recommended value
		    //// Data-Read   
		    .c0_ddr4_s_axi_rvalid  (wire_ddr_rvalid ),
		    .c0_ddr4_s_axi_rready  (wire_ddr_rready ),
		    .c0_ddr4_s_axi_rdata   (wire_ddr_rdata  ),
		    ///////// AXI_Full signals
		    //// Read         
		    .c0_ddr4_s_axi_arlen   (wire_ddr_arlen  ), 
		    .c0_ddr4_s_axi_arsize  (wire_ddr_arsize ),    
                    .c0_ddr4_s_axi_arburst (wire_ddr_arburst),
                    .c0_ddr4_s_axi_rlast   (wire_ddr_rlast  ),
                    // Write        
                    .c0_ddr4_s_axi_awlen   (8'd0            ),
                    .c0_ddr4_s_axi_awsize  (3'b010          ),
                    .c0_ddr4_s_axi_awburst (2'b00           ),
                    .c0_ddr4_s_axi_wlast   (|wire_ddr_wstrb ),
                    .c0_ddr4_s_axi_bresp   (wire_ddr_bresp  ),
                    //unused 
                    .c0_ddr4_s_axi_awlock                (1'b0),
                    .c0_ddr4_s_axi_awqos                 (4'b0),
                    .c0_ddr4_s_axi_arlock                (1'b0),
                    .c0_ddr4_s_axi_arprot                (3'b0),
                    .c0_ddr4_s_axi_arqos                 (4'b0),
                    // Constraints of the DDR4 
                    .sys_rst             (sys_rst),
                    .c0_ddr4_act_n       (c0_ddr4_act_n),
                    .c0_ddr4_adr         (c0_ddr4_adr),
                    .c0_ddr4_ba          (c0_ddr4_ba),
                    .c0_ddr4_bg          (c0_ddr4_bg),
                    .c0_ddr4_cke         (c0_ddr4_cke),
                    .c0_ddr4_odt         (c0_ddr4_odt),
                    .c0_ddr4_cs_n        (c0_ddr4_cs_n),
                    .c0_ddr4_ck_t        (c0_ddr4_ck_t),
                    .c0_ddr4_ck_c        (c0_ddr4_ck_c),
                    .c0_ddr4_reset_n     (c0_ddr4_reset_n),
                    .c0_ddr4_dm_dbi_n    (c0_ddr4_dm_dbi_n),
                    .c0_ddr4_dq          (c0_ddr4_dq),
                    .c0_ddr4_dqs_c       (c0_ddr4_dqs_c),
                    .c0_ddr4_dqs_t       (c0_ddr4_dqs_t)
                    );   
   
 `ifdef DDR_INTERCONNECT
    axi_interconnect_0 cache2ddr (
        .INTERCONNECT_ACLK(clk),
        .INTERCONNECT_ARESETN(~reset && init_calib_complete),
        .M00_AXI_ARESET_OUT_N(),
        .M00_AXI_ACLK(clk),
        .M00_AXI_AWID(0),
        .M00_AXI_AWADDR(wire_ddr_awaddr),
        .M00_AXI_AWLEN(wire_ddr_awlen),
        .M00_AXI_AWSIZE(wire_ddr_awsize),
        .M00_AXI_AWBURST(wire_ddr_awburst),
        .M00_AXI_AWLOCK(wire_ddr_awlock),
        .M00_AXI_AWCACHE(wire_ddr_awcache),
        .M00_AXI_AWPROT(wire_ddr_awprot),
        .M00_AXI_AWQOS(wire_ddr_awqos),
        .M00_AXI_AWVALID(wire_ddr_awvalid),
        .M00_AXI_AWREADY(wire_ddr_awready),
        .M00_AXI_WDATA(wire_ddr_wdata),
        .M00_AXI_WSTRB(wire_ddr_wstrb),
        .M00_AXI_WLAST(wire_ddr_wlast),
        .M00_AXI_WVALID(wire_ddr_wvalid),
        .M00_AXI_WREADY(wire_ddr_wready),
        .M00_AXI_BID(),
        .M00_AXI_BRESP(wire_ddr_bresp),
        .M00_AXI_BVALID(wire_ddr_bvalid),
        .M00_AXI_BREADY(wire_ddr_bready),
        .M00_AXI_ARID(),
        .M00_AXI_ARADDR(wire_ddr_araddr),
        .M00_AXI_ARLEN(wire_ddr_arlen),
        .M00_AXI_ARSIZE(wire_ddr_arsize),
        .M00_AXI_ARBURST(wire_ddr_arburst),
        .M00_AXI_ARLOCK(wire_ddr_arlock),
        .M00_AXI_ARCACHE(wire_ddr_arcache),
        .M00_AXI_ARPROT(wire_ddr_arprot),
        .M00_AXI_ARQOS(wire_ddr_arqos),
        .M00_AXI_ARVALID(wire_ddr_arvalid),
        .M00_AXI_ARREADY(wire_ddr_arready),
        .M00_AXI_RID(),
        .M00_AXI_RDATA(wire_ddr_rdata),
        .M00_AXI_RRESP(wire_ddr_rresp),
        .M00_AXI_RLAST(wire_ddr_rlast),
        .M00_AXI_RVALID(wire_ddr_rvalid),
        .M00_AXI_RREADY(wire_ddr_rready),
        .S00_AXI_ARESET_OUT_N(),
        .S00_AXI_ACLK(sysclk),
        .S00_AXI_AWID(),
        .S00_AXI_AWADDR(wire_axi_awaddr[29:0]),
        .S00_AXI_AWLEN(8'd0),
        .S00_AXI_AWSIZE(3'b010),
        .S00_AXI_AWBURST(2'b00),
        .S00_AXI_AWLOCK(1'b0),
        .S00_AXI_AWCACHE(4'b0011),
        .S00_AXI_AWPROT(),
        .S00_AXI_AWQOS(),
        .S00_AXI_AWVALID(wire_axi_awvalid),
        .S00_AXI_AWREADY(wire_axi_awready),
        .S00_AXI_WDATA(wire_axi_wdata),
        .S00_AXI_WSTRB(wire_axi_wstrb),
        .S00_AXI_WLAST(|wire_axi_wstrb),
        .S00_AXI_WVALID(wire_axi_wvalid),
        .S00_AXI_WREADY(wire_axi_wready),
        .S00_AXI_BID(),
        .S00_AXI_BRESP(wire_axi_bresp),
        .S00_AXI_BVALID(wire_axi_bvalid),
        .S00_AXI_BREADY(wire_axi_bready),
        .S00_AXI_ARID(),
        .S00_AXI_ARADDR(wire_axi_araddr),
        .S00_AXI_ARLEN(wire_axi_arlen),
        .S00_AXI_ARSIZE(wire_axi_arsize),
        .S00_AXI_ARBURST(wire_axi_arburst),
        .S00_AXI_ARLOCK(1'b0),
        .S00_AXI_ARCACHE(4'b0011),
        .S00_AXI_ARPROT(3'b0),
        .S00_AXI_ARQOS(4'b0),
        .S00_AXI_ARVALID(wire_axi_arvalid),
        .S00_AXI_ARREADY(wire_axi_arready),
        .S00_AXI_RID(),
        .S00_AXI_RDATA(wire_axi_rdata),
        .S00_AXI_RRESP(),
        .S00_AXI_RLAST(wire_axi_rlast),
        .S00_AXI_RVALID(wire_axi_rvalid),
        .S00_AXI_RREADY(wire_axi_rready)
        );
 `endif //DDR_INTERCONNECT


`else
   
   bram_axi axi_bram (
		      //AXI Global Signals
		      .s_aclk (clk),
		      .s_aresetn (~reset),
		      //AXI                        Full/lite slave write (write side)
		      .s_axi_awid(),
		      .s_axi_awaddr(wire_axi_awaddr),
		      .s_axi_awlen(8'd0),
		      .s_axi_awsize(3'b010),
		      .s_axi_awburst(2'b00),
		      .s_axi_awvalid(wire_axi_awvalid),
		      .s_axi_awready(wire_axi_awready),
		      .s_axi_wdata(wire_axi_wdata),
		      .s_axi_wstrb(wire_axi_wstrb),
		      .s_axi_wlast(|wire_axi_wstrb),
		      .s_axi_wvalid(wire_axi_wvalid),
		      .s_axi_wready(wire_axi_wready),
		      .s_axi_bid(),
		      .s_axi_bresp(),
		      .s_axi_bvalid(wire_axi_bvalid),
		      .s_axi_bready(wire_axi_bready),
		      //AXI                        Full/lite slave read (write side)
		      .s_axi_arid(),
		      .s_axi_araddr(wire_axi_araddr),
		      .s_axi_arlen(wire_axi_arlen),
		      .s_axi_arsize(wire_axi_arsize),
		      .s_axi_arburst(wire_axi_arburst),
		      .s_axi_arvalid(wire_axi_arvalid),
		      .s_axi_arready(wire_axi_arready),
		      .s_axi_rid(),
		      .s_axi_rdata(wire_axi_rdata),
		      .s_axi_rresp(),
		      .s_axi_rlast(wire_axi_rlast),
		      .s_axi_rvalid(wire_axi_rvalid),
		      .s_axi_rready(wire_axi_rready)
		      );

   
`endif
                                        
endmodule