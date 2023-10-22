`timescale 1ns / 1ns

`include "Synchronous_FIFO_interface.sv"
`include "Synchronous_FIFO_package.sv"

module tb ();//#(parameter DATA_WIDTH=8);
  
  //parameter DATA_WIDTH = 8;
   import Synchronous_FIFO_package::*;
   
   intf vif_tb();
   
   environment env;
   
   // Generate Clock
   always
      #5 vif_tb.clk = !vif_tb.clk;
	  
   // Instantiate DUT
   synchronous_fifo DUT (vif_tb.clk, vif_tb.reset, vif_tb.wr_en, vif_tb.rd_en, vif_tb.data_in, vif_tb.data_out, vif_tb.full, vif_tb.empty);
   
   initial begin
      env = new(vif_tb);
	  env.gen.no_of_packets = 4;
      env.gen.FIFO_DEPTH = 32;	// Same as mentioned in RTL
	  env.run();
   end
   
   initial begin
     $dumpfile("dump.vcd");
	 $dumpvars;
   end
   
endmodule
