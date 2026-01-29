`timescale 1ns/1ps

import axi_vip_pkg::*;
import axi_vip_0_pkg::*;

module tb;
  // clock & reset
  logic ACLK;
  logic ARESETn;

  initial begin
    ACLK = 0;
    forever #5 ACLK = ~ACLK;   // 100 MHz
  end

  initial begin
    ARESETn = 0;
    repeat (20) @(posedge ACLK);
    ARESETn = 1;
  end

  // AXI signals
  logic [31:0] AWADDR;
  logic        AWVALID;
  logic        AWREADY;
  logic [2:0]  AWPROT;
  logic [3:0]  AWID;
  logic [7:0]  AWLEN;
  logic [2:0]  AWSIZE;
  logic [1:0]  AWBURST;
  logic [3:0]  AWCACHE;
  logic        AWLOCK;
  logic [3:0]  AWQOS;
  logic [3:0]  AWREGION;

  logic [31:0] WDATA;
  logic [3:0]  WSTRB;
  logic        WVALID;
  logic        WREADY;
  logic        WLAST;

  logic [1:0]  BRESP;
  logic        BVALID;
  logic        BREADY;
  logic        BID;

  logic [31:0] ARADDR;
  logic        ARVALID;
  logic        ARREADY;
  logic [2:0]  ARPROT;
  logic [3:0]  ARID;
  logic [7:0]  ARLEN;
  logic [2:0]  ARSIZE;
  logic [1:0]  ARBURST;  
  logic [3:0]  ARCACHE;
  logic        ARLOCK;
  logic [3:0]  ARQOS;
  logic [3:0]  ARREGION;

  logic [31:0] RDATA;
  logic [1:0]  RRESP;
  logic        RVALID;
  logic        RREADY;
  logic [3:0]  RID;
  logic        RLAST;

  // DUT: your AXI master
  master dut (
    .ACLK        (ACLK),
    .ARESETn     (ARESETn),

    .M_AXI_AWADDR (AWADDR),
    .M_AXI_AWVALID(AWVALID),
    .M_AXI_AWREADY(AWREADY),
    .M_AXI_AWPROT (AWPROT),
    .M_AXI_AWID (AWID),
    .M_AXI_AWLEN (AWLEN),
    .M_AXI_AWSIZE (AWSIZE),
    .M_AXI_AWBURST (AWBURST),
    .M_AXI_AWCACHE (AWCACHE),
    .M_AXI_AWLOCK (AWLOCK),
    .M_AXI_AWQOS (AWQOS),
    .M_AXI_AWREGION (AWREGION),

    .M_AXI_WDATA  (WDATA),
    .M_AXI_WSTRB  (WSTRB),
    .M_AXI_WVALID (WVALID),
    .M_AXI_WREADY (WREADY),
    .M_AXI_WLAST (WLAST),

    .M_AXI_BRESP  (BRESP),
    .M_AXI_BVALID (BVALID),
    .M_AXI_BREADY (BREADY),
    .M_AXI_BID (BID),

    .M_AXI_ARADDR (ARADDR),
    .M_AXI_ARVALID(ARVALID),
    .M_AXI_ARREADY(ARREADY),
    .M_AXI_ARPROT (ARPROT),
    .M_AXI_ARID (ARID),
    .M_AXI_ARLEN (ARLEN),
    .M_AXI_ARSIZE (ARSIZE),
    .M_AXI_ARBURST (ARBURST),
    .M_AXI_ARCACHE (ARCACHE),
    .M_AXI_ARLOCK (ARLOCK),
    .M_AXI_ARQOS (ARQOS),
    .M_AXI_ARREGION (ARREGION),

    .M_AXI_RDATA  (RDATA),
    .M_AXI_RRESP  (RRESP),
    .M_AXI_RVALID (RVALID),
    .M_AXI_RREADY (RREADY),
    .M_AXI_RID (RID),
    .M_AXI_RLAST (RLAST)
  );

  // AXI VIP (Slave)
  axi_vip_0 u_axi_vip (
    .aclk    (ACLK),
    .aresetn (ARESETn),

    .s_axi_awaddr  (AWADDR),
    .s_axi_awvalid (AWVALID),
    .s_axi_awready (AWREADY),
    .s_axi_awprot  (AWPROT),
    .s_axi_awid (AWID),
    .s_axi_awlen (AWLEN),
    .s_axi_awsize (AWSIZE),
    .s_axi_awburst (AWBURST),
    .s_axi_awcache (AWCACHE),
    .s_axi_awlock (AWLOCK),
    .s_axi_awqos (AWQOS),
    .s_axi_awregion (AWREGION),

    .s_axi_wdata   (WDATA),
    .s_axi_wstrb   (WSTRB),
    .s_axi_wvalid  (WVALID),
    .s_axi_wready  (WREADY),
    .s_axi_wlast (WLAST),

    .s_axi_bresp   (BRESP),
    .s_axi_bvalid  (BVALID),
    .s_axi_bready  (BREADY),
    .s_axi_bid (BID),

    .s_axi_araddr  (ARADDR),
    .s_axi_arvalid (ARVALID),
    .s_axi_arready (ARREADY),
    .s_axi_arprot  (ARPROT),
    .s_axi_arid (ARID),
    .s_axi_arlen (ARLEN),
    .s_axi_arsize (ARSIZE),
    .s_axi_arburst (ARBURST),
    .s_axi_arcache (ARCACHE),
    .s_axi_arlock (ARLOCK),
    .s_axi_arqos (ARQOS),
    .s_axi_arregion (ARREGION),

    .s_axi_rdata   (RDATA),
    .s_axi_rresp   (RRESP),
    .s_axi_rvalid  (RVALID),
    .s_axi_rready  (RREADY),
    .s_axi_rid (RID),
    .s_axi_rlast (RLAST)
  );

  // AXI VIP control
  axi_vip_0_slv_mem_t slv_agent;

  initial begin 
    wait (ARESETn === 1'b1);
    repeat (20) @(posedge ACLK);

    slv_agent = new("slv_agent", u_axi_vip.inst.IF);

    slv_agent.start_slave();

    $display("[TB] AXI VIP slave started");
  end

  /*
  always @(posedge ACLK) begin
    if (AWVALID)
      $display("[%0t] AWVALID addr=%h ready=%b", $time, AWADDR, AWREADY);
    if (WVALID)
      $display("[%0t] WVALID data=%h ready=%b", $time, WDATA, WREADY);
    if (BVALID)
      $display("[%0t] BVALID resp=%b", $time, BRESP);
  end
  */

endmodule
