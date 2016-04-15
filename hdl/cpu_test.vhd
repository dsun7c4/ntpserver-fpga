-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : cpu_test.vhd
-- Author     : My Account  <guest@dsun.org>
-- Company    : 
-- Created    : 2016-03-22
-- Last update: 2016-03-23
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-03-22  1.0      guest	Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity cpu is
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
    EPC_INTF_data_i : in STD_LOGIC_VECTOR ( 0 to 31 );
    EPC_INTF_data_o : out STD_LOGIC_VECTOR ( 0 to 31 );
    EPC_INTF_data_t : out STD_LOGIC_VECTOR ( 0 to 31 );
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
    GPIO_tri_i : in STD_LOGIC_VECTOR ( 15 downto 0 );
    GPIO_tri_o : out STD_LOGIC_VECTOR ( 15 downto 0 );
    GPIO_tri_t : out STD_LOGIC_VECTOR ( 15 downto 0 );
    IIC_0_scl_i : in STD_LOGIC;
    IIC_0_scl_o : out STD_LOGIC;
    IIC_0_scl_t : out STD_LOGIC;
    IIC_0_sda_i : in STD_LOGIC;
    IIC_0_sda_o : out STD_LOGIC;
    IIC_0_sda_t : out STD_LOGIC;
    IIC_1_scl_i : in STD_LOGIC;
    IIC_1_scl_o : out STD_LOGIC;
    IIC_1_scl_t : out STD_LOGIC;
    IIC_1_sda_i : in STD_LOGIC;
    IIC_1_sda_o : out STD_LOGIC;
    IIC_1_sda_t : out STD_LOGIC;
    IIC_scl_i : in STD_LOGIC;
    IIC_scl_o : out STD_LOGIC;
    IIC_scl_t : out STD_LOGIC;
    IIC_sda_i : in STD_LOGIC;
    IIC_sda_o : out STD_LOGIC;
    IIC_sda_t : out STD_LOGIC;
    M_AXI_GP0_ACLK : in STD_LOGIC;
    M_AXI_GP1_ACLK : in STD_LOGIC;
    UART_0_rxd : in STD_LOGIC;
    UART_0_txd : out STD_LOGIC;
    ext_reset_in : in STD_LOGIC;
    ext_reset_in_1 : in STD_LOGIC
  );
end cpu;



architecture TEST of cpu is

    --SIGNAL DDR_cas_n    : std_logic;
    --SIGNAL DDR_cke      : std_logic;
    --SIGNAL DDR_ck_n     : std_logic;
    --SIGNAL DDR_ck_p     : std_logic;
    --SIGNAL DDR_cs_n     : std_logic;
    --SIGNAL DDR_reset_n  : std_logic;
    --SIGNAL DDR_odt      : std_logic;
    --SIGNAL DDR_ras_n    : std_logic;
    --SIGNAL DDR_we_n     : std_logic;
    --SIGNAL DDR_ba       : std_logic_vector (2 downto 0);
    --SIGNAL DDR_addr     : std_logic_vector (14 downto 0);
    --SIGNAL DDR_dm       : std_logic_vector (3 downto 0);
    --SIGNAL DDR_dq       : std_logic_vector (31 downto 0);
    --SIGNAL DDR_dqs_n    : std_logic_vector (3 downto 0);
    --SIGNAL DDR_dqs_p    : std_logic_vector (3 downto 0);
    --SIGNAL FIXED_IO_mio : std_logic_vector (53 downto 0);
    --SIGNAL FIXED_IO_ddr_vrn: std_logic;
    --SIGNAL FIXED_IO_ddr_vrp: std_logic;
    --SIGNAL FIXED_IO_ps_srstb: std_logic;
    --SIGNAL FIXED_IO_ps_clk: std_logic;
    --SIGNAL FIXED_IO_ps_porb: std_logic;
    --SIGNAL UART_0_txd   : std_logic;
    --SIGNAL UART_0_rxd   : std_logic;
    --SIGNAL IIC_0_sda_i  : std_logic;
    --SIGNAL IIC_0_sda_o  : std_logic;
    --SIGNAL IIC_0_sda_t  : std_logic;
    --SIGNAL IIC_0_scl_i  : std_logic;
    --SIGNAL IIC_0_scl_o  : std_logic;
    --SIGNAL IIC_0_scl_t  : std_logic;
    --SIGNAL IIC_1_sda_i  : std_logic;
    --SIGNAL IIC_1_sda_o  : std_logic;
    --SIGNAL IIC_1_sda_t  : std_logic;
    --SIGNAL IIC_1_scl_i  : std_logic;
    --SIGNAL IIC_1_scl_o  : std_logic;
    --SIGNAL IIC_1_scl_t  : std_logic;
    --SIGNAL GPIO_tri_i   : std_logic_vector (15 downto 0);
    --SIGNAL GPIO_tri_o   : std_logic_vector (15 downto 0);
    --SIGNAL GPIO_tri_t   : std_logic_vector (15 downto 0);
    --SIGNAL IIC_scl_i    : std_logic;
    --SIGNAL IIC_scl_o    : std_logic;
    --SIGNAL IIC_scl_t    : std_logic;
    --SIGNAL IIC_sda_i    : std_logic;
    --SIGNAL IIC_sda_o    : std_logic;
    --SIGNAL IIC_sda_t    : std_logic;
    --SIGNAL EPC_INTF_addr: std_logic_vector (0 to 31);
    --SIGNAL EPC_INTF_ads : std_logic;
    --SIGNAL EPC_INTF_be  : std_logic_vector (0 to 3);
    --SIGNAL EPC_INTF_burst: std_logic;
    --SIGNAL EPC_INTF_clk : std_logic;
    --SIGNAL EPC_INTF_cs_n: std_logic_vector (0 to 0);
    --SIGNAL EPC_INTF_data_i: std_logic_vector (0 to 31);
    --SIGNAL EPC_INTF_data_o: std_logic_vector (0 to 31);
    --SIGNAL EPC_INTF_data_t: std_logic_vector (0 to 31);
    --SIGNAL EPC_INTF_rd_n: std_logic;
    --SIGNAL EPC_INTF_rdy : std_logic_vector (0 to 0);
    --SIGNAL EPC_INTF_rnw : std_logic;
    --SIGNAL EPC_INTF_rst : std_logic;
    --SIGNAL EPC_INTF_wr_n: std_logic;
    --SIGNAL FCLK_CLK0    : STD_LOGIC;
    --SIGNAL FCLK_RESET0_N: STD_LOGIC;
    --SIGNAL M_AXI_GP0_ACLK: STD_LOGIC;
    --SIGNAL M_AXI_GP1_ACLK: std_logic;
    --SIGNAL ext_reset_in : std_logic;
    --SIGNAL ext_reset_in_1: STD_LOGIC;


begin



end TEST;
