set_property PACKAGE_PIN W18 [get_ports i2c_clk_o]
set_property IOSTANDARD LVCMOS33 [get_ports i2c_clk_o]


set_property PACKAGE_PIN W19 [get_ports i2c_data_io]
set_property IOSTANDARD LVCMOS33 [get_ports i2c_data_io]

set_property PACKAGE_PIN Y18 [get_ports i2c_ce_o]
set_property IOSTANDARD LVCMOS33 [get_ports i2c_ce_o]

create_generated_clock -name system_i/i2c_top_0/inst/clk_200_khz -source [get_pins {system_i/processing_system7_0/inst/PS7_i/FCLKCLK[0]}] -divide_by 250 [get_pins system_i/i2c_top_0/inst/clk_200_khz_reg/Q]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
