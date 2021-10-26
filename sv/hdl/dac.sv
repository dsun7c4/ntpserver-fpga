//-----------------------------------------------------------------------------
// Title         : DAC Driver
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : dac.sv
// Author        : Daniel Sun  <dsun7c4osh@gmail.com>
// Created       : 29.10.2018
// Last modified : 29.10.2018
//-----------------------------------------------------------------------------
// Description : DAC driver
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 29.10.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module dac
  (input logic        rst_n,
   input logic        clk,

   input logic        tsc_1pps,
   input logic        tsc_1ppms,

   input logic        dac_ena,
   input logic        dac_tri,
   input logic [15:0] dac_val,

   output logic       dac_sclk,
   output logic       dac_cs_n,
   output logic       dac_sin
   );


   logic              trig;

   logic [15:0]       bit_sr;
   logic [4:0]        bit_cnt;
   logic              finish;

   logic              cs;
   logic              sclk;
   logic              s_in;

   (* keep = "true" *) logic    iob_rst_n;

   (* IOB = "true" *)  logic    dac_sclk_o;
   (* IOB = "true" *)  logic    dac_cs_n_o;
   (* IOB = "true" *)  logic    dac_sin_o;

   (* IOB = "true" *)  logic    dac_sclk_t;
   (* IOB = "true" *)  logic    dac_cs_n_t;
   (* IOB = "true" *)  logic    dac_sin_t;


    // 16-Bit DAC DAC8830ICD (Updates on dac_cs_n rising edge)
    //            _______                               ______
    // dac_cs_n          |_____________  ______________|
    //            _______ _____ _____ _  __ _____ _____ _______
    // dac_sin    _______X_____X_____X_  __X_____X_____X_______
    //                       __    __    __    __    __
    // dac_sclk   __________|  |__|  |_    |__|  |__|  |_______
    //
    // Bit                 15    14    ..     1     0
    //

    // Start triggering, update DAC once per second
   always_ff @(negedge rst_n, posedge clk)
     begin : dac_trig
        if (!rst_n)
            trig <= 1'b0;
        else
            if (tsc_1ppms == 1'b1)
                if (dac_ena == 1'b0)
                    trig <= 1'b0;
                else if (tsc_1pps == 1'b1)
                    trig <= 1'b1;
                else if (finish == 1'b1)
                    trig <= 1'b0;
    end;


    // bit counter
   always_ff @(negedge rst_n, posedge clk)
     begin : dac_cnt
        if (!rst_n)
          begin
             bit_cnt <= '0;
             finish  <= 1'b0;
          end
        else
            if (tsc_1ppms == 1'b1)
                if (dac_ena == 1'b0)
                  begin
                     bit_cnt <= '0;
                     finish  <= 1'b0;
                  end
                else
                  begin
                     if (trig == 1'b0)
                       bit_cnt <= '0;
                     else
                       bit_cnt <= bit_cnt + 1;

                     if (trig == 1'b0)
                        finish  <= 1'b0;
                     else if (bit_cnt == 30) 
                       finish  <= 1'b1;
                     else
                       finish  <= 1'b0;
                  end
     end;



    // Generate DAC control signals
   always_ff @(negedge rst_n, posedge clk)
     begin :  dac_sr
        if (!rst_n)
          begin
             bit_sr <= '0;
             cs     <= 1'b1;
             sclk   <= 1'b0;
             s_in   <= 1'b0;
          end
        else
          begin
             if (tsc_1ppms == 1'b1)
               if (dac_ena == 1'b0)
                 bit_sr <= '0;
               else if (tsc_1pps == 1'b1)
                 bit_sr <= dac_val;
               else if (bit_cnt[0] == 1'b1)
                 bit_sr <= {bit_sr, 1'b0};

                
             cs     <= ~trig;
             sclk   <= bit_cnt[0];
             s_in   <= bit_sr[$left(bit_sr)];
            end
        end


    // ----------------------------------------------------------------------
    // ----------------------------------------------------------------------
    // Written to allow for attributes for force the use of IOB registers.
    // The control signals (preset) can not be on a separate fanout.
    // The IOB attribute also seems to force the synthesizer to keep the
    // duplicate tri-state control registers.

   assign iob_rst_n = rst_n;

    // Final output register
    // Tristate IOB register for dac output
   always_ff @(negedge iob_rst_n, posedge clk)
    begin : dac_tri_oreg
       if (!iob_rst_n)
         begin
            dac_sclk_t <= 1'b1;
            dac_cs_n_t <= 1'b1;
            dac_sin_t  <= 1'b1;
            dac_sclk_o <= 1'b1;
            dac_cs_n_o <= 1'b1;
            dac_sin_o  <= 1'b1;
         end
       else
         begin
            dac_sclk_t <= dac_tri;
            dac_cs_n_t <= dac_tri;
            dac_sin_t  <= dac_tri;
            dac_sclk_o <= sclk;
            dac_cs_n_o <= cs;
            dac_sin_o  <= s_in;
         end;
    end;

   assign dac_cs_n  = dac_cs_n_t == 1'b0 ? dac_cs_n_o : 1'bZ;
   assign dac_sclk  = dac_sclk_t == 1'b0 ? dac_sclk_o : 1'bZ;
   assign dac_sin   = dac_sin_t  == 1'b0 ? dac_sin_o  : 1'bZ;

   // ----------------------------------------------------------------------
   // ----------------------------------------------------------------------

endmodule
