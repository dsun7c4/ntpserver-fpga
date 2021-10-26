//-----------------------------------------------------------------------------
// Title         : Clock
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : clock.sv
// Author        : Daniel Sun  <dsun7c4osh@gmail.com>
// Created       : 01.11.2018
// Last modified : 01.11.2018
//-----------------------------------------------------------------------------
// Description : Clock structure
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 01.11.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module clock
  (
   inout logic [14:0] DDR_addr,
   inout logic [2:0]  DDR_ba,
   inout logic        DDR_cas_n,
   inout logic        DDR_ck_n,
   inout logic        DDR_ck_p,
   inout logic        DDR_cke,
   inout logic        DDR_cs_n,
   inout logic [3:0]  DDR_dm,
   inout logic [31:0] DDR_dq,
   inout logic [3:0]  DDR_dqs_n,
   inout logic [3:0]  DDR_dqs_p,
   inout logic        DDR_odt,
   inout logic        DDR_ras_n,
   inout logic        DDR_reset_n,
   inout logic        DDR_we_n,

   inout logic        FIXED_IO_ddr_vrn,
   inout logic        FIXED_IO_ddr_vrp,
   inout logic [53:0] FIXED_IO_mio,
   inout logic        FIXED_IO_ps_clk,
   inout logic        FIXED_IO_ps_porb,
   inout logic        FIXED_IO_ps_srstb,

   input logic        Vp_Vn_v_n,
   input logic        Vp_Vn_v_p,

   inout logic        rtc_scl,
   inout logic        rtc_sda,
   input logic        rtc_32khz,
   input logic        rtc_int_n,

   inout logic        ocxo_ena,
   input logic        ocxo_clk,
   inout logic        ocxo_scl,
   inout logic        ocxo_sda,

   output logic       dac_sclk,
   output logic       dac_cs_n,
   output logic       dac_sin,

   inout logic        gps_ena,
   input logic        gps_rxd,
   output logic       gps_txd,
   input logic        gps_3dfix,
   input logic        gps_1pps,

   inout logic        temp_scl,
   inout logic        temp_sda,
   input logic        temp_int1_n,
   input logic        temp_int2_n,

   output logic       disp_sclk,
   output logic       disp_blank,
   output logic       disp_lat,
   output logic       disp_sin,
   output logic       disp_status,

   input logic        fan_tach,
   output logic       fan_pwm,

   inout logic [7:0]  gpio
   );


  import types_pkg::*;
   // import utils_pkg::*;


   logic [0:31]       EPC_INTF_addr;
   logic              EPC_INTF_ads;
   logic [0:3]        EPC_INTF_be;
   logic              EPC_INTF_burst;
   logic              EPC_INTF_cs_n;
   logic [0:31]       EPC_INTF_data_i;
   logic [0:31]       EPC_INTF_data_o;
   logic [0:31]       EPC_INTF_data_t;
   logic              EPC_INTF_rd_n;
   logic              EPC_INTF_rdy;
   logic              EPC_INTF_rnw;
   logic              EPC_INTF_wr_n;

   logic [15:0]       GPIO_tri_i;
   logic [15:0]       GPIO_tri_o;
   logic [15:0]       GPIO_tri_t;
   logic              dac_ena;
   logic              dac_tri;
   logic              disp_ena;
   logic              gps_tri;
   logic              gps_uart_rxd;
   logic              gps_uart_txd;
   logic              gps_uart_txd_o;
   logic              gps_uart_txd_t;

   logic              iic_0_scl_i;
   logic              iic_0_scl_o;
   logic              iic_0_scl_t;
   logic              iic_0_sda_i;
   logic              iic_0_sda_o;
   logic              iic_0_sda_t;

   logic              iic_1_scl_i;
   logic              iic_1_scl_o;
   logic              iic_1_scl_t;
   logic              iic_1_sda_i;
   logic              iic_1_sda_o;
   logic              iic_1_sda_t;

   logic              iic_scl_i;
   logic              iic_scl_o;
   logic              iic_scl_t;
   logic              iic_sda_i;
   logic              iic_sda_o;
   logic              iic_sda_t;

   logic [3:0]        intr;
   logic [3:0]        irq;

   logic              fclk;
   logic              fclk_rst_n;
   logic              rst_n;
   logic              pll_rst_n;
   logic              clk_sel;

   logic              clk;
   logic              locked;

   logic              rtc_int_n_d;
   logic              temp_int1_n_d;
   logic              temp_int2_n_d;

   logic [7:0]        fan_pct;
   logic [19:0]       fan_uspr;

   logic              gps_3dfix_d;
   logic              tsc_read;
   logic              tsc_sync;
   logic              pfd_resync;
   logic              gps_1pps_d;
   logic              tsc_1pps_d;
   logic              pll_trig;
   logic              pfd_status;

   logic [31:0]       pdiff_1pps;
   logic [31:0]       fdiff_1pps;

   logic [63:0]       tsc_cnt;
   logic [63:0]       tsc_cnt1;
   logic              tsc_1pps;
   logic              tsc_1ppms;
   logic              tsc_1ppus;

   logic              set;
   time_t             set_time;

   logic [15:0]       dac_val;

   time_t             cur_time;

   logic [9:0]        sram_addr;
   logic              sram_we;
   logic [31:0]       sram_datao;
   logic [31:0]       sram_datai;

   logic [3:0]        stat_src;
   logic [7:0]        disp_page;
   logic [7:0]        disp_pdm;

   cpu cpu_i
     (
      .DDR_addr(DDR_addr),
      .DDR_ba(DDR_ba),
      .DDR_cas_n(DDR_cas_n),
      .DDR_ck_n(DDR_ck_n),
      .DDR_ck_p(DDR_ck_p),
      .DDR_cke(DDR_cke),
      .DDR_cs_n(DDR_cs_n),
      .DDR_dm(DDR_dm),
      .DDR_dq(DDR_dq),
      .DDR_dqs_n(DDR_dqs_n),
      .DDR_dqs_p(DDR_dqs_p),
      .DDR_odt(DDR_odt),
      .DDR_ras_n(DDR_ras_n),
      .DDR_reset_n(DDR_reset_n),
      .DDR_we_n(DDR_we_n),

      .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
      .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
      .FIXED_IO_mio(FIXED_IO_mio),
      .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
      .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
      .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),

      .Vp_Vn_v_n(Vp_Vn_v_n),
      .Vp_Vn_v_p(Vp_Vn_v_p),

      .EPC_INTF_addr(EPC_INTF_addr),
      .EPC_INTF_ads(EPC_INTF_ads),
      .EPC_INTF_be(EPC_INTF_be),
      .EPC_INTF_burst(EPC_INTF_burst),
      .EPC_INTF_clk(clk),
      .EPC_INTF_cs_n(EPC_INTF_cs_n),
      .EPC_INTF_data_i(EPC_INTF_data_i),
      .EPC_INTF_data_o(EPC_INTF_data_o),
      .EPC_INTF_data_t(EPC_INTF_data_t),
      .EPC_INTF_rd_n(EPC_INTF_rd_n),
      .EPC_INTF_rdy(EPC_INTF_rdy),
      .EPC_INTF_rnw(EPC_INTF_rnw),
      .EPC_INTF_rst(rst_n),
      .EPC_INTF_wr_n(EPC_INTF_wr_n),

      .GPIO_tri_i(GPIO_tri_i),
      .GPIO_tri_o(GPIO_tri_o),
      .GPIO_tri_t(GPIO_tri_t),

      .IIC_0_scl_i(iic_0_scl_i),
      .IIC_0_scl_o(iic_0_scl_o),
      .IIC_0_scl_t(iic_0_scl_t),
      .IIC_0_sda_i(iic_0_sda_i),
      .IIC_0_sda_o(iic_0_sda_o),
      .IIC_0_sda_t(iic_0_sda_t),

      .IIC_1_scl_i(iic_1_scl_i),
      .IIC_1_scl_o(iic_1_scl_o),
      .IIC_1_scl_t(iic_1_scl_t),
      .IIC_1_sda_i(iic_1_sda_i),
      .IIC_1_sda_o(iic_1_sda_o),
      .IIC_1_sda_t(iic_1_sda_t),

      .IIC_scl_i(iic_scl_i),
      .IIC_scl_o(iic_scl_o),
      .IIC_scl_t(iic_scl_t),
      .IIC_sda_i(iic_sda_i),
      .IIC_sda_o(iic_sda_o),
      .IIC_sda_t(iic_sda_t),

      .UART_0_rxd(gps_uart_rxd),
      .UART_0_txd(gps_uart_txd),

      .OCXO_CLK100(clk),
      .FCLK_CLK0(fclk),
      .FCLK_RESET0_N(fclk_rst_n),
      .OCXO_RESETN(rst_n),
      .Int0(intr[0]),  // id# 63, hw# 31
      .Int1(intr[1]),  // id# 64, hw# 32
      .Int2(intr[2]),  // id# 65, hw# 33
      .Int3(intr[3])   // id# 66, hw# 34
      );


   // rtc I2C interface
   assign rtc_scl     = iic_0_scl_t == 1'b0 ? iic_0_scl_o : 1'bZ;
   assign iic_0_scl_i = rtc_scl;
   assign rtc_sda     = iic_0_sda_t == 1'b0 ? iic_0_sda_o : 1'bZ;
   assign iic_0_sda_i = rtc_sda;

   // ocxo I2C interface
   assign ocxo_scl    = iic_1_scl_t == 1'b0 ? iic_1_scl_o : 1'bZ;
   assign iic_1_scl_i = ocxo_scl;
   assign ocxo_sda    = iic_1_sda_t == 1'b0 ? iic_1_sda_o : 1'bZ;
   assign iic_1_sda_i = ocxo_sda;

   // Temperature sensor I2C interface
   assign temp_scl   = iic_scl_t == 1'b0 ? iic_scl_o : 1'bZ;
   assign iic_scl_i  = temp_scl;
   assign temp_sda   = iic_sda_t == 1'b0 ? iic_sda_o : 1'bZ;
   assign iic_sda_i  = temp_sda;

   // GPS uart IOB and tristate
   delay1 #(.CYCLES(1), .INIT(1'b1)) gps_rx_i
     (.rst_n(fclk_rst_n), .clk(fclk), .d(gps_rxd),      .q(gps_uart_rxd));
   delay1 #(.CYCLES(1), .INIT(1'b1)) gps_tx_t
     (.rst_n(fclk_rst_n), .clk(fclk), .d(gps_tri),      .q(gps_uart_txd_t));
   delay1 #(.CYCLES(1), .INIT(1'b1)) gps_tx_o
     (.rst_n(fclk_rst_n), .clk(fclk), .d(gps_uart_txd), .q(gps_uart_txd_o));
   assign gps_txd     = gps_uart_txd_t == 1'b0 ? gps_uart_txd_o : 1'bZ;


   io io_i
     (
      .fclk_rst_n(fclk_rst_n),
      .fclk(fclk),
      .rst_n(rst_n),
      .clk(clk),

      // fclk
      .GPIO_tri_i(GPIO_tri_i),
      .GPIO_tri_o(GPIO_tri_o),
      .GPIO_tri_t(GPIO_tri_t),

      // clk
      .locked(locked),
      .dac_ena(dac_ena),
      .dac_tri(dac_tri),
      .disp_ena(disp_ena),

      // fclk
      .pll_rst_n(pll_rst_n),
      .ocxo_ena(ocxo_ena),
      .gps_ena(gps_ena),
      .gps_tri(gps_tri),
      .gpio(gpio)
      );


   // Interrupts, clock domain transfer to cpu clock domain
   delay1 #(.CYCLES(1), .INIT(1'b1)) rtc_irq
     (.rst_n(fclk_rst_n), .clk(fclk), .d(rtc_int_n),   .q(rtc_int_n_d));
   delay1 #(.CYCLES(1), .INIT(1'b1)) temp_irq1
     (.rst_n(fclk_rst_n), .clk(fclk), .d(temp_int1_n), .q(temp_int1_n_d));
   delay1 #(.CYCLES(1), .INIT(1'b1)) temp_irq2
     (.rst_n(fclk_rst_n), .clk(fclk), .d(temp_int2_n), .q(temp_int2_n_d));
   assign irq[0] = ~rtc_int_n_d;    // RTC
   // assign irq[1] = 1'b0;    // 1pps
   // assign irq[2] = 1'b0;    // PLL
   assign irq[3] = ~temp_int1_n_d | ~temp_int2_n_d;    // temp sensors
   delay #(.SIZE($bits(irq)), .CYCLES(2)) irq_i
     (.rst_n(fclk_rst_n), .clk(fclk), .d(irq), .q(intr));

   assign clk_sel = 1'b0;

   syspll syspll_i
     (
      // Clock in ports
      .ocxo_clk(ocxo_clk),
      .fclk(fclk),
      .clk_sel(clk_sel),

      // Clock out ports
      .clk(clk),

      // Status and control signals
      .pll_rst_n(pll_rst_n),
      .locked(locked)
      );


   delay1 #(.CYCLES(2)) gps_3dfix_i
     (.rst_n, .clk, .d(gps_3dfix), .q(gps_3dfix_d));


   regs regs_i
     (
      .rst_n(rst_n),
      .clk(clk),

      .EPC_INTF_addr(EPC_INTF_addr),
      .EPC_INTF_be(EPC_INTF_be),
      .EPC_INTF_burst(EPC_INTF_burst),
      .EPC_INTF_cs_n(EPC_INTF_cs_n),
      .EPC_INTF_data_i(EPC_INTF_data_i),
      .EPC_INTF_data_o(EPC_INTF_data_o),
      .EPC_INTF_rdy(EPC_INTF_rdy),
      .EPC_INTF_rnw(EPC_INTF_rnw),

      // Time stamp counter
      .tsc_cnt(tsc_cnt),
      .tsc_cnt1(tsc_cnt1),
      .tsc_read(tsc_read),

      // Time setting
      .cur_time(cur_time),
      .set(set),
      .set_time(set_time),

      // PLL control
      .gps_3dfix_d(gps_3dfix_d),
      .gps_1pps_d(gps_1pps_d),
      .tsc_1pps_d(tsc_1pps_d),
      .pll_trig(pll_trig),
      .pfd_status(pfd_status),
      .pdiff_1pps(pdiff_1pps),
      .fdiff_1pps(fdiff_1pps),
      .tsc_sync(tsc_sync),
      .pfd_resync(pfd_resync),
      .dac_val(dac_val),
      .pps_irq(irq[1]),
      .pll_irq(irq[2]),

      // Fan ms per revolution, percent speed
      .fan_uspr(fan_uspr),
      .fan_pct(fan_pct),

      // Display memory
      .sram_addr(sram_addr),
      .sram_we(sram_we),
      .sram_datao(sram_datao),
      .sram_datai(sram_datai),

      .stat_src(stat_src),
      .disp_page(disp_page),
      .disp_pdm(disp_pdm)

      );


   fan fan_i
     (
      .rst_n(rst_n),
      .clk(clk),

      .tsc_1ppms(tsc_1ppms),
      .tsc_1ppus(tsc_1ppus),

      .fan_pct(fan_pct),
      .fan_tach(fan_tach),

      .fan_pwm(fan_pwm),
      .fan_uspr(fan_uspr)
      );


   tsc tsc_i
     (
      .rst_n(rst_n),
      .clk(clk),

      .gps_1pps(gps_1pps),
      .gps_3dfix_d(gps_3dfix_d),
      .tsc_read(tsc_read),
      .tsc_sync(tsc_sync),
      .pfd_resync(pfd_resync),
      .gps_1pps_d(gps_1pps_d),
      .tsc_1pps_d(tsc_1pps_d),
      .pll_trig(pll_trig),
      .pfd_status(pfd_status),

      .pdiff_1pps(pdiff_1pps),
      .fdiff_1pps(fdiff_1pps),

      .tsc_cnt(tsc_cnt),
      .tsc_cnt1(tsc_cnt1),
      .tsc_1pps(tsc_1pps),
      .tsc_1ppms(tsc_1ppms),
      .tsc_1ppus(tsc_1ppus)
      );


   bcdtime  bcdtime_i
     (
      .rst_n(rst_n),
      .clk(clk),

      .tsc_1pps(tsc_1pps),
      .tsc_1ppms(tsc_1ppms),

      .set(set),
      .set_time(set_time),

      .cur_time(cur_time)
      );


   dac dac_i
     (
      .rst_n(rst_n),
      .clk(clk),

      .tsc_1pps(tsc_1pps),
      .tsc_1ppms(tsc_1ppms),

      .dac_ena(dac_ena),
      .dac_tri(dac_tri),
      .dac_val(dac_val),

      .dac_sclk(dac_sclk),
      .dac_cs_n(dac_cs_n),
      .dac_sin(dac_sin)
      );


   disp disp_i
     (
      .rst_n(rst_n),
      .clk(clk),

      .tsc_1pps(tsc_1pps),
      .tsc_1ppms(tsc_1ppms),
      .tsc_1ppus(tsc_1ppus),

      .disp_ena(disp_ena),
      .disp_page(disp_page),
      .disp_pdm(disp_pdm),
      .stat_src(stat_src),
      .stat({
             9'b0_0000_0000,
             pfd_status,
             pll_trig,
             tsc_1pps_d,
             gps_1pps_d,
             gps_3dfix_d,
             1'b1,
             1'b0
             }),

      // Display memory
      .sram_addr(sram_addr),
      .sram_we(sram_we),
      .sram_datao(sram_datao),
      .sram_datai(sram_datai),

      // Time of day
      .cur_time(cur_time),

      // Output to tlc59282 LED driver
      .disp_sclk(disp_sclk),
      .disp_blank(disp_blank),
      .disp_lat(disp_lat),
      .disp_sin(disp_sin),
      .disp_status(disp_status)
      );

endmodule
