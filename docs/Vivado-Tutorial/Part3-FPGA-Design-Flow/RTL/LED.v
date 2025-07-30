module LED(
    input            clk ,
    input            rst ,
    input      [1:0] sw  ,
    output reg [3:0] led
);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        led <= 4'b0000;
    end
    else begin
        case(sw)
            2'b00: led <= 4'b0000;
            2'b01: led <= (led == 0) ? 4'b0001 : led << 1;
            2'b10: led <= (led == 0) ? 4'b1000 : led >> 1;
            2'b11: led <= 4'b1111;
        endcase
    end
end

endmodule
