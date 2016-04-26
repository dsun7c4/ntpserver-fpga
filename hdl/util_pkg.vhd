-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : util_pkg.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-04-26
-- Last update: 2016-04-26
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Utility components
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-04-26  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


package util_pkg is

    component delay_sig
        generic (
            cycles : in natural := 0
            );
        port (
            signal rst_n : in std_logic;
            signal clk   : in std_logic;

            signal d : in std_logic;
            signal q : out std_logic
            );
    end component delay_sig;
                        
    component delay_vec
        generic (
            cycles : in natural := 0
            );
        port (
            signal rst_n : in std_logic;
            signal clk   : in std_logic;

            signal d : in std_logic_vector;
            signal q : out std_logic_vector
            );
    end component delay_vec;
                        
end package util_pkg;

package body util_pkg is

end package body util_pkg;




library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity delay_sig is
    generic (
        cycles : in natural := 0
        );
    port (
        signal rst_n : in std_logic;
        signal clk   : in std_logic;

        signal d : in std_logic;
        signal q : out std_logic
        );
end delay_sig;


architecture rtl of delay_sig is
begin

    zero:
    if (cycles = 0) generate
        q <= d;
    end generate zero;

    one:
    if (cycles = 1) generate
        process (rst_n, clk)
        begin
            if (rst_n = '0') then
                q <= '0';
            elsif (clk'event and clk = '1') then
                q <= d;
            end if;
        end process;
    end generate;

    gt_one:
    if (cycles > 1) generate
        signal dly : std_logic_vector(cycles - 1 downto 0);
    begin

        process (rst_n, clk)
        begin
            if (rst_n = '0') then
                dly <= (others => '0');
            elsif (clk'event and clk = '1') then
                dly(0) <= d;
                for i in 1 to cycles - 1 loop
                    dly(i) <= dly(i - 1);
                end loop;
            end if;
        end process;

        q <= dly(cycles - 1);
    end generate;

end rtl;




library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity delay_vec is
    generic (
        cycles : in natural := 0
        );
    port (
        signal rst_n : in std_logic;
        signal clk   : in std_logic;

        signal d : in std_logic_vector;
        signal q : out std_logic_vector
        );
end delay_vec;


architecture rtl of delay_vec is
begin

    zero:
    if (cycles = 0) generate
        q <= d;
    end generate zero;

    one:
    if (cycles = 1) generate
        process (rst_n, clk)
        begin
            if (rst_n = '0') then
                q <= (others => '0');
            elsif (clk'event and clk = '1') then
                q <= d;
            end if;
        end process;
    end generate;

    gt_one:
    if (cycles > 1) generate
        type dly_arr is array(natural range <>) of std_logic_vector(d'range);
        signal dly : dly_arr(cycles - 1 downto 0);
    begin
        
        process (rst_n, clk)
        begin
            if (rst_n = '0') then
                for i in 0 to cycles - 1 loop
                    dly(i) <= (others => '0');
                end loop;
            elsif (clk'event and clk = '1') then
                dly(0) <= d;
                for i in 1 to cycles - 1 loop
                    dly(i) <= dly(i - 1);
                end loop;
            end if;
        end process;

        q <= dly(cycles - 1);
    end generate;

end rtl;
