-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : syspll.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-06
-- Last update: 2016-05-06
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: System PLL
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-05-06  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

--library work;
--use work.util_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity syspll is
    port (
        -- Clock in ports
        ocxo_clk          : IN    std_logic;
        fclk              : IN    std_logic;
        clk_sel           : in    std_logic;

        -- Clock out ports
        clk               : out   std_logic;

        -- Status and control signals
        pll_rst_n         : in    std_logic;
        locked            : out   std_logic
        );
end syspll;



architecture structure of syspll is

    component ocxo_clk_pll
        port (
            -- Clock in ports
            clk_in1  : in  std_logic;
            -- Clock out ports
            clk_out1 : out std_logic;
            -- Status and control signals
            resetn   : in  std_logic;
            locked   : out std_logic
            );
    end component;

    attribute SYN_BLACK_BOX                 : boolean;
    attribute SYN_BLACK_BOX of ocxo_clk_pll : component is true;

    attribute BLACK_BOX_PAD_PIN                 : string;
    attribute BLACK_BOX_PAD_PIN of ocxo_clk_pll : component is "clk_in1,clk_out1,resetn,locked";

    signal pll_clk0   : std_logic;
    signal pll_locked : std_logic;

begin

    syspll : ocxo_clk_pll
        port map (
            -- Clock in ports
            clk_in1  => ocxo_clk,
            -- Clock out ports  
            clk_out1 => pll_clk0,
            -- Status and control signals                
            resetn   => pll_rst_n,
            locked   => pll_locked
            );


    clkmux: BUFGMUX_CTRL
        port map (
            O  => clk,
            I0 => fclk,
            I1 => pll_clk0,
            S  => pll_locked
            );

    
    --clkbuf: BUFG
    --    port map (
    --        O  => clk,
    --        I => pll_clk0
    --        );

    locked<= pll_locked;

end structure;
