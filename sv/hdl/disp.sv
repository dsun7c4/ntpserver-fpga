//-----------------------------------------------------------------------------
// Title         : Display controller
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : disp.sv
// Author        : Daniel Sun  <dcsun88osh@gmail.com>
// Created       : 01.11.2018
// Last modified : 01.11.2018
//-----------------------------------------------------------------------------
// Description : Display controller
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by  This model is the confidential and
// proprietary property of  and the possession or use of this
// file requires a written license from .
//------------------------------------------------------------------------------
// Modification history :
// 01.11.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module disp
  import types_pkg::*;
   (
    input logic         rst_n,
    input logic         clk,

    input logic         tsc_1pps,
    input logic         tsc_1ppms,
    input logic         tsc_1ppus,

    input logic         disp_ena,
    input logic [7:0]   disp_page,
    input logic [7:0]   disp_pdm,
    input logic [3:0]   stat_src,
    input logic [15:0]  stat,

      // Display memory
    input logic [9:0]   sram_addr,
    input logic         sram_we,
    input logic [31:0]  sram_datao,
    output logic [31:0] sram_datai,

      // Time of day
    input time_t        cur_time,

      // Output to tlc59282 LED driver
    output logic        disp_sclk,
    output logic        disp_blank,
    output logic        disp_lat,
    output logic        disp_sin,
    output logic        disp_status
    );


   logic [255:0]        disp_data;

   logic [11:0]         lut_addr;
   logic [7:0]          lut_data;


    disp_sr disp_sr_i
      (
       .rst_n(rst_n),
       .clk(clk),

       .tsc_1pps(tsc_1pps),
       .tsc_1ppms(tsc_1ppms),
       .tsc_1ppus(tsc_1ppus),

       .disp_data(disp_data),

       .disp_sclk(disp_sclk),
       .disp_lat(disp_lat),
       .disp_sin(disp_sin)
       );

    disp_lut disp_lut_i
      (
       .rst_n(rst_n),
       .clk(clk),

       .sram_addr(sram_addr),
       .sram_we(sram_we),
       .sram_datao(sram_datao),
       .sram_datai(sram_datai),

       .lut_addr(lut_addr),
       .lut_data(lut_data)
       );


    disp_dark disp_dark_i
      (
       .rst_n(rst_n),
       .clk(clk),

       .tsc_1ppus(tsc_1ppus),
       .stat_src(stat_src),
       .stat(stat),

       .disp_pdm(disp_pdm),

       .disp_blank(disp_blank),
       .disp_status(disp_status)
       );


    disp_ctl disp_ctl_i
      (
       .rst_n(rst_n),
       .clk(clk),

       .tsc_1ppms(tsc_1ppms),

       .disp_page(disp_page),
       .disp_ena(disp_ena),

       // Time of day
       .cur_time(cur_time),

       // Block memory display buffer and lut
       .lut_addr(lut_addr),
       .lut_data(lut_data),

       // Segment driver data
       .disp_data(disp_data)
       );

endmodule

