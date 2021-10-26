//-----------------------------------------------------------------------------
// Title         : Fan PDM
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : fan.sv
// Author        : Daniel Sun  <dsun7c4osh@gmail.com>
// Created       : 02.11.2018
// Last modified : 02.11.2018
//-----------------------------------------------------------------------------
// Description : Fan pulse width modulator 
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 02.11.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module fan
  (
   input logic         rst_n,
   input logic         clk,

   input logic         tsc_1ppms,
   input logic         tsc_1ppus,

   input logic [7:0]   fan_pct,
   input logic         fan_tach,

   output logic        fan_pwm,
   output logic [19:0] fan_uspr
   );

   // import utils_pkg::*;


   logic [3:0]         pwm_div;
   logic               pwm_ce;
   logic [7:0]         pwm_cnt;
   logic               pwm_term;
   logic               pwm_out;
    
   logic [2:0]         tach_dly;
   logic               tach_pulse;
   logic [19:0]        tach_meas;
   logic [19:0]        tach_msout;


   // First divider to generate clock enable for the PWM
   // Divide by 16
   always_ff @(negedge rst_n, posedge clk)
     begin : fan_pwmdiv
        if (!rst_n)
          begin
            pwm_div  <= '0;
            pwm_ce   <= 1'b0;
          end
        else
          begin
            if (pwm_ce == 1'b1)
                pwm_div  <= '0;
            else
                pwm_div  <= pwm_div + 1;

            if (pwm_div == 4'hE)
                pwm_ce   <= 1'b1;
            else
                pwm_ce   <= 1'b0;
          end
     end


   // Pulse width modulator counter
   always_ff @(negedge rst_n, posedge clk)
     begin : fan_pwmcnt
        if (!rst_n)
          begin
            pwm_cnt  <= '0;
            pwm_term <= 1'b0;
          end
        else
            if (pwm_ce == 1'b1)
              begin
                pwm_cnt  <= pwm_cnt + 1;
                
                if (pwm_cnt == 8'hFE)
                    pwm_term <= 1'b1;
                else
                    pwm_term <= 1'b0;
              end
     end


   // Pulse width modulator output
   always_ff @(negedge rst_n, posedge clk)
     begin : fan_pwmout
        if (!rst_n)
          pwm_out <= 1'b0;
        else
          if (pwm_ce == 1'b1)
            if (pwm_term == 1'b1)
              pwm_out <= 1'b1;
            else if (pwm_cnt == fan_pct)
              pwm_out <= 1'b0;
     end

    
   // Final output register
   delay1 #(.CYCLES(1)) fan_oreg
     (.rst_n, .clk, .d(pwm_out), .q(fan_pwm));

   // ----------------------------------------------------------------------
   // Tach measurement reference is 1 us

   // Tach input buffer and rising edge detector
   always_ff @(negedge rst_n, posedge clk)
     begin : fan_ireg
        if (!rst_n)
          begin
            tach_dly    <= '0;
            tach_pulse  <= 1'b0;
          end
        else
          begin
             tach_dly[0] <= fan_tach;  // input register
             if (tsc_1ppus == 1'b1)
               begin
                  tach_dly[1] <= tach_dly[0];
                  tach_dly[2] <= tach_dly[1];
                  tach_pulse  <= ~tach_dly[2] & tach_dly[1];
               end
          end
     end

    
   // Measure time between tach pulses
   always_ff @(negedge rst_n, posedge clk)
     begin : fan_meas
        logic [$bits(fan_uspr):0] tach_add;
        if (!rst_n)
          begin
            tach_meas  <= '0;
            tach_msout <= '0;
          end
        else
            if (tsc_1ppus == 1'b1)
              begin
                if (tach_pulse == 1'b1)
                  begin
                    tach_meas    <= '0;
                    tach_meas[0] <= 1'b1;   // Start measurement at one
                  end
                else
                  begin
                    // saturating up counter
                    tach_add = {1'b0, tach_meas} + 1;
                    if (tach_add[$left(tach_add)] == 1'b0)
                        tach_meas  <= tach_add;
                  end

                // Output at next pulse or overflow
                if (tach_pulse == 1'b1 || tach_add[$left(tach_add)] == 1'b1)
                    tach_msout <= tach_meas;
              end
     end

   assign fan_uspr = tach_msout;

endmodule
