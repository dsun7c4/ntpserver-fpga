library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


package util_pkg is

    procedure clock_gen ( period : in time; duty : in integer; signal clk : out std_logic );

end package util_pkg;

package body util_pkg is
    procedure clock_gen ( period : in time; duty : in integer; signal clk : out std_logic ) is
        variable high : time;
        variable low  : time;
    begin

        high := period * duty / 100;
        low  := period - high;

        clk <= '0';

        loop
            clk <= '1';
            wait for high;
            clk <= '0';
            wait for low;
        end loop;
    end procedure;

end package body util_pkg;
