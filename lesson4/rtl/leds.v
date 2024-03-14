module leds
	(

		input clk_100_i,
		output [3:0] leds_o

	);


    input_vio m_input_vio
     (
      .clk(clk_100_i),                // input wire clk
      .probe_out0(leds_o[0]),  // output wire [0 : 0] probe_out0
      .probe_out1(leds_o[1]),  // output wire [0 : 0] probe_out1
      .probe_out2(leds_o[2]),  // output wire [0 : 0] probe_out2
      .probe_out3(leds_o[3])  // output wire [0 : 0] probe_out3
    );



endmodule