`timescale 1ns / 1ps

module synchronous_fifo_temp_tb #(parameter FIFO_DEPTH=32, DATA_WIDTH=8);

	//input=reg output=wire
	bit CLK;
	reg RESET;
	reg WR_EN, RD_EN;
	reg [DATA_WIDTH-1:0] DATA_IN;
	wire [DATA_WIDTH-1:0] DATA_OUT;
	wire FULL, EMPTY;
	
	//Generate Clock
	always
		#5 CLK = !CLK;
		
	//Instantiate DUT
	synchronous_fifo DUT (.clk(CLK), .reset(RESET), .wr_en(WR_EN), .rd_en(RD_EN), .data_in(DATA_IN), .data_out(DATA_OUT), .full(FULL), .empty(EMPTY));
	
	task reset();
		RESET = 1'b1;
		@(posedge CLK);
		RESET = 1'b0;
	endtask
	
	task delay(int clock_cycles=1);
		repeat(clock_cycles)
			@(posedge CLK);
	endtask
	
	task write_only(bit [DATA_WIDTH-1:0] data_val=$random);
		RD_EN = 1'b0;
		WR_EN = 1'b1;
		DATA_IN = data_val;
		@(posedge CLK);
		WR_EN = 1'b0;
	endtask
	
	task read_only();
		RD_EN = 1'b1;
		WR_EN = 1'b0;
		@(posedge CLK);
		RD_EN = 1'b0;
	endtask
	
	task read_and_write(bit [DATA_WIDTH-1:0] data_val=$random);
		WR_EN = 1'b1;
		RD_EN = 1'b1;
		DATA_IN = data_val;
		@(posedge CLK);
		WR_EN = 1'b0;
		RD_EN = 1'b0;
	endtask
	
	initial begin
		$monitor("at time t=%0t, The value of WR_EN=%0b RD_EN=%0b DATA_IN=%0h DATA_OUT=%0h FULL=%0b EMPTY=%0b", $time, WR_EN, RD_EN, DATA_IN, DATA_OUT, FULL, EMPTY);
		
		WR_EN = 1'b0;
		RD_EN = 1'b0;
		DATA_IN = 'b0;
		
		reset();				// 1 clk cycle
		
		//Test1: Sanity Test - Write 15 cycles then Read 15 cycles
		repeat(15)
			write_only();
		repeat(15)
			read_only();		// 15+15 = 30 clk cycles
		
		//Test2: Write-Read Simultaneously
		delay();
		write_only();
		repeat(10)
			read_and_write();
		read_only();			// 1+1+10+1 = 13 clk cycles
		
		//Test3: Verify Full Condition
		delay();
		repeat(33)				// Only 32 were written, FIFO is full for inputs afterwards
			write_only();		// 1+33 = 34 clk cycles
		
		//Test4: Verify Empty Condition
		delay();
		repeat(32)				// Emptying the full FIFO
			read_only();		// 1+32 = 33 clk cycles
	end
	
	initial begin
		
		#((1+30+13+34+33 +5)*10) $finish;
	end

endmodule
