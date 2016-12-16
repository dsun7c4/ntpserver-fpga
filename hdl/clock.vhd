------------------------------------------------------------------------------
-- Title      : CLock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : clock.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-03-13
-- Last update: 2016-11-14
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Clock structure
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-03-13  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.util_pkg.all;
use work.types_pkg.all;

architecture STRUCTURE of clock is

    component cpu is
        port (
            DDR_cas_n         : inout std_logic;
            DDR_cke           : inout std_logic;
            DDR_ck_n          : inout std_logic;
            DDR_ck_p          : inout std_logic;
            DDR_cs_n          : inout std_logic;
            DDR_reset_n       : inout std_logic;
            DDR_odt           : inout std_logic;
            DDR_ras_n         : inout std_logic;
            DDR_we_n          : inout std_logic;
            DDR_ba            : inout std_logic_vector (2 downto 0);
            DDR_addr          : inout std_logic_vector (14 downto 0);
            DDR_dm            : inout std_logic_vector (3 downto 0);
            DDR_dq            : inout std_logic_vector (31 downto 0);
            DDR_dqs_n         : inout std_logic_vector (3 downto 0);
            DDR_dqs_p         : inout std_logic_vector (3 downto 0);
            FIXED_IO_mio      : inout std_logic_vector (53 downto 0);
            FIXED_IO_ddr_vrn  : inout std_logic;
            FIXED_IO_ddr_vrp  : inout std_logic;
            FIXED_IO_ps_srstb : inout std_logic;
            FIXED_IO_ps_clk   : inout std_logic;
            FIXED_IO_ps_porb  : inout std_logic;
            Vp_Vn_v_n         : in    std_logic;
            Vp_Vn_v_p         : in    std_logic;
            UART_0_txd        : out   std_logic;
            UART_0_rxd        : in    std_logic;
            IIC_0_sda_i       : in    std_logic;
            IIC_0_sda_o       : out   std_logic;
            IIC_0_sda_t       : out   std_logic;
            IIC_0_scl_i       : in    std_logic;
            IIC_0_scl_o       : out   std_logic;
            IIC_0_scl_t       : out   std_logic;
            IIC_1_sda_i       : in    std_logic;
            IIC_1_sda_o       : out   std_logic;
            IIC_1_sda_t       : out   std_logic;
            IIC_1_scl_i       : in    std_logic;
            IIC_1_scl_o       : out   std_logic;
            IIC_1_scl_t       : out   std_logic;
            GPIO_tri_i        : in    std_logic_vector (15 downto 0);
            GPIO_tri_o        : out   std_logic_vector (15 downto 0);
            GPIO_tri_t        : out   std_logic_vector (15 downto 0);
            IIC_scl_i         : in    std_logic;
            IIC_scl_o         : out   std_logic;
            IIC_scl_t         : out   std_logic;
            IIC_sda_i         : in    std_logic;
            IIC_sda_o         : out   std_logic;
            IIC_sda_t         : out   std_logic;
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
            OCXO_CLK100       : in    std_logic;
            FCLK_CLK0         : out   std_logic;
            FCLK_RESET0_N     : out   std_logic;
            OCXO_RESETN       : out   std_logic_vector (0 to 0);
            Int0              : in    std_logic_vector (0 to 0);
            Int1              : in    std_logic_vector (0 to 0);
            Int2              : in    std_logic_vector (0 to 0);
            Int3              : in    std_logic_vector (0 to 0)
            );
    end component cpu;


    component io
        port (
            fclk_rst_n        : in    std_logic;
            fclk              : in    std_logic;
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            -- fclk
            GPIO_tri_i        : out   std_logic_vector (15 downto 0);
            GPIO_tri_o        : in    std_logic_vector (15 downto 0);
            GPIO_tri_t        : in    std_logic_vector (15 downto 0);

            -- clk
            locked            : in    std_logic;
            dac_ena           : out   std_logic;
            dac_tri           : out   std_logic;
            disp_ena          : out   std_logic;

            -- fclk
            pll_rst_n         : out   std_logic;
            ocxo_ena          : inout std_logic;
            gps_ena           : inout std_logic;
            gps_tri           : out   std_logic;
            gpio              : inout std_logic_vector (7 DOWNTO 0)

            );
    end component;


    component syspll
        port (
            -- Clock in ports
            ocxo_clk          : in    std_logic;
            fclk              : in    std_logic;
            clk_sel           : in    std_logic;

            -- Clock out ports
            clk               : out   std_logic;

            -- Status and control signals
            pll_rst_n         : in    std_logic;
            locked            : out   std_logic
            );
    end component;


    component regs
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            EPC_INTF_addr     : in    std_logic_vector(0 to 31);
            EPC_INTF_be       : in    std_logic_vector(0 to 3);
            EPC_INTF_burst    : in    std_logic;
            EPC_INTF_cs_n     : in    std_logic;
            EPC_INTF_data_i   : out   std_logic_vector(0 to 31);
            EPC_INTF_data_o   : in    std_logic_vector(0 to 31);
            EPC_INTF_rdy      : out   std_logic;
            EPC_INTF_rnw      : in    std_logic;  -- Write when '0'

            -- Time stamp counter
            tsc_cnt           : in    std_logic_vector(63 downto 0);
            tsc_cnt1          : in    std_logic_vector(63 downto 0);
            tsc_read          : out   std_logic;

            -- Time setting
            cur_time          : in    time_ty;
            set               : out   std_logic;
            set_time          : out   time_ty;

            -- PLL control
            gps_3dfix_d       : in    std_logic;
            gps_1pps_d        : in    std_logic;
            pdiff_1pps        : in    std_logic_vector(31 downto 0);
            fdiff_1pps        : in    std_logic_vector(31 downto 0);
            tsc_sync          : out   std_logic;
            dac_val           : out   std_logic_vector(15 downto 0);

            -- Fan ms per revolution, percent speed
            fan_uspr          : in    std_logic_vector(19 downto 0);
            fan_pct           : out   std_logic_vector(7 downto 0);

            -- Display memory
            sram_addr         : out   std_logic_vector(9 downto 0);
            sram_we           : out   std_logic;
            sram_datao        : out   std_logic_vector(31 downto 0);
            sram_datai        : in    std_logic_vector(31 downto 0);

            dp                : out   std_logic_vector(31 downto 0);
            disp_pdm          : out   std_logic_vector(7 downto 0)
            );
    end component regs;


    component fan
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            tsc_1ppms         : in    std_logic;
            tsc_1ppus         : in    std_logic;

            fan_pct           : in    std_logic_vector(7 downto 0);
            fan_tach          : in    std_logic;

            fan_pwm           : out   std_logic;
            fan_uspr          : out   std_logic_vector(19 downto 0)
            );
    end component fan;


    component tsc
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            gps_1pps          : in    std_logic;
            gps_3dfix_d       : in    std_logic;
            tsc_read          : in    std_logic;
            tsc_sync          : in    std_logic;
            gps_1pps_d        : out   std_logic;

            pdiff_1pps        : out   std_logic_vector(31 downto 0);
            fdiff_1pps        : out   std_logic_vector(31 downto 0);

            tsc_cnt           : out   std_logic_vector(63 downto 0);
            tsc_cnt1          : out   std_logic_vector(63 downto 0);
            tsc_1pps          : out   std_logic;
            tsc_1ppms         : out   std_logic;
            tsc_1ppus         : out   std_logic

            );
    end component tsc;


    component bcdtime
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            tsc_1pps          : in    std_logic;
            tsc_1ppms         : in    std_logic;

            set               : in    std_logic;
            set_time          : in    time_ty;

            cur_time          : out   time_ty
            );
    end component;


    component dac
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            tsc_1pps          : in    std_logic;
            tsc_1ppms         : in    std_logic;

            dac_ena           : in    std_logic;
            dac_tri           : in    std_logic;
            dac_val           : in    std_logic_vector(15 downto 0);

            dac_sclk          : out   std_logic;
            dac_cs_n          : out   std_logic;
            dac_sin           : out   std_logic
            );
    end component;


    component disp
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            tsc_1pps          : in    std_logic;
            tsc_1ppms         : in    std_logic;
            tsc_1ppus         : in    std_logic;

            disp_ena          : in    std_logic;
            disp_pdm          : in    std_logic_vector(7 downto 0);
            dp                : in    std_logic_vector(31 downto 0);

            -- Display memory
            sram_addr         : in    std_logic_vector(9 downto 0);
            sram_we           : in    std_logic;
            sram_datao        : in    std_logic_vector(31 downto 0);
            sram_datai        : out   std_logic_vector(31 downto 0);

            -- Time of day
            cur_time          : in    time_ty;

            -- Output to tlc59282 LED driver
            disp_sclk         : out   std_logic;
            disp_blank        : out   std_logic;
            disp_lat          : out   std_logic;
            disp_sin          : out   std_logic
            );
    end component;


    signal EPC_INTF_addr   : std_logic_vector (0 to 31);
    signal EPC_INTF_ads    : std_logic;
    signal EPC_INTF_be     : std_logic_vector (0 to 3);
    signal EPC_INTF_burst  : std_logic;
    signal EPC_INTF_cs_n   : std_logic;
    signal EPC_INTF_data_i : std_logic_vector (0 to 31);
    signal EPC_INTF_data_o : std_logic_vector (0 to 31);
    signal EPC_INTF_data_t : std_logic_vector (0 to 31);
    signal EPC_INTF_rd_n   : std_logic;
    signal EPC_INTF_rdy    : std_logic;
    signal EPC_INTF_rnw    : std_logic;
    signal EPC_INTF_wr_n   : std_logic;

    signal GPIO_tri_i      : std_logic_vector (15 downto 0);
    signal GPIO_tri_o      : std_logic_vector (15 downto 0);
    signal GPIO_tri_t      : std_logic_vector (15 downto 0);
    SIGNAL dac_ena         : std_logic;
    SIGNAL dac_tri         : std_logic;
    SIGNAL disp_ena        : std_logic;
    SIGNAL gps_tri         : std_logic;
    SIGNAL gps_uart_rxd    : std_logic;
    SIGNAL gps_uart_txd    : std_logic;
    SIGNAL gps_uart_txd_o  : std_logic;
    SIGNAL gps_uart_txd_t  : std_logic;

    signal iic_0_scl_i     : std_logic;
    signal iic_0_scl_o     : std_logic;
    signal iic_0_scl_t     : std_logic;
    signal iic_0_sda_i     : std_logic;
    signal iic_0_sda_o     : std_logic;
    signal iic_0_sda_t     : std_logic;

    signal iic_1_scl_i     : std_logic;
    signal iic_1_scl_o     : std_logic;
    signal iic_1_scl_t     : std_logic;
    signal iic_1_sda_i     : std_logic;
    signal iic_1_sda_o     : std_logic;
    signal iic_1_sda_t     : std_logic;

    signal iic_scl_i       : std_logic;
    signal iic_scl_o       : std_logic;
    signal iic_scl_t       : std_logic;
    signal iic_sda_i       : std_logic;
    signal iic_sda_o       : std_logic;
    signal iic_sda_t       : std_logic;

    signal int             : std_logic_vector (3 downto 0);

    signal fclk            : std_logic;
    signal fclk_rst_n      : std_logic;
    signal rst_n           : std_logic;
    signal pll_rst_n       : std_logic;
    signal clk_sel         : std_logic;

    signal clk             : std_logic;
    signal locked          : std_logic;

    signal fan_pct         : std_logic_vector(7 downto 0);
    signal fan_uspr        : std_logic_vector(19 downto 0);

    signal gps_3dfix_d     : std_logic;
    signal tsc_read        : std_logic;
    signal tsc_sync        : std_logic;
    signal gps_1pps_d      : std_logic;

    SIGNAL pdiff_1pps      : std_logic_vector(31 downto 0);
    SIGNAL fdiff_1pps      : std_logic_vector(31 downto 0);

    signal tsc_cnt         : std_logic_vector(63 downto 0);
    SIGNAL tsc_cnt1        : std_logic_vector(63 downto 0);
    signal tsc_1pps        : std_logic;
    signal tsc_1ppms       : std_logic;
    signal tsc_1ppus       : std_logic;

    signal set             : std_logic;
    signal set_time        : time_ty;

    signal dac_val         : std_logic_vector(15 downto 0);

    SIGNAL cur_time        : time_ty;

    signal sram_addr       : std_logic_vector(9 downto 0);
    signal sram_we         : std_logic;
    signal sram_datao      : std_logic_vector(31 downto 0);
    signal sram_datai      : std_logic_vector(31 downto 0);

    signal dp              : std_logic_vector(31 downto 0);
    signal disp_pdm        : std_logic_vector(7 downto 0);

begin


    cpu_i : component cpu
        port map (
            DDR_addr(14 downto 0)     => DDR_addr(14 downto 0),
            DDR_ba(2 downto 0)        => DDR_ba(2 downto 0),
            DDR_cas_n                 => DDR_cas_n,
            DDR_ck_n                  => DDR_ck_n,
            DDR_ck_p                  => DDR_ck_p,
            DDR_cke                   => DDR_cke,
            DDR_cs_n                  => DDR_cs_n,
            DDR_dm(3 downto 0)        => DDR_dm(3 downto 0),
            DDR_dq(31 downto 0)       => DDR_dq(31 downto 0),
            DDR_dqs_n(3 downto 0)     => DDR_dqs_n(3 downto 0),
            DDR_dqs_p(3 downto 0)     => DDR_dqs_p(3 downto 0),
            DDR_odt                   => DDR_odt,
            DDR_ras_n                 => DDR_ras_n,
            DDR_reset_n               => DDR_reset_n,
            DDR_we_n                  => DDR_we_n,

            FIXED_IO_ddr_vrn          => FIXED_IO_ddr_vrn,
            FIXED_IO_ddr_vrp          => FIXED_IO_ddr_vrp,
            FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
            FIXED_IO_ps_clk           => FIXED_IO_ps_clk,
            FIXED_IO_ps_porb          => FIXED_IO_ps_porb,
            FIXED_IO_ps_srstb         => FIXED_IO_ps_srstb,

            Vp_Vn_v_n                 => Vp_Vn_v_n,
            Vp_Vn_v_p                 => Vp_Vn_v_p,

            EPC_INTF_addr             => EPC_INTF_addr,
            EPC_INTF_ads              => EPC_INTF_ads,
            EPC_INTF_be               => EPC_INTF_be,
            EPC_INTF_burst            => EPC_INTF_burst,
            EPC_INTF_clk              => clk,
            EPC_INTF_cs_n(0)          => EPC_INTF_cs_n,
            EPC_INTF_data_i           => EPC_INTF_data_i,
            EPC_INTF_data_o           => EPC_INTF_data_o,
            EPC_INTF_data_t           => EPC_INTF_data_t,
            EPC_INTF_rd_n             => EPC_INTF_rd_n,
            EPC_INTF_rdy(0)           => EPC_INTF_rdy,
            EPC_INTF_rnw              => EPC_INTF_rnw,
            EPC_INTF_rst              => rst_n,
            EPC_INTF_wr_n             => EPC_INTF_wr_n,

            GPIO_tri_i                => GPIO_tri_i,
            GPIO_tri_o                => GPIO_tri_o,
            GPIO_tri_t                => GPIO_tri_t,

            IIC_0_scl_i               => iic_0_scl_i,
            IIC_0_scl_o               => iic_0_scl_o,
            IIC_0_scl_t               => iic_0_scl_t,
            IIC_0_sda_i               => iic_0_sda_i,
            IIC_0_sda_o               => iic_0_sda_o,
            IIC_0_sda_t               => iic_0_sda_t,

            IIC_1_scl_i               => iic_1_scl_i,
            IIC_1_scl_o               => iic_1_scl_o,
            IIC_1_scl_t               => iic_1_scl_t,
            IIC_1_sda_i               => iic_1_sda_i,
            IIC_1_sda_o               => iic_1_sda_o,
            IIC_1_sda_t               => iic_1_sda_t,

            IIC_scl_i                 => iic_scl_i,
            IIC_scl_o                 => iic_scl_o,
            IIC_scl_t                 => iic_scl_t,
            IIC_sda_i                 => iic_sda_i,
            IIC_sda_o                 => iic_sda_o,
            IIC_sda_t                 => iic_sda_t,

            UART_0_rxd                => gps_uart_rxd,
            UART_0_txd                => gps_uart_txd,

            OCXO_CLK100               => clk,
            FCLK_CLK0                 => fclk,
            FCLK_RESET0_N             => fclk_rst_n,
            OCXO_RESETN(0)            => rst_n,
            Int0(0)                   => int(0),
            Int1(0)                   => int(1),
            Int2(0)                   => int(2),
            Int3(0)                   => int(3)
            );



    -- rtc I2C interface
    rtc_scl     <= iic_0_scl_o when iic_0_scl_t = '0' else 'Z';
    iic_0_scl_i <= rtc_scl;
    rtc_sda     <= iic_0_sda_o when iic_0_sda_t = '0' else 'Z';
    iic_0_sda_i <= rtc_sda;

    -- ocxo I2C interface
    ocxo_scl    <= iic_1_scl_o when iic_1_scl_t = '0' else 'Z';
    iic_1_scl_i <= ocxo_scl;
    ocxo_sda    <= iic_1_sda_o when iic_1_sda_t = '0' else 'Z';
    iic_1_sda_i <= ocxo_sda;

    -- Temperature sensor I2C interface
    temp_scl    <= iic_scl_o when iic_scl_t = '0' else 'Z';
    iic_scl_i   <= temp_scl;
    temp_sda    <= iic_sda_o when iic_sda_t = '0' else 'Z';
    iic_sda_i   <= temp_sda;

    -- GPS uart IOB and tristate
    gps_rx_i:  delay_sig generic map (1)      port map (fclk_rst_n, fclk, gps_rxd,      gps_uart_rxd);
    gps_tx_t:  delay_sig generic map (1, '1') port map (fclk_rst_n, fclk, gps_tri,      gps_uart_txd_t);
    gps_tx_o:  delay_sig generic map (1, '1') port map (fclk_rst_n, fclk, gps_uart_txd, gps_uart_txd_o);
    gps_txd     <= gps_uart_txd_o when gps_uart_txd_t = '0' else 'Z';


    io_i : io
        port map (
            fclk_rst_n        => fclk_rst_n,
            fclk              => fclk,
            rst_n             => rst_n,
            clk               => clk,

            -- fclk
            GPIO_tri_i        => GPIO_tri_i,
            GPIO_tri_o        => GPIO_tri_o,
            GPIO_tri_t        => GPIO_tri_t,

            -- clk
            locked            => locked,
            dac_ena           => dac_ena,
            dac_tri           => dac_tri,
            disp_ena          => disp_ena,

            -- fclk
            pll_rst_n         => pll_rst_n,
            ocxo_ena          => ocxo_ena,
            gps_ena           => gps_ena,
            gps_tri           => gps_tri,
            gpio              => gpio
            );


    -- Interrupts
    int(0) <= '0';    -- RTC
    int(1) <= '0';    -- 1pps
    int(2) <= '0';    -- PLL
    int(3) <= '0';    -- Spare

    clk_sel <= '0';

    syspll_i : syspll
        port map (
            -- Clock in ports
            ocxo_clk          => ocxo_clk,
            fclk              => fclk,
            clk_sel           => clk_sel,

            -- Clock out ports
            clk               => clk,

            -- Status and control signals
            pll_rst_n         => pll_rst_n,
            locked            => locked
            );


    gps_3dfix_i:  delay_sig generic map (2) port map (rst_n, clk, gps_3dfix,  gps_3dfix_d);

    regs_i: regs
        port map (
            rst_n             => rst_n,
            clk               => clk,

            EPC_INTF_addr     => EPC_INTF_addr,
            EPC_INTF_be       => EPC_INTF_be,
            EPC_INTF_burst    => EPC_INTF_burst,
            EPC_INTF_cs_n     => EPC_INTF_cs_n,
            EPC_INTF_data_i   => EPC_INTF_data_i,
            EPC_INTF_data_o   => EPC_INTF_data_o,
            EPC_INTF_rdy      => EPC_INTF_rdy,
            EPC_INTF_rnw      => EPC_INTF_rnw,

            -- Time stamp counter
            tsc_cnt           => tsc_cnt,
            tsc_cnt1          => tsc_cnt1,
            tsc_read          => tsc_read,

            -- Time setting
            cur_time          => cur_time,
            set               => set,
            set_time          => set_time,

            -- PLL control
            gps_3dfix_d       => gps_3dfix_d,
            gps_1pps_d        => gps_1pps_d,
            pdiff_1pps        => pdiff_1pps,
            fdiff_1pps        => fdiff_1pps,
            tsc_sync          => tsc_sync,
            dac_val           => dac_val,

            -- Fan ms per revolution, percent speed
            fan_uspr          => fan_uspr,
            fan_pct           => fan_pct,

            -- Display memory
            sram_addr         => sram_addr,
            sram_we           => sram_we,
            sram_datao        => sram_datao,
            sram_datai        => sram_datai,

            dp                => dp,
            disp_pdm          => disp_pdm

            );


    fan_i: fan
        port map (
            rst_n             => rst_n,
            clk               => clk,

            tsc_1ppms         => tsc_1ppms,
            tsc_1ppus         => tsc_1ppus,

            fan_pct           => fan_pct,
            fan_tach          => fan_tach,

            fan_pwm           => fan_pwm,
            fan_uspr          => fan_uspr
            );


    tsc_i: tsc
        port map (
            rst_n             => rst_n,
            clk               => clk,

            gps_1pps          => gps_1pps,
            gps_3dfix_d       => gps_3dfix_d,
            tsc_read          => tsc_read,
            tsc_sync          => tsc_sync,
            gps_1pps_d        => gps_1pps_d,

            pdiff_1pps        => pdiff_1pps,
            fdiff_1pps        => fdiff_1pps,

            tsc_cnt           => tsc_cnt,
            tsc_cnt1          => tsc_cnt1,
            tsc_1pps          => tsc_1pps,
            tsc_1ppms         => tsc_1ppms,
            tsc_1ppus         => tsc_1ppus
            );


    bcdtime_i:  bcdtime
        port map (
            rst_n             => rst_n,
            clk               => clk,

            tsc_1pps          => tsc_1pps,
            tsc_1ppms         => tsc_1ppms,

            set               => set,
            set_time          => set_time,

            cur_time          => cur_time
            );


    dac_i: dac
        port map (
            rst_n             => rst_n,
            clk               => clk,

            tsc_1pps          => tsc_1pps,
            tsc_1ppms         => tsc_1ppms,

            dac_ena           => dac_ena,
            dac_tri           => dac_tri,
            dac_val           => dac_val,

            dac_sclk          => dac_sclk,
            dac_cs_n          => dac_cs_n,
            dac_sin           => dac_sin
            );


    disp_i : disp
        port map (
            rst_n             => rst_n,
            clk               => clk,

            tsc_1pps          => tsc_1pps,
            tsc_1ppms         => tsc_1ppms,
            tsc_1ppus         => tsc_1ppus,

            disp_ena          => disp_ena,
            disp_pdm          => disp_pdm,
            dp                => dp,

            -- Display memory
            sram_addr         => sram_addr,
            sram_we           => sram_we,
            sram_datao        => sram_datao,
            sram_datai        => sram_datai,

            -- Time of day
            cur_time          => cur_time,

            -- Output to tlc59282 LED driver
            disp_sclk         => disp_sclk,
            disp_blank        => disp_blank,
            disp_lat          => disp_lat,
            disp_sin          => disp_sin
            );


end STRUCTURE;
