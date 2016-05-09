--Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2014.4 (lin64) Build 1071353 Tue Nov 18 16:47:07 MST 2014
--Date        : Sun May  8 17:08:06 2016
--Host        : graviton running 64-bit Debian GNU/Linux 7.10 (wheezy)
--Command     : generate_target cpu_wrapper.bd
--Design      : cpu_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity cpu_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    EPC_INTF_addr : out STD_LOGIC_VECTOR ( 0 to 31 );
    EPC_INTF_ads : out STD_LOGIC;
    EPC_INTF_be : out STD_LOGIC_VECTOR ( 0 to 3 );
    EPC_INTF_burst : out STD_LOGIC;
    EPC_INTF_clk : in STD_LOGIC;
    EPC_INTF_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    EPC_INTF_rd_n : out STD_LOGIC;
    EPC_INTF_rdy : in STD_LOGIC_VECTOR ( 0 to 0 );
    EPC_INTF_rnw : out STD_LOGIC;
    EPC_INTF_rst : in STD_LOGIC;
    EPC_INTF_wr_n : out STD_LOGIC;
    FCLK_CLK0 : out STD_LOGIC;
    FCLK_RESET0_N : out STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    Int0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    Int1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    OCXO_CLK100 : in STD_LOGIC;
    OCXO_RESETN : out STD_LOGIC_VECTOR ( 0 to 0 );
    UART_0_rxd : in STD_LOGIC;
    UART_0_txd : out STD_LOGIC;
    epc_intf_data_io : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    gpio_tri_io : inout STD_LOGIC_VECTOR ( 15 downto 0 );
    iic_0_scl_io : inout STD_LOGIC;
    iic_0_sda_io : inout STD_LOGIC;
    iic_1_scl_io : inout STD_LOGIC;
    iic_1_sda_io : inout STD_LOGIC;
    iic_scl_io : inout STD_LOGIC;
    iic_sda_io : inout STD_LOGIC
  );
end cpu_wrapper;

architecture STRUCTURE of cpu_wrapper is
  component cpu is
  port (
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    UART_0_txd : out STD_LOGIC;
    UART_0_rxd : in STD_LOGIC;
    IIC_0_sda_i : in STD_LOGIC;
    IIC_0_sda_o : out STD_LOGIC;
    IIC_0_sda_t : out STD_LOGIC;
    IIC_0_scl_i : in STD_LOGIC;
    IIC_0_scl_o : out STD_LOGIC;
    IIC_0_scl_t : out STD_LOGIC;
    IIC_1_sda_i : in STD_LOGIC;
    IIC_1_sda_o : out STD_LOGIC;
    IIC_1_sda_t : out STD_LOGIC;
    IIC_1_scl_i : in STD_LOGIC;
    IIC_1_scl_o : out STD_LOGIC;
    IIC_1_scl_t : out STD_LOGIC;
    GPIO_tri_i : in STD_LOGIC_VECTOR ( 15 downto 0 );
    GPIO_tri_o : out STD_LOGIC_VECTOR ( 15 downto 0 );
    GPIO_tri_t : out STD_LOGIC_VECTOR ( 15 downto 0 );
    IIC_scl_i : in STD_LOGIC;
    IIC_scl_o : out STD_LOGIC;
    IIC_scl_t : out STD_LOGIC;
    IIC_sda_i : in STD_LOGIC;
    IIC_sda_o : out STD_LOGIC;
    IIC_sda_t : out STD_LOGIC;
    EPC_INTF_addr : out STD_LOGIC_VECTOR ( 0 to 31 );
    EPC_INTF_ads : out STD_LOGIC;
    EPC_INTF_be : out STD_LOGIC_VECTOR ( 0 to 3 );
    EPC_INTF_burst : out STD_LOGIC;
    EPC_INTF_clk : in STD_LOGIC;
    EPC_INTF_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    EPC_INTF_data_i : in STD_LOGIC_VECTOR ( 0 to 31 );
    EPC_INTF_data_o : out STD_LOGIC_VECTOR ( 0 to 31 );
    EPC_INTF_data_t : out STD_LOGIC_VECTOR ( 0 to 31 );
    EPC_INTF_rd_n : out STD_LOGIC;
    EPC_INTF_rdy : in STD_LOGIC_VECTOR ( 0 to 0 );
    EPC_INTF_rnw : out STD_LOGIC;
    EPC_INTF_rst : in STD_LOGIC;
    EPC_INTF_wr_n : out STD_LOGIC;
    OCXO_CLK100 : in STD_LOGIC;
    OCXO_RESETN : out STD_LOGIC_VECTOR ( 0 to 0 );
    FCLK_CLK0 : out STD_LOGIC;
    FCLK_RESET0_N : out STD_LOGIC;
    Int0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    Int1 : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component cpu;
  component IOBUF is
  port (
    I : in STD_LOGIC;
    O : out STD_LOGIC;
    T : in STD_LOGIC;
    IO : inout STD_LOGIC
  );
  end component IOBUF;
  signal epc_intf_data_i_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal epc_intf_data_i_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal epc_intf_data_i_10 : STD_LOGIC_VECTOR ( 10 to 10 );
  signal epc_intf_data_i_11 : STD_LOGIC_VECTOR ( 11 to 11 );
  signal epc_intf_data_i_12 : STD_LOGIC_VECTOR ( 12 to 12 );
  signal epc_intf_data_i_13 : STD_LOGIC_VECTOR ( 13 to 13 );
  signal epc_intf_data_i_14 : STD_LOGIC_VECTOR ( 14 to 14 );
  signal epc_intf_data_i_15 : STD_LOGIC_VECTOR ( 15 to 15 );
  signal epc_intf_data_i_16 : STD_LOGIC_VECTOR ( 16 to 16 );
  signal epc_intf_data_i_17 : STD_LOGIC_VECTOR ( 17 to 17 );
  signal epc_intf_data_i_18 : STD_LOGIC_VECTOR ( 18 to 18 );
  signal epc_intf_data_i_19 : STD_LOGIC_VECTOR ( 19 to 19 );
  signal epc_intf_data_i_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal epc_intf_data_i_20 : STD_LOGIC_VECTOR ( 20 to 20 );
  signal epc_intf_data_i_21 : STD_LOGIC_VECTOR ( 21 to 21 );
  signal epc_intf_data_i_22 : STD_LOGIC_VECTOR ( 22 to 22 );
  signal epc_intf_data_i_23 : STD_LOGIC_VECTOR ( 23 to 23 );
  signal epc_intf_data_i_24 : STD_LOGIC_VECTOR ( 24 to 24 );
  signal epc_intf_data_i_25 : STD_LOGIC_VECTOR ( 25 to 25 );
  signal epc_intf_data_i_26 : STD_LOGIC_VECTOR ( 26 to 26 );
  signal epc_intf_data_i_27 : STD_LOGIC_VECTOR ( 27 to 27 );
  signal epc_intf_data_i_28 : STD_LOGIC_VECTOR ( 28 to 28 );
  signal epc_intf_data_i_29 : STD_LOGIC_VECTOR ( 29 to 29 );
  signal epc_intf_data_i_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal epc_intf_data_i_30 : STD_LOGIC_VECTOR ( 30 to 30 );
  signal epc_intf_data_i_31 : STD_LOGIC_VECTOR ( 31 to 31 );
  signal epc_intf_data_i_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal epc_intf_data_i_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal epc_intf_data_i_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal epc_intf_data_i_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal epc_intf_data_i_8 : STD_LOGIC_VECTOR ( 8 to 8 );
  signal epc_intf_data_i_9 : STD_LOGIC_VECTOR ( 9 to 9 );
  signal epc_intf_data_io_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal epc_intf_data_io_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal epc_intf_data_io_10 : STD_LOGIC_VECTOR ( 10 to 10 );
  signal epc_intf_data_io_11 : STD_LOGIC_VECTOR ( 11 to 11 );
  signal epc_intf_data_io_12 : STD_LOGIC_VECTOR ( 12 to 12 );
  signal epc_intf_data_io_13 : STD_LOGIC_VECTOR ( 13 to 13 );
  signal epc_intf_data_io_14 : STD_LOGIC_VECTOR ( 14 to 14 );
  signal epc_intf_data_io_15 : STD_LOGIC_VECTOR ( 15 to 15 );
  signal epc_intf_data_io_16 : STD_LOGIC_VECTOR ( 16 to 16 );
  signal epc_intf_data_io_17 : STD_LOGIC_VECTOR ( 17 to 17 );
  signal epc_intf_data_io_18 : STD_LOGIC_VECTOR ( 18 to 18 );
  signal epc_intf_data_io_19 : STD_LOGIC_VECTOR ( 19 to 19 );
  signal epc_intf_data_io_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal epc_intf_data_io_20 : STD_LOGIC_VECTOR ( 20 to 20 );
  signal epc_intf_data_io_21 : STD_LOGIC_VECTOR ( 21 to 21 );
  signal epc_intf_data_io_22 : STD_LOGIC_VECTOR ( 22 to 22 );
  signal epc_intf_data_io_23 : STD_LOGIC_VECTOR ( 23 to 23 );
  signal epc_intf_data_io_24 : STD_LOGIC_VECTOR ( 24 to 24 );
  signal epc_intf_data_io_25 : STD_LOGIC_VECTOR ( 25 to 25 );
  signal epc_intf_data_io_26 : STD_LOGIC_VECTOR ( 26 to 26 );
  signal epc_intf_data_io_27 : STD_LOGIC_VECTOR ( 27 to 27 );
  signal epc_intf_data_io_28 : STD_LOGIC_VECTOR ( 28 to 28 );
  signal epc_intf_data_io_29 : STD_LOGIC_VECTOR ( 29 to 29 );
  signal epc_intf_data_io_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal epc_intf_data_io_30 : STD_LOGIC_VECTOR ( 30 to 30 );
  signal epc_intf_data_io_31 : STD_LOGIC_VECTOR ( 31 to 31 );
  signal epc_intf_data_io_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal epc_intf_data_io_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal epc_intf_data_io_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal epc_intf_data_io_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal epc_intf_data_io_8 : STD_LOGIC_VECTOR ( 8 to 8 );
  signal epc_intf_data_io_9 : STD_LOGIC_VECTOR ( 9 to 9 );
  signal epc_intf_data_o_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal epc_intf_data_o_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal epc_intf_data_o_10 : STD_LOGIC_VECTOR ( 10 to 10 );
  signal epc_intf_data_o_11 : STD_LOGIC_VECTOR ( 11 to 11 );
  signal epc_intf_data_o_12 : STD_LOGIC_VECTOR ( 12 to 12 );
  signal epc_intf_data_o_13 : STD_LOGIC_VECTOR ( 13 to 13 );
  signal epc_intf_data_o_14 : STD_LOGIC_VECTOR ( 14 to 14 );
  signal epc_intf_data_o_15 : STD_LOGIC_VECTOR ( 15 to 15 );
  signal epc_intf_data_o_16 : STD_LOGIC_VECTOR ( 16 to 16 );
  signal epc_intf_data_o_17 : STD_LOGIC_VECTOR ( 17 to 17 );
  signal epc_intf_data_o_18 : STD_LOGIC_VECTOR ( 18 to 18 );
  signal epc_intf_data_o_19 : STD_LOGIC_VECTOR ( 19 to 19 );
  signal epc_intf_data_o_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal epc_intf_data_o_20 : STD_LOGIC_VECTOR ( 20 to 20 );
  signal epc_intf_data_o_21 : STD_LOGIC_VECTOR ( 21 to 21 );
  signal epc_intf_data_o_22 : STD_LOGIC_VECTOR ( 22 to 22 );
  signal epc_intf_data_o_23 : STD_LOGIC_VECTOR ( 23 to 23 );
  signal epc_intf_data_o_24 : STD_LOGIC_VECTOR ( 24 to 24 );
  signal epc_intf_data_o_25 : STD_LOGIC_VECTOR ( 25 to 25 );
  signal epc_intf_data_o_26 : STD_LOGIC_VECTOR ( 26 to 26 );
  signal epc_intf_data_o_27 : STD_LOGIC_VECTOR ( 27 to 27 );
  signal epc_intf_data_o_28 : STD_LOGIC_VECTOR ( 28 to 28 );
  signal epc_intf_data_o_29 : STD_LOGIC_VECTOR ( 29 to 29 );
  signal epc_intf_data_o_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal epc_intf_data_o_30 : STD_LOGIC_VECTOR ( 30 to 30 );
  signal epc_intf_data_o_31 : STD_LOGIC_VECTOR ( 31 to 31 );
  signal epc_intf_data_o_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal epc_intf_data_o_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal epc_intf_data_o_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal epc_intf_data_o_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal epc_intf_data_o_8 : STD_LOGIC_VECTOR ( 8 to 8 );
  signal epc_intf_data_o_9 : STD_LOGIC_VECTOR ( 9 to 9 );
  signal epc_intf_data_t_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal epc_intf_data_t_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal epc_intf_data_t_10 : STD_LOGIC_VECTOR ( 10 to 10 );
  signal epc_intf_data_t_11 : STD_LOGIC_VECTOR ( 11 to 11 );
  signal epc_intf_data_t_12 : STD_LOGIC_VECTOR ( 12 to 12 );
  signal epc_intf_data_t_13 : STD_LOGIC_VECTOR ( 13 to 13 );
  signal epc_intf_data_t_14 : STD_LOGIC_VECTOR ( 14 to 14 );
  signal epc_intf_data_t_15 : STD_LOGIC_VECTOR ( 15 to 15 );
  signal epc_intf_data_t_16 : STD_LOGIC_VECTOR ( 16 to 16 );
  signal epc_intf_data_t_17 : STD_LOGIC_VECTOR ( 17 to 17 );
  signal epc_intf_data_t_18 : STD_LOGIC_VECTOR ( 18 to 18 );
  signal epc_intf_data_t_19 : STD_LOGIC_VECTOR ( 19 to 19 );
  signal epc_intf_data_t_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal epc_intf_data_t_20 : STD_LOGIC_VECTOR ( 20 to 20 );
  signal epc_intf_data_t_21 : STD_LOGIC_VECTOR ( 21 to 21 );
  signal epc_intf_data_t_22 : STD_LOGIC_VECTOR ( 22 to 22 );
  signal epc_intf_data_t_23 : STD_LOGIC_VECTOR ( 23 to 23 );
  signal epc_intf_data_t_24 : STD_LOGIC_VECTOR ( 24 to 24 );
  signal epc_intf_data_t_25 : STD_LOGIC_VECTOR ( 25 to 25 );
  signal epc_intf_data_t_26 : STD_LOGIC_VECTOR ( 26 to 26 );
  signal epc_intf_data_t_27 : STD_LOGIC_VECTOR ( 27 to 27 );
  signal epc_intf_data_t_28 : STD_LOGIC_VECTOR ( 28 to 28 );
  signal epc_intf_data_t_29 : STD_LOGIC_VECTOR ( 29 to 29 );
  signal epc_intf_data_t_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal epc_intf_data_t_30 : STD_LOGIC_VECTOR ( 30 to 30 );
  signal epc_intf_data_t_31 : STD_LOGIC_VECTOR ( 31 to 31 );
  signal epc_intf_data_t_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal epc_intf_data_t_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal epc_intf_data_t_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal epc_intf_data_t_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal epc_intf_data_t_8 : STD_LOGIC_VECTOR ( 8 to 8 );
  signal epc_intf_data_t_9 : STD_LOGIC_VECTOR ( 9 to 9 );
  signal gpio_tri_i_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal gpio_tri_i_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal gpio_tri_i_10 : STD_LOGIC_VECTOR ( 10 to 10 );
  signal gpio_tri_i_11 : STD_LOGIC_VECTOR ( 11 to 11 );
  signal gpio_tri_i_12 : STD_LOGIC_VECTOR ( 12 to 12 );
  signal gpio_tri_i_13 : STD_LOGIC_VECTOR ( 13 to 13 );
  signal gpio_tri_i_14 : STD_LOGIC_VECTOR ( 14 to 14 );
  signal gpio_tri_i_15 : STD_LOGIC_VECTOR ( 15 to 15 );
  signal gpio_tri_i_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal gpio_tri_i_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal gpio_tri_i_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal gpio_tri_i_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal gpio_tri_i_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal gpio_tri_i_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal gpio_tri_i_8 : STD_LOGIC_VECTOR ( 8 to 8 );
  signal gpio_tri_i_9 : STD_LOGIC_VECTOR ( 9 to 9 );
  signal gpio_tri_io_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal gpio_tri_io_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal gpio_tri_io_10 : STD_LOGIC_VECTOR ( 10 to 10 );
  signal gpio_tri_io_11 : STD_LOGIC_VECTOR ( 11 to 11 );
  signal gpio_tri_io_12 : STD_LOGIC_VECTOR ( 12 to 12 );
  signal gpio_tri_io_13 : STD_LOGIC_VECTOR ( 13 to 13 );
  signal gpio_tri_io_14 : STD_LOGIC_VECTOR ( 14 to 14 );
  signal gpio_tri_io_15 : STD_LOGIC_VECTOR ( 15 to 15 );
  signal gpio_tri_io_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal gpio_tri_io_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal gpio_tri_io_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal gpio_tri_io_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal gpio_tri_io_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal gpio_tri_io_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal gpio_tri_io_8 : STD_LOGIC_VECTOR ( 8 to 8 );
  signal gpio_tri_io_9 : STD_LOGIC_VECTOR ( 9 to 9 );
  signal gpio_tri_o_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal gpio_tri_o_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal gpio_tri_o_10 : STD_LOGIC_VECTOR ( 10 to 10 );
  signal gpio_tri_o_11 : STD_LOGIC_VECTOR ( 11 to 11 );
  signal gpio_tri_o_12 : STD_LOGIC_VECTOR ( 12 to 12 );
  signal gpio_tri_o_13 : STD_LOGIC_VECTOR ( 13 to 13 );
  signal gpio_tri_o_14 : STD_LOGIC_VECTOR ( 14 to 14 );
  signal gpio_tri_o_15 : STD_LOGIC_VECTOR ( 15 to 15 );
  signal gpio_tri_o_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal gpio_tri_o_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal gpio_tri_o_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal gpio_tri_o_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal gpio_tri_o_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal gpio_tri_o_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal gpio_tri_o_8 : STD_LOGIC_VECTOR ( 8 to 8 );
  signal gpio_tri_o_9 : STD_LOGIC_VECTOR ( 9 to 9 );
  signal gpio_tri_t_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal gpio_tri_t_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal gpio_tri_t_10 : STD_LOGIC_VECTOR ( 10 to 10 );
  signal gpio_tri_t_11 : STD_LOGIC_VECTOR ( 11 to 11 );
  signal gpio_tri_t_12 : STD_LOGIC_VECTOR ( 12 to 12 );
  signal gpio_tri_t_13 : STD_LOGIC_VECTOR ( 13 to 13 );
  signal gpio_tri_t_14 : STD_LOGIC_VECTOR ( 14 to 14 );
  signal gpio_tri_t_15 : STD_LOGIC_VECTOR ( 15 to 15 );
  signal gpio_tri_t_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal gpio_tri_t_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal gpio_tri_t_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal gpio_tri_t_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal gpio_tri_t_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal gpio_tri_t_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal gpio_tri_t_8 : STD_LOGIC_VECTOR ( 8 to 8 );
  signal gpio_tri_t_9 : STD_LOGIC_VECTOR ( 9 to 9 );
  signal iic_0_scl_i : STD_LOGIC;
  signal iic_0_scl_o : STD_LOGIC;
  signal iic_0_scl_t : STD_LOGIC;
  signal iic_0_sda_i : STD_LOGIC;
  signal iic_0_sda_o : STD_LOGIC;
  signal iic_0_sda_t : STD_LOGIC;
  signal iic_1_scl_i : STD_LOGIC;
  signal iic_1_scl_o : STD_LOGIC;
  signal iic_1_scl_t : STD_LOGIC;
  signal iic_1_sda_i : STD_LOGIC;
  signal iic_1_sda_o : STD_LOGIC;
  signal iic_1_sda_t : STD_LOGIC;
  signal iic_scl_i : STD_LOGIC;
  signal iic_scl_o : STD_LOGIC;
  signal iic_scl_t : STD_LOGIC;
  signal iic_sda_i : STD_LOGIC;
  signal iic_sda_o : STD_LOGIC;
  signal iic_sda_t : STD_LOGIC;
begin
cpu_i: component cpu
    port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      EPC_INTF_addr(0 to 31) => EPC_INTF_addr(0 to 31),
      EPC_INTF_ads => EPC_INTF_ads,
      EPC_INTF_be(0 to 3) => EPC_INTF_be(0 to 3),
      EPC_INTF_burst => EPC_INTF_burst,
      EPC_INTF_clk => EPC_INTF_clk,
      EPC_INTF_cs_n(0) => EPC_INTF_cs_n(0),
      EPC_INTF_data_i(0) => epc_intf_data_i_0(0),
      EPC_INTF_data_i(1) => epc_intf_data_i_1(1),
      EPC_INTF_data_i(2) => epc_intf_data_i_2(2),
      EPC_INTF_data_i(3) => epc_intf_data_i_3(3),
      EPC_INTF_data_i(4) => epc_intf_data_i_4(4),
      EPC_INTF_data_i(5) => epc_intf_data_i_5(5),
      EPC_INTF_data_i(6) => epc_intf_data_i_6(6),
      EPC_INTF_data_i(7) => epc_intf_data_i_7(7),
      EPC_INTF_data_i(8) => epc_intf_data_i_8(8),
      EPC_INTF_data_i(9) => epc_intf_data_i_9(9),
      EPC_INTF_data_i(10) => epc_intf_data_i_10(10),
      EPC_INTF_data_i(11) => epc_intf_data_i_11(11),
      EPC_INTF_data_i(12) => epc_intf_data_i_12(12),
      EPC_INTF_data_i(13) => epc_intf_data_i_13(13),
      EPC_INTF_data_i(14) => epc_intf_data_i_14(14),
      EPC_INTF_data_i(15) => epc_intf_data_i_15(15),
      EPC_INTF_data_i(16) => epc_intf_data_i_16(16),
      EPC_INTF_data_i(17) => epc_intf_data_i_17(17),
      EPC_INTF_data_i(18) => epc_intf_data_i_18(18),
      EPC_INTF_data_i(19) => epc_intf_data_i_19(19),
      EPC_INTF_data_i(20) => epc_intf_data_i_20(20),
      EPC_INTF_data_i(21) => epc_intf_data_i_21(21),
      EPC_INTF_data_i(22) => epc_intf_data_i_22(22),
      EPC_INTF_data_i(23) => epc_intf_data_i_23(23),
      EPC_INTF_data_i(24) => epc_intf_data_i_24(24),
      EPC_INTF_data_i(25) => epc_intf_data_i_25(25),
      EPC_INTF_data_i(26) => epc_intf_data_i_26(26),
      EPC_INTF_data_i(27) => epc_intf_data_i_27(27),
      EPC_INTF_data_i(28) => epc_intf_data_i_28(28),
      EPC_INTF_data_i(29) => epc_intf_data_i_29(29),
      EPC_INTF_data_i(30) => epc_intf_data_i_30(30),
      EPC_INTF_data_i(31) => epc_intf_data_i_31(31),
      EPC_INTF_data_o(0) => epc_intf_data_o_0(0),
      EPC_INTF_data_o(1) => epc_intf_data_o_1(1),
      EPC_INTF_data_o(2) => epc_intf_data_o_2(2),
      EPC_INTF_data_o(3) => epc_intf_data_o_3(3),
      EPC_INTF_data_o(4) => epc_intf_data_o_4(4),
      EPC_INTF_data_o(5) => epc_intf_data_o_5(5),
      EPC_INTF_data_o(6) => epc_intf_data_o_6(6),
      EPC_INTF_data_o(7) => epc_intf_data_o_7(7),
      EPC_INTF_data_o(8) => epc_intf_data_o_8(8),
      EPC_INTF_data_o(9) => epc_intf_data_o_9(9),
      EPC_INTF_data_o(10) => epc_intf_data_o_10(10),
      EPC_INTF_data_o(11) => epc_intf_data_o_11(11),
      EPC_INTF_data_o(12) => epc_intf_data_o_12(12),
      EPC_INTF_data_o(13) => epc_intf_data_o_13(13),
      EPC_INTF_data_o(14) => epc_intf_data_o_14(14),
      EPC_INTF_data_o(15) => epc_intf_data_o_15(15),
      EPC_INTF_data_o(16) => epc_intf_data_o_16(16),
      EPC_INTF_data_o(17) => epc_intf_data_o_17(17),
      EPC_INTF_data_o(18) => epc_intf_data_o_18(18),
      EPC_INTF_data_o(19) => epc_intf_data_o_19(19),
      EPC_INTF_data_o(20) => epc_intf_data_o_20(20),
      EPC_INTF_data_o(21) => epc_intf_data_o_21(21),
      EPC_INTF_data_o(22) => epc_intf_data_o_22(22),
      EPC_INTF_data_o(23) => epc_intf_data_o_23(23),
      EPC_INTF_data_o(24) => epc_intf_data_o_24(24),
      EPC_INTF_data_o(25) => epc_intf_data_o_25(25),
      EPC_INTF_data_o(26) => epc_intf_data_o_26(26),
      EPC_INTF_data_o(27) => epc_intf_data_o_27(27),
      EPC_INTF_data_o(28) => epc_intf_data_o_28(28),
      EPC_INTF_data_o(29) => epc_intf_data_o_29(29),
      EPC_INTF_data_o(30) => epc_intf_data_o_30(30),
      EPC_INTF_data_o(31) => epc_intf_data_o_31(31),
      EPC_INTF_data_t(0) => epc_intf_data_t_0(0),
      EPC_INTF_data_t(1) => epc_intf_data_t_1(1),
      EPC_INTF_data_t(2) => epc_intf_data_t_2(2),
      EPC_INTF_data_t(3) => epc_intf_data_t_3(3),
      EPC_INTF_data_t(4) => epc_intf_data_t_4(4),
      EPC_INTF_data_t(5) => epc_intf_data_t_5(5),
      EPC_INTF_data_t(6) => epc_intf_data_t_6(6),
      EPC_INTF_data_t(7) => epc_intf_data_t_7(7),
      EPC_INTF_data_t(8) => epc_intf_data_t_8(8),
      EPC_INTF_data_t(9) => epc_intf_data_t_9(9),
      EPC_INTF_data_t(10) => epc_intf_data_t_10(10),
      EPC_INTF_data_t(11) => epc_intf_data_t_11(11),
      EPC_INTF_data_t(12) => epc_intf_data_t_12(12),
      EPC_INTF_data_t(13) => epc_intf_data_t_13(13),
      EPC_INTF_data_t(14) => epc_intf_data_t_14(14),
      EPC_INTF_data_t(15) => epc_intf_data_t_15(15),
      EPC_INTF_data_t(16) => epc_intf_data_t_16(16),
      EPC_INTF_data_t(17) => epc_intf_data_t_17(17),
      EPC_INTF_data_t(18) => epc_intf_data_t_18(18),
      EPC_INTF_data_t(19) => epc_intf_data_t_19(19),
      EPC_INTF_data_t(20) => epc_intf_data_t_20(20),
      EPC_INTF_data_t(21) => epc_intf_data_t_21(21),
      EPC_INTF_data_t(22) => epc_intf_data_t_22(22),
      EPC_INTF_data_t(23) => epc_intf_data_t_23(23),
      EPC_INTF_data_t(24) => epc_intf_data_t_24(24),
      EPC_INTF_data_t(25) => epc_intf_data_t_25(25),
      EPC_INTF_data_t(26) => epc_intf_data_t_26(26),
      EPC_INTF_data_t(27) => epc_intf_data_t_27(27),
      EPC_INTF_data_t(28) => epc_intf_data_t_28(28),
      EPC_INTF_data_t(29) => epc_intf_data_t_29(29),
      EPC_INTF_data_t(30) => epc_intf_data_t_30(30),
      EPC_INTF_data_t(31) => epc_intf_data_t_31(31),
      EPC_INTF_rd_n => EPC_INTF_rd_n,
      EPC_INTF_rdy(0) => EPC_INTF_rdy(0),
      EPC_INTF_rnw => EPC_INTF_rnw,
      EPC_INTF_rst => EPC_INTF_rst,
      EPC_INTF_wr_n => EPC_INTF_wr_n,
      FCLK_CLK0 => FCLK_CLK0,
      FCLK_RESET0_N => FCLK_RESET0_N,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      GPIO_tri_i(15) => gpio_tri_i_15(15),
      GPIO_tri_i(14) => gpio_tri_i_14(14),
      GPIO_tri_i(13) => gpio_tri_i_13(13),
      GPIO_tri_i(12) => gpio_tri_i_12(12),
      GPIO_tri_i(11) => gpio_tri_i_11(11),
      GPIO_tri_i(10) => gpio_tri_i_10(10),
      GPIO_tri_i(9) => gpio_tri_i_9(9),
      GPIO_tri_i(8) => gpio_tri_i_8(8),
      GPIO_tri_i(7) => gpio_tri_i_7(7),
      GPIO_tri_i(6) => gpio_tri_i_6(6),
      GPIO_tri_i(5) => gpio_tri_i_5(5),
      GPIO_tri_i(4) => gpio_tri_i_4(4),
      GPIO_tri_i(3) => gpio_tri_i_3(3),
      GPIO_tri_i(2) => gpio_tri_i_2(2),
      GPIO_tri_i(1) => gpio_tri_i_1(1),
      GPIO_tri_i(0) => gpio_tri_i_0(0),
      GPIO_tri_o(15) => gpio_tri_o_15(15),
      GPIO_tri_o(14) => gpio_tri_o_14(14),
      GPIO_tri_o(13) => gpio_tri_o_13(13),
      GPIO_tri_o(12) => gpio_tri_o_12(12),
      GPIO_tri_o(11) => gpio_tri_o_11(11),
      GPIO_tri_o(10) => gpio_tri_o_10(10),
      GPIO_tri_o(9) => gpio_tri_o_9(9),
      GPIO_tri_o(8) => gpio_tri_o_8(8),
      GPIO_tri_o(7) => gpio_tri_o_7(7),
      GPIO_tri_o(6) => gpio_tri_o_6(6),
      GPIO_tri_o(5) => gpio_tri_o_5(5),
      GPIO_tri_o(4) => gpio_tri_o_4(4),
      GPIO_tri_o(3) => gpio_tri_o_3(3),
      GPIO_tri_o(2) => gpio_tri_o_2(2),
      GPIO_tri_o(1) => gpio_tri_o_1(1),
      GPIO_tri_o(0) => gpio_tri_o_0(0),
      GPIO_tri_t(15) => gpio_tri_t_15(15),
      GPIO_tri_t(14) => gpio_tri_t_14(14),
      GPIO_tri_t(13) => gpio_tri_t_13(13),
      GPIO_tri_t(12) => gpio_tri_t_12(12),
      GPIO_tri_t(11) => gpio_tri_t_11(11),
      GPIO_tri_t(10) => gpio_tri_t_10(10),
      GPIO_tri_t(9) => gpio_tri_t_9(9),
      GPIO_tri_t(8) => gpio_tri_t_8(8),
      GPIO_tri_t(7) => gpio_tri_t_7(7),
      GPIO_tri_t(6) => gpio_tri_t_6(6),
      GPIO_tri_t(5) => gpio_tri_t_5(5),
      GPIO_tri_t(4) => gpio_tri_t_4(4),
      GPIO_tri_t(3) => gpio_tri_t_3(3),
      GPIO_tri_t(2) => gpio_tri_t_2(2),
      GPIO_tri_t(1) => gpio_tri_t_1(1),
      GPIO_tri_t(0) => gpio_tri_t_0(0),
      IIC_0_scl_i => iic_0_scl_i,
      IIC_0_scl_o => iic_0_scl_o,
      IIC_0_scl_t => iic_0_scl_t,
      IIC_0_sda_i => iic_0_sda_i,
      IIC_0_sda_o => iic_0_sda_o,
      IIC_0_sda_t => iic_0_sda_t,
      IIC_1_scl_i => iic_1_scl_i,
      IIC_1_scl_o => iic_1_scl_o,
      IIC_1_scl_t => iic_1_scl_t,
      IIC_1_sda_i => iic_1_sda_i,
      IIC_1_sda_o => iic_1_sda_o,
      IIC_1_sda_t => iic_1_sda_t,
      IIC_scl_i => iic_scl_i,
      IIC_scl_o => iic_scl_o,
      IIC_scl_t => iic_scl_t,
      IIC_sda_i => iic_sda_i,
      IIC_sda_o => iic_sda_o,
      IIC_sda_t => iic_sda_t,
      Int0(0) => Int0(0),
      Int1(0) => Int1(0),
      OCXO_CLK100 => OCXO_CLK100,
      OCXO_RESETN(0) => OCXO_RESETN(0),
      UART_0_rxd => UART_0_rxd,
      UART_0_txd => UART_0_txd
    );
epc_intf_data_iobuf_0: component IOBUF
    port map (
      I => epc_intf_data_o_0(0),
      IO => epc_intf_data_io(0),
      O => epc_intf_data_i_0(0),
      T => epc_intf_data_t_0(0)
    );
epc_intf_data_iobuf_1: component IOBUF
    port map (
      I => epc_intf_data_o_1(1),
      IO => epc_intf_data_io(1),
      O => epc_intf_data_i_1(1),
      T => epc_intf_data_t_1(1)
    );
epc_intf_data_iobuf_10: component IOBUF
    port map (
      I => epc_intf_data_o_10(10),
      IO => epc_intf_data_io(10),
      O => epc_intf_data_i_10(10),
      T => epc_intf_data_t_10(10)
    );
epc_intf_data_iobuf_11: component IOBUF
    port map (
      I => epc_intf_data_o_11(11),
      IO => epc_intf_data_io(11),
      O => epc_intf_data_i_11(11),
      T => epc_intf_data_t_11(11)
    );
epc_intf_data_iobuf_12: component IOBUF
    port map (
      I => epc_intf_data_o_12(12),
      IO => epc_intf_data_io(12),
      O => epc_intf_data_i_12(12),
      T => epc_intf_data_t_12(12)
    );
epc_intf_data_iobuf_13: component IOBUF
    port map (
      I => epc_intf_data_o_13(13),
      IO => epc_intf_data_io(13),
      O => epc_intf_data_i_13(13),
      T => epc_intf_data_t_13(13)
    );
epc_intf_data_iobuf_14: component IOBUF
    port map (
      I => epc_intf_data_o_14(14),
      IO => epc_intf_data_io(14),
      O => epc_intf_data_i_14(14),
      T => epc_intf_data_t_14(14)
    );
epc_intf_data_iobuf_15: component IOBUF
    port map (
      I => epc_intf_data_o_15(15),
      IO => epc_intf_data_io(15),
      O => epc_intf_data_i_15(15),
      T => epc_intf_data_t_15(15)
    );
epc_intf_data_iobuf_16: component IOBUF
    port map (
      I => epc_intf_data_o_16(16),
      IO => epc_intf_data_io(16),
      O => epc_intf_data_i_16(16),
      T => epc_intf_data_t_16(16)
    );
epc_intf_data_iobuf_17: component IOBUF
    port map (
      I => epc_intf_data_o_17(17),
      IO => epc_intf_data_io(17),
      O => epc_intf_data_i_17(17),
      T => epc_intf_data_t_17(17)
    );
epc_intf_data_iobuf_18: component IOBUF
    port map (
      I => epc_intf_data_o_18(18),
      IO => epc_intf_data_io(18),
      O => epc_intf_data_i_18(18),
      T => epc_intf_data_t_18(18)
    );
epc_intf_data_iobuf_19: component IOBUF
    port map (
      I => epc_intf_data_o_19(19),
      IO => epc_intf_data_io(19),
      O => epc_intf_data_i_19(19),
      T => epc_intf_data_t_19(19)
    );
epc_intf_data_iobuf_2: component IOBUF
    port map (
      I => epc_intf_data_o_2(2),
      IO => epc_intf_data_io(2),
      O => epc_intf_data_i_2(2),
      T => epc_intf_data_t_2(2)
    );
epc_intf_data_iobuf_20: component IOBUF
    port map (
      I => epc_intf_data_o_20(20),
      IO => epc_intf_data_io(20),
      O => epc_intf_data_i_20(20),
      T => epc_intf_data_t_20(20)
    );
epc_intf_data_iobuf_21: component IOBUF
    port map (
      I => epc_intf_data_o_21(21),
      IO => epc_intf_data_io(21),
      O => epc_intf_data_i_21(21),
      T => epc_intf_data_t_21(21)
    );
epc_intf_data_iobuf_22: component IOBUF
    port map (
      I => epc_intf_data_o_22(22),
      IO => epc_intf_data_io(22),
      O => epc_intf_data_i_22(22),
      T => epc_intf_data_t_22(22)
    );
epc_intf_data_iobuf_23: component IOBUF
    port map (
      I => epc_intf_data_o_23(23),
      IO => epc_intf_data_io(23),
      O => epc_intf_data_i_23(23),
      T => epc_intf_data_t_23(23)
    );
epc_intf_data_iobuf_24: component IOBUF
    port map (
      I => epc_intf_data_o_24(24),
      IO => epc_intf_data_io(24),
      O => epc_intf_data_i_24(24),
      T => epc_intf_data_t_24(24)
    );
epc_intf_data_iobuf_25: component IOBUF
    port map (
      I => epc_intf_data_o_25(25),
      IO => epc_intf_data_io(25),
      O => epc_intf_data_i_25(25),
      T => epc_intf_data_t_25(25)
    );
epc_intf_data_iobuf_26: component IOBUF
    port map (
      I => epc_intf_data_o_26(26),
      IO => epc_intf_data_io(26),
      O => epc_intf_data_i_26(26),
      T => epc_intf_data_t_26(26)
    );
epc_intf_data_iobuf_27: component IOBUF
    port map (
      I => epc_intf_data_o_27(27),
      IO => epc_intf_data_io(27),
      O => epc_intf_data_i_27(27),
      T => epc_intf_data_t_27(27)
    );
epc_intf_data_iobuf_28: component IOBUF
    port map (
      I => epc_intf_data_o_28(28),
      IO => epc_intf_data_io(28),
      O => epc_intf_data_i_28(28),
      T => epc_intf_data_t_28(28)
    );
epc_intf_data_iobuf_29: component IOBUF
    port map (
      I => epc_intf_data_o_29(29),
      IO => epc_intf_data_io(29),
      O => epc_intf_data_i_29(29),
      T => epc_intf_data_t_29(29)
    );
epc_intf_data_iobuf_3: component IOBUF
    port map (
      I => epc_intf_data_o_3(3),
      IO => epc_intf_data_io(3),
      O => epc_intf_data_i_3(3),
      T => epc_intf_data_t_3(3)
    );
epc_intf_data_iobuf_30: component IOBUF
    port map (
      I => epc_intf_data_o_30(30),
      IO => epc_intf_data_io(30),
      O => epc_intf_data_i_30(30),
      T => epc_intf_data_t_30(30)
    );
epc_intf_data_iobuf_31: component IOBUF
    port map (
      I => epc_intf_data_o_31(31),
      IO => epc_intf_data_io(31),
      O => epc_intf_data_i_31(31),
      T => epc_intf_data_t_31(31)
    );
epc_intf_data_iobuf_4: component IOBUF
    port map (
      I => epc_intf_data_o_4(4),
      IO => epc_intf_data_io(4),
      O => epc_intf_data_i_4(4),
      T => epc_intf_data_t_4(4)
    );
epc_intf_data_iobuf_5: component IOBUF
    port map (
      I => epc_intf_data_o_5(5),
      IO => epc_intf_data_io(5),
      O => epc_intf_data_i_5(5),
      T => epc_intf_data_t_5(5)
    );
epc_intf_data_iobuf_6: component IOBUF
    port map (
      I => epc_intf_data_o_6(6),
      IO => epc_intf_data_io(6),
      O => epc_intf_data_i_6(6),
      T => epc_intf_data_t_6(6)
    );
epc_intf_data_iobuf_7: component IOBUF
    port map (
      I => epc_intf_data_o_7(7),
      IO => epc_intf_data_io(7),
      O => epc_intf_data_i_7(7),
      T => epc_intf_data_t_7(7)
    );
epc_intf_data_iobuf_8: component IOBUF
    port map (
      I => epc_intf_data_o_8(8),
      IO => epc_intf_data_io(8),
      O => epc_intf_data_i_8(8),
      T => epc_intf_data_t_8(8)
    );
epc_intf_data_iobuf_9: component IOBUF
    port map (
      I => epc_intf_data_o_9(9),
      IO => epc_intf_data_io(9),
      O => epc_intf_data_i_9(9),
      T => epc_intf_data_t_9(9)
    );
gpio_tri_iobuf_0: component IOBUF
    port map (
      I => gpio_tri_o_0(0),
      IO => gpio_tri_io(0),
      O => gpio_tri_i_0(0),
      T => gpio_tri_t_0(0)
    );
gpio_tri_iobuf_1: component IOBUF
    port map (
      I => gpio_tri_o_1(1),
      IO => gpio_tri_io(1),
      O => gpio_tri_i_1(1),
      T => gpio_tri_t_1(1)
    );
gpio_tri_iobuf_10: component IOBUF
    port map (
      I => gpio_tri_o_10(10),
      IO => gpio_tri_io(10),
      O => gpio_tri_i_10(10),
      T => gpio_tri_t_10(10)
    );
gpio_tri_iobuf_11: component IOBUF
    port map (
      I => gpio_tri_o_11(11),
      IO => gpio_tri_io(11),
      O => gpio_tri_i_11(11),
      T => gpio_tri_t_11(11)
    );
gpio_tri_iobuf_12: component IOBUF
    port map (
      I => gpio_tri_o_12(12),
      IO => gpio_tri_io(12),
      O => gpio_tri_i_12(12),
      T => gpio_tri_t_12(12)
    );
gpio_tri_iobuf_13: component IOBUF
    port map (
      I => gpio_tri_o_13(13),
      IO => gpio_tri_io(13),
      O => gpio_tri_i_13(13),
      T => gpio_tri_t_13(13)
    );
gpio_tri_iobuf_14: component IOBUF
    port map (
      I => gpio_tri_o_14(14),
      IO => gpio_tri_io(14),
      O => gpio_tri_i_14(14),
      T => gpio_tri_t_14(14)
    );
gpio_tri_iobuf_15: component IOBUF
    port map (
      I => gpio_tri_o_15(15),
      IO => gpio_tri_io(15),
      O => gpio_tri_i_15(15),
      T => gpio_tri_t_15(15)
    );
gpio_tri_iobuf_2: component IOBUF
    port map (
      I => gpio_tri_o_2(2),
      IO => gpio_tri_io(2),
      O => gpio_tri_i_2(2),
      T => gpio_tri_t_2(2)
    );
gpio_tri_iobuf_3: component IOBUF
    port map (
      I => gpio_tri_o_3(3),
      IO => gpio_tri_io(3),
      O => gpio_tri_i_3(3),
      T => gpio_tri_t_3(3)
    );
gpio_tri_iobuf_4: component IOBUF
    port map (
      I => gpio_tri_o_4(4),
      IO => gpio_tri_io(4),
      O => gpio_tri_i_4(4),
      T => gpio_tri_t_4(4)
    );
gpio_tri_iobuf_5: component IOBUF
    port map (
      I => gpio_tri_o_5(5),
      IO => gpio_tri_io(5),
      O => gpio_tri_i_5(5),
      T => gpio_tri_t_5(5)
    );
gpio_tri_iobuf_6: component IOBUF
    port map (
      I => gpio_tri_o_6(6),
      IO => gpio_tri_io(6),
      O => gpio_tri_i_6(6),
      T => gpio_tri_t_6(6)
    );
gpio_tri_iobuf_7: component IOBUF
    port map (
      I => gpio_tri_o_7(7),
      IO => gpio_tri_io(7),
      O => gpio_tri_i_7(7),
      T => gpio_tri_t_7(7)
    );
gpio_tri_iobuf_8: component IOBUF
    port map (
      I => gpio_tri_o_8(8),
      IO => gpio_tri_io(8),
      O => gpio_tri_i_8(8),
      T => gpio_tri_t_8(8)
    );
gpio_tri_iobuf_9: component IOBUF
    port map (
      I => gpio_tri_o_9(9),
      IO => gpio_tri_io(9),
      O => gpio_tri_i_9(9),
      T => gpio_tri_t_9(9)
    );
iic_0_scl_iobuf: component IOBUF
    port map (
      I => iic_0_scl_o,
      IO => iic_0_scl_io,
      O => iic_0_scl_i,
      T => iic_0_scl_t
    );
iic_0_sda_iobuf: component IOBUF
    port map (
      I => iic_0_sda_o,
      IO => iic_0_sda_io,
      O => iic_0_sda_i,
      T => iic_0_sda_t
    );
iic_1_scl_iobuf: component IOBUF
    port map (
      I => iic_1_scl_o,
      IO => iic_1_scl_io,
      O => iic_1_scl_i,
      T => iic_1_scl_t
    );
iic_1_sda_iobuf: component IOBUF
    port map (
      I => iic_1_sda_o,
      IO => iic_1_sda_io,
      O => iic_1_sda_i,
      T => iic_1_sda_t
    );
iic_scl_iobuf: component IOBUF
    port map (
      I => iic_scl_o,
      IO => iic_scl_io,
      O => iic_scl_i,
      T => iic_scl_t
    );
iic_sda_iobuf: component IOBUF
    port map (
      I => iic_sda_o,
      IO => iic_sda_io,
      O => iic_sda_i,
      T => iic_sda_t
    );
end STRUCTURE;
