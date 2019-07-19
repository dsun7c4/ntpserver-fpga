-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : bcdtime_tb.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-04
-- Last update: 2018-06-29
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
use work.types_pkg.all;
use work.tb_pkg.all;

architecture STRUCTURE of bcdtime_tb is

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


    SIGNAL rst_n        : std_logic;
    SIGNAL clk          : std_logic;

    SIGNAL tsc_1pps     : std_logic;
    SIGNAL tsc_1ppms    : std_logic;

    SIGNAL set          : std_logic;
    SIGNAL set_time     : time_ty;

    SIGNAL cur_time     : time_ty;

begin


    digits:  bcdtime
        port map (
            rst_n             => rst_n,
            clk               => clk,

            tsc_1pps          => tsc_1pps,
            tsc_1ppms         => tsc_1ppms,

            set               => set,
            set_time          => set_time,

            cur_time          => cur_time
            );


    clk_200MHZ: clk_gen(5 ns, 50, clk);
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

    set              <= '0';
    set_time.t_1ms   <= (others => '0');
    set_time.t_10ms  <= (others => '0');
    set_time.t_100ms <= (others => '0');
    set_time.t_1s    <= (others => '0');
    set_time.t_10s   <= (others => '0');
    set_time.t_1m    <= (others => '0');
    set_time.t_10m   <= (others => '0');
    set_time.t_1h    <= (others => '0');
    set_time.t_10h   <= (others => '0');


end STRUCTURE;


