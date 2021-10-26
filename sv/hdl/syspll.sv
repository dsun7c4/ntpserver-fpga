//-----------------------------------------------------------------------------
// Title         : System PLL
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : syspll.sv
// Author        : Daniel Sun  <dsun7c4osh@gmail.com>
// Created       : 01.11.2018
// Last modified : 01.11.2018
//-----------------------------------------------------------------------------
// Description : System PLL wrapper
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 01.11.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module syspll
  (
   // Clock in ports
   input logic  ocxo_clk,
   input logic  fclk,
   input logic  clk_sel,

   // Clock out ports
   output logic clk,

   // Status and control signals
   input logic  pll_rst_n,
   output logic locked
   );


   logic        pll_clk0;
   logic        pll_locked;

    ocxo_clk_pll syspll
      (
       // Clock in ports
       .clk_in1(ocxo_clk),
       // Clock out ports  
       .clk_out1(pll_clk0),
       // Status and control signals                
       .resetn(pll_rst_n),
       .locked(pll_locked)
       );


    BUFGMUX_CTRL clkmux
      (
       .O(clk),
       .I0(fclk),
       .I1(pll_clk0),
       .S(pll_locked)
       );

    
    //clkbuf: BUFG
    //    port map (
    //        O  => clk,
    //        I => pll_clk0
    //        );

   assign locked = pll_locked;

endmodule
