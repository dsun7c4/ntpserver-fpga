# BUFGMUX is for debug only
# Set analysis case for normal operation only

#set_case_analysis 0 [get_pins "syspll_i/clkmux/CE0"]
#set_case_analysis 1 [get_pins "syspll_i/clkmux/CE1"]

set_case_analysis 1 [get_pins "syspll_i/clkmux/S0"]
#set_case_analysis 1 [get_pins "syspll_i/clkmux/S1"]

# Dont time the single bit clock domain transfer through two registers
set_false_path -to [get_cells irq_i/*dly_reg[0]*]
set_false_path -to [get_cells io_i/gpio_dac_ena/*dly_reg[0]*]
set_false_path -to [get_cells io_i/gpio_disp_ena/*dly_reg[0]*]
set_false_path -to [get_cells io_i/xtal_pwr/*dly_reg[0]*]
