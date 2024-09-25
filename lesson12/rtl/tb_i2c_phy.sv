module tb_i2c_phy();



   parameter PERIOD = 5;
   
   logic clk = 0;

   initial begin
      clk = 1'b0;
      #(PERIOD/2);
      forever
         #(PERIOD/2) clk = ~clk;
   end
   
   logic rst = 0;
   
   initial
   begin
   
        rst <= 1;
        repeat (10) @ (posedge clk);
        rst <= 0;
   
   end
   
   
   logic wr_en = 0;
   logic [7:0] wr_addr;
   logic [7:0] wr_data;
   
   logic rd_en = 0;
   logic [7:0] rd_addr = 0;
   
   initial
   begin
   
   
        wr_en <= 0;
        repeat (50) @ (posedge clk);
        wr_en <= 1;
        wr_addr <= 8'b1010_0101;
        wr_data <= 8'b1000_0101;
        @ (posedge clk);
        wr_en <= 0;
        repeat (50) @ (posedge clk);
        wr_en <= 1;
        wr_addr <= 8'b1010_0101;
        wr_data <= 8'b1000_0101;
        @ (posedge clk);
        wr_en <= 0;
        
        
        repeat (50) @ (posedge clk);
        rd_en <= 1;
        rd_addr <= 8'b1010_0101;
        @ (posedge clk);
        rd_en <= 0;
        
        repeat (50) @ (posedge clk);
        rd_en <= 1;
        rd_addr <= 8'b1010_0101;
        @ (posedge clk);
        rd_en <= 0;
        
        
   
   end
   
   
   i2c_phy m_i2c_phy
   (
   
       .clk_i(clk),
       .rst_i(rst),
       
       .i2c_ce_o(),
       .i2c_data_io(),
       .i2c_clk_o(),
       
       
       .wr_en_i(wr_en),
       .wr_addr_i(wr_addr),
       .wr_data_i(wr_data),
       
       
       .rd_en_i(rd_en),
       .rd_addr_i(rd_addr),
       .rd_valid_o(),
       .rd_data_o()

   );



endmodule