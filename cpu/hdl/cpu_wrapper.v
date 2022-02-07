//Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2014.4 (lin64) Build 1071353 Tue Nov 18 16:47:07 MST 2014
//Date        : Mon Feb  7 08:51:43 2022
//Host        : graviton running 64-bit Devuan GNU/Linux 3 (beowulf)
//Command     : generate_target cpu_wrapper.bd
//Design      : cpu_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module cpu_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    EPC_INTF_addr,
    EPC_INTF_ads,
    EPC_INTF_be,
    EPC_INTF_burst,
    EPC_INTF_clk,
    EPC_INTF_cs_n,
    EPC_INTF_rd_n,
    EPC_INTF_rdy,
    EPC_INTF_rnw,
    EPC_INTF_rst,
    EPC_INTF_wr_n,
    FCLK_CLK0,
    FCLK_RESET0_N,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    Int0,
    Int1,
    Int2,
    Int3,
    OCXO_CLK100,
    OCXO_RESETN,
    UART_0_rxd,
    UART_0_txd,
    Vp_Vn_v_n,
    Vp_Vn_v_p,
    epc_intf_data_io,
    gpio_tri_io,
    iic_0_scl_io,
    iic_0_sda_io,
    iic_1_scl_io,
    iic_1_sda_io,
    iic_2_scl_io,
    iic_2_sda_io);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  output [0:31]EPC_INTF_addr;
  output EPC_INTF_ads;
  output [0:3]EPC_INTF_be;
  output EPC_INTF_burst;
  input EPC_INTF_clk;
  output [0:0]EPC_INTF_cs_n;
  output EPC_INTF_rd_n;
  input [0:0]EPC_INTF_rdy;
  output EPC_INTF_rnw;
  input EPC_INTF_rst;
  output EPC_INTF_wr_n;
  output FCLK_CLK0;
  output FCLK_RESET0_N;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  input [0:0]Int0;
  input [0:0]Int1;
  input [0:0]Int2;
  input [0:0]Int3;
  input OCXO_CLK100;
  output [0:0]OCXO_RESETN;
  input UART_0_rxd;
  output UART_0_txd;
  input Vp_Vn_v_n;
  input Vp_Vn_v_p;
  inout [31:0]epc_intf_data_io;
  inout [15:0]gpio_tri_io;
  inout iic_0_scl_io;
  inout iic_0_sda_io;
  inout iic_1_scl_io;
  inout iic_1_sda_io;
  inout iic_2_scl_io;
  inout iic_2_sda_io;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire [0:31]EPC_INTF_addr;
  wire EPC_INTF_ads;
  wire [0:3]EPC_INTF_be;
  wire EPC_INTF_burst;
  wire EPC_INTF_clk;
  wire [0:0]EPC_INTF_cs_n;
  wire EPC_INTF_rd_n;
  wire [0:0]EPC_INTF_rdy;
  wire EPC_INTF_rnw;
  wire EPC_INTF_rst;
  wire EPC_INTF_wr_n;
  wire FCLK_CLK0;
  wire FCLK_RESET0_N;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [0:0]Int0;
  wire [0:0]Int1;
  wire [0:0]Int2;
  wire [0:0]Int3;
  wire OCXO_CLK100;
  wire [0:0]OCXO_RESETN;
  wire UART_0_rxd;
  wire UART_0_txd;
  wire Vp_Vn_v_n;
  wire Vp_Vn_v_p;
  wire [0:0]epc_intf_data_i_0;
  wire [1:1]epc_intf_data_i_1;
  wire [10:10]epc_intf_data_i_10;
  wire [11:11]epc_intf_data_i_11;
  wire [12:12]epc_intf_data_i_12;
  wire [13:13]epc_intf_data_i_13;
  wire [14:14]epc_intf_data_i_14;
  wire [15:15]epc_intf_data_i_15;
  wire [16:16]epc_intf_data_i_16;
  wire [17:17]epc_intf_data_i_17;
  wire [18:18]epc_intf_data_i_18;
  wire [19:19]epc_intf_data_i_19;
  wire [2:2]epc_intf_data_i_2;
  wire [20:20]epc_intf_data_i_20;
  wire [21:21]epc_intf_data_i_21;
  wire [22:22]epc_intf_data_i_22;
  wire [23:23]epc_intf_data_i_23;
  wire [24:24]epc_intf_data_i_24;
  wire [25:25]epc_intf_data_i_25;
  wire [26:26]epc_intf_data_i_26;
  wire [27:27]epc_intf_data_i_27;
  wire [28:28]epc_intf_data_i_28;
  wire [29:29]epc_intf_data_i_29;
  wire [3:3]epc_intf_data_i_3;
  wire [30:30]epc_intf_data_i_30;
  wire [31:31]epc_intf_data_i_31;
  wire [4:4]epc_intf_data_i_4;
  wire [5:5]epc_intf_data_i_5;
  wire [6:6]epc_intf_data_i_6;
  wire [7:7]epc_intf_data_i_7;
  wire [8:8]epc_intf_data_i_8;
  wire [9:9]epc_intf_data_i_9;
  wire [0:0]epc_intf_data_io_0;
  wire [1:1]epc_intf_data_io_1;
  wire [10:10]epc_intf_data_io_10;
  wire [11:11]epc_intf_data_io_11;
  wire [12:12]epc_intf_data_io_12;
  wire [13:13]epc_intf_data_io_13;
  wire [14:14]epc_intf_data_io_14;
  wire [15:15]epc_intf_data_io_15;
  wire [16:16]epc_intf_data_io_16;
  wire [17:17]epc_intf_data_io_17;
  wire [18:18]epc_intf_data_io_18;
  wire [19:19]epc_intf_data_io_19;
  wire [2:2]epc_intf_data_io_2;
  wire [20:20]epc_intf_data_io_20;
  wire [21:21]epc_intf_data_io_21;
  wire [22:22]epc_intf_data_io_22;
  wire [23:23]epc_intf_data_io_23;
  wire [24:24]epc_intf_data_io_24;
  wire [25:25]epc_intf_data_io_25;
  wire [26:26]epc_intf_data_io_26;
  wire [27:27]epc_intf_data_io_27;
  wire [28:28]epc_intf_data_io_28;
  wire [29:29]epc_intf_data_io_29;
  wire [3:3]epc_intf_data_io_3;
  wire [30:30]epc_intf_data_io_30;
  wire [31:31]epc_intf_data_io_31;
  wire [4:4]epc_intf_data_io_4;
  wire [5:5]epc_intf_data_io_5;
  wire [6:6]epc_intf_data_io_6;
  wire [7:7]epc_intf_data_io_7;
  wire [8:8]epc_intf_data_io_8;
  wire [9:9]epc_intf_data_io_9;
  wire [0:0]epc_intf_data_o_0;
  wire [1:1]epc_intf_data_o_1;
  wire [10:10]epc_intf_data_o_10;
  wire [11:11]epc_intf_data_o_11;
  wire [12:12]epc_intf_data_o_12;
  wire [13:13]epc_intf_data_o_13;
  wire [14:14]epc_intf_data_o_14;
  wire [15:15]epc_intf_data_o_15;
  wire [16:16]epc_intf_data_o_16;
  wire [17:17]epc_intf_data_o_17;
  wire [18:18]epc_intf_data_o_18;
  wire [19:19]epc_intf_data_o_19;
  wire [2:2]epc_intf_data_o_2;
  wire [20:20]epc_intf_data_o_20;
  wire [21:21]epc_intf_data_o_21;
  wire [22:22]epc_intf_data_o_22;
  wire [23:23]epc_intf_data_o_23;
  wire [24:24]epc_intf_data_o_24;
  wire [25:25]epc_intf_data_o_25;
  wire [26:26]epc_intf_data_o_26;
  wire [27:27]epc_intf_data_o_27;
  wire [28:28]epc_intf_data_o_28;
  wire [29:29]epc_intf_data_o_29;
  wire [3:3]epc_intf_data_o_3;
  wire [30:30]epc_intf_data_o_30;
  wire [31:31]epc_intf_data_o_31;
  wire [4:4]epc_intf_data_o_4;
  wire [5:5]epc_intf_data_o_5;
  wire [6:6]epc_intf_data_o_6;
  wire [7:7]epc_intf_data_o_7;
  wire [8:8]epc_intf_data_o_8;
  wire [9:9]epc_intf_data_o_9;
  wire [0:0]epc_intf_data_t_0;
  wire [1:1]epc_intf_data_t_1;
  wire [10:10]epc_intf_data_t_10;
  wire [11:11]epc_intf_data_t_11;
  wire [12:12]epc_intf_data_t_12;
  wire [13:13]epc_intf_data_t_13;
  wire [14:14]epc_intf_data_t_14;
  wire [15:15]epc_intf_data_t_15;
  wire [16:16]epc_intf_data_t_16;
  wire [17:17]epc_intf_data_t_17;
  wire [18:18]epc_intf_data_t_18;
  wire [19:19]epc_intf_data_t_19;
  wire [2:2]epc_intf_data_t_2;
  wire [20:20]epc_intf_data_t_20;
  wire [21:21]epc_intf_data_t_21;
  wire [22:22]epc_intf_data_t_22;
  wire [23:23]epc_intf_data_t_23;
  wire [24:24]epc_intf_data_t_24;
  wire [25:25]epc_intf_data_t_25;
  wire [26:26]epc_intf_data_t_26;
  wire [27:27]epc_intf_data_t_27;
  wire [28:28]epc_intf_data_t_28;
  wire [29:29]epc_intf_data_t_29;
  wire [3:3]epc_intf_data_t_3;
  wire [30:30]epc_intf_data_t_30;
  wire [31:31]epc_intf_data_t_31;
  wire [4:4]epc_intf_data_t_4;
  wire [5:5]epc_intf_data_t_5;
  wire [6:6]epc_intf_data_t_6;
  wire [7:7]epc_intf_data_t_7;
  wire [8:8]epc_intf_data_t_8;
  wire [9:9]epc_intf_data_t_9;
  wire [0:0]gpio_tri_i_0;
  wire [1:1]gpio_tri_i_1;
  wire [10:10]gpio_tri_i_10;
  wire [11:11]gpio_tri_i_11;
  wire [12:12]gpio_tri_i_12;
  wire [13:13]gpio_tri_i_13;
  wire [14:14]gpio_tri_i_14;
  wire [15:15]gpio_tri_i_15;
  wire [2:2]gpio_tri_i_2;
  wire [3:3]gpio_tri_i_3;
  wire [4:4]gpio_tri_i_4;
  wire [5:5]gpio_tri_i_5;
  wire [6:6]gpio_tri_i_6;
  wire [7:7]gpio_tri_i_7;
  wire [8:8]gpio_tri_i_8;
  wire [9:9]gpio_tri_i_9;
  wire [0:0]gpio_tri_io_0;
  wire [1:1]gpio_tri_io_1;
  wire [10:10]gpio_tri_io_10;
  wire [11:11]gpio_tri_io_11;
  wire [12:12]gpio_tri_io_12;
  wire [13:13]gpio_tri_io_13;
  wire [14:14]gpio_tri_io_14;
  wire [15:15]gpio_tri_io_15;
  wire [2:2]gpio_tri_io_2;
  wire [3:3]gpio_tri_io_3;
  wire [4:4]gpio_tri_io_4;
  wire [5:5]gpio_tri_io_5;
  wire [6:6]gpio_tri_io_6;
  wire [7:7]gpio_tri_io_7;
  wire [8:8]gpio_tri_io_8;
  wire [9:9]gpio_tri_io_9;
  wire [0:0]gpio_tri_o_0;
  wire [1:1]gpio_tri_o_1;
  wire [10:10]gpio_tri_o_10;
  wire [11:11]gpio_tri_o_11;
  wire [12:12]gpio_tri_o_12;
  wire [13:13]gpio_tri_o_13;
  wire [14:14]gpio_tri_o_14;
  wire [15:15]gpio_tri_o_15;
  wire [2:2]gpio_tri_o_2;
  wire [3:3]gpio_tri_o_3;
  wire [4:4]gpio_tri_o_4;
  wire [5:5]gpio_tri_o_5;
  wire [6:6]gpio_tri_o_6;
  wire [7:7]gpio_tri_o_7;
  wire [8:8]gpio_tri_o_8;
  wire [9:9]gpio_tri_o_9;
  wire [0:0]gpio_tri_t_0;
  wire [1:1]gpio_tri_t_1;
  wire [10:10]gpio_tri_t_10;
  wire [11:11]gpio_tri_t_11;
  wire [12:12]gpio_tri_t_12;
  wire [13:13]gpio_tri_t_13;
  wire [14:14]gpio_tri_t_14;
  wire [15:15]gpio_tri_t_15;
  wire [2:2]gpio_tri_t_2;
  wire [3:3]gpio_tri_t_3;
  wire [4:4]gpio_tri_t_4;
  wire [5:5]gpio_tri_t_5;
  wire [6:6]gpio_tri_t_6;
  wire [7:7]gpio_tri_t_7;
  wire [8:8]gpio_tri_t_8;
  wire [9:9]gpio_tri_t_9;
  wire iic_0_scl_i;
  wire iic_0_scl_io;
  wire iic_0_scl_o;
  wire iic_0_scl_t;
  wire iic_0_sda_i;
  wire iic_0_sda_io;
  wire iic_0_sda_o;
  wire iic_0_sda_t;
  wire iic_1_scl_i;
  wire iic_1_scl_io;
  wire iic_1_scl_o;
  wire iic_1_scl_t;
  wire iic_1_sda_i;
  wire iic_1_sda_io;
  wire iic_1_sda_o;
  wire iic_1_sda_t;
  wire iic_2_scl_i;
  wire iic_2_scl_io;
  wire iic_2_scl_o;
  wire iic_2_scl_t;
  wire iic_2_sda_i;
  wire iic_2_sda_io;
  wire iic_2_sda_o;
  wire iic_2_sda_t;

cpu cpu_i
       (.DDR_addr(DDR_addr),
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
        .EPC_INTF_addr(EPC_INTF_addr),
        .EPC_INTF_ads(EPC_INTF_ads),
        .EPC_INTF_be(EPC_INTF_be),
        .EPC_INTF_burst(EPC_INTF_burst),
        .EPC_INTF_clk(EPC_INTF_clk),
        .EPC_INTF_cs_n(EPC_INTF_cs_n),
        .EPC_INTF_data_i({epc_intf_data_i_0,epc_intf_data_i_1,epc_intf_data_i_2,epc_intf_data_i_3,epc_intf_data_i_4,epc_intf_data_i_5,epc_intf_data_i_6,epc_intf_data_i_7,epc_intf_data_i_8,epc_intf_data_i_9,epc_intf_data_i_10,epc_intf_data_i_11,epc_intf_data_i_12,epc_intf_data_i_13,epc_intf_data_i_14,epc_intf_data_i_15,epc_intf_data_i_16,epc_intf_data_i_17,epc_intf_data_i_18,epc_intf_data_i_19,epc_intf_data_i_20,epc_intf_data_i_21,epc_intf_data_i_22,epc_intf_data_i_23,epc_intf_data_i_24,epc_intf_data_i_25,epc_intf_data_i_26,epc_intf_data_i_27,epc_intf_data_i_28,epc_intf_data_i_29,epc_intf_data_i_30,epc_intf_data_i_31}),
        .EPC_INTF_data_o({epc_intf_data_o_0,epc_intf_data_o_1,epc_intf_data_o_2,epc_intf_data_o_3,epc_intf_data_o_4,epc_intf_data_o_5,epc_intf_data_o_6,epc_intf_data_o_7,epc_intf_data_o_8,epc_intf_data_o_9,epc_intf_data_o_10,epc_intf_data_o_11,epc_intf_data_o_12,epc_intf_data_o_13,epc_intf_data_o_14,epc_intf_data_o_15,epc_intf_data_o_16,epc_intf_data_o_17,epc_intf_data_o_18,epc_intf_data_o_19,epc_intf_data_o_20,epc_intf_data_o_21,epc_intf_data_o_22,epc_intf_data_o_23,epc_intf_data_o_24,epc_intf_data_o_25,epc_intf_data_o_26,epc_intf_data_o_27,epc_intf_data_o_28,epc_intf_data_o_29,epc_intf_data_o_30,epc_intf_data_o_31}),
        .EPC_INTF_data_t({epc_intf_data_t_0,epc_intf_data_t_1,epc_intf_data_t_2,epc_intf_data_t_3,epc_intf_data_t_4,epc_intf_data_t_5,epc_intf_data_t_6,epc_intf_data_t_7,epc_intf_data_t_8,epc_intf_data_t_9,epc_intf_data_t_10,epc_intf_data_t_11,epc_intf_data_t_12,epc_intf_data_t_13,epc_intf_data_t_14,epc_intf_data_t_15,epc_intf_data_t_16,epc_intf_data_t_17,epc_intf_data_t_18,epc_intf_data_t_19,epc_intf_data_t_20,epc_intf_data_t_21,epc_intf_data_t_22,epc_intf_data_t_23,epc_intf_data_t_24,epc_intf_data_t_25,epc_intf_data_t_26,epc_intf_data_t_27,epc_intf_data_t_28,epc_intf_data_t_29,epc_intf_data_t_30,epc_intf_data_t_31}),
        .EPC_INTF_rd_n(EPC_INTF_rd_n),
        .EPC_INTF_rdy(EPC_INTF_rdy),
        .EPC_INTF_rnw(EPC_INTF_rnw),
        .EPC_INTF_rst(EPC_INTF_rst),
        .EPC_INTF_wr_n(EPC_INTF_wr_n),
        .FCLK_CLK0(FCLK_CLK0),
        .FCLK_RESET0_N(FCLK_RESET0_N),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .GPIO_tri_i({gpio_tri_i_15,gpio_tri_i_14,gpio_tri_i_13,gpio_tri_i_12,gpio_tri_i_11,gpio_tri_i_10,gpio_tri_i_9,gpio_tri_i_8,gpio_tri_i_7,gpio_tri_i_6,gpio_tri_i_5,gpio_tri_i_4,gpio_tri_i_3,gpio_tri_i_2,gpio_tri_i_1,gpio_tri_i_0}),
        .GPIO_tri_o({gpio_tri_o_15,gpio_tri_o_14,gpio_tri_o_13,gpio_tri_o_12,gpio_tri_o_11,gpio_tri_o_10,gpio_tri_o_9,gpio_tri_o_8,gpio_tri_o_7,gpio_tri_o_6,gpio_tri_o_5,gpio_tri_o_4,gpio_tri_o_3,gpio_tri_o_2,gpio_tri_o_1,gpio_tri_o_0}),
        .GPIO_tri_t({gpio_tri_t_15,gpio_tri_t_14,gpio_tri_t_13,gpio_tri_t_12,gpio_tri_t_11,gpio_tri_t_10,gpio_tri_t_9,gpio_tri_t_8,gpio_tri_t_7,gpio_tri_t_6,gpio_tri_t_5,gpio_tri_t_4,gpio_tri_t_3,gpio_tri_t_2,gpio_tri_t_1,gpio_tri_t_0}),
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
        .IIC_2_scl_i(iic_2_scl_i),
        .IIC_2_scl_o(iic_2_scl_o),
        .IIC_2_scl_t(iic_2_scl_t),
        .IIC_2_sda_i(iic_2_sda_i),
        .IIC_2_sda_o(iic_2_sda_o),
        .IIC_2_sda_t(iic_2_sda_t),
        .Int0(Int0),
        .Int1(Int1),
        .Int2(Int2),
        .Int3(Int3),
        .OCXO_CLK100(OCXO_CLK100),
        .OCXO_RESETN(OCXO_RESETN),
        .UART_0_rxd(UART_0_rxd),
        .UART_0_txd(UART_0_txd),
        .Vp_Vn_v_n(Vp_Vn_v_n),
        .Vp_Vn_v_p(Vp_Vn_v_p));
IOBUF epc_intf_data_iobuf_0
       (.I(epc_intf_data_o_0),
        .IO(epc_intf_data_io[0]),
        .O(epc_intf_data_i_0),
        .T(epc_intf_data_t_0));
IOBUF epc_intf_data_iobuf_1
       (.I(epc_intf_data_o_1),
        .IO(epc_intf_data_io[1]),
        .O(epc_intf_data_i_1),
        .T(epc_intf_data_t_1));
IOBUF epc_intf_data_iobuf_10
       (.I(epc_intf_data_o_10),
        .IO(epc_intf_data_io[10]),
        .O(epc_intf_data_i_10),
        .T(epc_intf_data_t_10));
IOBUF epc_intf_data_iobuf_11
       (.I(epc_intf_data_o_11),
        .IO(epc_intf_data_io[11]),
        .O(epc_intf_data_i_11),
        .T(epc_intf_data_t_11));
IOBUF epc_intf_data_iobuf_12
       (.I(epc_intf_data_o_12),
        .IO(epc_intf_data_io[12]),
        .O(epc_intf_data_i_12),
        .T(epc_intf_data_t_12));
IOBUF epc_intf_data_iobuf_13
       (.I(epc_intf_data_o_13),
        .IO(epc_intf_data_io[13]),
        .O(epc_intf_data_i_13),
        .T(epc_intf_data_t_13));
IOBUF epc_intf_data_iobuf_14
       (.I(epc_intf_data_o_14),
        .IO(epc_intf_data_io[14]),
        .O(epc_intf_data_i_14),
        .T(epc_intf_data_t_14));
IOBUF epc_intf_data_iobuf_15
       (.I(epc_intf_data_o_15),
        .IO(epc_intf_data_io[15]),
        .O(epc_intf_data_i_15),
        .T(epc_intf_data_t_15));
IOBUF epc_intf_data_iobuf_16
       (.I(epc_intf_data_o_16),
        .IO(epc_intf_data_io[16]),
        .O(epc_intf_data_i_16),
        .T(epc_intf_data_t_16));
IOBUF epc_intf_data_iobuf_17
       (.I(epc_intf_data_o_17),
        .IO(epc_intf_data_io[17]),
        .O(epc_intf_data_i_17),
        .T(epc_intf_data_t_17));
IOBUF epc_intf_data_iobuf_18
       (.I(epc_intf_data_o_18),
        .IO(epc_intf_data_io[18]),
        .O(epc_intf_data_i_18),
        .T(epc_intf_data_t_18));
IOBUF epc_intf_data_iobuf_19
       (.I(epc_intf_data_o_19),
        .IO(epc_intf_data_io[19]),
        .O(epc_intf_data_i_19),
        .T(epc_intf_data_t_19));
IOBUF epc_intf_data_iobuf_2
       (.I(epc_intf_data_o_2),
        .IO(epc_intf_data_io[2]),
        .O(epc_intf_data_i_2),
        .T(epc_intf_data_t_2));
IOBUF epc_intf_data_iobuf_20
       (.I(epc_intf_data_o_20),
        .IO(epc_intf_data_io[20]),
        .O(epc_intf_data_i_20),
        .T(epc_intf_data_t_20));
IOBUF epc_intf_data_iobuf_21
       (.I(epc_intf_data_o_21),
        .IO(epc_intf_data_io[21]),
        .O(epc_intf_data_i_21),
        .T(epc_intf_data_t_21));
IOBUF epc_intf_data_iobuf_22
       (.I(epc_intf_data_o_22),
        .IO(epc_intf_data_io[22]),
        .O(epc_intf_data_i_22),
        .T(epc_intf_data_t_22));
IOBUF epc_intf_data_iobuf_23
       (.I(epc_intf_data_o_23),
        .IO(epc_intf_data_io[23]),
        .O(epc_intf_data_i_23),
        .T(epc_intf_data_t_23));
IOBUF epc_intf_data_iobuf_24
       (.I(epc_intf_data_o_24),
        .IO(epc_intf_data_io[24]),
        .O(epc_intf_data_i_24),
        .T(epc_intf_data_t_24));
IOBUF epc_intf_data_iobuf_25
       (.I(epc_intf_data_o_25),
        .IO(epc_intf_data_io[25]),
        .O(epc_intf_data_i_25),
        .T(epc_intf_data_t_25));
IOBUF epc_intf_data_iobuf_26
       (.I(epc_intf_data_o_26),
        .IO(epc_intf_data_io[26]),
        .O(epc_intf_data_i_26),
        .T(epc_intf_data_t_26));
IOBUF epc_intf_data_iobuf_27
       (.I(epc_intf_data_o_27),
        .IO(epc_intf_data_io[27]),
        .O(epc_intf_data_i_27),
        .T(epc_intf_data_t_27));
IOBUF epc_intf_data_iobuf_28
       (.I(epc_intf_data_o_28),
        .IO(epc_intf_data_io[28]),
        .O(epc_intf_data_i_28),
        .T(epc_intf_data_t_28));
IOBUF epc_intf_data_iobuf_29
       (.I(epc_intf_data_o_29),
        .IO(epc_intf_data_io[29]),
        .O(epc_intf_data_i_29),
        .T(epc_intf_data_t_29));
IOBUF epc_intf_data_iobuf_3
       (.I(epc_intf_data_o_3),
        .IO(epc_intf_data_io[3]),
        .O(epc_intf_data_i_3),
        .T(epc_intf_data_t_3));
IOBUF epc_intf_data_iobuf_30
       (.I(epc_intf_data_o_30),
        .IO(epc_intf_data_io[30]),
        .O(epc_intf_data_i_30),
        .T(epc_intf_data_t_30));
IOBUF epc_intf_data_iobuf_31
       (.I(epc_intf_data_o_31),
        .IO(epc_intf_data_io[31]),
        .O(epc_intf_data_i_31),
        .T(epc_intf_data_t_31));
IOBUF epc_intf_data_iobuf_4
       (.I(epc_intf_data_o_4),
        .IO(epc_intf_data_io[4]),
        .O(epc_intf_data_i_4),
        .T(epc_intf_data_t_4));
IOBUF epc_intf_data_iobuf_5
       (.I(epc_intf_data_o_5),
        .IO(epc_intf_data_io[5]),
        .O(epc_intf_data_i_5),
        .T(epc_intf_data_t_5));
IOBUF epc_intf_data_iobuf_6
       (.I(epc_intf_data_o_6),
        .IO(epc_intf_data_io[6]),
        .O(epc_intf_data_i_6),
        .T(epc_intf_data_t_6));
IOBUF epc_intf_data_iobuf_7
       (.I(epc_intf_data_o_7),
        .IO(epc_intf_data_io[7]),
        .O(epc_intf_data_i_7),
        .T(epc_intf_data_t_7));
IOBUF epc_intf_data_iobuf_8
       (.I(epc_intf_data_o_8),
        .IO(epc_intf_data_io[8]),
        .O(epc_intf_data_i_8),
        .T(epc_intf_data_t_8));
IOBUF epc_intf_data_iobuf_9
       (.I(epc_intf_data_o_9),
        .IO(epc_intf_data_io[9]),
        .O(epc_intf_data_i_9),
        .T(epc_intf_data_t_9));
IOBUF gpio_tri_iobuf_0
       (.I(gpio_tri_o_0),
        .IO(gpio_tri_io[0]),
        .O(gpio_tri_i_0),
        .T(gpio_tri_t_0));
IOBUF gpio_tri_iobuf_1
       (.I(gpio_tri_o_1),
        .IO(gpio_tri_io[1]),
        .O(gpio_tri_i_1),
        .T(gpio_tri_t_1));
IOBUF gpio_tri_iobuf_10
       (.I(gpio_tri_o_10),
        .IO(gpio_tri_io[10]),
        .O(gpio_tri_i_10),
        .T(gpio_tri_t_10));
IOBUF gpio_tri_iobuf_11
       (.I(gpio_tri_o_11),
        .IO(gpio_tri_io[11]),
        .O(gpio_tri_i_11),
        .T(gpio_tri_t_11));
IOBUF gpio_tri_iobuf_12
       (.I(gpio_tri_o_12),
        .IO(gpio_tri_io[12]),
        .O(gpio_tri_i_12),
        .T(gpio_tri_t_12));
IOBUF gpio_tri_iobuf_13
       (.I(gpio_tri_o_13),
        .IO(gpio_tri_io[13]),
        .O(gpio_tri_i_13),
        .T(gpio_tri_t_13));
IOBUF gpio_tri_iobuf_14
       (.I(gpio_tri_o_14),
        .IO(gpio_tri_io[14]),
        .O(gpio_tri_i_14),
        .T(gpio_tri_t_14));
IOBUF gpio_tri_iobuf_15
       (.I(gpio_tri_o_15),
        .IO(gpio_tri_io[15]),
        .O(gpio_tri_i_15),
        .T(gpio_tri_t_15));
IOBUF gpio_tri_iobuf_2
       (.I(gpio_tri_o_2),
        .IO(gpio_tri_io[2]),
        .O(gpio_tri_i_2),
        .T(gpio_tri_t_2));
IOBUF gpio_tri_iobuf_3
       (.I(gpio_tri_o_3),
        .IO(gpio_tri_io[3]),
        .O(gpio_tri_i_3),
        .T(gpio_tri_t_3));
IOBUF gpio_tri_iobuf_4
       (.I(gpio_tri_o_4),
        .IO(gpio_tri_io[4]),
        .O(gpio_tri_i_4),
        .T(gpio_tri_t_4));
IOBUF gpio_tri_iobuf_5
       (.I(gpio_tri_o_5),
        .IO(gpio_tri_io[5]),
        .O(gpio_tri_i_5),
        .T(gpio_tri_t_5));
IOBUF gpio_tri_iobuf_6
       (.I(gpio_tri_o_6),
        .IO(gpio_tri_io[6]),
        .O(gpio_tri_i_6),
        .T(gpio_tri_t_6));
IOBUF gpio_tri_iobuf_7
       (.I(gpio_tri_o_7),
        .IO(gpio_tri_io[7]),
        .O(gpio_tri_i_7),
        .T(gpio_tri_t_7));
IOBUF gpio_tri_iobuf_8
       (.I(gpio_tri_o_8),
        .IO(gpio_tri_io[8]),
        .O(gpio_tri_i_8),
        .T(gpio_tri_t_8));
IOBUF gpio_tri_iobuf_9
       (.I(gpio_tri_o_9),
        .IO(gpio_tri_io[9]),
        .O(gpio_tri_i_9),
        .T(gpio_tri_t_9));
IOBUF iic_0_scl_iobuf
       (.I(iic_0_scl_o),
        .IO(iic_0_scl_io),
        .O(iic_0_scl_i),
        .T(iic_0_scl_t));
IOBUF iic_0_sda_iobuf
       (.I(iic_0_sda_o),
        .IO(iic_0_sda_io),
        .O(iic_0_sda_i),
        .T(iic_0_sda_t));
IOBUF iic_1_scl_iobuf
       (.I(iic_1_scl_o),
        .IO(iic_1_scl_io),
        .O(iic_1_scl_i),
        .T(iic_1_scl_t));
IOBUF iic_1_sda_iobuf
       (.I(iic_1_sda_o),
        .IO(iic_1_sda_io),
        .O(iic_1_sda_i),
        .T(iic_1_sda_t));
IOBUF iic_2_scl_iobuf
       (.I(iic_2_scl_o),
        .IO(iic_2_scl_io),
        .O(iic_2_scl_i),
        .T(iic_2_scl_t));
IOBUF iic_2_sda_iobuf
       (.I(iic_2_sda_o),
        .IO(iic_2_sda_io),
        .O(iic_2_sda_i),
        .T(iic_2_sda_t));
endmodule
