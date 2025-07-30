`timescale 1ns / 1ps

module CONV_tb;

// Clock and reset
reg clk = 0;
reg reset = 1;
always #5 clk = ~clk;  // 100 MHz

// Input signals
reg ready = 0;
reg [31:0] data_r;

// Output signals from DUT
wire busy;
wire done;
wire crd;
wire [9:0] addr_r;
wire [9:0] addr_w;
wire [31:0] data_w;
wire [3:0] BYTE_WRITE;

// Memory
reg [31:0] input_mem [0:783];
reg [31:0] golden_mem [0:675];
reg [31:0] captured_mem [0:675];

integer i;
integer error_count = 0;

// DUT instantiation
CONV uut (
.clk(clk),
.reset(reset),
.ready(ready),
.data_r(data_r),
.busy(busy),
.done(done),
.crd(crd),
.addr_r(addr_r),
.addr_w(addr_w),
.data_w(data_w),
.BYTE_WRITE(BYTE_WRITE)
);

initial begin
$readmemh("./input.hex", input_mem);
$readmemh("./golden.hex", golden_mem);

reset = 1;
#20;
reset = 0;
#20;

ready = 1;
#10;
ready = 0;
end

reg [9:0] addr_r_d;

always @(posedge clk) begin
    addr_r_d <= addr_r;
end

always @(*) begin
    if (crd)
        data_r = input_mem[addr_r_d];
end


always @(posedge clk) begin
if (crd && BYTE_WRITE == 4'b1111)
    captured_mem[addr_w] <= data_w;
end

always @(posedge clk) begin
if (done) begin
    #10;
    $writememh("result.hex", captured_mem);
    for (i = 0; i < 676; i = i + 1) begin
    if (captured_mem[i] !== golden_mem[i]) begin
        $display("Mismatch at %0d: got %h, expected %h", i, captured_mem[i], golden_mem[i]);
        error_count = error_count + 1;
    end
    end
    if (error_count == 0)
    $display("PASS: All outputs match golden data.");
    else
    $display("FAIL: %0d mismatches found.", error_count);
    $finish;
end
end

endmodule
