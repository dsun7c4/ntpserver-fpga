//-----------------------------------------------------------------------------
// Title         : Display SR
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : disp_sr.sv
// Author        : Daniel Sun  <dcsun88osh@gmail.com>
// Created       : 30.10.2018
// Last modified : 30.10.2018
//-----------------------------------------------------------------------------
// Description : Display shift register
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

module disp_sr
   (
    input logic         rst_n,
    input logic         clk,

    input logic         tsc_1pps,
    input logic         tsc_1ppms,
    input logic         tsc_1ppus,

    input logic [255:0] disp_data,

    output logic        disp_sclk,
    output logic        disp_lat,
    output logic        disp_sin    
    );

   import util_pkg::*;

   logic                 trig;
   logic                 trig_arm;

   logic [255:0]         bit_sr;
   logic [8:0]           bit_cnt;
   logic                 finish;

   logic                 lat;
   logic                 sclk;
   logic                 s_in;



    //
    //                  __
    // disp_lat    ____|  |_____________  ______________________
    //             _______ _____ _____ _  __ _____ _____ _______
    // disp_sin    _______X_____X_____X_  __X_____X_____X_______
    //                        __    __    __    __    __
    // disp_sclk   __________|  |__|  |_    |__|  |__|  |_______
    //
    // Bit                 255   254    ..     1     0
    //


    // Start triggering
   always_ff @(negedge rst_n, posedge clk)
     begin : disp_trig
        if (!rst_n)
          begin
             trig     <= 1'b0;
             trig_arm <= 1'b0;
          end
        else
          begin
             if (tsc_1ppms == 1'b1)
               trig_arm <= 1'b1;
             else if (tsc_1ppus == 1'b1)
               trig_arm <= 1'b0;

             if (tsc_1ppus == 1'b1 && trig_arm == 1'b1)
               trig     <= 1'b1;
             else if (finish == 1'b1)
               trig     <= 1'b0;
          end
     end


    // bit counter
    always_ff @(negedge rst_n, posedge clk)
    begin : disp_cnt
       if (!rst_n)
         begin
            bit_cnt <= '0;
            finish  <= 1'b0;
         end
        else
          begin
             if (trig == 1'b0)
               bit_cnt <= '0;
             else if (tsc_1ppus == 1'b1 && trig == 1'b1)
               bit_cnt <= bit_cnt + 1;

             if (tsc_1ppus == 1'b1 && bit_cnt == 511) 
               finish <= 1'b1;
             else
               finish <= 1'b0;
          end
    end


    // Generate DISP control signals
    always_ff @(negedge rst_n, posedge clk)
    begin : disp_shift
       if (!rst_n)
         begin
            bit_sr        <= '0;
            bit_sr[7:0]   <= 8'h1c;
            bit_sr[15:8]  <= 8'hce;
            bit_sr[23:16] <= 8'hbc;
            lat           <= 1'b0;
            sclk          <= 1'b0;
            s_in          <= 1'b0;
         end
       else
         begin
            if (tsc_1ppms == 1'b1)
              bit_sr        <= disp_data;
            else if (tsc_1ppus == 1'b1 && bit_cnt[0] == 1'b1)
              bit_sr        <= {bit_sr, 1'b0};
                
            if (tsc_1ppus == 1'b1)
              begin
                 lat           <= trig_arm;
                 sclk          <= bit_cnt[0];
                 s_in          <= bit_sr[$left(bit_sr)];
              end
         end
    end


    // Final output register
   delay1 #(.CYCLES(1)) disp_olat  (.rst_n, .clk, .d(lat),  .q(disp_lat));
   delay1 #(.CYCLES(1)) disp_osclk (.rst_n, .clk, .d(sclk), .q(disp_sclk));
   delay1 #(.CYCLES(1)) disp_osin  (.rst_n, .clk, .d(s_in), .q(disp_sin));

endmodule
