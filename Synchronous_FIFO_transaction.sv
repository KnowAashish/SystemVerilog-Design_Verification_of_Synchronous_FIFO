class transaction;

   parameter DATA_WIDTH = 8;
  
   // Define Control Signals, Global Signals will be defined in TB top
   randc bit [1:0] 			opr;
   logic 					wr_en, rd_en;
   logic [DATA_WIDTH-1:0]	data_in;
   logic [DATA_WIDTH-1:0] 	data_out;
   logic 					full, empty;
   
   // No deep copy code because we are doing in-order execution of our code
    string OPER;
  
  function void display_operation(string TAG = "XTN", bit[1:0] OPR = 2'b00);
    string OPER;
    case(OPR)
      2'b00 : OPER = "NOP";
      2'b01 : OPER = "Write Only";
      2'b10 : OPER = "Read Only";
      2'b11 : OPER = "Write-Read Simultaneously";
      default	: OPER = "NOP";
    endcase 
    //$display("at time t=%0t, [%s] : Operation = %0d -> %s", $time, TAG, OPR, OPER);
    $strobe("at time t=%0t, [%s] : Operation = %0d -> %s", $time, TAG, OPR, OPER);
   endfunction
   
   function void display_input(string TAG, bit[1:0] OPR, bit WR_EN, RD_EN, bit [DATA_WIDTH-1:0] DATA_IN);
    string OPER;
    case(OPR)
      2'b00 : OPER = "NOP";
      2'b01 : OPER = "Write Only";
      2'b10 : OPER = "Read Only";
      2'b11 : OPER = "Write-Read Simultaneously";
      default	: OPER = "NOP";
    endcase
     //$display("at time t=%0t, [%s] : Operation = %0d -> %s \n\t Wr_En = %0b Rd_En = %0b Data_In = 0x%0h", $time, TAG, OPR, OPER, WR_EN, RD_EN, DATA_IN);
     $strobe("at time t=%0t, [%s] : Operation = %0d -> %s \n\t Wr_En = %0b Rd_En = %0b Data_In = 0x%0h", $time, TAG, OPR, OPER, WR_EN, RD_EN, DATA_IN);
   endfunction
   
      function void display_output(string TAG, bit[1:0] OPR, bit WR_EN, RD_EN, FULL, EMPTY, bit [DATA_WIDTH-1:0] DATA_IN, DATA_OUT);
    string OPER;
    case(OPR)
      2'b00 : OPER = "NOP";
      2'b01 : OPER = "Write Only";
      2'b10 : OPER = "Read Only";
      2'b11 : OPER = "Write-Read Simultaneously";
      default	: OPER = "NOP";
    endcase
        $strobe("at time t=%0t, [%s] : Operation = %0d -> %s : Wr_En = %0b Rd_En = %0b Data_In = 0x%0h Data_Out = 0x%0h Full = %0b Empty = %0b", $time, TAG, OPR, OPER, WR_EN, RD_EN, DATA_IN, DATA_OUT, FULL, EMPTY);
   endfunction
  
  function void border();
    $display("---------------------------------------------------------------");
  endfunction
endclass
