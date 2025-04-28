module motor_ctrl
    (

        input clk_i,
        
        input start_i,
        input [30:0] pause_i,
        input [15:0] repeat_i,
        input direction_i,
        output logic finish_o,
        
        output logic motor_0_o,
        output logic motor_1_o,
        output logic motor_2_o,
        output logic motor_3_o

    );
    
    
    enum logic [2:0] 
    {
    
        ST_IDLE,
        ST_PHASE_0,
        ST_PHASE_1,
        ST_PHASE_2,
        ST_PHASE_3
    
    }  state = ST_IDLE;
    
    logic [30:0] cnt_pause = 0;
    logic [15:0] cnt_repeat = 0;
        
        always @ (posedge clk_i)
        begin
        
        
            case(state)
            
                ST_IDLE:
                begin
                
                    motor_0_o <= 0;
                    motor_1_o <= 0;
                    motor_2_o <= 0;
                    motor_3_o <= 0;
                                    
                
                    if (start_i)
                    begin
                        finish_o <= 0;
                        state <= ST_PHASE_0;
                    
                    end
                end
                ST_PHASE_0:
                begin
                    motor_0_o <= 1;
                    motor_1_o <= 0;
                    motor_2_o <= 0;
                    motor_3_o <= 1;
                    
                    if (cnt_pause == pause_i)
                        begin
                            state <= ST_PHASE_1;
                            cnt_pause <= 0;
                        end 
                    else
                        begin
                            cnt_pause <= cnt_pause + 1;
                        end
                end
                ST_PHASE_1:
                begin
                
                    if (direction_i)
                        begin
                            motor_0_o <= 1;
                            motor_1_o <= 1;
                            motor_2_o <= 0;
                            motor_3_o <= 0;
                        end
                    else
                        begin
                            motor_0_o <= 0;
                            motor_1_o <= 0;
                            motor_2_o <= 1;
                            motor_3_o <= 1;                       
                        end
                

                    
                    if (cnt_pause == pause_i)
                        begin
                            state <= ST_PHASE_2;
                            cnt_pause <= 0;
                        end 
                    else
                        begin
                            cnt_pause <= cnt_pause + 1;
                        end
                end                
                ST_PHASE_2:
                begin
                    motor_0_o <= 0;
                    motor_1_o <= 1;
                    motor_2_o <= 1;
                    motor_3_o <= 0;
                    
                    if (cnt_pause == pause_i)
                        begin
                            state <= ST_PHASE_3;
                            cnt_pause <= 0;
                        end 
                    else
                        begin
                            cnt_pause <= cnt_pause + 1;
                        end
                end                
                ST_PHASE_3:
                begin
                
                    if (direction_i)
                        begin
                            motor_0_o <= 0;
                            motor_1_o <= 0;
                            motor_2_o <= 1;
                            motor_3_o <= 1;
                        end
                    else
                        begin
                            motor_0_o <= 1;
                            motor_1_o <= 1;
                            motor_2_o <= 0;
                            motor_3_o <= 0;                       
                        end
                    
                    if (cnt_pause == pause_i)
                        begin
                        
                            if (cnt_repeat == repeat_i)
                                begin
                                    cnt_repeat <= 0;
                                    finish_o <= 1;
                                    state <= ST_IDLE;
                                end
                            else
                                begin
                                    cnt_repeat <= cnt_repeat + 1;
                                    state <= ST_PHASE_0;
                                
                                end
                            
                            cnt_pause <= 0;
                        end 
                    else
                        begin
                            cnt_pause <= cnt_pause + 1;
                        end
                end                
            
            endcase
        
        
        end
        
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
endmodule
