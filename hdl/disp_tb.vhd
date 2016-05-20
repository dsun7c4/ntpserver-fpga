-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : disp_tb.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-19
-- Last update: 2016-05-19
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Display controller test bench
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-05-19  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity disp_tb is
end disp_tb;


library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.tb_pkg.all;

architecture STRUCTURE of disp_tb is

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

    SIGNAL rst_n        : std_logic;
    SIGNAL clk          : std_logic;

    SIGNAL tsc_1pps     : std_logic;
    SIGNAL tsc_1ppms    : std_logic;
    SIGNAL tsc_1ppus    : std_logic;

    SIGNAL disp_pdm     : std_logic_vector(7 downto 0);

      -- Display memory
    SIGNAL dp           : std_logic_vector(31 downto 0);
    SIGNAL cpu_addr     : std_logic_vector(9 downto 0);
    SIGNAL cpu_we       : std_logic;
    SIGNAL cpu_datao    : std_logic_vector(31 downto 0);
    SIGNAL cpu_datai    : std_logic_vector(31 downto 0);

      -- Time of day
    SIGNAL t_1ms        : std_logic_vector(3 downto 0);
    SIGNAL t_10ms       : std_logic_vector(3 downto 0);
    SIGNAL t_100ms      : std_logic_vector(3 downto 0);

    SIGNAL t_1s         : std_logic_vector(3 downto 0);
    SIGNAL t_10s        : std_logic_vector(3 downto 0);

    SIGNAL t_1m         : std_logic_vector(3 downto 0);
    SIGNAL t_10m        : std_logic_vector(3 downto 0);

    SIGNAL t_1h         : std_logic_vector(3 downto 0);
    SIGNAL t_10h        : std_logic_vector(3 downto 0);

      -- Output to tlc59282 LED driver
    SIGNAL disp_sclk    : std_logic;
    SIGNAL disp_blank   : std_logic;
    SIGNAL disp_lat     : std_logic;
    SIGNAL disp_sin     : std_logic;

begin


    disp_i: disp
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


    clk_100MHZ: clk_gen(10 ns, 50, clk);
    reset:      rst_n_gen(1 us, rst_n);

    -- 1 second pulse
    process
    begin
        tsc_1pps <= '0';

        run_clk(clk, 1000);

        loop
            tsc_1pps <= '1';

            run_clk(clk, 1);

            tsc_1pps <= '0';

            run_clk(clk, 1999999);

        end loop;
    end process;

    -- 1 milli second pulse
    process
    begin
        tsc_1ppms <= '0';

        run_clk(clk, 1000);

        loop
            tsc_1ppms <= '1';

            run_clk(clk, 1);

            tsc_1ppms <= '0';

            run_clk(clk, 1999);

        end loop;
    end process;

    -- 1 micro second pulse
    process
    begin
        tsc_1ppus <= '0';

        run_clk(clk, 1000);

        loop
            tsc_1ppus <= '1';

            run_clk(clk, 1);

            tsc_1ppus <= '0';

            run_clk(clk, 1);

        end loop;
    end process;


    -- pdm setting
    process
    begin
        disp_pdm <= (others =>'0');

        run_clk(clk, 2000);

        disp_pdm <= x"aa";
        
        run_clk(clk, 2000);

        wait;
    end process;


    -- input
    process
    begin
        dp             <= (others => '0');
        cpu_addr       <= (others => '0');
        cpu_we         <= '0';
        cpu_datao      <= (others => '0');

        t_1ms          <= (others => '0');
        t_10ms         <= (others => '0');
        t_100ms        <= (others => '0');
        t_1s           <= (others => '0');
        t_10s          <= (others => '0');
        t_1m           <= (others => '0');
        t_10m          <= (others => '0');
        t_1h           <= (others => '0');
        t_10h          <= (others => '0');

        run_clk(clk, 2000);

        wait;
    end process;


end STRUCTURE;
