module master(
    input  wire        ACLK,
    input  wire        ARESETn,

    // Write Address
    output reg  [31:0] M_AXI_AWADDR,
    output reg         M_AXI_AWVALID,
    input  wire        M_AXI_AWREADY,
    output reg  [2:0]  M_AXI_AWPROT,

    output reg  [3:0]  M_AXI_AWID,
    output reg  [7:0]  M_AXI_AWLEN,
    output reg  [2:0]  M_AXI_AWSIZE,
    output reg  [1:0]  M_AXI_AWBURST,

    output reg  [3:0]  M_AXI_AWCACHE,
    output reg         M_AXI_AWLOCK,
    output reg  [3:0]  M_AXI_AWQOS,
    output reg  [3:0]  M_AXI_AWREGION,

    // Write Data
    output reg  [31:0] M_AXI_WDATA,
    output reg  [3:0]  M_AXI_WSTRB,
    output reg         M_AXI_WVALID,
    input  wire        M_AXI_WREADY,

    output reg         M_AXI_WLAST,

    // Write Response
    input  wire [1:0]  M_AXI_BRESP,
    input  wire        M_AXI_BVALID,
    output reg         M_AXI_BREADY,

    input  wire [3:0]  M_AXI_BID,

    // Read Address
    output reg  [31:0] M_AXI_ARADDR,
    output reg         M_AXI_ARVALID,
    input  wire        M_AXI_ARREADY,
    output reg  [2:0]  M_AXI_ARPROT,

    output reg  [3:0]  M_AXI_ARID,
    output reg  [7:0]  M_AXI_ARLEN,
    output reg  [2:0]  M_AXI_ARSIZE,
    output reg  [1:0]  M_AXI_ARBURST,

    output reg  [3:0]  M_AXI_ARCACHE,
    output reg         M_AXI_ARLOCK,
    output reg  [3:0]  M_AXI_ARQOS,
    output reg  [3:0]  M_AXI_ARREGION,

    // Read Data
    input  wire [31:0] M_AXI_RDATA,
    input  wire [1:0]  M_AXI_RRESP,
    input  wire        M_AXI_RVALID,
    output reg         M_AXI_RREADY,

    input  wire [3:0]  M_AXI_RID,
    input  wire        M_AXI_RLAST
);

parameter RESET_WAIT = 2'd0, WRITE = 2'd1, READ = 2'd2, DONE = 2'd3;
reg [1:0] state;

// burst
localparam BURST_LEN = 4;       // beats
reg [7:0] w_beat_cnt;           // beat count of current burst
reg [7:0] r_beat_cnt;

// outstanding
localparam TOTAL_BURSTS = 8;
localparam MAX_WR_OUTSTANDING = 4;
reg [2:0] wr_outstanding;       // not yet response number
reg [2:0] rd_outstanding;

reg w_active;
reg [7:0] aw_issue_idx;
reg [7:0] w_burst_idx;
reg [3:0] aw_pending;

reg r_active;
reg [7:0] ar_issue_idx;
reg [7:0] r_burst_idx;

wire aw_can_issue;
assign aw_can_issue = (aw_issue_idx < TOTAL_BURSTS) && 
                    (wr_outstanding < MAX_WR_OUTSTANDING) && 
                    !M_AXI_AWVALID;

wire ar_can_issue;
assign ar_can_issue = (ar_issue_idx < TOTAL_BURSTS) &&
                    (rd_outstanding < MAX_WR_OUTSTANDING) &&
                    !M_AXI_ARVALID;


always @(posedge ACLK) begin
    if (!ARESETn) begin
        state <= RESET_WAIT;

        // AW
        M_AXI_AWVALID <= 0;
        M_AXI_AWPROT <= 0;
        M_AXI_AWID <= 0;
        M_AXI_AWLEN <= 0;
        M_AXI_AWSIZE <= 3'b010;
        M_AXI_AWBURST <= 2'b01;
        M_AXI_AWCACHE <= 4'b0011;
        M_AXI_AWLOCK <= 0;
        M_AXI_AWQOS <= 0;
        M_AXI_AWREGION <= 0;

        // W
        M_AXI_WVALID  <= 0;
        M_AXI_WLAST <= 0;

        // B
        M_AXI_BREADY  <= 1;         // always ready !!!

        // write outstanding
        w_active <= 0;
        aw_issue_idx <= 0;
        w_burst_idx <= 0;
        aw_pending <= 0;
        
        // AR
        M_AXI_ARVALID <= 0;
        M_AXI_ARPROT <= 0;
        M_AXI_ARID    <= 0;
        M_AXI_ARLEN   <= 0;
        M_AXI_ARSIZE  <= 3'b010;
        M_AXI_ARBURST <= 2'b01;
        M_AXI_ARCACHE <= 4'b0011;
        M_AXI_ARLOCK <= 0;
        M_AXI_ARQOS <= 0;
        M_AXI_ARREGION <= 0;

        // R
        M_AXI_RREADY  <= 0;

        // read outstanding
        r_active <= 0;
        ar_issue_idx <= 0;
        r_burst_idx <= 0;

    end else begin
        case (state)
            RESET_WAIT: begin
                state <= WRITE;
            end
            WRITE: begin
                // Issue new AW
                if (aw_can_issue) begin
                    M_AXI_AWADDR  <= 32'h0000_0000 + (aw_issue_idx * 16);
                    M_AXI_AWLEN   <= BURST_LEN - 1;
                    M_AXI_AWSIZE  <= 3'b010;
                    M_AXI_AWBURST <= 2'b01;
                    M_AXI_AWVALID <= 1;

                    aw_issue_idx <= aw_issue_idx + 1;
                end 

                // AW handshake
                if (M_AXI_AWVALID && M_AXI_AWREADY) begin
                    M_AXI_AWVALID <= 0;
                    aw_pending <= aw_pending + 1;
                end

                // W channel
                // start to send next burst
                if (!w_active && aw_pending > 0) begin
                    M_AXI_WDATA <= 32'h1000_0000 + (w_burst_idx * 16);
                    M_AXI_WSTRB <= 4'b1111;
                    M_AXI_WVALID <= 1;
                    M_AXI_WLAST <= 0;

                    w_active <= 1;
                    w_beat_cnt <= 0;
                end

                if (w_active && M_AXI_WVALID && M_AXI_WREADY) begin
                    w_beat_cnt <= w_beat_cnt + 1;
                    M_AXI_WDATA <= M_AXI_WDATA + 1;

                    if (w_beat_cnt == BURST_LEN - 2) begin
                        M_AXI_WLAST <= 1;
                    end

                    if (w_beat_cnt == BURST_LEN - 1) begin
                        M_AXI_WVALID <= 0;
                        M_AXI_WLAST <= 0;

                        w_active <= 0;
                        w_burst_idx <= w_burst_idx + 1;
                        aw_pending <= aw_pending - 1;
                    end
                end


                if ((aw_issue_idx == TOTAL_BURSTS) && 
                    (wr_outstanding == 0) && 
                    !w_active && !M_AXI_AWVALID) begin
                    state <= READ;
                end 
            end
            READ: begin
                // start AR
                if (ar_can_issue) begin
                    M_AXI_ARADDR <= 32'h0000_0000 + ar_issue_idx * 16;
                    M_AXI_ARLEN <= BURST_LEN - 1;
                    M_AXI_ARSIZE <= 3'b010;
                    M_AXI_ARBURST <= 2'b01;
                    M_AXI_ARVALID <= 1;

                    ar_issue_idx <= ar_issue_idx + 1;
                end

                // AR handshake
                if (M_AXI_ARVALID && M_AXI_ARREADY) begin
                    M_AXI_ARVALID <= 0;
                end

                // start R
                if (!r_active && rd_outstanding > 0) begin
                    M_AXI_RREADY <= 1;

                    r_active <= 1;
                    r_beat_cnt <= 0;
                end

                // receive data
                if (r_active && M_AXI_RVALID && M_AXI_RREADY) begin
                    // expected = 32'h1000_0000 + r_burst_idx * 16 + r_beat_cnt;
                    // check or store M_AXI_RDATA
                    $display("Read burst %0d beat %0d = %h", 
                            r_burst_idx, r_beat_cnt, M_AXI_RDATA);

                    if (M_AXI_RLAST) begin
                        // If rd_outstanding > 0, then keep RREADY high
                        if (rd_outstanding == 0) begin
                            M_AXI_RREADY <= 0;
                        end

                        r_active <= 0;
                        r_burst_idx <= r_burst_idx + 1;
                    end
                    else begin
                        r_beat_cnt <= r_beat_cnt + 1;
                    end
                end

                if ((ar_issue_idx == TOTAL_BURSTS) && 
                    (rd_outstanding == 0) && 
                    !r_active && !M_AXI_ARVALID) begin
                    state <= DONE;
                end 

            end 
            DONE: begin
                state <= DONE;
            end
        endcase
    end
end

// Independent B channel counter
always @(posedge ACLK) begin
    if (!ARESETn) begin
        wr_outstanding <= 0;
    end else begin
        case ({M_AXI_AWVALID && M_AXI_AWREADY,
               M_AXI_BVALID  && M_AXI_BREADY})
            2'b10: wr_outstanding <= wr_outstanding + 1;
            2'b01: wr_outstanding <= wr_outstanding - 1;
            2'b11: wr_outstanding <= wr_outstanding;        // same cycle issue + complete
            default: wr_outstanding <= wr_outstanding;
        endcase
    end
end

// Independent R channel counter
always @(posedge ACLK) begin
    if (!ARESETn) begin
        rd_outstanding <= 0;
    end else begin
        case ({M_AXI_ARVALID && M_AXI_ARREADY,
               M_AXI_RVALID && M_AXI_RREADY && M_AXI_RLAST})
            2'b10: rd_outstanding <= rd_outstanding + 1;
            2'b01: rd_outstanding <= rd_outstanding - 1;
            2'b11: rd_outstanding <= rd_outstanding;
            default: rd_outstanding <= rd_outstanding;
        endcase
    end
end
endmodule