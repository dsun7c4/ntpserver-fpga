//-----------------------------------------------------------------------------
// Title         : Display controller testbench
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : disp_tb.sv
// Author        : Daniel Sun  <dsun7c4osh@gmail.com>
// Created       : 01.11.2018
// Last modified : 01.11.2018
//-----------------------------------------------------------------------------
// Description : Display controller testbench
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 01.11.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module disp_tb
   import tb_pkg::*, types_pkg::*;
   ();

   logic                rst_n;
   logic                clk;

   logic                tsc_1pps;
   logic                tsc_1ppms;
   logic                tsc_1ppus;

   logic                disp_ena;
   logic [7:0]          disp_page;
   logic [7:0]          disp_pdm;
   logic [3:0]          stat_src;
   logic [15:0]         stat;

   // Display memory
   logic [9:0]          sram_addr;
   logic                sram_we;
   logic [31:0]         sram_datao;
   logic [31:0]         sram_datai;

   // Time of day
   time_t               cur_time;

   // Output to tlc59282 LED driver
   logic                disp_sclk;
   logic                disp_blank;
   logic                disp_lat;
   logic                disp_sin;
   logic                disp_status;


   clk_gen   #(.period(10), .duty(50)) clk_100MHZ (.clk(clk));
   rst_n_gen #(.delay(996))            reset      (.rst_n(rst_n));

   disp disp_i (.*);

   // 1 second pulse
   initial
     begin
        tsc_1pps <= 1'b0;

        run_clk(clk, 1000);

        while (1)
          begin
             tsc_1pps <= 1'b1;

             run_clk(clk, 1);

             tsc_1pps <= 1'b0;

             run_clk(clk, 1999999);
          end
     end


   // 1 milli second pulse
   initial
     begin
        tsc_1ppms <= 1'b0;

        run_clk(clk, 1000);

        while (1)
          begin
             tsc_1ppms <= 1'b1;

             run_clk(clk, 1);

             tsc_1ppms <= 1'b0;

             run_clk(clk, 1999);
          end
     end


   // 1 micro second pulse
   initial
     begin
        tsc_1ppus <= 1'b0;

        run_clk(clk, 1000);

        while (1)
          begin
             tsc_1ppus <= 1'b1;

             run_clk(clk, 1);

             tsc_1ppus <= 1'b0;

             run_clk(clk, 1);
          end
    end


   // pdm setting
   initial
     begin
        disp_pdm <= '0;

        run_clk(clk, 2000);

        disp_pdm <= 8'haa;
        
        run_clk(clk, 12800);

        disp_pdm <= 8'hff;
        
        run_clk(clk, 12800);

        disp_pdm <= 8'hfe;
        
        run_clk(clk, 12800);

        disp_pdm <= 8'hfd;
        
        run_clk(clk, 12800);

        disp_pdm <= 8'h7f;
        
        run_clk(clk, 12800);

        disp_pdm <= 8'h80;
        
        run_clk(clk, 12800);

        disp_pdm <= 8'h81;
        
        run_clk(clk, 12800);

        disp_pdm <= 8'h00;
        
        run_clk(clk, 12800);

        disp_pdm <= 8'h01;
        
        run_clk(clk, 12800);

        disp_pdm <= 8'h02;
        
        run_clk(clk, 12800);

        disp_pdm <= 8'h03;
        
        run_clk(clk, 12800);

    end


   // input
   initial
     begin
        disp_ena       <= 1'b1;
        disp_page      <= '0;
        sram_addr      <= '0;
        sram_we        <= 1'b0;
        sram_datao     <= '0;
        stat_src       <= '0;
        stat           <= '0;

        cur_time.t_1ms          <= '0;
        cur_time.t_10ms         <= '0;
        cur_time.t_100ms        <= '0;
        cur_time.t_1s           <= '0;
        cur_time.t_10s          <= '0;
        cur_time.t_1m           <= '0;
        cur_time.t_10m          <= '0;
        cur_time.t_1h           <= '0;
        cur_time.t_10h          <= '0;

        run_clk(clk, 2000);

        run_clk(clk, 10000);
        disp_page      <= 8'h08;

        run_clk(clk, 10000);
        disp_page      <= 8'h1f;

        run_clk(clk, 2000);

     end

endmodule
