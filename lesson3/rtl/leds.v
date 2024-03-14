module leds
	(

		input clk_100_i,
		output reg[3:0] leds_o = 0

	);


	reg [26:0] count = 0;

	always @ (posedge clk_100_i)
	begin

		if (count == 27'd49_999_999)
		begin
			count <= 0;
			leds_o <= ~leds_o;
		end
		else
			count <= count + 1;

	end


endmodule