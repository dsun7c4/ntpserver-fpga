-------------------------------------------------------------------------------
-- Title      : CLock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : disp.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-14
-- Last update: 2016-05-15
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Display controller
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-05-14  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

--library work;
--use work.util_pkg.all;

entity disp is
  port (
      rst_n             : in    std_logic;
      clk               : in    std_logic;

      tsc_1pps          : in    std_logic;
      tsc_1ppms         : in    std_logic;
      tsc_1ppus         : in    std_logic;

      disp_pdm          : in    std_logic_vector(7 downto 0);
      dp                : in    std_logic_vector(31 downto 0);
      disp_data         : in    std_logic_vector(31 downto 0);
      disp_addr         : out   std_logic_vector(4 downto 0);

      t_1ms             : in    std_logic_vector(3 downto 0);
      t_10ms            : in    std_logic_vector(3 downto 0);
      t_100ms           : in    std_logic_vector(3 downto 0);

      t_1s              : in    std_logic_vector(3 downto 0);
      t_10s             : in    std_logic_vector(3 downto 0);

      t_1m              : in    std_logic_vector(3 downto 0);
      t_10m             : in    std_logic_vector(3 downto 0);

      t_1h              : in    std_logic_vector(3 downto 0);
      t_10h             : in    std_logic_vector(3 downto 0);

      disp_sclk         : OUT   std_logic;
      disp_blank        : OUT   std_logic;
      disp_lat          : OUT   std_logic;
      disp_sin          : OUT   std_logic

      );
end disp;



architecture rtl of disp is


begin


end rtl;

