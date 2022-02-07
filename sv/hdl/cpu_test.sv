//-----------------------------------------------------------------------------
// Title         : CPU tes vectors
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : cpu_test.sv
// Author        : Daniel Sun  <dsun7c4osh@gmail.com>
// Created       : 03.11.2018
// Last modified : 03.11.2018
//-----------------------------------------------------------------------------
// Description : CPU EPC, GPIO output testbench
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 03.11.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module cpu
  (inout logic [14:0]  DDR_addr,
   inout logic [2:0]   DDR_ba,
   inout logic         DDR_cas_n,
   inout logic         DDR_ck_n,
   inout logic         DDR_ck_p,
   inout logic         DDR_cke,
   inout logic         DDR_cs_n,
   inout logic [3:0]   DDR_dm,
   inout logic [31:0]  DDR_dq,
   inout logic [3:0]   DDR_dqs_n,
   inout logic [3:0]   DDR_dqs_p,
   inout logic         DDR_odt,
   inout logic         DDR_ras_n,
   inout logic         DDR_reset_n,
   inout logic         DDR_we_n,
   output logic [0:31] EPC_INTF_addr,
   output logic        EPC_INTF_ads,
   output logic [0:3]  EPC_INTF_be,
   output logic        EPC_INTF_burst,
   input logic         EPC_INTF_clk,
   output logic [0:0]  EPC_INTF_cs_n,
   input logic [0:31]  EPC_INTF_data_i,
   output logic [0:31] EPC_INTF_data_o,
   output logic [0:31] EPC_INTF_data_t,
   output logic        EPC_INTF_rd_n,
   input logic [0:0]   EPC_INTF_rdy,
   output logic        EPC_INTF_rnw,
   input logic         EPC_INTF_rst,
   output logic        EPC_INTF_wr_n,
   output logic        FCLK_CLK0,
   output logic        FCLK_RESET0_N,
   inout logic         FIXED_IO_ddr_vrn,
   inout logic         FIXED_IO_ddr_vrp,
   inout logic [53:0]  FIXED_IO_mio,
   inout logic         FIXED_IO_ps_clk,
   inout logic         FIXED_IO_ps_porb,
   inout logic         FIXED_IO_ps_srstb,
   input logic [15:0]  GPIO_tri_i,
   output logic [15:0] GPIO_tri_o,
   output logic [15:0] GPIO_tri_t,
   input logic         IIC_0_scl_i,
   output logic        IIC_0_scl_o,
   output logic        IIC_0_scl_t,
   input logic         IIC_0_sda_i,
   output logic        IIC_0_sda_o,
   output logic        IIC_0_sda_t,
   input logic         IIC_1_scl_i,
   output logic        IIC_1_scl_o,
   output logic        IIC_1_scl_t,
   input logic         IIC_1_sda_i,
   output logic        IIC_1_sda_o,
   output logic        IIC_1_sda_t,
   input logic         IIC_2_scl_i,
   output logic        IIC_2_scl_o,
   output logic        IIC_2_scl_t,
   input logic         IIC_2_sda_i,
   output logic        IIC_2_sda_o,
   output logic        IIC_2_sda_t,
   input logic [0:0]   Int0,
   input logic [0:0]   Int1,
   input logic [0:0]   Int2,
   input logic [0:0]   Int3,
   input logic         OCXO_CLK100,
   output logic [0:0]  OCXO_RESETN,
   input logic         UART_0_rxd,
   output logic        UART_0_txd,
   input logic         Vp_Vn_v_n,
   input logic         Vp_Vn_v_p
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
   assign IIC_2_scl_o = 1'b0;
   assign IIC_2_scl_t = 1'b0;
   assign IIC_2_sda_o = 1'b0;
   assign IIC_2_sda_t = 1'b0;
   assign UART_0_txd  = 1'b0;

    
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
    

   task automatic reg_write (input logic [31:0] addr,
                             input logic [31:0] data);
      int count;

      count             = 0;
      EPC_INTF_addr     = addr;
      EPC_INTF_ads      = 1'b1;
      EPC_INTF_be       = 4'hf;
      EPC_INTF_cs_n[0]  = 1'b0;
      EPC_INTF_data_o   = data;
      EPC_INTF_data_t   = '0;
      EPC_INTF_rnw      = 1'b0;
      run_clk(clk, 1);

      EPC_INTF_ads      = 1'b0;
      while (EPC_INTF_rdy[0] != 1'b1 && count < 10)
        begin
           count = count + 1;
           run_clk(clk, 1);
        end

      EPC_INTF_cs_n[0]  = 1'b1;
      EPC_INTF_rnw      = 1'b1;
      EPC_INTF_data_t   = '1;
      run_clk(clk, 1);

   endtask

   task automatic reg_read (input logic [31:0] addr);
      int count;

      count             = 0;
      EPC_INTF_addr     = addr;
      EPC_INTF_ads      = 1'b1;
      EPC_INTF_be       = 4'hf;
      EPC_INTF_cs_n[0]  = 1'b0;
      EPC_INTF_data_o   = '1;
      EPC_INTF_data_t   = '1;
      EPC_INTF_rnw      = 1'b1;
      run_clk(clk, 1);

      EPC_INTF_ads      = 1'b0;
      while (EPC_INTF_rdy[0] != 1'b1 && count < 10)
        begin
           count = count + 1;
           run_clk(clk, 1);
        end

      EPC_INTF_cs_n[0]  = 1'b1;
      EPC_INTF_rnw      = 1'b1;
      EPC_INTF_data_t   = '1;
      run_clk(clk, 1);

   endtask

   initial
     begin : regw
        EPC_INTF_addr     = '0;
        EPC_INTF_ads      = 1'b0;
        EPC_INTF_be       = '0;
        EPC_INTF_burst    = 1'b0;
        EPC_INTF_cs_n     = '1;
        EPC_INTF_data_o   = '0;
        EPC_INTF_data_t   = '1;
        EPC_INTF_rd_n     = 1'b1;
        EPC_INTF_rnw      = 1'b1;
        EPC_INTF_wr_n     = 1'b1;

        run_clk(clk, 2000);

        reg_write(32'haaaaaaaa, 32'h55555555);

        run_clk(clk, 100);

        reg_read(32'ha5a5a5a5);

        run_clk(clk, 100);

        reg_write(32'h00000100, 32'h12345678);

        run_clk(clk, 10000);

        reg_write(32'h00000200, 32'h00000080);

        run_clk(clk, 100);

        reg_read(32'h00000000);

        run_clk(clk, 100);

        reg_read(32'h00000314);

        run_clk(clk, 100);

        reg_read(32'h00000100);

        run_clk(clk, 10000);

        reg_write(32'h00000200, 32'h000000ff);

        run_clk(clk, 1000);

        reg_read(32'h00001004);

        run_clk(clk, 1000);

        reg_read(32'h00001830);

        run_clk(clk, 1000);

        reg_read(32'h00000004);

        run_clk(clk, 1000);

        reg_write(32'h00000300, 32'h0000004f);

        run_clk(clk, 100000);

        reg_write(32'h00000124, 32'h000080ff);

        run_clk(clk, 100000);

        reg_read(32'h00000100);

        run_clk(clk, 100000);

        reg_read(32'h00000104);
     end


endmodule
