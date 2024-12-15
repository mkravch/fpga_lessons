module calc_sha_iterations
    (

        clk,
        rst,
        const_plus_word_i,
        counter_iteration,
        padding_done,
        a_out,
        b_out,
        c_out,
        d_out,
        e_out,
        f_out,
        g_out,
        h_out
							
	);
	  
	 
	 input clk,rst,padding_done;
	 input [6:0] counter_iteration;
	 input [31:0] const_plus_word_i;
	 //(* use_dsp48="yes" *)
	 output reg [31:0] a_out,b_out,c_out,d_out,e_out,f_out,g_out,h_out;
	 
	 reg temp_case,temp_if;
	 reg [31:0] semation_0,semation_1,ch,maj;
	 
	 always@(posedge clk)
	 begin
         if(rst==0)
             begin
                    temp_case=1'b0;
                    a_out<=32'h6a09e667;
                    b_out<=32'hbb67ae85;
                    c_out<=32'h3c6ef372;
                    d_out<=32'ha54ff53a;
                    e_out<=32'h510e527f;
                    f_out<=32'h9b05688c;
                    g_out<=32'h1f83d9ab;
                    h_out<=32'h5be0cd19;
                    temp_if = 0;
             end
         else
             begin
                    semation_0=({a_out[1:0],a_out[31:2]}) ^ ({a_out[12:0],a_out[31:13]}) ^ ({a_out[21:0],a_out[31:22]}); //last 22 ROTR22
                    semation_1=({e_out[5:0],e_out[31:6]}) ^ ({e_out[10:0],e_out[31:11]}) ^ ({e_out[24:0],e_out[31:25]});
             
                    maj=(a_out & b_out) ^ (a_out & c_out) ^ (b_out & c_out);
                    ch=(e_out & f_out) ^ (~e_out & g_out);
                    
                    if(counter_iteration==65)
                        begin
                            a_out<=a_out;
                            b_out<=b_out;
                            c_out<=c_out;
                            d_out<=d_out;
                            e_out<=e_out;
                            f_out<=f_out;
                            g_out<=g_out;
                            h_out<=h_out;
                        end
                    else
                        begin
                        
                            if(padding_done==1)
                                begin
                                    case(temp_case)
                                        1'b0: temp_case=1'b1;
                                        1'b1: temp_if=1'b1;
                                    endcase
                                end
                            
                            if(temp_if==1 && counter_iteration!=64)
                                begin
                                    a_out <= h_out + semation_1 + ch + const_plus_word_i + semation_0 + maj; 	// T2= semation_0 + maj(a,b,c);
                                    b_out <= a_out;
                                    c_out <= b_out;
                                    d_out <= c_out;
                                    e_out <= d_out + h_out + semation_1 + ch + const_plus_word_i;		//T1 = h_out + semation_1 + ch + k + w;
                                    f_out <= e_out;
                                    g_out <= f_out;
                                    h_out <= g_out;
                                end
                        end
             end
         
     end
     
    
//    always @ (posedge clk)
//    begin
    
//        a_out <= h_out + semation_1 + ch + const_plus_word_i + semation_0 + maj; 	// T2= semation_0 + maj(a,b,c);
//        b_out <= a_out;
//        c_out <= b_out;
//        d_out <= c_out;
//        e_out <= d_out + h_out + semation_1 + ch + const_plus_word_i;        //T1 = h_out + semation_1 + ch + k + w;
//        f_out <= e_out;
//        g_out <= f_out;
//        h_out <= g_out;
    
//    end



endmodule
