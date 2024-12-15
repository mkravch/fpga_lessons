module calc_sha_parser
	(

	   input clk_i,
	   input aresetn_i,
	   input [31:0] data_i,
	   input valid_i,
	   input [3:0] keep_i,
	   input last_i,
	   
	   output logic calc_start_o,
	   output logic writing_done_o,
	   output logic [31:0] data_o = 0,
	   
	   input calc_done_i,
	   output logic rst_o

	);


	logic [31:0] packet_data;
	logic [3:0] packet_keep;
	logic packet_valid;
	logic packet_last;
	logic packet_ready;

	packet_fifo m_packet_fifo
	 (
		.s_aclk(clk_i),                // input wire s_aclk
		.s_aresetn(aresetn_i),          // input wire s_aresetn
		.s_axis_tvalid(valid_i),  // input wire s_axis_tvalid
		.s_axis_tready(),  // output wire s_axis_tready
		.s_axis_tdata(data_i),    // input wire [31 : 0] s_axis_tdata
		.s_axis_tkeep(keep_i),    // input wire [3 : 0] s_axis_tkeep
		.s_axis_tlast(last_i),    // input wire s_axis_tlast

		.m_axis_tvalid(packet_valid),  // output wire m_axis_tvalid
		.m_axis_tready(1),  // input wire m_axis_tready packet_ready
		.m_axis_tdata(packet_data),    // output wire [31 : 0] m_axis_tdata
		.m_axis_tkeep(packet_keep),    // output wire [3 : 0] m_axis_tkeep
		.m_axis_tlast(packet_last)    // output wire m_axis_tlast
	);


    logic [1:0] state = 0;
    logic calc_start = 0;
    logic writing_done = 0;
    logic [4:0] cnt = 0;
    logic [31:0] sum_bits = 0;
    logic [31:0] d_packet_data = 0;
    logic [3:0] d_keep = 0;
    logic [3:0] keep_and_valid;
    logic d_valid;


    always @ (posedge clk_i)
    begin
    	d_packet_data <= packet_data;
        d_keep <= packet_keep;
        d_valid <= packet_valid;
        
        keep_and_valid[0] <= packet_keep[0] && packet_valid;
        keep_and_valid[1] <= packet_keep[1] && packet_valid;
        keep_and_valid[2] <= packet_keep[2] && packet_valid;
        keep_and_valid[3] <= packet_keep[3] && packet_valid;
    end


    always @ (posedge clk_i)
    begin

        case(state)
            2'd0:
            begin
            	
                writing_done_o <= 0;
                calc_start_o <= 0;
                cnt <= 0;
                if (packet_valid)
                begin
                    state <= 1;
                    sum_bits <= 0;
                    rst_o <= 1;
                end
                else
                    rst_o <= 0;
            
            end
            2'd1:
            begin
            	rst_o <= 1;
                calc_start_o <= 1;
                cnt <= cnt + 1;
                
                case (keep_and_valid)
                    4'h0:
                    begin
                    
                        state <= 2;
                        if (d_keep == 4'hf)
                            data_o <= 32'h8000_0000;
                        else
                            data_o <= 32'h0000_0000;
                    
                    end
                    4'h8:
                    begin
                        data_o[31:24] <= d_packet_data[31:24];
                        data_o[23:16] <= 8'h80;
                        data_o[15:0] <= 16'h00;    
                        
                        sum_bits <= sum_bits + 8;                     
                    
                    end
                    4'hC:
                    begin
                        data_o[31:16] <= d_packet_data[31:16];
                        data_o[15:8] <= 8'h80;
                        data_o[7:0] <= 8'h00;   
                        
                        sum_bits <= sum_bits + 16;
                                       
                    end
                    4'hE:
                    begin
                        data_o[31:8] <= d_packet_data[31:8];
                        data_o[7:0] <= 8'h80;
                        
                        sum_bits <= sum_bits + 24;
                        
                    end
                    4'hF:
                    begin
                        data_o <= d_packet_data;
                        
                        sum_bits <= sum_bits + 32;
                    end
                endcase
            
            end
            2'd2:
            begin
            
                cnt <= cnt + 1;
                
                if (cnt == 15)
                    begin
                        data_o <= sum_bits;
                        
                        state <= 3;
                    end
                else
                    data_o <= 0;
            
            
            end 
            2'd3:
            begin
            
                writing_done_o <= 1;
                
                if (calc_done_i)
                    state <= 0;
                    
            
            end
        endcase
    end



endmodule