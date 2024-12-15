module calc_sha_digest
    (
        clk,
        rst,
        counter_iteration,
        a_in,
        b_in,
        c_in,
        d_in,
        e_in,
        f_in,
        g_in,
        h_in,
        m_digest_final,
        valid_o


    );
	 output reg [255:0] m_digest_final;
	 output reg valid_o = 0;
	 input clk,rst;
	 input [6:0] counter_iteration; //1-64 itterations
	 (*S="TRUE"*)input [31:0] a_in,b_in,c_in,d_in,e_in,f_in,g_in,h_in;
	 
	 reg temp_delay;
	 
	 reg [31:0] H0 ;
	 reg [31:0] H1 ;
	 reg [31:0] H2 ;
	 reg [31:0] H3 ;
	 reg [31:0] H4 ;
	 reg [31:0] H5 ;
	 reg [31:0] H6 ;
	 reg [31:0] H7 ;
	 
	 always@(posedge clk)
	 begin
	 
         if(rst == 0)
             begin
                 temp_delay = 1'b0;
                 m_digest_final <= 256'd0;
                 
                 H0 = 32'h6a09e667;
                 H1 = 32'hbb67ae85;
                 H2 = 32'h3c6ef372;
                 H3 = 32'ha54ff53a;
                 H4 = 32'h510e527f;
                 H5 = 32'h9b05688c;
                 H6 = 32'h1f83d9ab;
                 H7 = 32'h5be0cd19;
             end
         else
           begin
               if(counter_iteration==7'd64) //only add for 1 time for 1 512_block
                 begin//32'bit modulo adder
                     H0 = H0 + a_in;
                     H1 = H1 + b_in;
                     H2 = H2 + c_in;
                     H3 = H3 + d_in;
                     H4 = H4 + e_in;
                     H5 = H5 + f_in;
                     H6 = H6 + g_in;
                     H7 = H7 + h_in;
                     
                     if(temp_delay==0)
                         begin
                             temp_delay = temp_delay + 1;
                             m_digest_final <= {H0,H1,H2,H3,H4,H5,H6,H7};
                             valid_o <= 1;
                         end
                     else
                        begin
                        
                            valid_o <= 0;
                        
                        end    
                 end
               end
	 end
	 
	 endmodule
