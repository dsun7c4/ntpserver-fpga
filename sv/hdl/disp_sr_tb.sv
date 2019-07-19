//-----------------------------------------------------------------------------
// Title         : Display SR testbench
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : disp_sr_tb.sv
// Author        : Daniel Sun  <dcsun88osh@gmail.com>
// Created       : 30.10.2018
// Last modified : 30.10.2018
//-----------------------------------------------------------------------------
// Description : Disp shift register testbench
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by  This model is the confidential and
// proprietary property of  and the possession or use of this
// file requires a written license from .
//------------------------------------------------------------------------------
// Modification history :
// 30.10.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module disp_sr_tb
  import tb_pkg::*;
   ();

   logic                rst_n;
   logic                clk;

   logic                tsc_1pps;
   logic                tsc_1ppms;
   logic                tsc_1ppus;

   logic [255:0]        disp_data;

   logic                disp_sclk;
   logic                disp_lat;
   logic                disp_sin;


   clk_gen   #(.period(10), .duty(50)) clk_100MHZ (.clk(clk));
   rst_n_gen #(.delay(996))            reset      (.rst_n(rst_n));

   disp_sr disp_sr_i (.*);

   initial
     begin
        $display("bits: %3d  size: %3d  left: %3d  low: %3d  right: %3d  high: %3d",
                 $bits(disp_data),
                 $size(disp_data),
                 $left(disp_data),
                 $low(disp_data),
                 $right(disp_data),
                 $high(disp_data));
        tsc_1pps = 1'b0;

        run_clk(clk, 1000);

        while (1)
          begin
             tsc_1pps = 1'b1;

             run_clk(clk, 1);

             tsc_1pps = 1'b0;

             run_clk(clk, 1999999);

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

             run_clk(clk, 1999);

          end
      end

   initial
     begin
        tsc_1ppus = 1'b0;

        run_clk(clk, 1000);

        while (1)
          begin
             tsc_1ppus = 1'b1;

             run_clk(clk, 1);

             tsc_1ppus = 1'b0;

             run_clk(clk, 1);

          end
     end

   initial
     begin
        disp_data = '0;

        run_clk(clk, 2000);

        disp_data = 256'h5aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa5;

        run_clk(clk, 2000);

        disp_data = 256'ha55555555555555555555555555555555555555555555555555555555555555a;

        run_clk(clk, 2000);

        disp_data = 256'ha5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5;

        run_clk(clk, 2000);

        disp_data = 256'h5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a;

        run_clk(clk, 2000);

    end


endmodule

