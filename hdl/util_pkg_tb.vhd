-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : util_pkg_tb.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-08-11
-- Last update: 2016-08-12
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Testbench for util package
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-08-11  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity util_pkg_tb is
end util_pkg_tb;


library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.tb_pkg.all;
use work.util_pkg.all;

architecture STRUCTURE of util_pkg_tb is


    SIGNAL rst_n        : std_logic;
    SIGNAL clk          : std_logic;

    SIGNAL i            : std_logic;
    SIGNAL i_vec        : std_logic_vector(31 downto 0);

    SIGNAL d            : std_logic;
    SIGNAL d_vec        : std_logic_vector(31 downto 0);

    type vec_arr is array (natural range <>) of std_logic_vector(31 downto 0);

    SIGNAL q_vec        : vec_arr(31 downto 0);
    SIGNAL q_sig        : std_logic_vector(31 downto 0);
    SIGNAL q_pulse      : std_logic_vector(31 downto 0);



begin

    clk_100MHZ: clk_gen(10 ns, 50, clk);
    reset:      rst_n_gen(1 us, rst_n);


    process
    begin
        i     <= '0';
        i_vec <= (others => '0');

        run_clk(clk, 200);

        i     <= '1';
        i_vec <= x"5555aaaa";
        run_clk(clk, 1);

        i     <= '0';
        i_vec <= (others => '0');
        run_clk(clk, 64);

        for j in 0 to 32 loop
            i     <= '1';
            i_vec <= x"5555aaaa";
            run_clk(clk, 1);

            i     <= '0';
            i_vec <= (others => '0');
            run_clk(clk, j);
        end loop;

        wait;
    end process;

    -- So the test input lines up with the clock edge...
    d_s: delay_sig   generic map (1) port map (rst_n, clk, i,     d);
    d_v: delay_vec   generic map (1) port map (rst_n, clk, i_vec, d_vec);

    tests:
    for i in 0 to 31 generate
        s: delay_sig   generic map (i) port map (rst_n, clk, d,     q_sig(i));
        v: delay_vec   generic map (i) port map (rst_n, clk, d_vec, q_vec(i));
        p: delay_pulse generic map (i) port map (rst_n, clk, d,     q_pulse(i));
    end generate;
    

end STRUCTURE;
