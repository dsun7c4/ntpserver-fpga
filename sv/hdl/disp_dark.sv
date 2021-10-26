//-----------------------------------------------------------------------------
// Title         : Display PDM
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : disp_dark.sv
// Author        : Daniel Sun  <dsun7c4osh@gmail.com>
// Created       : 31.10.2018
// Last modified : 31.10.2018
//-----------------------------------------------------------------------------
// Description : Display PDM dimmer
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 31.10.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module disp_dark
   (
    input logic        rst_n,
    input logic        clk,

    input logic        tsc_1ppus,
    input logic [3:0]  stat_src,
    input logic [15:0] stat,

    input logic [7:0]  disp_pdm,

    output logic       disp_blank,
    output logic       disp_status
    );

   import util_pkg::*;

   logic [0:0]         pdm_ce_div;
   logic               pdm_ce;
   logic [7:0]         pdm_cnt;
   logic               pdm_term;
   logic               pdm_status;

   logic               status_mux;
   logic               status;

    // Divider to run pdm at 2 us intervals
    always_ff @(negedge rst_n, posedge clk)
      begin : disp_div
         if (!rst_n)
           begin
              pdm_ce_div <= '0;
              pdm_ce     <= 1'b0;
           end
         else
           begin
              if (tsc_1ppus == 1'b1)
                pdm_ce_div <= pdm_ce_div + 1;

              if (tsc_1ppus == 1'b1 && pdm_ce_div == 0)
                pdm_ce <= 1'b1;
              else
                pdm_ce <= 1'b0;
           end
      end

    
    // Pulse width modulator counter 512uS cycle
   always_ff @(negedge rst_n, posedge clk)
      begin : disp_pdmcnt
         logic [8:0] pdm_sum;

         if (!rst_n)
           begin
              pdm_cnt  <= '0;
              pdm_term <= 1'b1;
           end
         else
            if (pdm_ce == 1'b1)
              begin
                pdm_sum   = {1'b0, pdm_cnt} + disp_pdm;

                pdm_cnt  <= pdm_sum;
                pdm_term <= ~pdm_sum[$left(pdm_sum)];
              end
      end


    // Status LED mux, generate minimum 10 mS pulse for status
    always_ff @(negedge rst_n, posedge clk)
    begin : disp_stat_sel
        if (!rst_n)
            status_mux <= 1'b0;
        else
            status_mux <= stat[stat_src];
    end

   pulse_stretch  #(.CYCLES(1000000)) st (.rst_n, .clk, .d(status_mux), .q(status));
   assign pdm_status = ~pdm_term & status;

    // Final output register
   delay1 #(.CYCLES(1)) disp_oreg        (.rst_n, .clk, .d(pdm_term),   .q(disp_blank));
   delay1 #(.CYCLES(1)) disp_status_oreg (.rst_n, .clk, .d(pdm_status), .q(disp_status));

endmodule
