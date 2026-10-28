module ram_dual #(parameter RAM_INIT = "ram_a_init.txt")(
    input clk,
    input [5:0] addr1,
    input [5:0] addr2,
    output reg signed [7:0] data1,
    output reg signed [7:0] data2
);

reg signed [7:0] mem [0:63];

initial begin
    $readmemb(RAM_INIT, mem);
end

always @(posedge clk) begin
    data1 <= mem[addr1];
    data2 <= mem[addr2];
end

endmodule
