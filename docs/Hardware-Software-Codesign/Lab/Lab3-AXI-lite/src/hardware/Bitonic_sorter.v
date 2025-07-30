`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2025 06:17:49 PM
// Design Name: 
// Module Name: Bitonic_sorter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Bitonic_sorter(
    input clk,
    input rst,
    input direction, //1 for ascending, 0 for descending
    input start,
    input [31:0] data_in, //each element is 4bits total 8 elements
    output reg [31:0] data_out,
    output reg done
    );
reg [1:0] state;
reg [1:0] next_state;
reg [3:0] data [0:7];
reg [2:0] cnt;

reg [3:0] cmp_in [7:0]; 
wire [3:0] cmp_out [7:0];
reg dir [3:0]; //1 for ascending, 0 for descending

integer i;

parameter 
IDLE = 2'd0,
INPUT = 2'd1,
SORT = 2'd2,
DONE = 2'd3;

always @(posedge clk or negedge rst) begin
    if(!rst) state <= IDLE;
    else state <= next_state;
end

always @(*) begin
    case(state)
        IDLE: next_state = start ? INPUT : IDLE;
        INPUT: next_state = SORT;
        SORT: begin
            if (cnt == 3'd5) next_state = DONE;
            else next_state = SORT;
        end
        DONE: next_state = start ? DONE : IDLE;
    endcase
end

always @(posedge clk or negedge rst) begin
    if(!rst) cnt <= 3'd0;
    else begin
        case(state)
            IDLE: cnt <= 3'd0;
            INPUT: cnt <= 3'd0;
            SORT: begin
                if (cnt == 3'd5) cnt <= 3'd0;
                else cnt <= cnt + 1'b1;
            end
            DONE: cnt <= 3'd0;
        endcase
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst)begin
        for(i=0;i<8;i=i+1) data[i] <= 4'b0000;
    end else begin
        case(state)
            INPUT:begin
                data[0] <= data_in[3:0];
                data[1] <= data_in[7:4];
                data[2] <= data_in[11:8];
                data[3] <= data_in[15:12];
                data[4] <= data_in[19:16];
                data[5] <= data_in[23:20];
                data[6] <= data_in[27:24];
                data[7] <= data_in[31:28];
            end
            SORT:begin
                case(cnt)
                    3'd0:begin
                        data[0] <= cmp_out[0];
                        data[1] <= cmp_out[1];
                        data[2] <= cmp_out[2];
                        data[3] <= cmp_out[3];
                        data[4] <= cmp_out[4];
                        data[5] <= cmp_out[5];
                        data[6] <= cmp_out[6];
                        data[7] <= cmp_out[7];
                    end
                    3'd1:begin
                        data[0] <= cmp_out[0];
                        data[2] <= cmp_out[1];
                        data[1] <= cmp_out[2];
                        data[3] <= cmp_out[3];
                        data[4] <= cmp_out[4];
                        data[6] <= cmp_out[5];
                        data[5] <= cmp_out[6];
                        data[7] <= cmp_out[7];
                    end
                    3'd2:begin
                        data[0] <= cmp_out[0];
                        data[1] <= cmp_out[1];
                        data[2] <= cmp_out[2];
                        data[3] <= cmp_out[3];
                        data[4] <= cmp_out[4];
                        data[5] <= cmp_out[5];
                        data[6] <= cmp_out[6];
                        data[7] <= cmp_out[7];
                    end
                    3'd3:begin
                        data[0] <= cmp_out[0];
                        data[4] <= cmp_out[1];
                        data[1] <= cmp_out[2];
                        data[5] <= cmp_out[3];
                        data[2] <= cmp_out[4];
                        data[6] <= cmp_out[5];
                        data[3] <= cmp_out[6];
                        data[7] <= cmp_out[7];
                    end
                    3'd4:begin
                        data[0] <= cmp_out[0];
                        data[2] <= cmp_out[1];
                        data[1] <= cmp_out[2];
                        data[3] <= cmp_out[3];
                        data[4] <= cmp_out[4];
                        data[6] <= cmp_out[5];
                        data[5] <= cmp_out[6];
                        data[7] <= cmp_out[7];
                    end
                    3'd5:begin
                        data[0] <= cmp_out[0];
                        data[1] <= cmp_out[1];
                        data[2] <= cmp_out[2];
                        data[3] <= cmp_out[3];
                        data[4] <= cmp_out[4];
                        data[5] <= cmp_out[5];
                        data[6] <= cmp_out[6];
                        data[7] <= cmp_out[7];
                    end
                endcase
            end
        endcase
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst)begin
        data_out <= 32'b0;
        done <= 1'b0;
    end else begin
        if(!start && state == DONE)begin
            done <= 1'b0;
        end else if(state == DONE) begin
            data_out <= {data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]};
            done <= 1'b1;
        end
    end
end

always @(*) begin
    case(cnt)
        3'd0:begin
            cmp_in[0] = data[0];
            cmp_in[1] = data[1];
            cmp_in[2] = data[2];
            cmp_in[3] = data[3];
            cmp_in[4] = data[4];
            cmp_in[5] = data[5];
            cmp_in[6] = data[6];
            cmp_in[7] = data[7];
            dir[0] = 1'b1;
            dir[1] = 1'b0;
            dir[2] = 1'b1;
            dir[3] = 1'b0;
        end
        3'd1:begin
            cmp_in[0] = data[0];
            cmp_in[1] = data[2];
            cmp_in[2] = data[1];
            cmp_in[3] = data[3];
            cmp_in[4] = data[4];
            cmp_in[5] = data[6];
            cmp_in[6] = data[5];
            cmp_in[7] = data[7];
            dir[0] = 1'b1;
            dir[1] = 1'b1;
            dir[2] = 1'b0;
            dir[3] = 1'b0;
        end
        3'd2:begin
            cmp_in[0] = data[0];
            cmp_in[1] = data[1];
            cmp_in[2] = data[2];
            cmp_in[3] = data[3];
            cmp_in[4] = data[4];
            cmp_in[5] = data[5];
            cmp_in[6] = data[6];
            cmp_in[7] = data[7];
            dir[0] = 1'b1;
            dir[1] = 1'b1;
            dir[2] = 1'b0;
            dir[3] = 1'b0;
        end
        3'd3:begin
            cmp_in[0] = data[0];
            cmp_in[1] = data[4];
            cmp_in[2] = data[1];
            cmp_in[3] = data[5];
            cmp_in[4] = data[2];
            cmp_in[5] = data[6];
            cmp_in[6] = data[3];
            cmp_in[7] = data[7];
            dir[0] = direction;
            dir[1] = direction;
            dir[2] = direction;
            dir[3] = direction;
        end
        3'd4:begin
            cmp_in[0] = data[0];
            cmp_in[1] = data[2];
            cmp_in[2] = data[1];
            cmp_in[3] = data[3];
            cmp_in[4] = data[4];
            cmp_in[5] = data[6];
            cmp_in[6] = data[5];
            cmp_in[7] = data[7];
            dir[0] = direction;
            dir[1] = direction;
            dir[2] = direction;
            dir[3] = direction;
        end
        3'd5:begin
            cmp_in[0] = data[0];
            cmp_in[1] = data[1];
            cmp_in[2] = data[2];
            cmp_in[3] = data[3];
            cmp_in[4] = data[4];
            cmp_in[5] = data[5];
            cmp_in[6] = data[6];
            cmp_in[7] = data[7];
            dir[0] = direction;
            dir[1] = direction;
            dir[2] = direction;
            dir[3] = direction;
        end
    endcase
end

compare_unit cp0(.in1(cmp_in[0]), .in2(cmp_in[1]), .direction(dir[0]), .out1(cmp_out[0]), .out2(cmp_out[1]));
compare_unit cp1(.in1(cmp_in[2]), .in2(cmp_in[3]), .direction(dir[1]), .out1(cmp_out[2]), .out2(cmp_out[3]));
compare_unit cp2(.in1(cmp_in[4]), .in2(cmp_in[5]), .direction(dir[2]), .out1(cmp_out[4]), .out2(cmp_out[5]));
compare_unit cp3(.in1(cmp_in[6]), .in2(cmp_in[7]), .direction(dir[3]), .out1(cmp_out[6]), .out2(cmp_out[7]));

endmodule
