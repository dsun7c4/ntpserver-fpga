-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dac_tb.vhd
-- Author     : Daniel Sun  <dsun7c4osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-05
-- Last update: 2016-08-26
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Testbench for DAC driver
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-05-05  1.0      dsun7c4osh  Created
-------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity dac_tb is
end dac_tb;


library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.tb_pkg.all;

architecture STRUCTURE of dac_tb is

    component dac
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            tsc_1pps          : in    std_logic;
            tsc_1ppms         : in    std_logic;

            dac_ena           : in    std_logic;
            dac_tri           : in    std_logic;
            dac_val           : in    std_logic_vector(15 downto 0);

            dac_sclk          : OUT   std_logic;
            dac_cs_n          : OUT   std_logic;
            dac_sin           : OUT   std_logic
            );
    end component;


    SIGNAL rst_n        : std_logic;
    SIGNAL clk          : std_logic;

    SIGNAL tsc_1pps     : std_logic;
    SIGNAL tsc_1ppms    : std_logic;
    SIGNAL dac_ena      : std_logic;
    SIGNAL dac_tri      : std_logic;
    SIGNAL dac_val      : std_logic_vector(15 downto 0);

    SIGNAL dac_sclk     : std_logic;
    SIGNAL dac_cs_n     : std_logic;
    SIGNAL dac_sin      : std_logic;

begin


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


    clk_100MHZ: clk_gen(10 ns, 50, clk);
    reset:      rst_n_gen(1 us, rst_n);

    dac_ena <= '1';
    dac_tri <= '0';

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

    process
    begin
        dac_val <= (others =>'0');

        run_clk(clk, 2000);

        dac_val <= x"aaaa";

        run_clk(clk, 2000);

        dac_val <= x"5555";

        run_clk(clk, 2000);

        dac_val <= x"a5a5";

        run_clk(clk, 2000);

        dac_val <= x"5a5a";

        run_clk(clk, 2000);

        wait;
    end process;


end STRUCTURE;
