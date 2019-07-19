//-----------------------------------------------------------------------------
// Title         : Testbench for time counters
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : bcdtime_tb.sv
// Author        : Daniel Sun  <dcsun88osh@gmail.com>
// Created       : 29.10.2018
// Last modified : 29.10.2018
//-----------------------------------------------------------------------------
// Description : Testbench for time counters
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by  This model is the confidential and
// proprietary property of  and the possession or use of this
// file requires a written license from .
//------------------------------------------------------------------------------
// Modification history :
// 29.10.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module bcdtime_tb
   import tb_pkg::*, types_pkg::*;
   ();

   logic        rst_n;
   logic        clk;

   logic        tsc_1pps;
   logic        tsc_1ppms;

   logic        set;
   time_t       set_time;

   time_t       cur_time;

   clk_gen   #(.period(10), .duty(50)) clk_100MHZ (.clk(clk));
   rst_n_gen #(.delay(996))            reset      (.rst_n(rst_n));

   bcdtime digits (.*);

   assign set              = 1'b0;
   assign set_time.t_1ms   = '0;
   assign set_time.t_10ms  = '0;
   assign set_time.t_100ms = '0;
   assign set_time.t_1s    = '0;
   assign set_time.t_10s   = '0;
   assign set_time.t_1m    = '0;
   assign set_time.t_10m   = '0;
   assign set_time.t_1h    = '0;
   assign set_time.t_10h   = '0;

   initial
     begin
        tsc_1pps = 1'b0;

        run_clk(clk, 1000);

        while (1)
          begin
             tsc_1pps = 1'b1;

             run_clk(clk, 1);

             tsc_1pps = 1'b0;

             run_clk(clk, 1999);

          end
     end

    initial
      begin
         tsc_1ppms = 1'b0;

         run_clk(clk, 1000);

         while (1)
           begin
              tsc_1ppms = 1'b1;

              run_clk(clk, 1);

              tsc_1ppms = 1'b0;

              run_clk(clk, 1);
           end
      end

endmodule
