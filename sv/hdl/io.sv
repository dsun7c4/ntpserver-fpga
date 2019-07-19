//-----------------------------------------------------------------------------
// Title         : IO block
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : io.sv
// Author        : Daniel Sun  <dcsun88osh@gmail.com>
// Created       : 02.11.2018
// Last modified : 02.11.2018
//-----------------------------------------------------------------------------
// Description : GPIO tri-state buffer and clock domain transfer
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by  This model is the confidential and
// proprietary property of  and the possession or use of this
// file requires a written license from .
//------------------------------------------------------------------------------
// Modification history :
// 02.11.2018 : created
//-----------------------------------------------------------------------------

//
//              Address range: 0x412_0000 - 0x4120_0004
//             |  1        |         0         |
//             |5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
// default      T T T T T T T T 0 0 T 1 T T 1 1
//
// 0x4120_0000 |     gpio      |d|a| |g| |l|p|o|  Read/Write
//                              | |   |   | | |
//                              | |   |   | | OCXO enable (power)  R/W
//                              | |   |   | PLL reset bar          R/W
//                              | |   |   PLL Locked               R
//                              | |   GPS enable (power)           R/W
//                              | DAC Controller enable            R/W
//                              Display controller enable          R/W
//
// 0x4120_0004 |               |               |  Tri state control
//

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module io
  (
   input logic         fclk_rst_n,
   input logic         fclk,
   input logic         rst_n,
   input logic         clk,

   // fclk
   output logic [15:0] GPIO_tri_i,
   input logic [15:0]  GPIO_tri_o,
   input logic [15:0]  GPIO_tri_t,

   // clk
   input logic         locked,
   output logic        dac_ena,
   output logic        dac_tri,
   output logic        disp_ena,

   // fclk
   output logic        pll_rst_n,
   inout logic         ocxo_ena,
   inout logic         gps_ena,
   output logic        gps_tri,
   inout logic [7:0]   gpio
   );


   logic [15:0]        gpio_o_d;
   logic [15:0]        gpio_t_d;
   logic               reset_n;

   logic               ocxo_ena_tri;

   logic               ocxo_pwr_ena;
   logic               ocxo_pwr_on;
   logic [12:0]        ocxo_on_ctr;  // 25 us turn on

   logic               gps_ena_tri;

   (* keep = "true" *) logic               gps_pwr_ena;
   logic               gps_pwr_on;
   logic [12:0]        gps_on_ctr;


   // Generic gpio interface output register
   delay #(.SIZE($bits(GPIO_tri_o)), .CYCLES(1)) io_oreg
     (.rst_n(fclk_rst_n), .clk(fclk), .d(GPIO_tri_o), .q(gpio_o_d));
   delay #(.SIZE($bits(GPIO_tri_t)), .CYCLES(1)) io_treg
     (.rst_n(fclk_rst_n), .clk(fclk), .d(GPIO_tri_t), .q(gpio_t_d));


   // gpio control interface
   // gpio[0]
   assign ocxo_ena      = gpio_t_d[0] == 1'b0 ? gpio_o_d[0] : 1'bZ;
   delay1 #(.CYCLES(1)) xtal_ena
     (.rst_n(fclk_rst_n), .clk(fclk), .d(ocxo_ena), .q(GPIO_tri_i[0]));
   delay1 #(.CYCLES(2)) xtal_pwr
     (.rst_n, .clk, .d(GPIO_tri_o[0]), .q(ocxo_pwr_ena));

   // gpio[1]
   assign reset_n       = gpio_o_d[1] & fclk_rst_n;
   assign GPIO_tri_i[1] = reset_n;
   assign pll_rst_n     = reset_n;

   // gpio[2]
   delay1 #(.CYCLES(2)) pll_lock
     (.rst_n(fclk_rst_n), .clk(fclk), .d(locked), .q(GPIO_tri_i[2]));

   // gpio[3]
   assign GPIO_tri_i[3] = 1'b0;

   // gpio[4]
   assign gps_ena       = gpio_t_d[4] == 1'b0 ? gpio_o_d[4] : 1'bZ;
   delay1 #(.CYCLES(1)) loc_ena
     (.rst_n(fclk_rst_n), .clk(fclk), .d(gps_ena), .q(GPIO_tri_i[4]));

   // gpio[5]
   assign GPIO_tri_i[5] = 1'b0;

   // gpio[6]
   delay1 #(.CYCLES(2)) gpio_dac_ena
     (.rst_n, .clk, .d(GPIO_tri_o[6]), .q(dac_ena));
   assign GPIO_tri_i[6] = GPIO_tri_o[6];

   // gpio[7]
   delay1 #(.CYCLES(2)) gpio_disp_ena
     (.rst_n, .clk, .d(GPIO_tri_o[7]), .q(disp_ena));
   assign GPIO_tri_i[7] = GPIO_tri_o[7];


   // gpio[15:8]
   for (genvar i = 8; i < 16; i++)
     begin : io_tri
        // io_tri_iobuf: component IOBUF
        //    port map (
        //        I => GPIO_tri_o(i),
        //        IO => gpio(i),
        //        O => GPIO_tri_i(i),
        //        T => GPIO_tri_t(i)
        //        );

        assign gpio[i - 8] = gpio_t_d[i] == 1'b0 ? gpio_o_d[i] : 1'bZ;
     end

   delay #(.SIZE($bits(gpio)), .CYCLES(1)) io_ireg
     (.rst_n(fclk_rst_n), .clk(fclk), .d(gpio), .q(GPIO_tri_i[15:8]));

    // gpio[0]       <= gpio_t_d[8]  = 1'b0 ? gpio_o_d[8]  : 1'bZ;
    // gpio[1]       <= gpio_t_d[9]  = 1'b0 ? gpio_o_d[9]  : 1'bZ;
    // gpio[2]       <= gpio_t_d[10] = 1'b0 ? gpio_o_d[10] : 1'bZ;
    // gpio[3]       <= gpio_t_d[11] = 1'b0 ? gpio_o_d[11] : 1'bZ;
    // gpio[4]       <= gpio_t_d[12] = 1'b0 ? gpio_o_d[12] : 1'bZ;
    // gpio[5]       <= gpio_t_d[13] = 1'b0 ? gpio_o_d[13] : 1'bZ;
    // gpio[6]       <= gpio_t_d[14] = 1'b0 ? gpio_o_d[14] : 1'bZ;
    // gpio[7]       <= gpio_t_d[15] = 1'b0 ? gpio_o_d[15] : 1'bZ;


    // The ocxo dac 50 us tristate enable delay
    always_ff @(negedge rst_n, posedge clk)
    begin : ocxo_tristate
       if (!rst_n)
         begin
            ocxo_on_ctr <= 5000;
            ocxo_pwr_on <= 1'b0;
            dac_tri     <= 1'b1;
         end
       else
         begin
            if (ocxo_pwr_ena == 1'b0 || ocxo_pwr_on == 1'b1)
              ocxo_on_ctr  <= 5000;
            else
              ocxo_on_ctr  <= ocxo_on_ctr - 1;

            if (ocxo_pwr_ena == 1'b0)
              ocxo_pwr_on <= 1'b0;
            else if (ocxo_on_ctr == 1)
              ocxo_pwr_on <= 1'b1;
            else
              ocxo_pwr_on <= 1'b0;
                
            if (ocxo_pwr_ena == 1'b0)
              dac_tri     <= 1'b1;
            else if (ocxo_pwr_on == 1'b1)
              dac_tri     <= 1'b0;
         end
    end


   // loc_pwr: delay_sig generic map (1) port map (fclk_rst_n, fclk, GPIO_tri_o(4), gps_pwr_ena);
   // Duplicate output buffer for enable
   always_ff @(negedge fclk_rst_n, posedge fclk)
     begin : gps_ena_dup
        if (!fclk_rst_n)
          gps_pwr_ena <= 1'b0;
        else
          gps_pwr_ena <= GPIO_tri_o[4];
     end


   // The gps rs232 tx 50 us tristate enable delay
   always_ff @(negedge fclk_rst_n, posedge fclk)
     begin : gps_tristate
        if (!fclk_rst_n)
          begin
            gps_on_ctr <= 5000;
            gps_pwr_on <= 1'b0;
            gps_tri    <= 1'b1;
          end
        else
          begin
            if (gps_pwr_ena == 1'b0 || gps_pwr_on == 1'b1)
              gps_on_ctr  <= 5000;
            else
              gps_on_ctr <= gps_on_ctr - 1;

            if (gps_pwr_ena == 1'b0)
              gps_pwr_on <= 1'b0;
            else if (gps_on_ctr == 1)
              gps_pwr_on <= 1'b1;
            else
              gps_pwr_on <= 1'b0;
                
            if (gps_pwr_ena == 1'b0)
              gps_tri     <= 1'b1;
            else if (gps_pwr_on == 1'b1)
              gps_tri     <= 1'b0;
          end
     end

endmodule
