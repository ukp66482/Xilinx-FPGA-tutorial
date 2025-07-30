module CONV(rst_n, clk, ready ,R_req, R_addr, W_addr, R_data, W_req, W_data,done,read_req,read_w_req);


input 			rst_n;
input 			clk;
input	[31:0]	R_data;
input 			ready;

output			R_req;
output 			read_req;
output reg	[31:0]	R_addr;
output reg	[31:0]	W_addr;
output reg	[3:0]	W_req;
output 		[3:0]	read_w_req;
output reg	[31:0]	W_data;
output reg			done;



assign read_req = 1'b1;
assign read_w_req = 4'd0;

parameter IDLE = 0;
parameter READ = 1;
parameter WRITE = 2;
parameter DONE = 3;

reg [1:0] curr_state,next_state;

reg [3:0] read_counter;
reg [4:0] index_X,index_Y;

wire rst;
assign rst = ~rst_n;

//read_counter
always @(posedge clk or posedge rst)
	if(rst)
		read_counter <= 0;
	else
		if(curr_state==READ)
			read_counter <= read_counter + 1;
		else
			read_counter <= 0;

//index_X
always @(posedge clk or posedge rst)
	if(rst)
		index_X <= 1;
	else
		if(curr_state==WRITE)
			if(index_X==5'd26)
				index_X <= 1;
			else
				index_X <= index_X + 1;
		else
			index_X <= index_X;


//index_Y
always @(posedge clk or posedge rst)
	if(rst)
		index_Y <= 1;
	else
		if(curr_state==WRITE && index_X==5'd26)
			index_Y <= index_Y + 1;
		else
			index_Y <= index_Y;

//FSM
always @(posedge clk or posedge rst)
	if(rst)
		curr_state <= IDLE;
	else
		curr_state <= next_state;

always @(*)	
	if(rst)
		next_state = IDLE;
	else
		case(curr_state)
			IDLE : 	if(ready)
						next_state = READ;
					else
						next_state = IDLE;
			READ : 	if(read_counter==4'd10)
						next_state = WRITE;
					else
						next_state = READ;
			WRITE : if(index_X==5'd26 && index_Y==5'd26)
						next_state = DONE;
					else
						next_state = READ;
			DONE : 	next_state = DONE;
		endcase


////////////////////////////////////////////////////////////////////////////////////////////////////

parameter kernel0 = 16'h00A8;
parameter kernel1 = 16'h0092;
parameter kernel2 = 16'h006D;
parameter kernel3 = 16'h0010;
parameter kernel4 = 16'hFF8F;
parameter kernel5 = 16'hFF6E;
parameter kernel6 = 16'hFFA6;
parameter kernel7 = 16'hFFC8;
parameter kernel8 = 16'hFFAC;


reg signed [31:0] conv_temp; 
reg signed [15:0] kernel_temp;
wire signed [31:0] mul_temp;

assign mul_temp = kernel_temp * $signed(R_data[15:0]);

always @(*)
        case(read_counter)
            4'd2: kernel_temp = kernel0;
            4'd3: kernel_temp = kernel1;
            4'd4: kernel_temp = kernel2;
            4'd5: kernel_temp = kernel3;
            4'd6: kernel_temp = kernel4;
            4'd7: kernel_temp = kernel5;
            4'd8: kernel_temp = kernel6;
            4'd9: kernel_temp = kernel7;
            4'd10: kernel_temp = kernel8;
            default: kernel_temp = 16'd0;
        endcase

always @(posedge clk or posedge rst)
   if(rst) 
       conv_temp <= 32'd0; 
   else if(curr_state == READ)
       case(read_counter)
           4'd0:   conv_temp <= 32'd0;
           4'd2:   conv_temp <= mul_temp;
           4'd3:   conv_temp <= conv_temp + mul_temp;
           4'd4:   conv_temp <= conv_temp + mul_temp;
           4'd5:   conv_temp <= conv_temp + mul_temp;
           4'd6:   conv_temp <= conv_temp + mul_temp;
           4'd7:   conv_temp <= conv_temp + mul_temp;
           4'd8:   conv_temp <= conv_temp + mul_temp;
           4'd9:   conv_temp <= conv_temp + mul_temp;
           4'd10:  conv_temp <= conv_temp + mul_temp;
           default : conv_temp <= conv_temp;
       endcase




wire [4:0] index_X_plus;
wire [4:0] index_X_minus;
wire [4:0] index_Y_plus;
wire [4:0] index_Y_minus;
assign index_X_minus = index_X - 6'd1;
assign index_X_plus = index_X + 6'd1;
assign index_Y_minus = index_Y - 6'd1;
assign index_Y_plus = index_Y + 6'd1;


//output	

//R_req
assign R_req = 1'b1;

//R_addr
always @(posedge clk or posedge rst)
    if(rst)  
        R_addr <= 32'd0; 
    else if(curr_state == READ)
        case(read_counter)
		4'd0: R_addr <= {(index_Y_minus*28 + index_X_minus),2'b00};
        4'd1: R_addr <= {(index_Y_minus*28 + index_X),2'b00};
        4'd2: R_addr <= {(index_Y_minus*28+index_X_plus),2'b00};
        4'd3: R_addr <= {(index_Y*28+ index_X_minus),2'b00};
        4'd4: R_addr <= {(index_Y*28+ index_X),2'b00};
        4'd5: R_addr <= {(index_Y*28+ index_X_plus),2'b00};
        4'd6: R_addr <= {(index_Y_plus*28+ index_X_minus),2'b00};
        4'd7: R_addr <= {(index_Y_plus*28+ index_X),2'b00};
        4'd8: R_addr <= {(index_Y_plus*28+ index_X_plus),2'b00};
        default: R_addr <= 32'd0;
        endcase


//W_addr
always @(posedge clk or posedge rst)
	if(rst)
		W_addr <= 0;
	else
		W_addr <= {(((index_Y-1)*26)+(index_X-1)),2'b00};

//W_req
always @(posedge clk or posedge rst) 
	if(rst)
		W_req <= 4'b0000;
	else
		if(curr_state==WRITE)
			W_req <= 4'b1111;
		else
			W_req <= 4'b0000;

//W_data
always @(posedge clk or posedge rst)
	if(rst)
		W_data <= 0;
	else
		W_data <= conv_temp;
reg delay_flag;
//done
always @(posedge clk or posedge rst) 
	if(rst)
		done <= 0;
	else
		if(curr_state==DONE && delay_flag==1'b1)
			done <= 1'b1;
		else
			done <= 1'b0;

always @(posedge clk or posedge rst) 
	if(rst)
		delay_flag <= 0;
	else
		if(curr_state==DONE)
			delay_flag <= 1'b1;
		else
			delay_flag <= 1'b0;


endmodule