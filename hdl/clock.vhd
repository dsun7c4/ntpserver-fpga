-------------------------------------------------------------------------------
-- Title      : CLock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : clock.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-03-13
-- Last update: 2016-05-20
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


    component IOBUF is
        port (
            I : in STD_LOGIC;
            O : out STD_LOGIC;
            T : in STD_LOGIC;
            IO : inout STD_LOGIC
            );
    end component IOBUF;


    component syspll
        port (
            -- Clock in ports
            ocxo_clk          : IN    std_logic;
            fclk              : IN    std_logic;
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
            dp                : out   std_logic_vector(31 downto 0);
            cpu_addr          : out   std_logic_vector(9 downto 0);
            cpu_we            : out   std_logic;
            cpu_datao         : out   std_logic_vector(31 downto 0);
            cpu_datai         : in    std_logic_vector(31 downto 0);

            disp_pdm          : out   std_logic_vector(7 downto 0);

            tmp               : out   std_logic
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

            dac_val           : in    std_logic_vector(15 downto 0);

            dac_sclk          : OUT   std_logic;
            dac_cs_n          : OUT   std_logic;
            dac_sin           : OUT   std_logic
            );
    end component;


    component disp
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            tsc_1pps          : in    std_logic;
            tsc_1ppms         : in    std_logic;
            tsc_1ppus         : in    std_logic;

            disp_pdm          : in    std_logic_vector(7 downto 0);

            -- Display memory
            dp                : in    std_logic_vector(31 downto 0);
            cpu_addr          : in    std_logic_vector(9 downto 0);
            cpu_we            : in    std_logic;
            cpu_datao         : in    std_logic_vector(31 downto 0);
            cpu_datai         : out   std_logic_vector(31 downto 0);

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
            disp_sclk         : OUT   std_logic;
            disp_blank        : OUT   std_logic;
            disp_lat          : OUT   std_logic;
            disp_sin          : OUT   std_logic
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

    signal gpio_tri_i      : std_logic_vector (15 downto 0);
    signal gpio_tri_o      : std_logic_vector (15 downto 0);
    signal gpio_tri_t      : std_logic_vector (15 downto 0);
    signal gpio_o_d        : std_logic_vector (15 downto 0);
    signal gpio_t_d        : std_logic_vector (15 downto 0);

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

    SIGNAL int             : std_logic_vector (1 downto 0);

    SIGNAL fclk            : STD_LOGIC;
    SIGNAL fclk_reset_n    : STD_LOGIC;
    SIGNAL rst_n           : std_logic;
    SIGNAL pll_rst_n       : std_logic;
    SIGNAL clk_sel         : std_logic;

    SIGNAL clk             : STD_LOGIC;
    SIGNAL locked          : STD_LOGIC;

    SIGNAL fan_pct      : std_logic_vector(7 downto 0);
    SIGNAL fan_mspr     : std_logic_vector(15 downto 0);

    SIGNAL tsc_read     : std_logic;
    SIGNAL tsc_sync     : std_logic;

    SIGNAL diff_1pps    : std_logic_vector(31 downto 0);

    SIGNAL tsc_cnt      : std_logic_vector(63 downto 0);
    SIGNAL tsc_1pps     : std_logic;
    SIGNAL tsc_1ppms    : std_logic;
    SIGNAL tsc_1ppus    : std_logic;

    SIGNAL set          : std_logic;
    SIGNAL set_1s       : std_logic_vector(3 downto 0);
    SIGNAL set_10s      : std_logic_vector(3 downto 0);
    SIGNAL set_1m       : std_logic_vector(3 downto 0);
    SIGNAL set_10m      : std_logic_vector(3 downto 0);
    SIGNAL set_1h       : std_logic_vector(3 downto 0);
    SIGNAL set_10h      : std_logic_vector(3 downto 0);
    SIGNAL dac_val      : std_logic_vector(15 downto 0);

    SIGNAL t_1ms        : std_logic_vector(3 downto 0);
    SIGNAL t_10ms       : std_logic_vector(3 downto 0);
    SIGNAL t_100ms      : std_logic_vector(3 downto 0);

    SIGNAL t_1s         : std_logic_vector(3 downto 0);
    SIGNAL t_10s        : std_logic_vector(3 downto 0);

    SIGNAL t_1m         : std_logic_vector(3 downto 0);
    SIGNAL t_10m        : std_logic_vector(3 downto 0);

    SIGNAL t_1h         : std_logic_vector(3 downto 0);
    SIGNAL t_10h        : std_logic_vector(3 downto 0);

    SIGNAL dp           : std_logic_vector(31 downto 0);
    SIGNAL cpu_addr     : std_logic_vector(9 downto 0);
    SIGNAL cpu_we       : std_logic;
    SIGNAL cpu_datao    : std_logic_vector(31 downto 0);
    SIGNAL cpu_datai    : std_logic_vector(31 downto 0);

    SIGNAL disp_pdm     : std_logic_vector(7 downto 0);

    SIGNAL tmp          : std_logic;

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
            FCLK_RESET0_N             => fclk_reset_n,
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


    -- Generic gpio interface
    gpio_oreg: delay_vec generic map (1) port map(fclk_reset_n, fclk, GPIO_tri_o, gpio_o_d);
    gpio_treg: delay_vec generic map (1) port map(fclk_reset_n, fclk, GPIO_tri_t, gpio_t_d);

    gpio_tri: for i in 8 to 15 generate
    begin
        --gpio_tri_iobuf: component IOBUF
        --    port map (
        --        I => GPIO_tri_o(i),
        --        IO => gpio(i),
        --        O => GPIO_tri_i(i),
        --        T => GPIO_tri_t(i)
        --        );

        gpio(i - 8) <= gpio_o_d(i) when gpio_t_d(i) = '0' else 'Z';
    end generate;

    gpio_ireg: delay_vec generic map (1) port map(fclk_reset_n, fclk, gpio, GPIO_tri_i(15 downto 8));

    --gpio(0)       <= gpio_o_d(8)  when gpio_t_d(8)  = '0' else 'Z';
    --gpio(1)       <= gpio_o_d(9)  when gpio_t_d(9)  = '0' else 'Z';
    --gpio(2)       <= gpio_o_d(10) when gpio_t_d(10) = '0' else 'Z';
    --gpio(3)       <= gpio_o_d(11) when gpio_t_d(11) = '0' else 'Z';
    --gpio(4)       <= gpio_o_d(12) when gpio_t_d(12) = '0' else 'Z';
    --gpio(5)       <= gpio_o_d(13) when gpio_t_d(13) = '0' else 'Z';
    --gpio(6)       <= gpio_o_d(14) when gpio_t_d(14) = '0' else 'Z';
    --gpio(7)       <= gpio_o_d(15) when gpio_t_d(15) = '0' else 'Z';
                                                      
    -- gpio control interface
    ocxo_ena      <= gpio_o_d(0)  when gpio_t_d(0)  = '0' else 'Z';
    xtal_ena: delay_sig generic map (1) port map (rst_n, clk, gpio_o_d(0), GPIO_tri_i(0));
    pll_rst_n     <= gpio_o_d(1) and fclk_reset_n;
    GPIO_tri_i(1) <= pll_rst_n;
    pll_lock: delay_sig generic map (1) port map (rst_n, clk, locked, GPIO_tri_i(2));
    --GPIO_tri_i(2) <= '0';
    GPIO_tri_i(3) <= '0';

    gps_ena       <= gpio_o_d(4)  when gpio_t_d(4)  = '0' else 'Z';
    loc_ena: delay_sig generic map (1) port map (rst_n, clk, gpio_o_d(4), GPIO_tri_i(4));
    GPIO_tri_i(5) <= '0';
    GPIO_tri_i(6) <= '0';
    GPIO_tri_i(7) <= '0';


    -- Interrupts
    int(0) <= '0';
    int(1) <= '0';


    pll : syspll
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


    cpu_regs: regs
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
            dp                => dp,
            cpu_addr          => cpu_addr,
            cpu_we            => cpu_we,
            cpu_datao         => cpu_datao,
            cpu_datai         => cpu_datai,

            disp_pdm          => disp_pdm,

            tmp               => tmp

            );


  fan_ctl: fan
      port map (
          rst_n             => rst_n,
          clk               => clk,

          tsc_1ppms         => tsc_1ppms,

          fan_pct           => fan_pct,
          fan_tach          => fan_tach,

          fan_pwm           => fan_pwm,
          fan_mspr          => fan_mspr
          );


  time_stamp: tsc
      port map (
          rst_n             => rst_n,
          clk               => clk,

          gps_1pps          => gps_1pps,
          tsc_read          => tsc_read,
          tsc_sync          => tsc_sync,

          diff_1pps         => diff_1pps,

          tsc_cnt           => tsc_cnt,
          tsc_1pps          => tsc_1pps,
          tsc_1ppms         => tsc_1ppms,
          tsc_1ppus         => tsc_1ppus
          );


    digits:  bcdtime
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


    dac_spi: dac
        port map (
            rst_n             => rst_n,
            clk               => clk,

            tsc_1pps          => tsc_1pps,
            tsc_1ppms         => tsc_1ppms,

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

            disp_pdm          => disp_pdm,

            -- Display memory
            dp                => dp,
            cpu_addr          => cpu_addr,
            cpu_we            => cpu_we,
            cpu_datao         => cpu_datao,
            cpu_datai         => cpu_datai,

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
