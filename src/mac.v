// Task 1
module mac(
	input wire macc_clear,
	input wire signed [7:0] x,
	input wire signed [7:0] y,
	output reg signed [18:0] s,
	input wire clk,
	input wire reset
);

	
	always @(posedge clk) begin
		if(reset == 1'd1) begin
			s <= 19'd0;
		end
		else if(macc_clear == 1'd1) begin
			s <= x * y;
		end
		else begin
			s <= s + (x * y);
		end
	end
endmodule
