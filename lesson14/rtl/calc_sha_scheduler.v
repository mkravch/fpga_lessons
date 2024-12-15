module calc_sha_scheduler
        (

            input clk,rst,flag_0_15,padding_done,
            input [31:0] data_in,
            
            output [31:0] const_plus_word_o,
            output [6:0] iteration_o,
            output reg valid_o
         );  //counter counter_iteration out to increment addresses of 4 pointr from 512-block 
		
		
		reg temp_case;
		reg temp_case_const;
		
		
		reg [6:0] counter_iteration;
		reg [31:0] mreg_15;
		reg [31:0] mreg_0,mreg_1,mreg_2,mreg_3,mreg_4,mreg_5,mreg_6,mreg_7,mreg_8,mreg_9,mreg_10,mreg_11,mreg_12,mreg_13,mreg_14;
		wire [31:0] m_in_mreg15;
		reg [31:0] K;
		reg [6:0] iteration_out;
		
		reg [31:0] const_plus_word;
		
		reg [31:0] sigma_0,sigma_1,sigma_0_reg;
		reg [31:0] sum_reg_1_and_10,sum_reg_2_and_11,sum_reg_sigma_0;
		
		always @ (posedge clk)    
		begin
		  sigma_0<=({mreg_2[6:0],mreg_2[31:7]} ^ {mreg_2[17:0],mreg_2[31:18]} ^ mreg_2[31:0]>>2'b11);
		  sigma_0_reg<=({mreg_3[6:0],mreg_3[31:7]} ^ {mreg_3[17:0],mreg_3[31:18]} ^ mreg_3[31:0]>>2'b11);
		  
		  sigma_1=({mreg_15[16:0],mreg_15[31:17]} ^ {mreg_15[18:0],mreg_15[31:19]} ^ mreg_15[31:0]>>4'b1010);
		  
		  sum_reg_1_and_10 <= mreg_1 + mreg_10;
		  sum_reg_2_and_11 <= mreg_2 + mreg_11;
		  sum_reg_sigma_0 <= sum_reg_2_and_11 + sigma_0_reg;
		  
	    end
		
		assign m_in_mreg15 = sum_reg_sigma_0 + sigma_1;
		
		always@(posedge clk)
		begin
		if(rst==0)
            begin
                temp_case<=1'b0;
                iteration_out<=7'd0;
                counter_iteration<=7'd1;
                mreg_15<=32'd0;
                mreg_14<=32'd0;
                mreg_13<=32'd0;
                mreg_12<=32'd0;
                mreg_11<=32'd0;
                mreg_10<=32'd0;
                mreg_9<=32'd0;
                mreg_8<=32'd0;
                mreg_7<=32'd0;
                mreg_6<=32'd0;
                mreg_5<=32'd0;
                mreg_4<=32'd0;
                mreg_3<=32'd0;
                mreg_2<=32'd0;
                mreg_1<=32'd0;
                mreg_0<=32'd0;
            end
		else
            begin
                if(flag_0_15==0 && counter_iteration<17 && counter_iteration>0)
                    begin
                        const_plus_word <= data_in + K;
                        mreg_15<=data_in;
                        mreg_14<=mreg_15;
                        mreg_13<=mreg_14;
                        mreg_12<=mreg_13;
                        mreg_11<=mreg_12;
                        mreg_10<=mreg_11;
                        mreg_9<=mreg_10;
                        mreg_8<=mreg_9;
                        mreg_7<=mreg_8;
                        mreg_6<=mreg_7;
                        mreg_5<=mreg_6;
                        mreg_4<=mreg_5;
                        mreg_3<=mreg_4;
                        mreg_2<=mreg_3;
                        mreg_1<=mreg_2;
                        mreg_0<=mreg_1;
                    end
                else				//flag_0_15==1 when all the 32 bit data_in from 32*16=512block has received
                    begin
                        if(counter_iteration!=64 && counter_iteration>0)
                            begin
                                const_plus_word <= m_in_mreg15 + K;
                                mreg_15<=m_in_mreg15;
                                mreg_14<=mreg_15;
                                mreg_13<=mreg_14;
                                mreg_12<=mreg_13;
                                mreg_11<=mreg_12;
                                mreg_10<=mreg_11;
                                mreg_9<=mreg_10;
                                mreg_8<=mreg_9;
                                mreg_7<=mreg_8;
                                mreg_6<=mreg_7;
                                mreg_5<=mreg_6;
                                mreg_4<=mreg_5;
                                mreg_3<=mreg_4;
                                mreg_2<=mreg_3;
                                mreg_1<=mreg_2;
                                mreg_0<=mreg_1;
                            end
                        end
                    
                    
                        if(counter_iteration==0 && padding_done==0)
                            begin
                                counter_iteration<=7'd0;
                            end
                        else
                            begin
                                if(counter_iteration==64 && padding_done==1)
                                    begin
                                        counter_iteration<=7'd64;
                                        iteration_out<=67'd64;
                                        mreg_15<=mreg_15;
                                        const_plus_word <= mreg_15 + K;
                                    end
                                else
                                    begin
                                        if(padding_done==0)
                                            begin
                                                counter_iteration<=7'd1;
                                            end
                                        else
                                            begin
                                                case(temp_case)
                                                    1'b0: temp_case<=1'b1;
                                                    1'b1: 
                                                    begin
                                                        iteration_out<=counter_iteration;
                                                        counter_iteration<=counter_iteration+1;
                                                    end
                                                endcase
                                            end
                                    end
                            end
                    end
                end
   
   
   
    reg [31:0] d_const = 0;
    reg [31:0] d_word = 0;
    wire [31:0] const_plus_word_sum_adder;
    
    reg [6:0] d_iteration_out,dd_iteration_out,ddd_iteration_out;
    
    reg [31:0] data_check, d_data_check, dd_data_check,ddd_data_check;
    
    reg [31:0] division = 0;
    
    reg d_padding,dd_padding,ddd_padding;
   
    always @ (posedge clk)
    begin
    
        d_padding <= padding_done;
        dd_padding <= d_padding;
        ddd_padding <= dd_padding;
    
        valid_o <= dd_padding;
    
    
        d_const <= K;
        
        if (flag_0_15==0 && counter_iteration<17 && counter_iteration>0)
            d_word <= data_in;
        else if (counter_iteration!=64 && counter_iteration>0)
            d_word <= m_in_mreg15;
        else
            d_word <= mreg_15; 
            
            
        data_check <= const_plus_word;
        d_data_check <= data_check;
        dd_data_check <= d_data_check;
        ddd_data_check <= dd_data_check;
        
        division <= dd_data_check - const_plus_word_sum_adder;
            
        d_iteration_out <= iteration_out;
        dd_iteration_out <= d_iteration_out;
        ddd_iteration_out <= dd_iteration_out;
    
    end
   
    assign const_plus_word_o = const_plus_word_sum_adder;
    assign iteration_o = ddd_iteration_out;
    
    const_plus_word_sum m_const_plus_word_sum
    (
      .A(d_const),      // input wire [31 : 0] A
      .B(d_word),      // input wire [31 : 0] B
      .CLK(clk),  // input wire CLK
      .S(const_plus_word_sum_adder)      // output wire [31 : 0] S
    );
      
    
    always@(posedge clk)
    begin
        if(rst==0)
            begin
                K=32'h428a2f98;
                temp_case_const=1'b0;
            end
        else
            begin
            if(padding_done==1)
                begin
                case(temp_case_const)
                    1'b0: 
                    begin
                        temp_case_const=1'b1;
                        K = 32'h71374491;
                    end
                    1'b1: 
                    begin
                        case(counter_iteration)
                            7'd0: K = 32'h71374491;
                            7'd1: K = 32'hb5c0fbcf;
                            7'd2: K = 32'he9b5dba5;
                            7'd3: K = 32'h3956c25b;
                            7'd4: K = 32'h59f111f1;
                            7'd5: K = 32'h923f82a4;
                            7'd6: K = 32'hab1c5ed5;
                            7'd7: K = 32'hd807aa98;
                            7'd8: K = 32'h12835b01;
                            7'd9: K = 32'h243185be;
                            7'd10: K = 32'h550c7dc3;
                            7'd11: K = 32'h72be5d74;
                            7'd12: K = 32'h80deb1fe;
                            7'd13: K = 32'h9bdc06a7;
                            7'd14: K = 32'hc19bf174;
                            7'd15: K = 32'he49b69c1;
                            7'd16: K = 32'hefbe4786;
                            7'd17: K = 32'h0fc19dc6;
                            7'd18: K = 32'h240ca1cc;
                            7'd19: K = 32'h2de92c6f;
                            7'd20: K = 32'h4a7484aa;
                            7'd21: K = 32'h5cb0a9dc;
                            7'd22: K = 32'h76f988da;
                            7'd23: K = 32'h983e5152;
                            7'd24: K = 32'ha831c66d;
                            7'd25: K = 32'hb00327c8;
                            7'd26: K = 32'hbf597fc7;
                            7'd27: K = 32'hc6e00bf3;
                            7'd28: K = 32'hd5a79147;
                            7'd29: K = 32'h06ca6351;
                            7'd30: K = 32'h14292967;
                            7'd31: K = 32'h27b70a85;
                            7'd32: K = 32'h2e1b2138;
                            7'd33: K = 32'h4d2c6dfc;
                            7'd34: K = 32'h53380d13;
                            7'd35: K = 32'h650a7354;
                            7'd36: K = 32'h766a0abb;
                            7'd37: K = 32'h81c2c92e;
                            7'd38: K = 32'h92722c85;
                            7'd39: K = 32'ha2bfe8a1;
                            7'd40: K = 32'ha81a664b;
                            7'd41: K = 32'hc24b8b70;
                            7'd42: K = 32'hc76c51a3;
                            7'd43: K = 32'hd192e819;
                            7'd44: K = 32'hd6990624;
                            7'd45: K = 32'hf40e3585;
                            7'd46: K = 32'h106aa070;
                            7'd47: K = 32'h19a4c116;
                            7'd48: K = 32'h1e376c08;
                            7'd49: K = 32'h2748774c;
                            7'd50: K = 32'h34b0bcb5;
                            7'd51: K = 32'h391c0cb3;
                            7'd52: K = 32'h4ed8aa4a;
                            7'd53: K = 32'h5b9cca4f;
                            7'd54: K = 32'h682e6ff3;
                            7'd55: K = 32'h748f82ee;
                            7'd56: K = 32'h78a5636f;
                            7'd57: K = 32'h84c87814;
                            7'd58: K = 32'h8cc70208;
                            7'd59: K = 32'h90befffa;
                            7'd60: K = 32'ha4506ceb;
                            7'd61: K = 32'hbef9a3f7;
                            7'd62: K = 32'hc67178f2; //63 values 
                            default:K=32'd0;
                        endcase
                        end
                    endcase            //end temp_case
                end
            else
                begin
                    K = 32'h428a2f98;
                end
            end
    end            
                

endmodule
