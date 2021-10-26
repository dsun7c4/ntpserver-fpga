-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : cpu_test.vhd
-- Author     : Daniel Sun  <dsun7c4osh@gmail.com>
-- Company    : 
-- Created    : 2016-03-22
-- Last update: 2016-09-30
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: CPU EPC, GPIO output testbench
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-03-22  1.0      dsun7c4osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.util_pkg.all;
use work.tb_pkg.all;

entity cpu is
    port (
        DDR_addr          : inout std_logic_vector (14 downto 0);
        DDR_ba            : inout std_logic_vector (2 downto 0);
        DDR_cas_n         : inout std_logic;
        DDR_ck_n          : inout std_logic;
        DDR_ck_p          : inout std_logic;
        DDR_cke           : inout std_logic;
        DDR_cs_n          : inout std_logic;
        DDR_dm            : inout std_logic_vector (3 downto 0);
        DDR_dq            : inout std_logic_vector (31 downto 0);
        DDR_dqs_n         : inout std_logic_vector (3 downto 0);
        DDR_dqs_p         : inout std_logic_vector (3 downto 0);
        DDR_odt           : inout std_logic;
        DDR_ras_n         : inout std_logic;
        DDR_reset_n       : inout std_logic;
        DDR_we_n          : inout std_logic;
        EPC_INTF_addr     : out   std_logic_vector (0 to 31);
        EPC_INTF_ads      : out   std_logic;
        EPC_INTF_be       : out   std_logic_vector (0 to 3);
        EPC_INTF_burst    : out   std_logic;
        EPC_INTF_clk      : in    std_logic;
        EPC_INTF_cs_n     : out   std_logic_vector (0 to 0);
        EPC_INTF_data_i   : in    std_logic_vector (0 to 31);
        EPC_INTF_data_o   : out   std_logic_vector (0 to 31);
        EPC_INTF_data_t   : out   std_logic_vector (0 to 31);
        EPC_INTF_rd_n     : out   std_logic;
        EPC_INTF_rdy      : in    std_logic_vector (0 to 0);
        EPC_INTF_rnw      : out   std_logic;
        EPC_INTF_rst      : in    std_logic;
        EPC_INTF_wr_n     : out   std_logic;
        FCLK_CLK0         : out   std_logic;
        FCLK_RESET0_N     : out   std_logic;
        FIXED_IO_ddr_vrn  : inout std_logic;
        FIXED_IO_ddr_vrp  : inout std_logic;
        FIXED_IO_mio      : inout std_logic_vector (53 downto 0);
        FIXED_IO_ps_clk   : inout std_logic;
        FIXED_IO_ps_porb  : inout std_logic;
        FIXED_IO_ps_srstb : inout std_logic;
        Vp_Vn_v_n         : in    std_logic;
        Vp_Vn_v_p         : in    std_logic;
        GPIO_tri_i        : in    std_logic_vector (15 downto 0);
        GPIO_tri_o        : out   std_logic_vector (15 downto 0);
        GPIO_tri_t        : out   std_logic_vector (15 downto 0);
        IIC_0_scl_i       : in    std_logic;
        IIC_0_scl_o       : out   std_logic;
        IIC_0_scl_t       : out   std_logic;
        IIC_0_sda_i       : in    std_logic;
        IIC_0_sda_o       : out   std_logic;
        IIC_0_sda_t       : out   std_logic;
        IIC_1_scl_i       : in    std_logic;
        IIC_1_scl_o       : out   std_logic;
        IIC_1_scl_t       : out   std_logic;
        IIC_1_sda_i       : in    std_logic;
        IIC_1_sda_o       : out   std_logic;
        IIC_1_sda_t       : out   std_logic;
        IIC_scl_i         : in    std_logic;
        IIC_scl_o         : out   std_logic;
        IIC_scl_t         : out   std_logic;
        IIC_sda_i         : in    std_logic;
        IIC_sda_o         : out   std_logic;
        IIC_sda_t         : out   std_logic;
        UART_0_rxd        : in    std_logic;
        UART_0_txd        : out   std_logic;
        OCXO_CLK100       : in    std_logic;
        OCXO_RESETN       : out   std_logic_vector (0 to 0);
        Int0              : in    std_logic_vector (0 to 0);
        Int1              : in    std_logic_vector (0 to 0);
        Int2              : in    std_logic_vector (0 to 0);
        Int3              : in    std_logic_vector (0 to 0)
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

    signal clk   : std_logic;
    signal fclk  : std_logic;
    signal rst_n : std_logic;

begin

    cpu_ck1:  clk_gen(10 ns, 50, fclk);
    cpu_rst:  rst_n_gen(1 us, fclk_reset0_n);
    ocxo_rst: rst_n_gen(1 us, rst_n);

    FCLK_CLK0      <= fclk;
    clk            <= OCXO_CLK100;
    OCXO_RESETN(0) <= rst_n;

    -- Place holder signal assignments
    IIC_0_scl_o <= '0';
    IIC_0_scl_t <= '0';
    IIC_0_sda_o <= '0';
    IIC_0_sda_t <= '0';
    IIC_1_scl_o <= '0';
    IIC_1_scl_t <= '0';
    IIC_1_sda_o <= '0';
    IIC_1_sda_t <= '0';
    IIC_scl_o   <= '0';
    IIC_scl_t   <= '0';
    IIC_sda_o   <= '0';
    IIC_sda_t   <= '0';
    UART_0_txd  <= '0';


    gpio:
    process
    begin
        GPIO_tri_o <= x"00d3";
        GPIO_tri_t <= (others => '0');
        run_clk(fclk, 12000);

        GPIO_tri_o <= x"00c2";
        run_clk(fclk, 12000);

        GPIO_tri_o <= x"00d3";
        GPIO_tri_t <= (others => '0');
        run_clk(fclk, 12000);

        wait;
    end process;
    

    regw:
    process
        procedure reg_write (addr : in std_logic_vector(31 downto 0);
                             data : in std_logic_vector(31 downto 0)) is
            variable count : natural;
        begin
            count            := 0;
            EPC_INTF_addr    <= addr;
            EPC_INTF_ads     <= '1';
            EPC_INTF_be      <= x"F";
            EPC_INTF_cs_n(0) <= '0';
            EPC_INTF_data_o  <= data;
            EPC_INTF_data_t  <= (others =>'0');
            EPC_INTF_rnw     <= '0';
            run_clk(clk, 1);

            EPC_INTF_ads     <= '0';
            while (EPC_INTF_rdy(0) /= '1' and count < 10) loop
                count := count + 1;
                run_clk(clk, 1);
            end loop;

            EPC_INTF_cs_n(0) <= '1';
            EPC_INTF_rnw     <= '1';
            EPC_INTF_data_t  <= (others =>'1');
            run_clk(clk, 1);
            
        end procedure;
        
        procedure reg_read (addr : in std_logic_vector(31 downto 0)) is
            variable count : natural;
        begin
            count            := 0;
            EPC_INTF_addr    <= addr;
            EPC_INTF_ads     <= '1';
            EPC_INTF_be      <= x"F";
            EPC_INTF_cs_n(0) <= '0';
            EPC_INTF_data_t  <= (others =>'1');
            EPC_INTF_rnw     <= '1';
            run_clk(clk, 1);

            EPC_INTF_ads     <= '0';
            while (EPC_INTF_rdy(0) /= '1' and count < 10) loop
                count := count + 1;
                run_clk(clk, 1);
            end loop;

            EPC_INTF_cs_n(0) <= '1';
            EPC_INTF_rnw     <= '1';
            run_clk(clk, 1);
            
        end procedure;
        
    begin

        EPC_INTF_addr     <= (others =>'0');
        EPC_INTF_ads      <= '0';
        EPC_INTF_be       <= (others =>'0');
        EPC_INTF_burst    <= '0';
        EPC_INTF_cs_n     <= (others =>'1');
        EPC_INTF_data_o   <= (others =>'0');
        EPC_INTF_data_t   <= (others =>'1');
        EPC_INTF_rd_n     <= '1';
        EPC_INTF_rnw      <= '1';
        EPC_INTF_wr_n     <= '1';

        run_clk(clk, 2000);

        reg_write(x"aaaaaaaa", x"55555555");

        run_clk(clk, 100);

        reg_read(x"a5a5a5a5");

        run_clk(clk, 100);

        reg_write(x"00000100", x"12345678");

        run_clk(clk, 10000);

        reg_write(x"00000200", x"00000080");

        run_clk(clk, 100);

        reg_read(x"00000000");

        run_clk(clk, 100);

        reg_read(x"00000314");

        run_clk(clk, 100);

        reg_read(x"00000100");

        run_clk(clk, 10000);

        reg_write(x"00000200", x"000000ff");

        run_clk(clk, 1000);

        reg_read(x"00001004");

        run_clk(clk, 1000);

        reg_read(x"00001830");

        run_clk(clk, 1000);

        reg_read(x"00000004");

        run_clk(clk, 1000);

        reg_write(x"00000300", x"0000004f");

        run_clk(clk, 100000);

        reg_write(x"00000124", x"000080ff");

        run_clk(clk, 100000);

        reg_read(x"00000100");

        run_clk(clk, 100000);

        reg_read(x"00000104");

        wait;
        
    end process;

    
end TEST;
