# BUFGMUX is for debug only
# Set analysis case for normal operation only

#set_case_analysis 0 [get_pins "syspll_i/clkmux/CE0"]
#set_case_analysis 1 [get_pins "syspll_i/clkmux/CE1"]

set_case_analysis 1 [get_pins "syspll_i/clkmux/S0"]
#set_case_analysis 1 [get_pins "syspll_i/clkmux/S1"]
