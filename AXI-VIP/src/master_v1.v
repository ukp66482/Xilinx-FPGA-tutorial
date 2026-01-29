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

parameter 
    RESET_WAIT = 0,
    IDLE = 1,
    WRITE = 2,
    WAIT_B = 3,
    READ = 4,
    WAIT_R = 5,
    DONE = 6;

reg [2:0] state;

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
        M_AXI_WLAST <= 1;

        // B
        M_AXI_BREADY  <= 0;

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

    end else begin
        case (state)
            RESET_WAIT: begin
                state <= IDLE;
            end
            IDLE: begin
                // prepare write
                M_AXI_AWADDR  <= 32'h0000_0004;
                M_AXI_WDATA   <= 32'h1234_5678;
                M_AXI_WSTRB  <= 4'b1111;

                M_AXI_AWVALID <= 1;
                M_AXI_WVALID  <= 1;

                state <= WRITE;
            end

            WRITE: begin
                if (M_AXI_AWREADY) M_AXI_AWVALID <= 0;
                if (M_AXI_WREADY)  M_AXI_WVALID  <= 0;

                if (!M_AXI_AWVALID && !M_AXI_WVALID) begin
                    M_AXI_BREADY <= 1;
                    state <= WAIT_B;
                end
            end

            WAIT_B: begin
                if (M_AXI_BVALID) begin
                    M_AXI_BREADY <= 0;
                    state <= READ;
                end
            end

            READ: begin
                M_AXI_ARADDR  <= 32'h0000_0004;
                M_AXI_ARVALID <= 1;

                if (M_AXI_ARVALID && M_AXI_ARREADY) begin
                    M_AXI_ARVALID <= 0;
                    M_AXI_RREADY  <= 1;
                    state <= WAIT_R;
                end
            end

            WAIT_R: begin
                if (M_AXI_RVALID && M_AXI_RLAST) begin
                    // we can check M_AXI_RDATA here
                    M_AXI_RREADY <= 0;
                    state <= DONE;
                end
            end

            DONE: begin
                // stop here
                state <= DONE;
            end
        endcase
    end
end

endmodule
