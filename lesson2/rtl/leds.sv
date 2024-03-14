module leds
	(

		input clk_100_i,
		output logic[3:0] leds_o = 0

	);


    logic [26:0] count = 0;

    clk_dbg m_clk_dbg
    (
        .clk(clk_100_i),
        .probe0(count) //27
    
    );


	always @ (posedge clk_100_i)
	begin

		if (count == 27'd99_999_999)
		begin
			count <= 0;
			leds_o <= ~leds_o;
		end
		else
			count <= count + 1;

	end


endmodule