//-----------------------------------------------------------------------------
// Title         : Clock testbench
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : clock_tb.sv
// Author        : Daniel Sun  <dsun7c4osh@gmail.com>
// Created       : 03.11.2018
// Last modified : 03.11.2018
//-----------------------------------------------------------------------------
// Description : Clock top level test bench
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 03.11.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module clock_tb
   ();

   wire [14:0]  DDR_addr;
   wire [2:0]   DDR_ba;
   wire         DDR_cas_n;
   wire         DDR_ck_n;
   wire         DDR_ck_p;
   wire         DDR_cke;
   wire         DDR_cs_n;
   wire [3:0]   DDR_dm;
   wire [31:0]  DDR_dq;
   wire [3:0]   DDR_dqs_n;
   wire [3:0]   DDR_dqs_p;
   wire         DDR_odt;
   wire         DDR_ras_n;
   wire         DDR_reset_n;
   wire         DDR_we_n;

   wire         FIXED_IO_ddr_vrn;
   wire         FIXED_IO_ddr_vrp;
   wire [53:0]  FIXED_IO_mio;
   wire         FIXED_IO_ps_clk;
   wire         FIXED_IO_ps_porb;
   wire         FIXED_IO_ps_srstb;

   logic        Vp_Vn_v_n;
   logic        Vp_Vn_v_p;

   wire         rtc_scl;
   wire         rtc_sda;
   logic        rtc_32khz;
   logic        rtc_int_n;

   wire         ocxo_ena;
   logic        ocxo_clk;
   wire         ocxo_scl;
   wire         ocxo_sda;

   logic        dac_sclk;
   logic        dac_cs_n;
   logic        dac_sin;

   wire         gps_ena;
   logic        gps_rxd;
   wire         gps_txd;
   logic        gps_3dfix;
   logic        gps_1pps;

   wire         temp_scl;
   wire         temp_sda;
   logic        temp_int1_n;
   logic        temp_int2_n;

   logic        disp_sclk;
   logic        disp_blank;
   logic        disp_lat;
   logic        disp_sin;
   logic        disp_status;

   logic        fan_tach;
   logic        fan_pwm;

   wire [7:0]   gpio;


   import tb_pkg::*;


   clock fpga (.*);

   clk_gen   #(.period(100), .duty(50)) ocxo_10MHZ (.clk(ocxo_clk));


   initial
     begin
        while (1)
          begin
            fan_tach = 1'b1;

            run_clk(ocxo_clk, 10000);

            fan_tach = 1'b0;

            run_clk(ocxo_clk, 20000);

            fan_tach = 1'b1;

            run_clk(ocxo_clk, 30000);

            fan_tach = 1'b0;

            run_clk(ocxo_clk, 40000);

          end
     end


   initial
     begin
        gps_1pps  = 1'b0;

        run_clk(ocxo_clk, 10000);

        while (1)
          begin
            gps_1pps  = 1'b1;

            run_clk(ocxo_clk, 1);

            gps_1pps  = 1'b0;

            run_clk(ocxo_clk, 9999999);

            gps_1pps  = 1'b1;

            run_clk(ocxo_clk, 1);

            gps_1pps  = 1'b0;

            run_clk(ocxo_clk, 9999989);

            gps_1pps  = 1'b1;

            run_clk(ocxo_clk, 1);

            gps_1pps  = 1'b0;

            run_clk(ocxo_clk, 10000019);

          end
     end


   assign gps_3dfix   = 1'b0;
   assign gps_rxd     = 1'b0;
   assign Vp_Vn_v_n   = 1'b0;
   assign Vp_Vn_v_p   = 1'b0;
   assign rtc_int_n   = 1'b1;
   assign temp_int1_n = 1'b1;
   assign temp_int2_n = 1'b1;


endmodule
