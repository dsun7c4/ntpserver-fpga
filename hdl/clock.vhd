-------------------------------------------------------------------------------
-- Title      : CLock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : clock.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-03-13
-- Last update: 2016-06-12
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
            Int1              : in    std_logic_vector (0 to 0)
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
            disp_ena          : out   std_logic;

            -- fclk
            pll_rst_n         : out   std_logic;
            ocxo_ena          : out   std_logic;
            gps_ena           : out   std_logic;
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
            tsc_read          : out   std_logic;
            tsc_sync          : out   std_logic;
            gps_3dfix_d       : in    std_logic;
            diff_1pps         : in    std_logic_vector(31 downto 0);
            tsc_cnt           : in    std_logic_vector(63 downto 0);

            -- Time setting
            set               : out   std_logic;
            set_1s            : out   std_logic_vector(3 downto 0);
            set_10s           : out   std_logic_vector(3 downto 0);
            set_1m            : out   std_logic_vector(3 downto 0);
            set_10m           : out   std_logic_vector(3 downto 0);
            set_1h            : out   std_logic_vector(3 downto 0);
            set_10h           : out   std_logic_vector(3 downto 0);
            dac_val           : out   std_logic_vector(15 downto 0);

            -- Fan ms per revolution, percent speed
            fan_mspr          : in    std_logic_vector(15 downto 0);
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

            fan_pct           : in    std_logic_vector(7 downto 0);
            fan_tach          : in    std_logic;

            fan_pwm           : out   std_logic;
            fan_mspr          : out   std_logic_vector(15 downto 0)
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

            diff_1pps         : out   std_logic_vector(31 downto 0);

            tsc_cnt           : out   std_logic_vector(63 downto 0);
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

            set_1s            : in    std_logic_vector(3 downto 0);
            set_10s           : in    std_logic_vector(3 downto 0);

            set_1m            : in    std_logic_vector(3 downto 0);
            set_10m           : in    std_logic_vector(3 downto 0);

            set_1h            : in    std_logic_vector(3 downto 0);
            set_10h           : in    std_logic_vector(3 downto 0);


            t_1ms             : out   std_logic_vector(3 downto 0);
            t_10ms            : out   std_logic_vector(3 downto 0);
            t_100ms           : out   std_logic_vector(3 downto 0);

            t_1s              : out   std_logic_vector(3 downto 0);
            t_10s             : out   std_logic_vector(3 downto 0);

            t_1m              : out   std_logic_vector(3 downto 0);
            t_10m             : out   std_logic_vector(3 downto 0);

            t_1h              : out   std_logic_vector(3 downto 0);
            t_10h             : out   std_logic_vector(3 downto 0)
            );
    end component;


    component dac
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            tsc_1pps          : in    std_logic;
            tsc_1ppms         : in    std_logic;

            dac_ena           : in    std_logic;
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
            t_1ms             : in    std_logic_vector(3 downto 0);
            t_10ms            : in    std_logic_vector(3 downto 0);
            t_100ms           : in    std_logic_vector(3 downto 0);

            t_1s              : in    std_logic_vector(3 downto 0);
            t_10s             : in    std_logic_vector(3 downto 0);

            t_1m              : in    std_logic_vector(3 downto 0);
            t_10m             : in    std_logic_vector(3 downto 0);

            t_1h              : in    std_logic_vector(3 downto 0);
            t_10h             : in    std_logic_vector(3 downto 0);

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
    SIGNAL disp_ena        : std_logic;

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

    signal int             : std_logic_vector (1 downto 0);

    signal fclk            : std_logic;
    signal fclk_rst_n      : std_logic;
    signal rst_n           : std_logic;
    signal pll_rst_n       : std_logic;
    signal clk_sel         : std_logic;

    signal clk             : std_logic;
    signal locked          : std_logic;

    signal fan_pct         : std_logic_vector(7 downto 0);
    signal fan_mspr        : std_logic_vector(15 downto 0);

    signal gps_3dfix_d     : std_logic;
    signal tsc_read        : std_logic;
    signal tsc_sync        : std_logic;

    signal diff_1pps       : std_logic_vector(31 downto 0);

    signal tsc_cnt         : std_logic_vector(63 downto 0);
    signal tsc_1pps        : std_logic;
    signal tsc_1ppms       : std_logic;
    signal tsc_1ppus       : std_logic;

    signal set             : std_logic;
    signal set_1s          : std_logic_vector(3 downto 0);
    signal set_10s         : std_logic_vector(3 downto 0);
    signal set_1m          : std_logic_vector(3 downto 0);
    signal set_10m         : std_logic_vector(3 downto 0);
    signal set_1h          : std_logic_vector(3 downto 0);
    signal set_10h         : std_logic_vector(3 downto 0);
    signal dac_val         : std_logic_vector(15 downto 0);

    signal t_1ms           : std_logic_vector(3 downto 0);
    signal t_10ms          : std_logic_vector(3 downto 0);
    signal t_100ms         : std_logic_vector(3 downto 0);

    signal t_1s            : std_logic_vector(3 downto 0);
    signal t_10s           : std_logic_vector(3 downto 0);

    signal t_1m            : std_logic_vector(3 downto 0);
    signal t_10m           : std_logic_vector(3 downto 0);

    signal t_1h            : std_logic_vector(3 downto 0);
    signal t_10h           : std_logic_vector(3 downto 0);

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

            UART_0_rxd                => gps_rxd,
            UART_0_txd                => gps_txd,

            OCXO_CLK100               => clk,
            FCLK_CLK0                 => fclk,
            FCLK_RESET0_N             => fclk_rst_n,
            OCXO_RESETN(0)            => rst_n,
            Int0(0)                   => int(0),
            Int1(0)                   => int(1)
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
            disp_ena          => disp_ena,

            -- fclk
            pll_rst_n         => pll_rst_n,
            ocxo_ena          => ocxo_ena,
            gps_ena           => gps_ena,
            gpio              => gpio
            );


    -- Interrupts
    int(0) <= '0';
    int(1) <= '0';

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
            tsc_read          => tsc_read,
            tsc_sync          => tsc_sync,
            gps_3dfix_d       => gps_3dfix_d,
            diff_1pps         => diff_1pps,
            tsc_cnt           => tsc_cnt,

            -- Time setting
            set               => set,
            set_1s            => set_1s,
            set_10s           => set_10s,
            set_1m            => set_1m,
            set_10m           => set_10m,
            set_1h            => set_1h,
            set_10h           => set_10h,
            dac_val           => dac_val,

            -- Fan ms per revolution, percent speed
            fan_mspr          => fan_mspr,
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

            fan_pct           => fan_pct,
            fan_tach          => fan_tach,

            fan_pwm           => fan_pwm,
            fan_mspr          => fan_mspr
            );


    tsc_i: tsc
        port map (
            rst_n             => rst_n,
            clk               => clk,

            gps_1pps          => gps_1pps,
            gps_3dfix_d       => gps_3dfix_d,
            tsc_read          => tsc_read,
            tsc_sync          => tsc_sync,

            diff_1pps         => diff_1pps,

            tsc_cnt           => tsc_cnt,
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

            set_1s            => set_1s,
            set_10s           => set_10s,

            set_1m            => set_1m,
            set_10m           => set_10m,

            set_1h            => set_1h,
            set_10h           => set_10h,


            t_1ms             => t_1ms,
            t_10ms            => t_10ms,
            t_100ms           => t_100ms,

            t_1s              => t_1s,
            t_10s             => t_10s,

            t_1m              => t_1m,
            t_10m             => t_10m,

            t_1h              => t_1h,
            t_10h             => t_10h
            );


    dac_i: dac
        port map (
            rst_n             => rst_n,
            clk               => clk,

            tsc_1pps          => tsc_1pps,
            tsc_1ppms         => tsc_1ppms,

            dac_ena           => dac_ena,
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
            t_1ms             => t_1ms,
            t_10ms            => t_10ms,
            t_100ms           => t_100ms,

            t_1s              => t_1s,
            t_10s             => t_10s,

            t_1m              => t_1m,
            t_10m             => t_10m,

            t_1h              => t_1h,
            t_10h             => t_10h,

            -- Output to tlc59282 LED driver
            disp_sclk         => disp_sclk,
            disp_blank        => disp_blank,
            disp_lat          => disp_lat,
            disp_sin          => disp_sin
            );


end STRUCTURE;
