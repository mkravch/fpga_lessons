module uart
	(
		input clk_50_i,
		input rx_uart_i,
		output tx_uart_o
	);


    wire [7:0] rx_data,rx_valid;
    wire [7:0] tx_data,tx_valid;

    reg [7:0] data_rx_for_vio;

    uart_dbg m_uart_dbg 
    (
        .clk(clk_50_i), // input wire clk
        .probe0(rx_data), // input wire [7:0]  probe0  
        .probe1(rx_valid) // input wire [0:0]  probe1
    );

    uart_phy 
    #(
        .FREQ(50000000),
        .BAUDRATE(115200)
    )
    m_uart_phy
    (
        .clk_i(clk_50_i),
        .rst_i(0),
        .rate_i(0),
        .rxd_i(rx_uart_i),
        .txd_o(tx_uart_o),
        .nd_i(tx_valid),
        .data_i(tx_data),
        .rfd_o(),
        .vd_o(rx_valid),
        .data_o(rx_data)
    );
    
    
    
    always @ (posedge clk_50_i)
    begin
        
        if (rx_valid)
            data_rx_for_vio <= rx_data;
    
    end


endmodule