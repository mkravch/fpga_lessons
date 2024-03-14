`timescale 1 ns/1 ps
module uart_phy_rx
    (
        input clk_i,
        input rst_i,
        input tick_i,
        input rxd_i,
        output reg vd_o,
        output reg [7:0] data_o
    );
    
    localparam [1:0] ST_IDLE = 2'b00;
    localparam [1:0] ST_RECV = 2'b01;
    localparam [1:0] ST_NEXT = 2'b10;
    localparam [1:0] ST_END = 2'b11;
    
    localparam [4:0] LEVEL = 5'd8;
    
    reg [2:0] rxd;
    reg rxd_sync;
    reg [9:0] rxd_buf;
    reg [3:0] rxd_buf_cnt;
    reg [4:0] rxd_buf_data;
    reg [3:0] tick_cnt;
    reg [1:0] state;
    wire rxd_buf_bit;
    
    assign rxd_buf_bit = ( rxd_buf_data < LEVEL )? 1'b0 : 1'b1;
    
    /*
     * Synchronize incoming data
     */
    always @ ( posedge clk_i )
        begin
            if ( rst_i )
                begin
                    rxd <= 3'b111;
                    rxd_sync <= 1'b1;
                end
            else
                begin
                    rxd <= {rxd[1:0], rxd_i};
                    rxd_sync <= ( rxd[2] )? ( rxd[1] | rxd[0] ) : ( rxd[1] & rxd[0] );
                end
        end
    
    /*
     * Receive controller
     */
    always @ ( posedge clk_i )
        begin
            if ( rst_i )
                begin
                    state <= ST_IDLE;
                    vd_o <= 1'b0;
                    tick_cnt <= 4'd0;
                    rxd_buf_cnt <= 4'd0;
                end
            else
                begin
                    case( state ) /* synthesis full_case */
                        ST_IDLE :
                            begin
                                vd_o <= 1'b0;
                                if ( tick_i & !rxd_sync )
                                    begin
                                        state <= ST_RECV;
                                        tick_cnt <= 4'd1;
                                        rxd_buf_cnt <= 4'd0;
                                        rxd_buf_data <= 5'd0;
                                    end
                            end
                            
                       ST_RECV :
                           begin
                               if ( tick_i )
                                   begin
                                       if ( tick_cnt == 4'd15 )
                                           begin
                                               state <= ST_NEXT;
                                           end
                                       tick_cnt <= tick_cnt + 4'd1;
                                       rxd_buf_data <= rxd_buf_data + {4'd0, rxd_sync};
                                   end
                           end
                           
                       ST_NEXT :
                           begin
                               state <= ( rxd_buf_cnt < 4'd9 )? ST_RECV : ST_END;
                               rxd_buf_cnt <= rxd_buf_cnt + 4'd1;
                               rxd_buf_data <= 5'd0;
                               rxd_buf <= { rxd_buf_bit, rxd_buf[9:1] };
                           end
                           
                       ST_END :
                           begin
                               state <= ST_IDLE;
                               vd_o <= rxd_buf[9] & !rxd_buf[0];
                               data_o <= rxd_buf[8:1];
                           end
                    endcase
                end
        end
    
endmodule /* uart_phy_rx */
