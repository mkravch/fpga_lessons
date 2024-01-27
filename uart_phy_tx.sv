`timescale 1 ns/1 ps
module uart_phy_tx(
    input rst_i,
    input clk_i,
    input tick_i,
    input nd_i,
    input [7:0] data_i,
    output rfd_o,
    output txd_o
    );
    
    localparam [0:0] ST_IDLE = 1'b0;
    localparam [0:0] ST_TX = 1'b1;
    
    reg [7:0] tx_data;
    reg tx_data_exist;
    reg [9:0] tx_buf;
    reg [3:0] tx_buf_cnt;
    reg [3:0] tick_cnt;
    reg state;
        
    assign rfd_o = !( nd_i | tx_data_exist );
    assign txd_o = tx_buf[0];
    
	
    always @ ( posedge clk_i )
        begin
            if ( rst_i )
                begin
                    tx_data_exist <= 1'b0;
                    state <= ST_IDLE;
                end
            else
                begin
                    case( state )
                        ST_IDLE:
                            begin
                                tick_cnt <= 4'd0;
                                tx_buf_cnt <= 4'd0;
                                tx_buf <= ( tick_i & tx_data_exist )? {1'b1, tx_data, 1'b0}: {10{1'b1}};
                                state <= ( tick_i & tx_data_exist )? ST_TX : ST_IDLE;
                                if ( nd_i )
                                    begin
                                        tx_data <= data_i;
                                        tx_data_exist <= 1'b1;
                                    end
                            end
                            
                         ST_TX:
                             begin   
                                 state <= ( tx_buf_cnt == 4'd10 )? ST_IDLE : ST_TX;
                                 if ( tick_i )
                                     begin
                                         tick_cnt <= tick_cnt + 4'd1;
										 
                                         if ( tick_cnt == 4'd15 )
                                             begin
                                                 tx_buf_cnt <= tx_buf_cnt + 4'd1;
                                                 tx_buf <= {1'b1, tx_buf[9:1]};
                                             end
                                     end
                                 if ( tx_buf_cnt == 4'd10 )
                                     begin
                                         tx_data_exist <= 1'b0;
                                     end
                             end    
                            
                    endcase
                end
        end
    
endmodule /* uart_phy_tx */

