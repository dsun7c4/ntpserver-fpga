-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2014.4 (lin64) Build 1071353 Tue Nov 18 16:47:07 MST 2014
-- Date        : Tue Mar 15 21:11:26 2016
-- Host        : graviton running 64-bit Debian GNU/Linux 7.9 (wheezy)
-- Command     : write_vhdl -force -mode synth_stub /home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_stub.vhdl
-- Design      : ocxo_clk_pll
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ocxo_clk_pll is
  Port ( 
    clk_in1 : in STD_LOGIC;
    clk_out1 : out STD_LOGIC;
    resetn : in STD_LOGIC;
    locked : out STD_LOGIC
  );

end ocxo_clk_pll;

architecture stub of ocxo_clk_pll is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_in1,clk_out1,resetn,locked";
begin
end;
