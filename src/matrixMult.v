module matrixMult ( // change tb from toplevel to matrixMult
	input clk,
	input start,
	input reset,
	output reg done,
	output reg [10:0] clock_count
);

reg [5:0] ADDR_A;
wire signed [7:0] DATA_O_A;

reg [5:0] ADDR_B;
wire signed [7:0] DATA_O_B;

reg [5:0] ADDR_C;
reg WE_C;

wire signed [18:0] macc_sum;
reg macc_clear;
reg macc_clear_d;
reg macc_clear_d2;

ram #(.RAM_INIT("ram_a_init.txt")) matrixA (
	.clk(clk),
	.ADDR(ADDR_A),
	.DATA_I(8'd0),
	.DATA_O(DATA_O_A),
	.WE(1'b0)
);

ram #(.RAM_INIT("ram_b_init.txt")) matrixB (
	.clk(clk),
	.ADDR(ADDR_B),
	.DATA_I(8'd0),
	.DATA_O(DATA_O_B),
	.WE(1'b0)
);


ram_output RAMOUTPUT (
	.clk(clk),
	.ADDR(ADDR_C),
	.DATA_I(macc_sum),
	.WE(WE_C)
);

mac mac1 (
	.macc_clear(macc_clear_d2),
	.x(DATA_O_A),
	.y(DATA_O_B),
	.clk(clk),
	.reset(reset),
	.s(macc_sum)
);

// finite state machine

parameter IDLE = 4'd0;
parameter CLEAR = 4'd1;
parameter LOAD = 4'd2;
parameter WAIT1 = 4'd3;
parameter MACC = 4'd4;
parameter WRITE = 4'd5;
parameter WAIT2 = 4'd6;
parameter NEXT = 4'd7;
parameter FIN = 4'd8;

reg [3:0] state;

reg [2:0] j; // row
reg[2:0] i; // col
reg [2:0] k; // dot product index

always @(posedge clk) begin
	if(reset == 1'b1) begin
	
		state <= IDLE;
		done <= 1'b0;
		clock_count <= 11'd0;
		
		j <= 3'b0;
		i <= 3'b0;
		k <= 3'b0;
		
		ADDR_A <= 6'd0;
		ADDR_B <= 6'd0;
		ADDR_C <= 6'd0;
		
		WE_C <= 1'b0;
		macc_clear <= 1'b0;
	end
	
	else begin
		
		WE_C <= 1'b0;
		macc_clear <= 1'b0;
		macc_clear_d <= macc_clear;
		macc_clear_d2 <= macc_clear_d;
		done <= 1'b0;

		case (state)
			IDLE: begin
				//clock_count <= 11'd0;
				
				i <= 4'd0;
				j <= 4'd0;
				k <= 4'd0;
				
				done <= 1'b0;
				
				if (start == 1'b1) begin
					state <= LOAD;
				end
			end
			
			CLEAR: begin
				macc_clear <= 1'b0;
				macc_clear_d <= macc_clear;
				k <= 4'd0;
				state <= LOAD;
			end
			
			LOAD: begin	
				ADDR_A <= (k << 3) + j;
				ADDR_B <= (i << 3) + k;
				macc_clear <= 1'b1;
				
				state <= MACC;
			end

			MACC: begin
				ADDR_A <= (k << 3) + j;
				ADDR_B <= (i << 3) + k;
				clock_count <= clock_count + 1'b1;
				
				if(k == 3'd0) begin
					macc_clear <= 1'b0;
					k <= k + 1;
				end	
				else if(k < 3'd7) begin
					k <= k + 1;
					end
				else begin
					k <= k + 1;
					state <= WAIT2;
				end			
			end	
		
			WAIT2: begin
				state <= WRITE;
			end
		
			
			WRITE: begin
				ADDR_C <= (i << 3) + j;
				WE_C <= 1'b1;				
				state <= NEXT;
			end
			
			NEXT: begin
				if (j == 3'd7) begin
					j <= 4'd0;	
					if (i == 3'd7) begin
						state <= FIN;
					end
					else begin
						i <= i + 3'd1;
						state <= CLEAR;
					end	
				end
				
				else begin
					j <= j + 3'd1;
					state <= CLEAR;
				end
			end
			
			FIN: begin
				done <= 1'b1;
				state <= FIN;
			end
		endcase
	end
end
endmodule 