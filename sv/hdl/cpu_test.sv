//-----------------------------------------------------------------------------
// Title         : CPU tes vectors
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : cpu_test.sv
// Author        : Daniel Sun  <dcsun88osh@gmail.com>
// Created       : 03.11.2018
// Last modified : 03.11.2018
//-----------------------------------------------------------------------------
// Description : CPU EPC, GPIO output testbench
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by  This model is the confidential and
// proprietary property of  and the possession or use of this
// file requires a written license from .
//------------------------------------------------------------------------------
// Modification history :
// 03.11.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module cpu
  (inout [14:0]  DDR_addr,
   inout [2:0]   DDR_ba,
   inout         DDR_cas_n,
   inout         DDR_ck_n,
   inout         DDR_ck_p,
   inout         DDR_cke,
   inout         DDR_cs_n,
   inout [3:0]   DDR_dm,
   inout [31:0]  DDR_dq,
   inout [3:0]   DDR_dqs_n,
   inout [3:0]   DDR_dqs_p,
   inout         DDR_odt,
   inout         DDR_ras_n,
   inout         DDR_reset_n,
   inout         DDR_we_n,
   output [0:31] EPC_INTF_addr,
   output        EPC_INTF_ads,
   output [0:3]  EPC_INTF_be,
   output        EPC_INTF_burst,
   input         EPC_INTF_clk,
   output [0:0]  EPC_INTF_cs_n,
   input [0:31]  EPC_INTF_data_i,
   output [0:31] EPC_INTF_data_o,
   output [0:31] EPC_INTF_data_t,
   output        EPC_INTF_rd_n,
   input [0:0]   EPC_INTF_rdy,
   output        EPC_INTF_rnw,
   input         EPC_INTF_rst,
   output        EPC_INTF_wr_n,
   output        FCLK_CLK0,
   output        FCLK_RESET0_N,
   inout         FIXED_IO_ddr_vrn,
   inout         FIXED_IO_ddr_vrp,
   inout [53:0]  FIXED_IO_mio,
   inout         FIXED_IO_ps_clk,
   inout         FIXED_IO_ps_porb,
   inout         FIXED_IO_ps_srstb,
   input [15:0]  GPIO_tri_i,
   output [15:0] GPIO_tri_o,
   output [15:0] GPIO_tri_t,
   input         IIC_0_scl_i,
   output        IIC_0_scl_o,
   output        IIC_0_scl_t,
   input         IIC_0_sda_i,
   output        IIC_0_sda_o,
   output        IIC_0_sda_t,
   input         IIC_1_scl_i,
   output        IIC_1_scl_o,
   output        IIC_1_scl_t,
   input         IIC_1_sda_i,
   output        IIC_1_sda_o,
   output        IIC_1_sda_t,
   input         IIC_scl_i,
   output        IIC_scl_o,
   output        IIC_scl_t,
   input         IIC_sda_i,
   output        IIC_sda_o,
   output        IIC_sda_t,
   input [0:0]   Int0,
   input [0:0]   Int1,
   input [0:0]   Int2,
   input [0:0]   Int3,
   input         OCXO_CLK100,
   output [0:0]  OCXO_RESETN,
   input         UART_0_rxd,
   output        UART_0_txd,
   input         Vp_Vn_v_n,
   input         Vp_Vn_v_p
   );


   import tb_pkg::*;


   logic         clk;
   logic         fclk;
   logic         rst_n;

   clk_gen   #(.period(10), .duty(50)) cpu_ck1  (.clk(fclk));
   rst_n_gen #(.delay(996))            cpu_rst  (.rst_n(FCLK_RESET0_N));
   rst_n_gen #(.delay(996))            ocxo_rst (.rst_n(rst_n));

   assign FCLK_CLK0      = fclk;
   assign clk            = OCXO_CLK100;
   assign OCXO_RESETN[0] = rst_n;

   // Place holder signal assignments
   assign IIC_0_scl_o = 1'b0;
   assign IIC_0_scl_t = 1'b0;
   assign IIC_0_sda_o = 1'b0;
   assign IIC_0_sda_t = 1'b0;
   assign IIC_1_scl_o = 1'b0;
   assign IIC_1_scl_t = 1'b0;
   assign IIC_1_sda_o = 1'b0;
   assign IIC_1_sda_t = 1'b0;
   assign IIC_scl_o   = 1'b0;
   assign IIC_scl_t   = 1'b0;
   assign IIC_sda_o   = 1'b0;
   assign IIC_sda_t   = 1'b0;
   assign UART_0_txd  = 1'b0;

    
   assign GPIO_tri_o = 16'h00d3;
   assign GPIO_tri_t = '0;

/* -----\/----- EXCLUDED -----\/-----
   initial
     begin : gpio
        GPIO_tri_o = 16'h00d3;
        GPIO_tri_t = '0;
        run_clk(fclk, 12000);

        GPIO_tri_o = 16'h00c2;
        run_clk(fclk, 12000);

        GPIO_tri_o = 16'h00d3;
        GPIO_tri_t = '0;
        run_clk(fclk, 12000);
     end
 -----/\----- EXCLUDED -----/\----- */
    

   assign EPC_INTF_addr     = '0;
   assign EPC_INTF_ads      = 1'b0;
   assign EPC_INTF_be       = '0;
   assign EPC_INTF_burst    = 1'b0;
   assign EPC_INTF_cs_n     = '1;
   assign EPC_INTF_data_o   = '0;
   assign EPC_INTF_data_t   = '1;
   assign EPC_INTF_rd_n     = 1'b1;
   assign EPC_INTF_rnw      = 1'b1;
   assign EPC_INTF_wr_n     = 1'b1;


endmodule
