module ram_output (
	input clk,
	input [5:0] ADDR,
	input signed [18:0] DATA_I,
	input WE
);

	reg signed [18:0] mem [0:63];
	
	always @(posedge clk) begin
		if(WE == 1'b1) begin
			mem[ADDR] <= DATA_I;
		end
	end
endmodule
