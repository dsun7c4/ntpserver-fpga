-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : types_pkg.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-08-22
-- Last update: 2016-08-22
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Record types
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-08-22  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


package types_pkg is

    type time_ty is
    record
        t_10h   : std_logic_vector(3 downto 0);
        t_1h    : std_logic_vector(3 downto 0);

        t_10m   : std_logic_vector(3 downto 0);
        t_1m    : std_logic_vector(3 downto 0);

        t_10s   : std_logic_vector(3 downto 0);
        t_1s    : std_logic_vector(3 downto 0);

        t_100ms : std_logic_vector(3 downto 0);
        t_10ms  : std_logic_vector(3 downto 0);
        t_1ms   : std_logic_vector(3 downto 0);
    end record;

end package types_pkg;


package body types_pkg is

end package body types_pkg;
