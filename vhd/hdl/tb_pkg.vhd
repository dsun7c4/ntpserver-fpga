-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_pkg.vhd
-- Author     : Daniel Sun  <dsun7c4osh@gmail.com>
-- Company    : 
-- Created    : 2016-04-26
-- Last update: 2016-04-26
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Testbench functions
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-04-26  1.0      dsun7c4osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


package tb_pkg is

    procedure clk_gen ( period : in time; duty : in integer; signal clk : out std_logic );
    procedure rst_n_gen ( delay : in time; signal rst_n : out std_logic );

    procedure run_clk ( signal clk : in std_logic; count : in natural );

end package tb_pkg;

package body tb_pkg is

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

end package body tb_pkg;
