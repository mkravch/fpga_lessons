`timescale 1 ns/1 ps
module uart_phy_tick 
    #(
        parameter FREQ = 100000000,
        parameter BAUDRATE = 921600
    )
    (
        input clk_i,    
        input rst_i,
        input [1:0] rate_i,
        output reg tick_o
    );
    
    localparam real TICK_INC_REAL_1 = ( ( 4294967296.0 * 16.0 * BAUDRATE ) / ( FREQ ) );
    localparam real TICK_INC_REAL_2 = ( ( 4294967296.0 * 8.0 * BAUDRATE ) / ( FREQ ) );
    localparam real TICK_INC_REAL_3 = ( ( 4294967296.0 * 4.0 * BAUDRATE ) / ( FREQ ) );
    localparam real TICK_INC_REAL_4 = ( ( 4294967296.0 * 2.0 * BAUDRATE ) / ( FREQ ) );
    
    localparam [32:0] TICK_INC_INT_1 = TICK_INC_REAL_1;
    localparam [32:0] TICK_INC_INT_2 = TICK_INC_REAL_2;
    localparam [32:0] TICK_INC_INT_3 = TICK_INC_REAL_3;
    localparam [32:0] TICK_INC_INT_4 = TICK_INC_REAL_4;
    
    reg [32:0] tick_cnt /* synthesis syn_keep = 1 */;
    reg [32:0] tick_inc;
    
    always @ ( posedge clk_i )
        begin
            if ( rst_i )
                begin
                    tick_cnt <= 33'd0;
                end
            else
                begin
                    if ( tick_cnt[32] )
                        begin
                            tick_cnt <= {1'b0, tick_cnt[31:0]} + tick_inc;
                        end
                    else
                        begin
                            tick_cnt <= tick_cnt + tick_inc;
                        end
                end
        end    
        
    always @ ( posedge clk_i )
        begin
            tick_o <= tick_cnt[32];
            case( rate_i ) /* synthesis full_case */
                2'd0 : tick_inc <= TICK_INC_INT_1;
                2'd1 : tick_inc <= TICK_INC_INT_2;
                2'd2 : tick_inc <= TICK_INC_INT_3;
                2'd3 : tick_inc <= TICK_INC_INT_4;
            endcase
        end
    
endmodule /* uart_phy_tick */

