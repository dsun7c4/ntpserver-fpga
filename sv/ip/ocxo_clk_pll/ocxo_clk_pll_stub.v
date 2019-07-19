// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.4 (lin64) Build 1071353 Tue Nov 18 16:47:07 MST 2014
// Date        : Fri Jul 19 13:44:18 2019
// Host        : graviton running 64-bit Devuan GNU/Linux ascii
// Command     : write_verilog -force -mode synth_stub
//               /home/guest/cae/fpga/ntpserver/sv/ip/ocxo_clk_pll/ocxo_clk_pll_stub.v
// Design      : ocxo_clk_pll
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module ocxo_clk_pll(clk_in1, clk_out1, resetn, locked)
/* synthesis syn_black_box black_box_pad_pin="clk_in1,clk_out1,resetn,locked" */;
  input clk_in1;
  output clk_out1;
  input resetn;
  output locked;
endmodule
