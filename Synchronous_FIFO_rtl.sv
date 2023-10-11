module synchronous_fifo #(parameter FIFO_DEPTH=32, DATA_WIDTH=8)
	(input clk,
	input reset,
	input wr_en, rd_en,
	input [DATA_WIDTH-1:0] data_in,
	output logic [DATA_WIDTH-1:0] data_out,
	output logic full, empty);
	
	logic [DATA_WIDTH-1:0] FIFO [FIFO_DEPTH-1:0];
	
	logic [$clog2(FIFO_DEPTH)-1:0] wr_ptr, rd_ptr;
	logic [$clog2(FIFO_DEPTH):0] fifo_count;		// To count till 32
	logic [DATA_WIDTH-1:0] out;
	
	always@(posedge clk) begin
		if(reset) begin
			out <= 0;
			wr_ptr <= 0;
			rd_ptr <= 0;
			fifo_count <= 0;
			FIFO <= '{default: '0};
		end
		
		//Read and Write Simultaneously (No conflicts), i.e. if either read or write is not possible then this condition will fail
		else if ((wr_en && !full) && (rd_en && !empty)) begin
			FIFO[wr_ptr] <= data_in;
			wr_ptr = wr_ptr+1;
			
			out <= FIFO[rd_ptr];
			rd_ptr = rd_ptr+1;
			
			fifo_count <= fifo_count;
			
		end
		//Write Only
		else if (wr_en && !full) begin
			FIFO[wr_ptr] <= data_in;
			wr_ptr = wr_ptr+1;
			fifo_count <= fifo_count + 1;
		end
		
		//Read Only
		else if (rd_en && !empty) begin
			out <= FIFO[rd_ptr];
			rd_ptr = rd_ptr+1;
			fifo_count <= fifo_count - 1;
		end
	end
	
	assign full = (fifo_count == FIFO_DEPTH) ? 1:0;
	assign empty = (fifo_count == 0) ? 1:0;
	assign data_out = out;
	
endmodule
