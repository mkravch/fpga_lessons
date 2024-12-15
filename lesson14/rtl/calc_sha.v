module calc_sha
    (
        input clk,
        input aresetn_i,
        
        input valid_i,
        input [31:0] data_i,
        input [3:0] keep_i,
        input last_i,
        
        output overflow_err,
        output [255:0] Hash_Digest,
        output hash_valid_o
    );
	 
	 wire flag_0_15,padding_done;
	 wire [6:0] counter_iteration;
	 wire [31:0] data_in_padd;
	 wire [31:0] a_out,b_out,c_out,d_out,e_out,f_out,g_out,h_out;
	 wire rst;
	 wire [31:0] const_plus_word;
	 wire valid;
	 
	 calc_sha_parser m_calc_sha_parser
	 (
	   .clk_i(clk),
	   .aresetn_i(aresetn_i),
	   .data_i(data_i),
	   .valid_i(valid_i),
	   .keep_i(keep_i),
	   .last_i(last_i),
	   
	   .calc_start_o(padding_done),
	   .writing_done_o(flag_0_15),
	   .data_o(data_in_padd),
	   
	   .calc_done_i(hash_valid_o),
	   .rst_o(rst)
	 
	 );
	 
	 
	 
     calc_sha_scheduler m_calc_sha_scheduler
     (
        .clk(clk),
        .rst(rst),
        .flag_0_15(flag_0_15),
        .padding_done(padding_done),
        .data_in(data_in_padd),
        .const_plus_word_o(const_plus_word),
        .iteration_o(counter_iteration),
        .valid_o(valid)
     );

     
	 calc_sha_iterations m_calc_sha_iterations
	 (
	   .clk(clk),
	   .rst(rst),
	   .const_plus_word_i(const_plus_word),
	   .counter_iteration(counter_iteration),
	   .padding_done(valid),
	   .a_out(a_out),
	   .b_out(b_out),
	   .c_out(c_out),
	   .d_out(d_out),
	   .e_out(e_out),
	   .f_out(f_out),
	   .g_out(g_out),
	   .h_out(h_out)
	 );
	 
	 calc_sha_digest  m_calc_sha_digest
	 (
	   .clk(clk),
	   .rst(rst),
	   .counter_iteration(counter_iteration),
	   .a_in(a_out),
	   .b_in(b_out),
	   .c_in(c_out),
	   .d_in(d_out),
	   .e_in(e_out),
	   .f_in(f_out),
	   .g_in(g_out),
	   .h_in(h_out),
	   .m_digest_final(Hash_Digest),
	   .valid_o(hash_valid_o)
	 );



endmodule
