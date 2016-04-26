library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


package util_pkg is

    procedure clk_gen ( period : in time; duty : in integer; signal clk : out std_logic );
    procedure rst_n_gen ( delay : in time; signal rst_n : out std_logic );

    procedure run_clk ( signal clk : in std_logic; count : in natural );

end package util_pkg;

package body util_pkg is

    -- ----------------------------------------------------------------------
    -- Generate a clock
    --
    --      _____       _____
    --     |     |_____|     |_____
    --
    --     |<--->| Duty cycle
    --     |<--------->| Period
    --
    -- ----------------------------------------------------------------------


    procedure clk_gen ( period : in time; duty : in integer; signal clk : out std_logic ) is
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


    -- ----------------------------------------------------------------------
    -- Generate reset
    --
    --                  ________________
    --     ____________|
    --
    --     |<--------->| Delay
    --
    -- ----------------------------------------------------------------------
    procedure rst_n_gen ( delay : in time; signal rst_n : out std_logic ) is
    begin

        rst_n <= '0';

        wait for delay;

        rst_n <= '1';

    end procedure;



    -- ----------------------------------------------------------------------
    -- Wait for count cycles of input
    --
    --                  ____________              ____________
    --     ____________|            |____________|
    --
    --                              |<--  Stops here
    --
    -- ----------------------------------------------------------------------
    procedure run_clk ( signal clk : in std_logic; count : in natural ) is
        variable i : natural;
    begin

        i := count;
        
        while (i > 0) loop
            wait until (clk'event and clk = '0');
            i := i - 1;
        end loop;

    end procedure;

end package body util_pkg;
