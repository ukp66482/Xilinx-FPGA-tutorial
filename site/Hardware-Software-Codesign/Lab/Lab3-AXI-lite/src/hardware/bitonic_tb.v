`timescale 1ns / 1ps
`include "Bitonic_sorter.v"
module tb_Bitonic_sorter;

reg clk;
reg rst;
reg start;
reg direction;
reg [31:0] data_in;
wire [31:0] data_out;
wire done;

Bitonic_sorter uut (
    .clk(clk),
    .rst(rst),
    .direction(direction),
    .start(start),
    .data_in(data_in),
    .data_out(data_out),
    .done(done)
);

// Clock generation
always #5 clk = ~clk;

initial begin
    // Initial state
    clk = 0;
    rst = 0;
    start = 0;
    direction = 0; // 0 for descending, 1 for ascending
    data_in = 32'h00000000;

    // Apply reset
    #10;
    rst = 1;
    #10;

    // Test 1: Descending sort
    data_in = 32'h52173864; // input: 5 2 1 7 3 8 6 4
    direction = 1; // Ascending
    start = 1;

    wait (done);

    $display("[Ascending] Input: 0x52173864 => Output: %h", data_out);
    #15 start = 0;
    #100;

    // Test 2: Descending sort
    data_in = 32'hf4a21987; // input: f 4 a 2 1 9 8 7
    direction = 0; // Descending
    start = 1;

    wait (done);
    $display("[Descending] Input: 0xf4a21987 => Output: %h", data_out);
    #15 start = 0;
    #100;

    $finish;
end

initial begin
    $fsdbDumpfile("Bitonic_sorter.fsdb");

	$fsdbDumpvars("+struct", "+mda", tb_Bitonic_sorter);
end


endmodule
