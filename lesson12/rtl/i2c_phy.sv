module i2c_phy
    (
    
        input clk_i,
        input rst_i,
        
        output logic i2c_ce_o,
        inout i2c_data_io,
        output logic i2c_clk_o,
        
        
        input wr_en_i,
        input [7:0] wr_addr_i,
        input [7:0] wr_data_i,
        
        input rd_en_i,
        input [7:0] rd_addr_i,
        output logic rd_valid_o,
        output logic [7:0] rd_data_o = 0

    );
    
    
    enum logic [1:0]
    {
    
        ST_IDLE,
        ST_TX,
        ST_TX_ADDR,
        ST_RX_DATA
    
    }
    state = ST_IDLE;
    
    
    localparam IO_WRITE = 0;
    localparam IO_READ = 1;
    
    logic parity = 0;
    logic dir = 0;
    logic wr_bit = 0;
    logic [7:0] data_buf = 0;
    logic [4:0] cnt = 0;
    logic rd_bit;
    logic rd_valid = 0;
    
    
       IOBUF m_iobuf
       (
           .O(rd_bit),     // Buffer output
           .IO(i2c_data_io),   // Buffer inout port (connect directly to top-level port)
           .I(wr_bit),     // Buffer input
           .T(dir)      // 3-state enable input, high=input, low=output
        );
    
    
    always @ (posedge clk_i)
    begin
    
        rd_valid_o <= rd_valid;
        
//        if (rd_valid)
        rd_data_o <= data_buf;
    
    end
    
    always @ (posedge clk_i)
    begin
    
    
        if (rst_i)
            begin
            
                state <= ST_IDLE;
            
            end
        else
            begin
            
                case(state)
                ST_IDLE:
                begin
                
                    i2c_ce_o <= 0;
                    i2c_clk_o <= 0;
                    cnt <= 0;
                    parity <= 0;
                    rd_valid <= 0;
                    
                    
                
                    if (wr_en_i)
                    begin
                        dir <= IO_WRITE;
                        data_buf <= wr_addr_i;
                        state <= ST_TX;
                    
                    end
                    else if (rd_en_i)
                    begin
                        dir <= IO_WRITE;
                        data_buf <= rd_addr_i;
                        state <= ST_TX_ADDR;                   
                    
                    end
                
                
                end
                ST_TX:
                begin
                
                    i2c_ce_o <= 1;
                    i2c_clk_o <= parity;
                    
                    parity <= ~parity;
                    
//                    wr_bit <= data_buf[7];
                    
                    wr_bit <= data_buf[0];
                    
                    if (parity)
                    begin
                        cnt <= cnt + 1;
                        
                        if (cnt == 7)
                            data_buf <= wr_data_i;
                        else
//                            data_buf <= {data_buf[6:0],1'b0};
                            data_buf <= {1'b0,data_buf[7:1]};
                                        
                    end
                    
                    if (cnt == 16)
                        state <= ST_IDLE;
                
                
                end
                ST_TX_ADDR:
                begin
                
                    i2c_ce_o <= 1;
                    i2c_clk_o <= parity;
                    
                    parity <= ~parity;
                    
//                    wr_bit <= data_buf[7];
                    
                    wr_bit <= data_buf[0];
                    
                    if (parity)
                    begin
                    
//                        data_buf <= {data_buf[6:0],1'b0};

                        data_buf <= {1'b0,data_buf[7:1]};
                    
                        if (cnt == 7)
                            begin
                                cnt <= 0;
                                state <= ST_RX_DATA;
                            end
                        else
                            cnt <= cnt + 1;
                                   
                    end
                end    
                ST_RX_DATA:
                begin
                    dir <= IO_READ;
                    i2c_ce_o <= 1;
                    i2c_clk_o <= parity;
                    
                    parity <= ~parity;
                    
                    
                    if (parity)
                    begin
                        cnt <= cnt + 1;
                        //data_buf <= {data_buf[6:0],rd_bit};
                        
                        data_buf <= {rd_bit,data_buf[7:1]};
                        
                    end
                    
                    if (cnt == 8)
                    begin
                    
                        state <= ST_IDLE;
                        rd_valid <= 1;
                    
                    end
                
                end         
                    
                
                endcase
            
            
            end
    
    end
    
    
    
    
    
endmodule
