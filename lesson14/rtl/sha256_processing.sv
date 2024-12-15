module sha256_processing
	(

		input axi_clk_i,
		input aresetn_i,
		input clk_200_mhz,

		input [31:0] ctrl_signals,
		input [31:0] string_i,
		input [31:0] repeat_i,
		
		output logic finish_repeat_o,
		output logic [255:0] hash_o
	);



     localparam NUM_MODULES = 8;
     
     wire rstn;
     
     xpm_cdc_array_single #(
     
       //Common module parameters
       .DEST_SYNC_FF   (4), // integer; range: 2-10
       .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
       .SRC_INPUT_REG  (0), // integer; 0=do not register input, 1=register input
       .WIDTH          (1)  // integer; range: 1-1024
     
     ) xpm_cdc_array_single_inst (
     
       .src_clk  (),  // optional; required when SRC_INPUT_REG = 1
       .src_in   (aresetn_i),
       .dest_clk (clk_200_mhz),
       .dest_out (rstn)
     
     );


    logic [31:0] ctrl_signals_sync,string_sync,repeat_sync;
    

    from_axi_to_rtl_fifo m_from_axi_to_rtl_fifo
    (
      .rst(~aresetn_i),        // input wire rst
      .wr_clk(axi_clk_i),  // input wire wr_clk
      .rd_clk(clk_200_mhz),  // input wire rd_clk
      .din({ctrl_signals,string_i,repeat_i}),        // input wire [95 : 0] din
      .wr_en(1),    // input wire wr_en
      .rd_en(1),    // input wire rd_en
      .dout({ctrl_signals_sync,string_sync,repeat_sync}),      // output wire [95 : 0] dout
      .full(),      // output wire full
      .empty()    // output wire empty
    );
    
    logic [255:0] hash_data [NUM_MODULES-1:0];
    logic [NUM_MODULES-1:0] hash_valid;
    
    logic [255:0] hash [NUM_MODULES-1:0];
    
    
    // sha_dbg m_sha_dbg
    // (
    //     .clk(axi_clk_i),
    //     .probe0(ctrl_signals), //32
    //     .probe1(string_i), //32
    //     .probe2(repeat_i), //32
    //     .probe3(finish_repeat_o), //1
    //     .probe4(hash_o) //256
    // );

	enum logic 
	{
		ST_IDLE,
		ST_PULSE

	} state_pulse = ST_IDLE;

    logic [31:0] slv_data;
    logic [3:0] slv_keep;
    logic slv_valid = 0 , slv_last = 0;
    
    logic [7:0] current_block;
    
	always @ (posedge clk_200_mhz)
	begin
		if (state_pulse == ST_IDLE)
			begin
				if (ctrl_signals_sync[31])
				begin
					slv_data <= string_sync;
					slv_keep <= ctrl_signals_sync[3:0];
					
					case(ctrl_signals_sync[7:4])
                        4'd0:current_block <= 8'b0000_0001;
                        4'd1:current_block <= 8'b0000_0010;
                        4'd2:current_block <= 8'b0000_0100;
                        4'd3:current_block <= 8'b0000_1000;
                        4'd4:current_block <= 8'b0001_0000;
                        4'd5:current_block <= 8'b0010_0000;
                        4'd6:current_block <= 8'b0100_0000;
                        4'd7:current_block <= 8'b1000_0000;
					endcase
					
					slv_valid <= 1;

					if (ctrl_signals_sync[30])
						slv_last <= 1;
					else
						slv_last <= 0;

					state_pulse <= ST_PULSE;
				end
			end
		else
			begin
				slv_valid <= 0;
				slv_last <= 0;

				if (ctrl_signals_sync[31] == 0)
					state_pulse <= ST_IDLE;

			end
	end

    logic [1:0] state_repeat = 0;
    
    logic [31:0] data_mux;
    logic [3:0] keep_mux;
    logic valid_mux = 0 , last_mux = 0;
    logic [2:0] cnt_256_by_32 = 0;
    logic [19:0] cnt_repeat = 0;
    logic write_to_fifo = 0;
    logic [255:0] shift_hash = 0;
    logic finish_repeat = 0;

    always @ (posedge clk_200_mhz)
    begin
        case(state_repeat)
            2'd0:
            begin
            
                data_mux <= slv_data;
                valid_mux <= slv_valid;
                keep_mux <= slv_keep;
                last_mux <= slv_last;
            
                if (slv_last)
                begin
                    state_repeat <= 1;
                end
                
                if (slv_valid)
                    finish_repeat <= 0;
            
            end
            2'd1:
            begin
            
                data_mux <= 0;
                valid_mux <= 0;
                keep_mux <= 0;
                last_mux <= 0;
            
                if (hash_valid)
                begin
                    write_to_fifo <= 1;
                    state_repeat <= 2'd2;
                    
//                    state_repeat <= 2'd0;
                    
                    shift_hash <= hash_data[0];
                end
            
            end
            2'd2:
            begin
                cnt_256_by_32 <= cnt_256_by_32 + 1;
                shift_hash <= shift_hash << 32;
                data_mux <= shift_hash[255:224];
                
//                shift_hash <= shift_hash >> 32;
//                data_mux <= shift_hash[31:0];
                
                valid_mux <= 1;
                keep_mux <= 4'hf;
                
                if (cnt_256_by_32 == 7)
                begin
                    last_mux <= 1;
                    
                    if (cnt_repeat == repeat_sync )
                        begin
                            state_repeat <= 0;
                            cnt_repeat <= 0;
                            finish_repeat <= 1;
                            write_to_fifo <= 1; 
                        end
                    else
                        begin
                            state_repeat <= 1;
                            cnt_repeat <= cnt_repeat + 1;
                        end
                end
                else
                    begin
                        last_mux <= 0;
                        write_to_fifo <= 0; 
                    end
            
            end
        endcase
    end


    genvar num_inst;
    generate
        for (num_inst=0;num_inst<NUM_MODULES;num_inst++)
        begin
    
             calc_sha m_calc_sha
             (
                 .clk(clk_200_mhz),
                 .aresetn_i(rstn),
                
                 .valid_i(valid_mux&current_block[num_inst]),
                 .data_i(data_mux),
                 .keep_i(keep_mux),
                 .last_i(last_mux),
        
                 .overflow_err(),
                 .Hash_Digest(hash_data[num_inst]),
                 .hash_valid_o(hash_valid[num_inst])
             );
         
         end
         
         always @ (posedge clk_200_mhz) if (hash_valid[num_inst]) hash[num_inst] <= hash_data[num_inst];
         
     
     endgenerate  
     


    
    logic [31:0] cnt_sha = 0;
    
    always @ (posedge clk_200_mhz)
    begin
    
        if (hash_valid[0])
            cnt_sha <= 0;
        else
            cnt_sha <= cnt_sha + 1;
    
    end
    
    from_rtl_to_axi_fifo m_from_rtl_to_axi_fifo
    (
      .rst(~aresetn_i),        // input wire rst
      .wr_clk(clk_200_mhz),  // input wire wr_clk
      .rd_clk(axi_clk_i),  // input wire rd_clk
      .din({hash[ctrl_signals_sync[7:4]],finish_repeat}),        // input wire [256 : 0] din
      .wr_en(write_to_fifo),    // input wire wr_en
      .rd_en(1),    // input wire rd_en
      .dout({hash_o,finish_repeat_o}),      // output wire [256 : 0] dout
      .full(),      // output wire full
      .empty()    // output wire empty
    );


endmodule