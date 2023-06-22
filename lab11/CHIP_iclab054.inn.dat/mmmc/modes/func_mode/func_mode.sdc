###############################################################
#  Generated by:      Cadence Innovus 20.15-s105_1
#  OS:                Linux x86_64(Host ID ee23)
#  Generated on:      Sun May 21 15:07:58 2023
#  Design:            CHIP
#  Command:           routeDesign -globalDetail -viaOpt -wireOpt
###############################################################
current_design CHIP
create_clock [get_ports {clk}]  -name clk -period 12.000000 -waveform {0.000000 6.000000}
set_propagated_clock  [get_ports {clk}]
set_load -pin_load -max  0.05  [get_ports {out_valid}]
set_load -pin_load -min  0.05  [get_ports {out_valid}]
set_load -pin_load -max  0.05  [get_ports {out_value}]
set_load -pin_load -min  0.05  [get_ports {out_value}]
set_input_delay -add_delay 6 -clock [get_clocks {clk}] [get_ports {in_valid}]
set_input_delay -add_delay 0 -clock [get_clocks {clk}] [get_ports {rst_n}]
set_input_delay -add_delay 6 -clock [get_clocks {clk}] [get_ports {matrix_size[1]}]
set_input_delay -add_delay 6 -clock [get_clocks {clk}] [get_ports {i_mat_idx}]
set_input_delay -add_delay 6 -clock [get_clocks {clk}] [get_ports {matrix}]
set_input_delay -add_delay 6 -clock [get_clocks {clk}] [get_ports {w_mat_idx}]
set_input_delay -add_delay 6 -clock [get_clocks {clk}] [get_ports {matrix_size[0]}]
set_input_delay -add_delay 6 -clock [get_clocks {clk}] [get_ports {in_valid2}]
set_output_delay -add_delay 6 -clock [get_clocks {clk}] [get_ports {out_value}]
set_output_delay -add_delay 6 -clock [get_clocks {clk}] [get_ports {out_valid}]