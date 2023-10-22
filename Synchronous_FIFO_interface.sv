interface intf();

   parameter DATA_WIDTH = 8;
   
   bit						clk;
   logic 					reset;
   logic 					wr_en, rd_en;
   logic [DATA_WIDTH-1:0] 	data_in;
   logic [DATA_WIDTH-1:0] 	data_out;
   logic 					full, empty;

endinterface
