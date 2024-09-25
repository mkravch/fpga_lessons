module i2c_top
    (
    
        input clk_50_mhz_i,
        
        output i2c_ce_o,
        inout i2c_data_io,
        output i2c_clk_o

    );
    
    
    
    reg clk_200_khz = 0;
    reg [8:0] cnt = 0;

    
    always @ (posedge clk_50_mhz_i)
    begin
        if (cnt == 249)
            cnt <= 0;
        else
            cnt <= cnt + 1;
            
            
        if (cnt > 127)
            clk_200_khz <= 1;
        else
            clk_200_khz <= 0;
    
    end
    
    
    wire rst;
    wire wr_en;
    wire [7:0] wr_addr;
    wire [7:0] wr_data;
    
    wire rd_en;
    wire [7:0] rd_addr;
    wire rd_valid;
    wire [7:0] rd_data;
    
    test_vio m_test_vio
    (
        .clk(clk_50_mhz_i),
        .probe_out0(rst), //1
        .probe_out1(wr_en), //1
        .probe_out2(wr_addr), //8
        .probe_out3(wr_data), //8
        .probe_out4(rd_en), //1
        .probe_out5(rd_addr), //8
        .probe_in0(rd_valid), //1
        .probe_in1(rd_data) //8
    );
    
    
    reg state_wr = 0;
    reg wr_en_pulse = 0;
    
    always @ (posedge clk_200_khz)
    begin
    
        if (state_wr == 0)
            begin
            
                if (wr_en)
                begin
                    wr_en_pulse <= 1;
                    state_wr <= 1;
                
                end
            
            end
        else
            begin
            
                wr_en_pulse <= 0;
                if (wr_en == 0)
                    state_wr <= 0;
            
            end
    end
    
    
    reg state_rd = 0;
    reg rd_en_pulse = 0;
    
    always @ (posedge clk_200_khz)
    begin
    
        if (state_rd == 0)
            begin
            
                if (rd_en)
                begin
                    rd_en_pulse <= 1;
                    state_rd <= 1;
                
                end
            
            end
        else
            begin
            
                rd_en_pulse <= 0;
                if (rd_en == 0)
                    state_rd <= 0;
            
            end
    end
    
    
    i2c_phy m_i2c_phy
    (
    
        .clk_i(clk_200_khz),
        .rst_i(rst),
        
        .i2c_ce_o(i2c_ce_o),
        .i2c_data_io(i2c_data_io),
        .i2c_clk_o(i2c_clk_o),
        
        
        .wr_en_i(wr_en_pulse),
        .wr_addr_i(wr_addr),
        .wr_data_i(wr_data),
        
        
        .rd_en_i(rd_en_pulse),
        .rd_addr_i(rd_addr),
        .rd_valid_o(rd_valid),
        .rd_data_o(rd_data)
 
    );
    
    
    
    
    
endmodule
