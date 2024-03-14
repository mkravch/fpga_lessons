module uart_phy 
    #(
        parameter FREQ = 100000000,
        parameter BAUDRATE = 921600
    )
    (
        input clk_i,
        input rst_i,
        input [1:0] rate_i,
        input rxd_i,
        output txd_o,
        input nd_i,
        input [7:0] data_i,
        output rfd_o,
        output vd_o,
        output [7:0] data_o
    );
    
    wire tick;
    
    uart_phy_tick 
    #(
        .FREQ(FREQ),
        .BAUDRATE(BAUDRATE)
    ) 
    m_tick
    (
        .rst_i(rst_i),
        .clk_i(clk_i),
        .rate_i(rate_i),
        .tick_o(tick)
    );
    
    uart_phy_rx m_rx
    (
        .rst_i(rst_i),
        .clk_i(clk_i),
        .tick_i(tick),
        .rxd_i(rxd_i),
        .vd_o(vd_o),
        .data_o(data_o)
    );
    
    uart_phy_tx m_tx
    (
        .rst_i(rst_i),
        .clk_i(clk_i),
        .tick_i(tick),
        .nd_i(nd_i),
        .data_i(data_i),
        .rfd_o(rfd_o),
        .txd_o(txd_o)
    );
       
endmodule /* uart_phy */

