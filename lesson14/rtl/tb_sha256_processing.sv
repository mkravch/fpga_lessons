module tb_sha256_processing();

   parameter PERIOD = 5;
   
   logic clk = 0;

   initial begin
      clk = 1'b0;
      #(PERIOD/2);
      forever
         #(PERIOD/2) clk = ~clk;
   end
   
   logic rst = 0;
   
   logic valid = 0;
   logic [7:0] data = 0;
   logic stop = 0;
   
   logic [31:0] slv_reg0 = 0,slv_reg1 , slv_reg2 = 0;
   
   logic aresetn = 0;
   
   
   task transmit
        (
            input [31:0] string_i,
            input [3:0] keep_i,
            input is_last
            
        );
   
    begin
            
            slv_reg1 <= string_i;
            slv_reg2 <= 9;

            repeat(20) @ (posedge clk);
            slv_reg0[31] <= 1;
            slv_reg0[30] <= is_last;
            
            slv_reg0[3:0] <= keep_i[3:0];
            
            repeat(20) @ (posedge clk);
            
            slv_reg0[31] <= 0;
            slv_reg0[30] <= 0;
    
    
    end
   
   
   
   endtask
   
   
   initial
   begin
   
   
        repeat(20) @ (posedge clk);
        aresetn <= 0;
        repeat(20) @ (posedge clk);
        aresetn <= 1;
        
        repeat(20) @ (posedge clk);
        
//        transmit("abcd",4'b1111,0);
//        transmit("efgh",4'b1111,1);
     
//        repeat(200) @ (posedge clk);
        

        
        transmit("abc0",4'b1110,1);
        
        repeat(400) @ (posedge clk);
        
        transmit("abc0",4'b1110,1);


//          transmit("ba78",4'b1111,0);
//          transmit("16bf",4'b1111,0);
//          transmit("8f01",4'b1111,0);
//          transmit("cfea",4'b1111,0);
//          transmit("4141",4'b1111,0);
//          transmit("40de",4'b1111,0);
//          transmit("5dae",4'b1111,0);
//          transmit("2223",4'b1111,0);
//          transmit("b003",4'b1111,0);
//          transmit("61a3",4'b1111,0);
//          transmit("9617",4'b1111,0);
//          transmit("7a9c",4'b1111,0);
//          transmit("b410",4'b1111,0);
//          transmit("ff61",4'b1111,0);
//          transmit("f200",4'b1111,0);
//          transmit("15ad",4'b1111,1);
        
//        repeat(200) @ (posedge clk);
        
//        transmit("abcd",4'b1111,0);
//        transmit("efgh",4'b1111,0);
//        transmit("ij00",4'b1100,1);
        
        

   end
   
   
    logic clk_200_mhz;
   
    clk_wiz_0 m_clk_wiz_0
    (
     .clk_in1(clk),
     .clk_out1(clk_200_mhz)
     
    );   

   sha256_processing m_sha256_processing
	(
		.axi_clk_i(clk),
		.aresetn_i(aresetn),
		.clk_200_mhz(clk_200_mhz),
		.ctrl_signals(slv_reg0),
		.string_i(slv_reg1),
		.repeat_i(slv_reg2),
		.finish_repeat_o(),
		.hash_o()
	);
   






endmodule