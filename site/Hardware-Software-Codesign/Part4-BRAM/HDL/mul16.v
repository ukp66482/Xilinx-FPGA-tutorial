module mul16(rst, clk, R_req, addr, R_data, W_req, W_data);


input 			rst;
input 			clk;
output			R_req;
output	[31:0]	addr;
input	[31:0]	R_data;
output	[3:0]	W_req;
output	[31:0]	W_data;

wire w_r;

reg		[1:0]	C_state;
wire	[1:0]	N_state;

reg 	[31:0]	indata	[1:0];

assign W_data = indata[0][15:0] * indata[1][15:0];
assign N_state = C_state + 1;
assign w_r = C_state[0] & C_state[1];
assign R_req = 1;
assign W_req = {w_r, w_r, w_r, w_r};
assign addr = {28'b0,C_state,2'b0};




always@(posedge clk or negedge rst)begin

	if(!rst)begin
		C_state <= 0;
		indata[0] <= 0;
		indata[1] <= 0;
		
	end

	else begin
		C_state <= N_state;
		indata[N_state[0]]<=R_data;
	end


end

endmodule