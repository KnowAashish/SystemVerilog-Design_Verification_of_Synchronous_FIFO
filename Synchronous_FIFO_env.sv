class environment;

   generator	gen;
   driver		drv;
  
   monitor 		mon;
   scoreboard 	sb;
   
   mailbox #(transaction) gen2drv;
   mailbox #(transaction) mon2sb;
   
   event next;
   
   virtual intf vif_env;
   
   function new (virtual intf VIF_ENV);
   
      // Connect GEN, DRV, MON, SB mailbox
      gen2drv	= new;
      gen		= new(gen2drv);
	  drv		= new(gen2drv);
	  
	  mon2sb	= new;
	  mon 		= new(mon2sb);
	  sb 		= new(mon2sb);
	  
	  //Connect Events
	  gen.gen_next 	= this.next;
	  sb.sb_next	= this.next;
	  
	  // Connect DRV, MON virtual interface
	  this.vif_env 	= VIF_ENV;
	  drv.vif_drv	= this.vif_env;
	  mon.vif_mon	= this.vif_env;
	  
   endfunction
   
   task pre_test();
      drv.reset();
   endtask
   
   task test();
      fork
	     gen.run();
		 drv.run();
		 mon.run();
		 sb.run();
	  join_any
   endtask
   
   task post_test();
      wait(gen.gen_done.triggered);
	//  $display("---------------------------------------------");
	  $display("at time t=%0t, [ENV] : Error Count = %0d", $time, sb.error);
      $display("---------------------------------------------------------------");
	  
	  $finish;
   endtask
   
   task run();
      pre_test();
	  test();
	  post_test();
   endtask
   
endclass
