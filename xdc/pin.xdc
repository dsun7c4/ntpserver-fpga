
# All user I/O are LVCMOS33

set_property IOSTANDARD LVCMOS33 [get_ports rtc*]
set_property DRIVE      8        [get_ports rtc*]
set_property PACKAGE_PIN P15 [get_ports rtc_scl]
set_property PACKAGE_PIN P16 [get_ports rtc_sda]

set_property IOSTANDARD LVCMOS33 [get_ports ocxo*]
set_property DRIVE      8        [get_ports ocxo*]
set_property PACKAGE_PIN N20 [get_ports ocxo_ena]
set_property PACKAGE_PIN U18 [get_ports ocxo_clk]
set_property PACKAGE_PIN W19 [get_ports ocxo_scl]
set_property PACKAGE_PIN W18 [get_ports ocxo_sda]

set_property IOSTANDARD LVCMOS33 [get_ports dac*]
set_property DRIVE      8        [get_ports dac*]
set_property IOB        TRUE     [get_ports dac*]
set_property PACKAGE_PIN J14 [get_ports dac_sclk]
set_property PACKAGE_PIN K14 [get_ports dac_cs_n]
set_property PACKAGE_PIN N15 [get_ports dac_sin]

set_property IOSTANDARD LVCMOS33 [get_ports gps*]
set_property DRIVE      8        [get_ports gps*]
set_property PACKAGE_PIN M14 [get_ports gps_ena]
set_property PACKAGE_PIN G18 [get_ports gps_rxd]
set_property PACKAGE_PIN G19 [get_ports gps_txd]
set_property PACKAGE_PIN G17 [get_ports gps_3dfix]
set_property IOB        TRUE     [get_ports gps_3dfix]
set_property PACKAGE_PIN G20 [get_ports gps_1pps]
set_property IOB        TRUE     [get_ports gps_1pps]

set_property IOSTANDARD LVCMOS33 [get_ports temp*]
set_property DRIVE      8        [get_ports temp*]
set_property PACKAGE_PIN W20 [get_ports temp_scl]
set_property PACKAGE_PIN V20 [get_ports temp_sda]

set_property IOSTANDARD LVCMOS33 [get_ports disp*]
set_property DRIVE      8        [get_ports disp*]
set_property IOB        TRUE     [get_ports disp*]
set_property PACKAGE_PIN W13 [get_ports disp_sclk]
set_property PACKAGE_PIN V12 [get_ports disp_blank]
set_property PACKAGE_PIN U12 [get_ports disp_lat]
set_property PACKAGE_PIN T12 [get_ports disp_sin]

set_property IOSTANDARD LVCMOS33 [get_ports fan*]
set_property DRIVE      8        [get_ports fan*]
set_property IOB        TRUE     [get_ports fan*]
set_property PACKAGE_PIN T14 [get_ports fan_tach]
set_property PACKAGE_PIN Y14 [get_ports fan_pwm]

set_property IOSTANDARD LVCMOS33 [get_ports gpio*]
set_property DRIVE      8        [get_ports gpio*]
set_property IOB        TRUE     [get_ports gpio*]
set_property PACKAGE_PIN L20 [get_ports gpio[0]]
set_property PACKAGE_PIN L19 [get_ports gpio[1]]
set_property PACKAGE_PIN E19 [get_ports gpio[2]]
set_property PACKAGE_PIN E18 [get_ports gpio[3]]
set_property PACKAGE_PIN D18 [get_ports gpio[4]]
set_property PACKAGE_PIN E17 [get_ports gpio[5]]
set_property PACKAGE_PIN B20 [get_ports gpio[6]]
set_property PACKAGE_PIN C20 [get_ports gpio[7]]

set_property PACKAGE_PIN K9  [get_ports Vp_Vn_v_p]
set_property PACKAGE_PIN L10 [get_ports Vp_Vn_v_n]

# Set properties for CFGBVS warning
set_property CFGBVS VCCO          [current_design]
set_property CONFIG_VOLTAGE  3.3  [current_design]
