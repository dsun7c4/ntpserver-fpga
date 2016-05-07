# BUFGMUX is for debug only
# Set analysis case for normal operation only

#set_case_analysis 0 [get_pins "pll/clkmux/CE0"]
#set_case_analysis 1 [get_pins "pll/clkmux/CE1"]

set_case_analysis 1 [get_pins "pll/clkmux/S0"]
#set_case_analysis 1 [get_pins "pll/clkmux/S1"]
