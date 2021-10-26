//-----------------------------------------------------------------------------
// Title         : Utils TB
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : util_pkg_tb.sv
// Author        : Daniel Sun  <dsun7c4osh@gmail.com>
// Created       : 23.10.2018
// Last modified : 23.10.2018
//-----------------------------------------------------------------------------
// Description : Testbench for util package
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 23.10.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module util_tb
  import tb_pkg::*;
   ();

   logic  rst_n;
   logic  clk;

   logic        d;
   logic [31:0] d_vec;

   logic [31:0] q_vec [15:0];
   logic [15:0] q_sig;
   logic [15:0] q_pulse;
   logic [15:0] q_stretch;

   genvar       i;

   clk_gen   #(.period(10), .duty(50)) clk_100MHZ (.clk(clk));
   rst_n_gen #(.delay(1001))           reset      (.rst_n(rst_n));


   for (i = 0; i < 16; i++)
     begin : tests
        delay         #(.SIZE($bits(q_vec[i])), .CYCLES(i)) dly_vec (.rst_n, .clk, .d(d_vec), .q(q_vec[i]));
        delay1        #(                        .CYCLES(i)) dly_sig (.rst_n, .clk, .d(d),     .q(q_sig[i]));
        delay_pulse   #(                        .CYCLES(i)) dly_p   (.rst_n, .clk, .d(d),     .q(q_pulse[i]));
        pulse_stretch #(                        .CYCLES(i)) dly_st  (.rst_n, .clk, .d(d),     .q(q_stretch[i]));
     end


   initial
     begin
        d     = '0;
        d_vec = '0;
     end

   
   always
     begin
        d     = '0;
        d_vec = '0;
        run_clk(clk, 200);

        d     = '1;
        d_vec = 'h5555aaaa;
        run_clk(clk, 1);

        d     = '0;
        d_vec = '0;
        run_clk(clk, 64);

        for (int j = 0; j < 33; j++)
          begin
             d     = '1;
             d_vec = 'h555aaaa;
             run_clk(clk, 1);

             d     = '0;
             d_vec = '0;
             run_clk(clk, j);
          end

     end

   
endmodule
