//-----------------------------------------------------------------------------
// Title         : Time Stamp Counter
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : tsc.sv
// Author        : Daniel Sun  <dcsun88osh@gmail.com>
// Created       : 25.10.2018
// Last modified : 25.10.2018
//-----------------------------------------------------------------------------
// Description : Time Stamp Counter
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by  This model is the confidential and
// proprietary property of  and the possession or use of this
// file requires a written license from .
//------------------------------------------------------------------------------
// Modification history :
// 25.10.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module tsc
//  import util_pkg::*;
   (
    input logic         rst_n,
    input logic         clk,

    input logic         gps_1pps,
    input logic         gps_3dfix_d,
    input logic         tsc_read,
    input logic         tsc_sync,
    input logic         pfd_resync,
    output logic        gps_1pps_d,
    output logic        tsc_1pps_d,
    output logic        pll_trig,
    output logic        pfd_status,

    output logic [31:0] pdiff_1pps,
    output logic [31:0] fdiff_1pps,

    output logic [63:0] tsc_cnt,
    output logic [63:0] tsc_cnt1,
    output logic        tsc_1pps,
    output logic        tsc_1ppms,
    output logic        tsc_1ppus
    );

   logic [63:0]         counter;

   logic [27:0]         pps_cnt;
   logic                pps_cnt_term;

   logic [16:0]         ppms_cnt;
   logic                ppms_cnt_term;

   logic [6:0]          ppus_cnt;
   logic                ppus_cnt_term;

   logic [2:0]          gps_1pps_dly;
   logic                gps_1pps_pulse;

   logic                pps_rst;
   logic [2:0]          tsc_1pps_dly;
   logic                tsc_1pps_pulse;

   typedef enum logic [10:0] {
                              PFD_IDLE     = 11'b000_0000_0001,
                              PFD_LEAD     = 11'b000_0000_0010,
                              PFD_LAG      = 11'b000_0000_0100,
                              PFD_TRIG     = 11'b000_0000_1000,
                              PFD_SYNC     = 11'b000_0001_0000,
                              PFD_TSC      = 11'b000_0010_0000,
                              PFD_GPS      = 11'b000_0100_0000,
                              PFD_DET_GPS  = 11'b000_1000_0000,
                              PFD_DET_TSC  = 11'b001_0000_0000,
                              PFD_WAIT_GPS = 11'b010_0000_0000,
                              PFD_WAIT_TS  = 11'b100_0000_0000
                              } pfd_t;

    pfd_t curr_state;
    pfd_t next_state;


   localparam int       CLKS_PER_SEC    = 100000000;
   localparam int       CLKS_PER_MS     = CLKS_PER_SEC / 1000;
   localparam int       CLKS_PER_US     = CLKS_PER_MS  / 1000;
   localparam int       CLKS_PER_SEC_2  = CLKS_PER_SEC / 2;
   localparam int       CLKS_PER_SEC_2N = -CLKS_PER_SEC_2;

   logic                lead;
   logic                lag;
   logic                trig;
   logic                gt_half;
   logic                clr_diff;
   logic                clr_status;
   logic                set_status;

   logic [31:0]         diff_cnt;
   logic [31:0]         pdiff;
   logic [31:0]         fdiff;


   // The TSC counter 64 bit running at 100MHz
   always_ff @(negedge rst_n, posedge clk)
     begin : tsc_counter
        if (!rst_n)
          counter <= '0;
        else
          counter <= counter + 1;
     end;


   // Output read sample register
   // Output count at one second
   always_ff @(negedge rst_n, posedge clk)
     begin : tsc_reg
        if (!rst_n)
          begin
             tsc_cnt  <= '0;
             tsc_cnt1 <= '0;
          end
        else
          begin
             if (tsc_read == 1'b1)
               tsc_cnt  <= counter;

             if (pps_cnt_term == 1'b1)
               tsc_cnt1 <= counter;
          end;
     end;


   // ----------------------------------------------------------------------


   // Reset signal register for pulse per s, ms, us counters and PFD
   always_ff @(negedge rst_n, posedge clk)
     begin : tsc_1pps_rst
        if (!rst_n)
          pps_rst <= '0;
        else
          pps_rst <= tsc_sync & gps_1pps_pulse;
     end;


    // One pulse pulse per second
   always_ff @(negedge rst_n, posedge clk)
     begin : tsc_1pps_ctr
        if (!rst_n)
          begin
             pps_cnt      <= '0;
             pps_cnt_term <= 1'b0;
          end
        else
          begin
             if (pps_cnt_term == 1'b1 || pps_rst == 1'b1)
               pps_cnt      <= '0;
             else
               pps_cnt      <= pps_cnt + 1;

             if (pps_rst == 1'b1)
               pps_cnt_term <= 1'b0;
             else if (pps_cnt == (CLKS_PER_SEC - 2))
               pps_cnt_term <= 1'b1;
             else
               pps_cnt_term <= 1'b0;
          end;
     end;

   assign tsc_1pps = pps_cnt_term;


   // Millisecond pulse generator synchronized to pps
   always_ff @(negedge rst_n, posedge clk)
     begin : tsc_1ppms_ctr
        if (!rst_n)
          begin
            ppms_cnt      <= '0;
            ppms_cnt_term <= 1'b0;
          end
        else
          begin
            if (ppms_cnt_term == 1'b1 || pps_cnt_term == 1'b1 || pps_rst == 1'b1)
                ppms_cnt      <= '0;
            else
                ppms_cnt      <= ppms_cnt + 1;

            if (pps_cnt_term == 1'b1 || pps_rst == 1'b1)
                ppms_cnt_term <= 1'b0;
            else if (ppms_cnt == (CLKS_PER_MS - 2))
                ppms_cnt_term <= 1'b1;
            else
                ppms_cnt_term <= 1'b0;
          end;
     end;

   assign tsc_1ppms = ppms_cnt_term;


   // Microsecond pulse generator synchronized to pps
   always_ff @(negedge rst_n, posedge clk)
     begin : tsc_1ppus_ctr
        if (!rst_n)
          begin
             ppus_cnt      <= '0;
             ppus_cnt_term <= 1'b0;
          end
        else
          begin
             if (ppus_cnt_term == 1'b1 || pps_cnt_term == 1'b1 || pps_rst == 1'b1)
               ppus_cnt      <= '0;
             else
               ppus_cnt      <= ppus_cnt + 1;

             if (pps_cnt_term == 1'b1 || pps_rst == 1'b1)
               ppus_cnt_term <= 1'b0;
             else if (ppus_cnt == (CLKS_PER_US - 2))
               ppus_cnt_term <= 1'b1;
             else
               ppus_cnt_term <= 1'b0;
          end;
     end;

   assign tsc_1ppus = ppus_cnt_term;


   // ----------------------------------------------------------------------


   // GPS 1 pulse per second input register
   // Delay the ocxo 1pps pulse approximately the same amount as the gps 1pps
   always_ff @(negedge rst_n, posedge clk)
     begin : tsc_ppd_delay
        if (!rst_n)
          begin
             gps_1pps_dly   <= '0;
             gps_1pps_pulse <= 1'b0;
             tsc_1pps_dly   <= '0;
             tsc_1pps_pulse <= 1'b0;
          end
        else
          begin
             gps_1pps_dly    <= {gps_1pps_dly, gps_1pps};
             gps_1pps_pulse  <= ~gps_1pps_dly[2] & gps_1pps_dly[1];

            if (pps_rst == 1'b1)
              begin
                 tsc_1pps_dly   <= '0;
                 tsc_1pps_pulse <= 1'b0;
              end
            else
              begin
                 tsc_1pps_dly    <= {tsc_1pps_dly, pps_cnt_term};
                 tsc_1pps_pulse  <= tsc_1pps_dly[1];
              end;
          end;
     end;

   assign gps_1pps_d = gps_1pps_pulse;
   assign tsc_1pps_d = tsc_1pps_pulse;



endmodule
