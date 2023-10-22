class generator;

   transaction xtn_gen;
   mailbox #(transaction) gen2drv;
   
   int no_of_packets;	// Total No of Packets Intended to Send
   int packets_sent;	// Total No of Packets Sent Till Now
   int FIFO_DEPTH;		// To assign value from TB module. Used in Full & Empty testcase
   
   event gen_next;			// Triggers when SB is done and next packet is to be sent
   event gen_done;			// When generator has finished sending all no_of_packets
   
   function new(mailbox #(transaction) GEN2DRV);
       xtn_gen 		= new();
	   this.gen2drv = GEN2DRV;
   endfunction
  
  function void operation (bit [1:0] OPR);
    
    string OPER;
    case(xtn_gen.opr)
           2'b00 : OPER = "NOP";
           2'b01 : OPER = "Write Only";
           2'b10 : OPER = "Read Only";
           2'b11 : OPER = "Write-Read Simultaneously";
           default	: OPER = "NOP";
         endcase 
         $strobe("at time t=%0t, [%s] : Operation = %0d -> %s", $time, "GEN", xtn_gen.opr, OPER);    
    
  endfunction
  
  task send();
    xtn_gen.border;
    
    packets_sent++;
    $strobe("at time t=%0t, [GEN] : Iteration = %0d", $time, packets_sent);
    
    operation(xtn_gen.opr);
    gen2drv.put(xtn_gen);
    
    @(gen_next);
  endtask
   
   task run();
     
     /* This is a sample test - Refer to write the next ones
     
     repeat(no_of_packets) begin
       assert(xtn_gen.randomize())
         else $error("at time t=%0t, [GEN]: RANDOMIZATION FAILED", $time);
       
       
       xtn_gen.border;       
       packets_sent++; 
       $strobe("at time t=%0t, [GEN] : Iteration = %0d", $time, packets_sent);
       
       
       //xtn_gen.display_operation("GEN", xtn_gen.opr); // FIX ME
       operation(xtn_gen.opr);
       gen2drv.put(xtn_gen);
       @(gen_next);		// This will be triggered in SB
     end
     */
     
     //Test 1: Sanity Test - Write 15 pkts and Read 15 pkts
     repeat(15) begin
       assert(xtn_gen.randomize() with {opr == 2'b01;})
         //assert(xtn_gen.randomize())
         else $error("at time t=%0t, [GEN]: RANDOMIZATION FAILED", $time);
       
       send();
     end
     
     repeat(15) begin
       assert(xtn_gen.randomize() with {opr == 2'b10;})
         else $error("at time t=%0t, [GEN] : RANDOMIZATION FAILED", $time);
       
       send();
     end
     
     //FIFO is empty before running Test 2
     //Test 2: Write-Read Simultaneously
     //Adding 1 extra Write-Read pair because repeat(10) dint balance write-read. 1 read was still remaining.
     //NOTE: In case of empty condition, the output remains last Dout.
     
     assert(xtn_gen.randomize() with {opr == 2'b01;}) //Write
       send();
     repeat(10) begin
       assert(xtn_gen.randomize() with {opr == 2'b11;}) //Write-Read
         else $error("at time t=%0t, [GEN] : RANDOMIZATION FAILED", $time);
       
       send();
     end
     assert(xtn_gen.randomize() with {opr == 2'b10;}) //Read
       send();
       
     //FIFO is empty before running Test 3
     //Test 3: Verify Full Condition (Running FIFO_DEPTH+1 transactions)
     // FIFO_DEPTH=32, change in tb and RTL module
     // Only 32 were written, FIFO is full for inputs afterward
     repeat(FIFO_DEPTH+1) begin 
       assert(xtn_gen.randomize() with {opr == 2'b01;}) //Write
         else $error("at time t=%0t, [GEN] : RANDOMIZATION FAILED", $time);
       
       send();
     end
     
     //FIFO is full before running Test 4
     //Test 4: Verify Empty Condition (Running FIFO_DEPTH+1 transactions)
     //Only 32 were read, FIFO is empty for inputs afterward
     repeat(FIFO_DEPTH+1) begin
       assert(xtn_gen.randomize() with {opr == 2'b10;})
         else $error("at time t=%0t, [GEN] : RANDOMIZATION FAILED",$time);
       
       send();
     end
     
     
     ->(gen_done);
   endtask

endclass
