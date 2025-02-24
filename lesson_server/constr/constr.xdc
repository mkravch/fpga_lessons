
############################################################
#		W19					W16
#   *    *    *	   *    *    *     *    *    *
#
#
#	*    *    *	   *    *    *     *    *    *
#		W18					V16
############################################################

set_property package_pin W19 [get_ports motor_0_o]
set_property iostandard lvcmos33 [get_ports motor_0_o]

set_property package_pin W18 [get_ports motor_1_o]
set_property iostandard lvcmos33 [get_ports motor_1_o]

set_property package_pin W16 [get_ports motor_2_o]
set_property iostandard lvcmos33 [get_ports motor_2_o]

set_property package_pin V16 [get_ports motor_3_o]
set_property iostandard lvcmos33 [get_ports motor_3_o]
