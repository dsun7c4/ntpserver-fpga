-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : disp_sr_tb.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-15
-- Last update: 2016-05-15
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Disp shift register test bench
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-05-15  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity disp_sr_tb is
end disp_sr_tb;


library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.tb_pkg.all;

architecture STRUCTURE of disp_sr_tb is

    component disp_sr
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            tsc_1pps          : in    std_logic;
            tsc_1ppms         : in    std_logic;
            tsc_1ppus         : in    std_logic;

            disp_data         : in    std_logic_vector(255 downto 0);

            disp_sclk         : OUT   std_logic;
            disp_lat          : OUT   std_logic;
            disp_sin          : OUT   std_logic

            );
    end component;

    SIGNAL rst_n        : std_logic;
    SIGNAL clk          : std_logic;

    SIGNAL tsc_1pps     : std_logic;
    SIGNAL tsc_1ppms    : std_logic;
    SIGNAL tsc_1ppus    : std_logic;

    SIGNAL disp_data    : std_logic_vector(255 downto 0);

    SIGNAL disp_sclk    : std_logic;
    SIGNAL disp_lat     : std_logic;
    SIGNAL disp_sin     : std_logic;

begin


    disp_sr_i: disp_sr
        port map (
            rst_n             => rst_n,
            clk               => clk,

            tsc_1pps          => tsc_1pps,
            tsc_1ppms         => tsc_1ppms,
            tsc_1ppus         => tsc_1ppus,

            disp_data         => disp_data,

            disp_sclk         => disp_sclk,
            disp_lat          => disp_lat,
            disp_sin          => disp_sin
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

            run_clk(clk, 1999999);

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

            run_clk(clk, 1999);

        end loop;
    end process;

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

    process
    begin
        disp_data <= (others =>'0');

        run_clk(clk, 2000);

        disp_data <= x"5aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa5";

        run_clk(clk, 2000);

        disp_data <= x"a55555555555555555555555555555555555555555555555555555555555555a";

        run_clk(clk, 2000);

        disp_data <= x"a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5";

        run_clk(clk, 2000);

        disp_data <= x"5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a";

        run_clk(clk, 2000);

        wait;
    end process;


end STRUCTURE;
