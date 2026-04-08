create_clock -period 10.500 -name sys_clk -waveform {0.000 5.250} [get_ports clk]
set_input_delay -clock [get_clocks sys_clk] -min -add_delay 0.000 [get_ports rst]
set_input_delay -clock [get_clocks sys_clk] -max -add_delay 2.000 [get_ports rst]
