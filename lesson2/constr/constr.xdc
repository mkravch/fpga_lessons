set_property package_pin F16 [get_ports leds_o[0]]
set_property package_pin M19 [get_ports leds_o[1]]
set_property package_pin M17 [get_ports leds_o[2]]
set_property package_pin L19 [get_ports leds_o[3]]

set_property iostandard lvcmos33 [get_ports leds_o[*]]

set_property package_pin K17 [get_ports clk_100_i]
set_property iostandard lvcmos33 [get_ports clk_100_i]

create_clock -period 10 [get_ports clk_100_i]