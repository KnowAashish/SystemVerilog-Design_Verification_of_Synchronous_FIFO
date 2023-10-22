class driver;

   transaction xtn_drv;
   mailbox #(transaction) drv2gen;
   
   virtual intf vif_drv; 
   
   function new(mailbox #(transaction) DRV2GEN);
      //xtn_drv = new;
	  
	  this.drv2gen = DRV2GEN;
   endfunction
   
   task reset();
      
	  vif_drv.reset 	<= 1'b1;
	  vif_drv.rd_en		<= 1'b0;
	  vif_drv.wr_en 	<= 1'b0;
	  vif_drv.data_in 	<=  'b0;
	  
	  @(posedge vif_drv.clk);
	  vif_drv.reset 	<= 1'b0;
	  
   endtask
   
   task run();
      
	  forever begin
        drv2gen.get(xtn_drv);
        //xtn_drv.display_operation("DRV", xtn_drv.opr);
	  
	  // NOP
	  if(xtn_drv.opr == 2'b00) begin
		 xtn_drv.wr_en			<= 1'b0;
		 xtn_drv.rd_en			<= 1'b0;
		 xtn_drv.data_in		<= 'bX; // FIXME
        xtn_drv.display_input("DRV", xtn_drv.opr, xtn_drv.wr_en, xtn_drv.rd_en, xtn_drv.data_in);
	  end
	  
	  // Write
	  else if(xtn_drv.opr == 2'b01) begin
		 xtn_drv.wr_en 			<= 1'b1;
		 xtn_drv.rd_en 			<= 1'b0;
		 xtn_drv.data_in 		<= $random; // FIXME
        xtn_drv.display_input("DRV", xtn_drv.opr, xtn_drv.wr_en, xtn_drv.rd_en, xtn_drv.data_in);
        //$strobe("at time t=%0t, [DRV] : Wr_En = %0b Rd_En = %0b Write Data = %0h", 4time, xtn_drv.wr_en, xtn_drv.rd_en, xtn_drv.data_in); // $display gave XX in 1st iteration
	  end
	  
	  // Read
	  else if(xtn_drv.opr == 2'b10) begin
		 xtn_drv.wr_en 			<= 1'b0;
		 xtn_drv.rd_en 			<= 1'b1;
        xtn_drv.display_input("DRV", xtn_drv.opr, xtn_drv.wr_en, xtn_drv.rd_en, xtn_drv.data_in);
	  end
	  
	  // Write-Read Simultaneously
	  else if(xtn_drv.opr == 2'b11) begin
		 xtn_drv.wr_en			<= 1'b1;
		 xtn_drv.rd_en			<= 1'b1;
		 xtn_drv.data_in		<= $random; // FIXME
        xtn_drv.display_input("DRV", xtn_drv.opr, xtn_drv.wr_en, xtn_drv.rd_en, xtn_drv.data_in);
	  end
	  
	  @(posedge vif_drv.clk);
      vif_drv.reset		<= 1'b0;	// Turn off reset during operation
	  vif_drv.wr_en 	<= xtn_drv.wr_en;
	  vif_drv.rd_en 	<= xtn_drv.rd_en;
	  vif_drv.data_in	<= xtn_drv.data_in;
	  
	  @(posedge vif_drv.clk);
	  vif_drv.wr_en 	<= 1'b0;
	  vif_drv.rd_en 	<= 1'b0;
	  
	  @(posedge vif_drv.clk);		// To simplify analysis of the waveform
	  
	  end
	  
   endtask
   
endclass
