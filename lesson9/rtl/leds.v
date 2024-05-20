`timescale 1ns / 1ps

module leds
    (

        input clk_50_i,
        output reg [3:0] leds_o = 4'hE

    );
    
    
    reg [27:0] cnt = 0;
    
    
    always @ (posedge clk_50_i)
    begin
    
        if (cnt == 28'd50_000_000)
            begin
                cnt <= 0;
                leds_o <= {leds_o[2:0],leds_o[3]};
            end
        else
            begin
                cnt <= cnt + 1;
            end
    
    end
    
    
    
    
endmodule
