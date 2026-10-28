`timescale 1ns/1ps
// Generic testbench: compile with -DDUT=matrixMult, matrixMult3, or matrixMult4
`ifndef DUT
`define DUT matrixMult4
`endif
module tb;
  reg clk = 0, start = 0, reset = 1;
  wire done;
  wire [10:0] clock_count;
  integer cycles = 0, i;
  reg running = 0;

  `DUT dut(.clk(clk), .start(start), .reset(reset), .done(done), .clock_count(clock_count));

  always #5 clk = ~clk;
  always @(posedge clk) if (running && !done) cycles = cycles + 1;

  initial begin
    #20 reset = 0;
    #20 start = 1; running = 1;
    #10 start = 0;
    wait (done == 1);
    #20;
    $display("Total cycles (start to done): %0d", cycles);
    for (i = 0; i < 64; i = i + 1) $display("C[%0d] = %0d", i, dut.RAMOUTPUT.mem[i]);
    $finish;
  end

  initial begin #200000 $display("TIMEOUT"); $finish; end
endmodule
