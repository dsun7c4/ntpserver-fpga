//-----------------------------------------------------------------------------
// Title         : DAC Driver TB
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : dac_tb.sv
// Author        : Daniel Sun  <dcsun88osh@gmail.com>
// Created       : 29.10.2018
// Last modified : 29.10.2018
//-----------------------------------------------------------------------------
// Description : Testbench for DAC driver
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 29.10.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module dac_tb
  import tb_pkg::*;
   ();

   logic                rst_n;
   logic                clk;

   logic                tsc_1pps;
   logic                tsc_1ppms;
   logic                dac_ena;
   logic                dac_tri;
   logic [15:0]         dac_val;

   logic                dac_sclk;
   logic                dac_cs_n;
   logic                dac_sin;

   clk_gen   #(.period(10), .duty(50)) clk_100MHZ (.clk(clk));
   rst_n_gen #(.delay(996))            reset      (.rst_n(rst_n));

   dac dac_i (.*);

   assign dac_ena = 1'b1;
   assign dac_tri = 1'b0;

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

   initial
     begin
        dac_val = '0;

        run_clk(clk, 2000);

        dac_val = 16'haaaa;

        run_clk(clk, 2000);

        dac_val = 16'h5555;

        run_clk(clk, 2000);

        dac_val = 16'ha5a5;

        run_clk(clk, 2000);

        dac_val =  16'h5a5a;

        run_clk(clk, 2000);
    end


endmodule
