class scoreboard;
  
   transaction xtn_sb;
   mailbox #(transaction) sb2mon;
   
   event sb_next;
   
   parameter DATA_WIDTH = 8;
   bit [DATA_WIDTH-1:0] din [$];		// Queue to store and read data
   bit [DATA_WIDTH-1:0] temp;
   
   int error;
   
   function new (mailbox #(transaction) SB2MON);
      this.sb2mon = SB2MON;
   endfunction
   
   task run();
     
     forever begin
       sb2mon.get(xtn_sb);
       xtn_sb.display_operation("SB", xtn_sb.opr);
       
       // NOP
       if (xtn_sb.wr_en == 2'b00 && xtn_sb.rd_en == 2'b00) begin
         //$display("at time t=%0t, [SB]  : NO OPERATION", $time);         
         xtn_sb.border;
       end
       
       // Write-Read Simultaneously
       else if((xtn_sb.wr_en && !xtn_sb.full) && (xtn_sb.rd_en && !xtn_sb.empty)) begin
         //$display("at time t=%0t, [SB]  : WRITE-READ SIMUL", $time);
         
         din.push_front(xtn_sb.data_in);
         $display("at time t=%0t, [SB]  : Data pushed in Queue = 0x%0h", $time, xtn_sb.data_in);
         
         temp = din.pop_back;
         if(xtn_sb.data_out == temp)
           $display("at time t=%0t, [SB]  : DATA MATCHED", $time);
         else begin
           $display("at time t=%0t, [SB]  : DATA MISMATCHED", $time);
           error++;
         end
         
         xtn_sb.border;
       end
       
       // Write Only
       else if(xtn_sb.wr_en == 1'b1) begin
         //$display("at time t=%0t, [SB]  : WRITE ONLY", $time);
         
         if(xtn_sb.full == 1'b0) begin
           din.push_front(xtn_sb.data_in);
           $display("at time t=%0t, [SB]  : Data pushed in Queue = 0x%0h", $time, xtn_sb.data_in);
         end
         else
           $display("at time t=%0t, [SB]  : Queue is Full", $time);
         
         xtn_sb.border;
       end
       
       
       // Read Only
       
       else if(xtn_sb.rd_en == 1'b1) begin
         //$display("at time t=%0t, [SB]  : READ ONLY", $time);
         
         if(xtn_sb.empty == 1'b0) begin
           temp = din.pop_back;
           
           if(xtn_sb.data_out == temp)
             $display("at time t=%0t, [SB]  : DATA MATCHED", $time);
           else begin
             $display("at time t=%0t, [SB]  : DATA MISMATCHED", $time);
             error++;
           end
           
         end
         else
           $display("at time t=%0t, [SB]  : Queue is Empty", $time);
         
         xtn_sb.border;
         
       end
       
       ->(sb_next);	// Notifies generator (via @(gen_next);) to send next packet through next repeat loop
     end
        
   endtask
  
endclass
