####################################################
## Filename: CHIP.sdc
## Record:
## v.0 -> Yu-Cheng Li 2018.09.01
####################################################
## Setting
set CLK_NAME CLK
set CLK_PERIOD 3.0
set CLK_UNCERT 0.1
#set RST_NAME reset
set RST_NAME reset_i
set I_DELAY 0.05
set O_DELAY 0.05
## Clock
create_clock -name $CLK_NAME -period $CLK_PERIOD [get_ports clk]
set_clock_uncertainty $CLK_UNCERT [all_clocks]
set_dont_touch_network [all_clocks]
set_ideal_network [get_ports clk]
set_fix_hold [all_clocks]
## Reset
set_dont_touch_network $RST_NAME
set_ideal_network [get_ports $RST_NAME]
## I/O
set_input_delay $I_DELAY -clock $CLK_NAME [all_inputs]
set_output_delay $O_DELAY -clock $CLK_NAME [all_outputs]

#The following are design spec. for synthesis
#You can NOT modify this seciton 
#####################################################
#create_clock -name CLK -period $cycle [get_ports clk]
#set_fix_hold                          [get_clocks CLK]
#set_dont_touch_network                [get_clocks CLK]
#set_ideal_network                     [get_ports clk]
#set_clock_uncertainty            0.1  [get_clocks CLK] 
#set_clock_latency                0.5  [get_clocks CLK] 

#set_max_fanout 6 [all_inputs] 

#set_operating_conditions -min_library fast -min fast -max_library slow -max slow
#set_wire_load_model -name tsmc13_wl10 -library slow  
#set_drive        1     [all_inputs]
#set_load         1     [all_outputs]
#set t_in   0.1
#set t_out  0.1
#set_input_delay  $t_in  -clock CLK [remove_from_collection [all_inputs] [get_ports clk]]
#set_output_delay $t_out -clock CLK [all_outputs]
#####################################################


#Compile and save files
#You may modified setting of compile 
#####################################################
#compile_ultra
#write_sdf -version 2.1 CHIP_syn.sdf
#write -format verilog -hier -output CHIP_syn.v
#write -format ddc     -hier -output CHIP_syn.ddc  
#####################################################  









