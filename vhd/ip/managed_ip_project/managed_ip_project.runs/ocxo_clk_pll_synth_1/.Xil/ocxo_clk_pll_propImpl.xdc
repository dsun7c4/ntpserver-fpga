set_property SRC_FILE_INFO {cfile:/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll.xdc rfile:../../../../ocxo_clk_pll/ocxo_clk_pll.xdc id:1 order:EARLY scoped_inst:U0} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:56 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.1
