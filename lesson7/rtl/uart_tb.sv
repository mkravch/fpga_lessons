module uart_tb();


   parameter PERIOD = 5;

    logic clk = 0;

   initial begin
      clk = 1'b0;
      #(PERIOD/2);
      forever
         #(PERIOD/2) clk = ~clk;
   end


    logic valid_i = 0;
    logic [7:0] data_i = 0;
    
    logic rst = 1;
    
    initial
    begin
    
        repeat(20) @ (posedge clk);
        rst <= 0;
        repeat(10) @ (posedge clk);
        valid_i <= 1;
        data_i <= 8'h4b;
        repeat(1) @ (posedge clk);
        valid_i <= 0;
    
    end

    logic txd;

    uart_phy 
    #(
        .FREQ(50000000),
        .BAUDRATE(115200)
    )
    m_uart_phy
    (
        .clk_i(clk),
        .rst_i(rst),
        .rate_i(0),
        .rxd_i(txd),
        .txd_o(txd),
        .nd_i(valid_i),
        .data_i(data_i),
        .rfd_o(),
        .vd_o(),
        .data_o()
    );



endmodule