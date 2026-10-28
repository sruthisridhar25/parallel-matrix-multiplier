module buffer(
    input clk,
    input rst,
    input [5:0] waddr,
    input signed [18:0] data,
    input ramwriteenable,

    output reg oramwriteenable,
    output reg [5:0] owaddr,
    output reg signed [18:0] odata
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        odata <= 19'sd0;
        owaddr <= 6'd0;
        oramwriteenable <= 1'b0;
    end
    else begin
        odata <= data;
        owaddr <= waddr;
        oramwriteenable <= ramwriteenable;
    end
end

endmodule
