-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : bcdtime_tb.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-04
-- Last update: 2016-05-05
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: testbench for time counters
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-05-04  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity bcdtime_tb is
end bcdtime_tb;


library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.tb_pkg.all;

architecture STRUCTURE of bcdtime_tb is

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


    SIGNAL rst_n        : std_logic;
    SIGNAL clk          : std_logic;

    SIGNAL tsc_1pps     : std_logic;
    SIGNAL tsc_1ppms    : std_logic;
    SIGNAL set          : std_logic;

    SIGNAL set_1s       : std_logic_vector(3 downto 0);
    SIGNAL set_10s      : std_logic_vector(3 downto 0);

    SIGNAL set_1m       : std_logic_vector(3 downto 0);
    SIGNAL set_10m      : std_logic_vector(3 downto 0);

    SIGNAL set_1h       : std_logic_vector(3 downto 0);
    SIGNAL set_10h      : std_logic_vector(3 downto 0);


    SIGNAL t_1ms        : std_logic_vector(3 downto 0);
    SIGNAL t_10ms       : std_logic_vector(3 downto 0);
    SIGNAL t_100ms      : std_logic_vector(3 downto 0);

    SIGNAL t_1s         : std_logic_vector(3 downto 0);
    SIGNAL t_10s        : std_logic_vector(3 downto 0);

    SIGNAL t_1m         : std_logic_vector(3 downto 0);
    SIGNAL t_10m        : std_logic_vector(3 downto 0);

    SIGNAL t_1h         : std_logic_vector(3 downto 0);
    SIGNAL t_10h        : std_logic_vector(3 downto 0);

begin


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


    clk_100MHZ: clk_gen(10 ns, 50, clk);
    reset:      rst_n_gen(1 us, rst_n);

    process
    begin
        tsc_1pps <= '0';

        run_clk(clk, 1000);

        loop
            tsc_1pps <= '1';

            run_clk(clk, 1);

            tsc_1pps <= '0';

            run_clk(clk, 1999);

        end loop;
    end process;

    process
    begin
        tsc_1ppms <= '0';

        run_clk(clk, 1000);

        loop
            tsc_1ppms <= '1';

            run_clk(clk, 1);

            tsc_1ppms <= '0';

            run_clk(clk, 1);

        end loop;
    end process;

    set       <= '0';
    set_1s    <= (others =>'0');
    set_10s   <= (others =>'0');
    set_1m    <= (others =>'0');
    set_10m   <= (others =>'0');
    set_1h    <= (others =>'0');
    set_10h   <= (others =>'0');


end STRUCTURE;


