`timescale 1ps/1ps

module tb_mac;
	reg macc_clear;
	reg signed [7:0] x;
	reg signed [7:0] y;
	wire signed [18:0] s;
	reg clk;
	reg reset;
	

mac mac_test(
	.macc_clear(macc_clear),
	.x(x),
	.y(y),
	.clk(clk),
	.reset(reset),
	.s(s)
);

always begin
	clk = 1'b0;
	forever #5 clk = ~clk;
end

initial begin
	reset = 1'b1;
	macc_clear = 1'b0;
	x = 0;
	y = 0;
	
	#10;
	reset = 1'b0;
	
	// Test 1 w/ macc_clear = 1, multiply 
	macc_clear = 1'b1;
	x = 8'd8;
	y = 8'd5; // 40
	
	#10;
	
	// Test 2 w/ macc_clear = 0, add 
	macc_clear = 1'b0;
	x = 8'd4;
	y = 8'd6; // 13
	#20;
	$finish;
		
	end	
endmodule
