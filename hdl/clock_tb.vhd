-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : clock_tb.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-03-22
-- Last update: 2016-06-28
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top level test bench
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-03-22  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

--configuration testbench of clock is
--    for STRUCTURE
--        for all : cpu
--            use entity work.cpu(TEST);
--        end for;
--    end for;
--end configuration;


library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity clock_tb is
end clock_tb;


library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.util_pkg.all;
use work.tb_pkg.all;

architecture STRUCTURE of clock_tb is

    component clock
        port (
            DDR_addr          : INOUT std_logic_vector (14 DOWNTO 0);
            DDR_ba            : INOUT std_logic_vector (2 DOWNTO 0);
            DDR_cas_n         : INOUT std_logic;
            DDR_ck_n          : INOUT std_logic;
            DDR_ck_p          : INOUT std_logic;
            DDR_cke           : INOUT std_logic;
            DDR_cs_n          : INOUT std_logic;
            DDR_dm            : INOUT std_logic_vector (3 DOWNTO 0);
            DDR_dq            : INOUT std_logic_vector (31 DOWNTO 0);
            DDR_dqs_n         : INOUT std_logic_vector (3 DOWNTO 0);
            DDR_dqs_p         : INOUT std_logic_vector (3 DOWNTO 0);
            DDR_odt           : INOUT std_logic;
            DDR_ras_n         : INOUT std_logic;
            DDR_reset_n       : INOUT std_logic;
            DDR_we_n          : INOUT std_logic;

            FIXED_IO_ddr_vrn  : INOUT std_logic;
            FIXED_IO_ddr_vrp  : INOUT std_logic;
            FIXED_IO_mio      : INOUT std_logic_vector (53 DOWNTO 0);
            FIXED_IO_ps_clk   : INOUT std_logic;
            FIXED_IO_ps_porb  : INOUT std_logic;
            FIXED_IO_ps_srstb : INOUT std_logic;

            Vp_Vn_v_n         : in    std_logic;
            Vp_Vn_v_p         : in    std_logic;

            rtc_scl           : INOUT std_logic;
            rtc_sda           : INOUT std_logic;

            ocxo_ena          : OUT   std_logic;
            ocxo_clk          : IN    std_logic;
            ocxo_scl          : INOUT std_logic;
            ocxo_sda          : INOUT std_logic;

            dac_sclk          : OUT   std_logic;
            dac_cs_n          : OUT   std_logic;
            dac_sin           : OUT   std_logic;

            gps_ena           : OUT   std_logic;
            gps_rxd           : IN    std_logic;
            gps_txd           : OUT   std_logic;
            gps_3dfix         : IN    std_logic;
            gps_1pps          : IN    std_logic;

            temp_scl          : INOUT std_logic;
            temp_sda          : INOUT std_logic;

            disp_sclk         : OUT   std_logic;
            disp_blank        : OUT   std_logic;
            disp_lat          : OUT   std_logic;
            disp_sin          : OUT   std_logic;

            fan_tach          : IN    std_logic;
            fan_pwm           : OUT   std_logic;

            gpio              : INOUT std_logic_vector (7 DOWNTO 0)

            );
    end component;


    SIGNAL DDR_addr     : std_logic_vector (14 DOWNTO 0);
    SIGNAL DDR_ba       : std_logic_vector (2 DOWNTO 0);
    SIGNAL DDR_cas_n    : std_logic;
    SIGNAL DDR_ck_n     : std_logic;
    SIGNAL DDR_ck_p     : std_logic;
    SIGNAL DDR_cke      : std_logic;
    SIGNAL DDR_cs_n     : std_logic;
    SIGNAL DDR_dm       : std_logic_vector (3 DOWNTO 0);
    SIGNAL DDR_dq       : std_logic_vector (31 DOWNTO 0);
    SIGNAL DDR_dqs_n    : std_logic_vector (3 DOWNTO 0);
    SIGNAL DDR_dqs_p    : std_logic_vector (3 DOWNTO 0);
    SIGNAL DDR_odt      : std_logic;
    SIGNAL DDR_ras_n    : std_logic;
    SIGNAL DDR_reset_n  : std_logic;
    SIGNAL DDR_we_n     : std_logic;

    signal FIXED_IO_ddr_vrn  : std_logic;
    signal FIXED_IO_ddr_vrp  : std_logic;
    signal FIXED_IO_mio      : std_logic_vector (53 downto 0);
    signal FIXED_IO_ps_clk   : std_logic;
    signal FIXED_IO_ps_porb  : std_logic;
    signal FIXED_IO_ps_srstb : std_logic;

    SIGNAL Vp_Vn_v_n    : std_logic;
    SIGNAL Vp_Vn_v_p    : std_logic;

    SIGNAL rtc_scl      : std_logic;
    SIGNAL rtc_sda      : std_logic;

    SIGNAL ocxo_ena     : std_logic;
    SIGNAL ocxo_clk     : std_logic;
    SIGNAL ocxo_scl     : std_logic;
    SIGNAL ocxo_sda     : std_logic;

    SIGNAL dac_sclk     : std_logic;
    SIGNAL dac_cs_n     : std_logic;
    SIGNAL dac_sin      : std_logic;

    SIGNAL gps_ena      : std_logic;
    SIGNAL gps_rxd      : std_logic;
    SIGNAL gps_txd      : std_logic;
    SIGNAL gps_3dfix    : std_logic;
    SIGNAL gps_1pps     : std_logic;

    SIGNAL temp_scl     : std_logic;
    SIGNAL temp_sda     : std_logic;

    SIGNAL disp_sclk    : std_logic;
    SIGNAL disp_blank   : std_logic;
    SIGNAL disp_lat     : std_logic;
    SIGNAL disp_sin     : std_logic;

    SIGNAL fan_tach     : std_logic;
    SIGNAL fan_pwm      : std_logic;

    SIGNAL gpio         : std_logic_vector (7 DOWNTO 0);

begin


    fpga: clock
        port map (
            DDR_addr          => DDR_addr,
            DDR_ba            => DDR_ba,
            DDR_cas_n         => DDR_cas_n,
            DDR_ck_n          => DDR_ck_n,
            DDR_ck_p          => DDR_ck_p,
            DDR_cke           => DDR_cke,
            DDR_cs_n          => DDR_cs_n,
            DDR_dm            => DDR_dm,
            DDR_dq            => DDR_dq,
            DDR_dqs_n         => DDR_dqs_n,
            DDR_dqs_p         => DDR_dqs_p,
            DDR_odt           => DDR_odt,
            DDR_ras_n         => DDR_ras_n,
            DDR_reset_n       => DDR_reset_n,
            DDR_we_n          => DDR_we_n,

            FIXED_IO_ddr_vrn  => FIXED_IO_ddr_vrn,
            FIXED_IO_ddr_vrp  => FIXED_IO_ddr_vrp,
            FIXED_IO_mio      => FIXED_IO_mio,
            FIXED_IO_ps_clk   => FIXED_IO_ps_clk,
            FIXED_IO_ps_porb  => FIXED_IO_ps_porb,
            FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,

            Vp_Vn_v_n         => Vp_Vn_v_n,
            Vp_Vn_v_p         => Vp_Vn_v_p,

            rtc_scl           => rtc_scl,
            rtc_sda           => rtc_sda,

            ocxo_ena          => ocxo_ena,
            ocxo_clk          => ocxo_clk,
            ocxo_scl          => ocxo_scl,
            ocxo_sda          => ocxo_sda,

            dac_sclk          => dac_sclk,
            dac_cs_n          => dac_cs_n,
            dac_sin           => dac_sin,

            gps_ena           => gps_ena,
            gps_rxd           => gps_rxd,
            gps_txd           => gps_txd,
            gps_3dfix         => gps_3dfix,
            gps_1pps          => gps_1pps,

            temp_scl          => temp_scl,
            temp_sda          => temp_sda,

            disp_sclk         => disp_sclk,
            disp_blank        => disp_blank,
            disp_lat          => disp_lat,
            disp_sin          => disp_sin,

            fan_tach          => fan_tach,
            fan_pwm           => fan_pwm,

            gpio              => gpio

            );


    ocxo_10MHZ: clk_gen(100 ns, 50, ocxo_clk);
    
    process
    begin
        loop
            fan_tach <= '1';

            run_clk(ocxo_clk, 10000);

            fan_tach <= '0';

            run_clk(ocxo_clk, 20000);

            fan_tach <= '1';

            run_clk(ocxo_clk, 30000);

            fan_tach <= '0';

            run_clk(ocxo_clk, 40000);

        end loop;
    end process;


    process
    begin
        gps_1pps  <= '0';

        run_clk(ocxo_clk, 10000);

        loop
            gps_1pps  <= '1';

            run_clk(ocxo_clk, 1);

            gps_1pps  <= '0';

            run_clk(ocxo_clk, 9999999);

            gps_1pps  <= '1';

            run_clk(ocxo_clk, 1);

            gps_1pps  <= '0';

            run_clk(ocxo_clk, 9999989);

            gps_1pps  <= '1';

            run_clk(ocxo_clk, 1);

            gps_1pps  <= '0';

            run_clk(ocxo_clk, 10000019);

        end loop;
    end process;


    gps_3dfix <= '0';
    gps_rxd   <= '0';
    Vp_Vn_v_n <= '0';
    Vp_Vn_v_p <= '0';



end STRUCTURE;


