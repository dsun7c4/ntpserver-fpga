-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : disp_tb.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-19
-- Last update: 2018-06-29
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
use work.types_pkg.all;
use work.tb_pkg.all;

architecture STRUCTURE of disp_tb is

    component disp
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            tsc_1pps          : in    std_logic;
            tsc_1ppms         : in    std_logic;
            tsc_1ppus         : in    std_logic;

            disp_ena          : in    std_logic;
            disp_page         : in    std_logic_vector(7 downto 0);
            disp_pdm          : in    std_logic_vector(7 downto 0);
            stat_src          : in    std_logic_vector(3 downto 0);
            stat              : in    std_logic_vector(15 downto 0);

            -- Display memory
            sram_addr          : in    std_logic_vector(9 downto 0);
            sram_we            : in    std_logic;
            sram_datao         : in    std_logic_vector(31 downto 0);
            sram_datai         : out   std_logic_vector(31 downto 0);

            -- Time of day
            cur_time          : in    time_ty;

            -- Output to tlc59282 LED driver
            disp_sclk         : OUT   std_logic;
            disp_blank        : OUT   std_logic;
            disp_lat          : OUT   std_logic;
            disp_sin          : OUT   std_logic;
            disp_status       : OUT   std_logic

            );
    end component;

    SIGNAL rst_n        : std_logic;
    SIGNAL clk          : std_logic;

    SIGNAL tsc_1pps     : std_logic;
    SIGNAL tsc_1ppms    : std_logic;
    SIGNAL tsc_1ppus    : std_logic;

    SIGNAL disp_ena     : std_logic;
    SIGNAL disp_page    : std_logic_vector(7 downto 0);
    SIGNAL disp_pdm     : std_logic_vector(7 downto 0);
    SIGNAL stat_src     : std_logic_vector(3 downto 0);
    SIGNAL stat         : std_logic_vector(15 downto 0);

      -- Display memory
    SIGNAL sram_addr    : std_logic_vector(9 downto 0);
    SIGNAL sram_we      : std_logic;
    SIGNAL sram_datao   : std_logic_vector(31 downto 0);
    SIGNAL sram_datai   : std_logic_vector(31 downto 0);

      -- Time of day
    SIGNAL cur_time     : time_ty;

      -- Output to tlc59282 LED driver
    SIGNAL disp_sclk    : std_logic;
    SIGNAL disp_blank   : std_logic;
    SIGNAL disp_lat     : std_logic;
    SIGNAL disp_sin     : std_logic;
    SIGNAL disp_status  : std_logic;

begin


    disp_i: disp
        port map (
            rst_n             => rst_n,
            clk               => clk,

            tsc_1pps          => tsc_1pps,
            tsc_1ppms         => tsc_1ppms,
            tsc_1ppus         => tsc_1ppus,

            disp_ena          => disp_ena,
            disp_page         => disp_page,
            disp_pdm          => disp_pdm,
            stat_src          => stat_src,
            stat              => stat,

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
            disp_sin          => disp_sin,
            disp_status       => disp_status
            );


    clk_200MHZ: clk_gen(5 ns, 50, clk);
    reset:      rst_n_gen(1 us, rst_n);

    -- 1 second pulse
    process
    begin
        tsc_1pps <= '0';

        run_clk(clk, 2000);

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

        run_clk(clk, 2000);

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

        run_clk(clk, 2000);

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

        run_clk(clk, 4000);

        disp_pdm <= x"aa";
        
        run_clk(clk, 12800);

        disp_pdm <= x"ff";
        
        run_clk(clk, 12800);

        disp_pdm <= x"fe";
        
        run_clk(clk, 12800);

        disp_pdm <= x"fd";
        
        run_clk(clk, 12800);

        disp_pdm <= x"7f";
        
        run_clk(clk, 12800);

        disp_pdm <= x"80";
        
        run_clk(clk, 12800);

        disp_pdm <= x"81";
        
        run_clk(clk, 12800);

        disp_pdm <= x"00";
        
        run_clk(clk, 12800);

        disp_pdm <= x"01";
        
        run_clk(clk, 12800);

        disp_pdm <= x"02";
        
        run_clk(clk, 12800);

        disp_pdm <= x"03";
        
        run_clk(clk, 12800);

        wait;
    end process;


    -- input
    process
    begin
        disp_ena       <= '1';
        disp_page      <= (others => '0');
        sram_addr      <= (others => '0');
        sram_we        <= '0';
        sram_datao     <= (others => '0');
        stat_src       <= (others => '0');
        stat           <= (others => '0');

        cur_time.t_1ms          <= (others => '0');
        cur_time.t_10ms         <= (others => '0');
        cur_time.t_100ms        <= (others => '0');
        cur_time.t_1s           <= (others => '0');
        cur_time.t_10s          <= (others => '0');
        cur_time.t_1m           <= (others => '0');
        cur_time.t_10m          <= (others => '0');
        cur_time.t_1h           <= (others => '0');
        cur_time.t_10h          <= (others => '0');

        run_clk(clk, 4000);

        run_clk(clk, 10000);
        disp_page      <= x"1f";

        run_clk(clk, 2000);

        wait;
    end process;


end STRUCTURE;
