//-----------------------------------------------------------------------------
// Title         : TSC Testbench
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : tsc_tb.sv
// Author        : Daniel Sun  <dcsun88osh@gmail.com>
// Created       : 25.10.2018
// Last modified : 25.10.2018
//-----------------------------------------------------------------------------
// Description : Testbench for time stamp counter
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 25.10.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module tsc_tb
  import tb_pkg::*;
   ();

   logic        rst_n;
   logic        clk;

   logic        gps_1pps;
   logic        gps_3dfix_d;
   logic        tsc_read;
   logic        tsc_sync;
   logic        pfd_resync;
   logic        gps_1pps_d;
   logic        tsc_1pps_d;
   logic        pll_trig;
   logic        pfd_status;

   logic [31:0] pdiff_1pps;
   logic [31:0] fdiff_1pps;

   logic [63:0] tsc_cnt;
   logic [63:0] tsc_cnt1;
   logic        tsc_1pps;
   logic        tsc_1ppms;
   logic        tsc_1ppus;

   clk_gen   #(.period(10), .duty(50)) clk_100MHZ (.clk(clk));
   rst_n_gen #(.delay(996))            reset      (.rst_n(rst_n));

   tsc tsc_i (.*);

   assign gps_3dfix_d = 1'b0;
   assign tsc_read    = 1'b0;

   initial
     begin
        gps_1pps   = 1'b0;
        tsc_sync   = 1'b0;
        pfd_resync = 1'b0;

        run_clk(clk, 100000099);
        // tsc pps pulse starts here

        run_clk(clk, 1000);
        // Generate gps pps pulse 1000 cycles later
        // 1s
        gps_1pps = 1'b1;                
        run_clk(clk, 1);
        gps_1pps = 1'b0;

        run_clk(clk, 99997999);
        // 1000 cycles before tsc
        // 2s
        gps_1pps = 1'b1;
        run_clk(clk, 1);
        gps_1pps = 1'b0;

        run_clk(clk, 100000999);
        // In line with tsc
        // 3s
        gps_1pps = 1'b0;
        run_clk(clk, 1);
        gps_1pps = 1'b0;

        run_clk(clk, 100000999);
        // 1000 cycles after tsc
        // 4s
        gps_1pps = 1'b1;
        run_clk(clk, 1);
        gps_1pps = 1'b0;

        // trigger resync
        // 4.5s
        run_clk(clk, 49999999);
        //tsc_sync = 1'b1;
        run_clk(clk, 50000000);

        // tsc resynced
        // 4 cycles before tsc from pipeline delay
        // 5s
        gps_1pps = 1'b1;
        run_clk(clk, 1);
        gps_1pps = 1'b0;
        run_clk(clk, 4);
        tsc_sync = 1'b0;
        run_clk(clk, 99999995);

        // 4 cycles before tsc from pipeline delay
        // 6s...
        while (1)
          begin
            gps_1pps = 1'b1;
            run_clk(clk, 1);
            gps_1pps = 1'b0;
            run_clk(clk, 99999999);
          end
     end

endmodule
