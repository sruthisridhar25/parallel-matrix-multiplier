module ram #(parameter RAM_INIT = "ram_mem_u.txt")(
	input clk,
	input [5:0] ADDR,
	input [7:0] DATA_I,
	output reg [7:0] DATA_O,
	input WE
);

	(* ramstyle = "MGK" *) reg [7:0] MEM[0:63];
 
	initial begin
		$readmemb(RAM_INIT, MEM);
	end

	always @(posedge clk) begin
		if(WE) begin
			MEM[ADDR] <= DATA_I;
		end
		
		DATA_O <= MEM[ADDR];
	end
endmodule 