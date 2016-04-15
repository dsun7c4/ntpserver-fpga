-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : clock_.vhd
-- Author     : My Account  <guest@dsun.org>
-- Company    : 
-- Created    : 2016-03-13
-- Last update: 2016-03-16
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-03-13  1.0      guest	Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity tri is
  port (
      GPIO_tri_i        : out   std_logic_vector (15 downto 0);
      GPIO_tri_o        : in    std_logic_vector (15 downto 0);
      GPIO_tri_t        : in    std_logic_vector (15 downto 0);

      gpio              : INOUT std_logic_vector (15 DOWNTO 0)

  );
end tri;

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

architecture STRUCTURE of tri is
begin
    -- Generic gpio interface
    gpio_tri: for i in 0 to 15 generate
    begin
        --gpio_tri_iobuf: component IOBUF
        --    port map (
        --        I => GPIO_tri_o(i),
        --        IO => gpio(i),
        --        O => GPIO_tri_i(i),
        --        T => GPIO_tri_t(i)
        --        );

        gpio(i)       <= GPIO_tri_o(i) when GPIO_tri_t(i) = '0' else 'Z';
        GPIO_tri_i(i) <= gpio(i);
    end generate;

    --gpio(0)       <= gpio_tri_o(0) when gpio_tri_t(0) = '0' else 'Z';
    --gpio(1)       <= gpio_tri_o(1) when gpio_tri_t(1) = '0' else 'Z';
    --gpio(2)       <= gpio_tri_o(2) when gpio_tri_t(2) = '0' else 'Z';
    --gpio(3)       <= gpio_tri_o(3) when gpio_tri_t(3) = '0' else 'Z';
    --gpio(4)       <= gpio_tri_o(4) when gpio_tri_t(4) = '0' else 'Z';
    --gpio(5)       <= gpio_tri_o(5) when gpio_tri_t(5) = '0' else 'Z';
    --gpio(6)       <= gpio_tri_o(6) when gpio_tri_t(6) = '0' else 'Z';
    --gpio(7)       <= gpio_tri_o(7) when gpio_tri_t(7) = '0' else 'Z';
                                                   

end STRUCTURE;

