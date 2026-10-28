module matrixMult4(
    input clk,
    input start,
    input reset,
    output reg done,
    output reg [10:0] clock_count
);

reg [5:0] addrA1, addrA2, addrB1, addrB2;
wire signed [7:0] inA1, inA2, inB1, inB2;

wire signed [18:0] s1, s2, s3, s4;
reg signed [18:0] save1, save2, save3, save4;

reg macc_clear;

reg [5:0] writeaddr;
reg signed [18:0] writedata;
reg ramwriteenable;

wire [5:0] outaddr;
wire signed [18:0] outdata;
wire outwriteenable;

reg [2:0] row;
reg [2:0] col;
reg [3:0] count;

reg [3:0] state;

parameter WAIT_START = 4'd0;
parameter LOAD = 4'd1;
parameter CALC = 4'd2;
parameter SAVE = 4'd3;
parameter WRITE1 = 4'd4;
parameter WRITE2 = 4'd5;
parameter WRITE3 = 4'd6;
parameter WRITE4 = 4'd7;
parameter NEXT = 4'd8;
parameter DONE_WAIT1 = 4'd9;
parameter DONE_WAIT2 = 4'd10;
parameter FINISH = 4'd11;

ram_dual #(.RAM_INIT("ram_a_init.txt")) rama(
    .clk(clk),
    .addr1(addrA1),
    .addr2(addrA2),
    .data1(inA1),
    .data2(inA2)
);

ram_dual #(.RAM_INIT("ram_b_init.txt")) ramb(
    .clk(clk),
    .addr1(addrB1),
    .addr2(addrB2),
    .data1(inB1),
    .data2(inB2)
);

mac mac1(
    .clk(clk),
    .macc_clear(macc_clear),
    .x(inA1),
    .y(inB1),
    .s(s1)
);

mac mac2(
    .clk(clk),
    .macc_clear(macc_clear),
    .x(inA2),
    .y(inB1),
    .s(s2)
);

mac mac3(
    .clk(clk),
    .macc_clear(macc_clear),
    .x(inA1),
    .y(inB2),
    .s(s3)
);

mac mac4(
    .clk(clk),
    .macc_clear(macc_clear),
    .x(inA2),
    .y(inB2),
    .s(s4)
);

buffer buff(
    .clk(clk),
    .rst(reset),
    .waddr(writeaddr),
    .data(writedata),
    .ramwriteenable(ramwriteenable),
    .oramwriteenable(outwriteenable),
    .owaddr(outaddr),
    .odata(outdata)
);

ram_output RAMOUTPUT(
    .clk(clk),
    .ADDR(outaddr),
    .DATA_I(outdata),
    .WE(outwriteenable)
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        done <= 1'b0;
        clock_count <= 11'd0;
        state <= WAIT_START;

        row <= 3'd0;
        col <= 3'd0;
        count <= 4'd0;

        addrA1 <= 6'd0;
        addrA2 <= 6'd0;
        addrB1 <= 6'd0;
        addrB2 <= 6'd0;

        save1 <= 19'd0;
        save2 <= 19'd0;
        save3 <= 19'd0;
        save4 <= 19'd0;

        writeaddr <= 6'd0;
        writedata <= 19'd0;
        ramwriteenable <= 1'b0;

        macc_clear <= 1'b0;
    end
    else begin
        done <= 1'b0;
        ramwriteenable <= 1'b0;
        macc_clear <= 1'b0;

        if (state != WAIT_START && state != FINISH)
            clock_count <= clock_count + 11'd1;

        case (state)

            WAIT_START: begin
                if (start) begin
                    row <= 3'd0;
                    col <= 3'd0;
                    count <= 4'd0;
                    clock_count <= 11'd0;

                    addrA1 <= 6'd0;
                    addrA2 <= 6'd1;
                    addrB1 <= 6'd0;
                    addrB2 <= 6'd8;

                    state <= LOAD;
                end
            end

            LOAD: begin
                macc_clear <= 1'b1;
                count <= 4'd1;

                addrA1 <= row + 6'd8;
                addrA2 <= (row + 3'd1) + 6'd8;
                addrB1 <= 6'd1 + (col << 3);
                addrB2 <= 6'd1 + ((col + 3'd1) << 3);

                state <= CALC;
            end

            CALC: begin
                if (count <= 4'd7) begin
                    if (count < 4'd7) begin
                        addrA1 <= row + (6'd8 * (count + 4'd1));
                        addrA2 <= (row + 3'd1) + (6'd8 * (count + 4'd1));
                        addrB1 <= (count + 4'd1) + (col << 3);
                        addrB2 <= (count + 4'd1) + ((col + 3'd1) << 3);
                    end
                    count <= count + 4'd1;
                end
                else begin
                    state <= SAVE;
                end
            end

            SAVE: begin
                save1 <= s1;
                save2 <= s2;
                save3 <= s3;
                save4 <= s4;
                state <= WRITE1;
            end

            WRITE1: begin
                writedata <= save1;
                writeaddr <= row + (col << 3);
                ramwriteenable <= 1'b1;
                state <= WRITE2;
            end

            WRITE2: begin
                writedata <= save2;
                writeaddr <= (row + 3'd1) + (col << 3);
                ramwriteenable <= 1'b1;
                state <= WRITE3;
            end

            WRITE3: begin
                writedata <= save3;
                writeaddr <= row + ((col + 3'd1) << 3);
                ramwriteenable <= 1'b1;
                state <= WRITE4;
            end

            WRITE4: begin
                writedata <= save4;
                writeaddr <= (row + 3'd1) + ((col + 3'd1) << 3);
                ramwriteenable <= 1'b1;
                state <= NEXT;
            end

            NEXT: begin
                if (row == 3'd6) begin
                    row <= 3'd0;
                    if (col == 3'd6) begin
                        state <= DONE_WAIT1;
                    end
                    else begin
                        col <= col + 3'd2;
                        count <= 4'd0;
                        addrA1 <= 6'd0;
                        addrA2 <= 6'd1;
                        addrB1 <= (col + 3'd2) << 3;
                        addrB2 <= (col + 3'd3) << 3;
                        state <= LOAD;
                    end
                end
                else begin
                    row <= row + 3'd2;
                    count <= 4'd0;
                    addrA1 <= row + 3'd2;
                    addrA2 <= row + 3'd3;
                    addrB1 <= (col << 3);
                    addrB2 <= ((col + 3'd1) << 3);
                    state <= LOAD;
                end
            end

            DONE_WAIT1: begin
                state <= DONE_WAIT2;
            end

            DONE_WAIT2: begin
                state <= FINISH;
            end

            FINISH: begin
                done <= 1'b1;
                state <= FINISH;
            end

            default: begin
                state <= WAIT_START;
            end

        endcase
    end
end

endmodule
