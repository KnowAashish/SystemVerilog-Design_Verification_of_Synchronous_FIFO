class monitor;

   transaction xtn_mon;
   mailbox #(transaction) mon2sb;
   
   virtual intf vif_mon;
   
  function new (mailbox #(transaction) MON2SB);
      this.mon2sb = MON2SB;
   endfunction
   
   task run();
      
	  xtn_mon = new();
	  
      forever begin
		repeat(2)
		   @(posedge vif_mon.clk);
        
		xtn_mon.wr_en 		= vif_mon.wr_en;
		xtn_mon.rd_en 		= vif_mon.rd_en;
		xtn_mon.data_in		= vif_mon.data_in;
		xtn_mon.full		= vif_mon.full;
		xtn_mon.empty		= vif_mon.empty;
		
        xtn_mon.opr			= {xtn_mon.wr_en,xtn_mon.rd_en};
        
		@(posedge vif_mon.clk);			// To have equal delay between driver and monitor (3clk cycles here)
		xtn_mon.data_out 	= vif_mon.data_out;
		
        $display("at time t=%0t, [MON] : Write Data from DUT = 0x%0h", $time, xtn_mon.data_out);
		mon2sb.put(xtn_mon);
        xtn_mon.display_output("MON", xtn_mon.opr, xtn_mon.wr_en, xtn_mon.rd_en,  xtn_mon.full, xtn_mon.empty, xtn_mon.data_in, xtn_mon.data_out);
      end
	  
   endtask
   
endclass
