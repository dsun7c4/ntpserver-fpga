-------------------------------------------------------------------------------
-- Title      : CLock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : regs.vhd
-- Author     : My Account  <guest@dsun.org>
-- Company    : 
-- Created    : 2016-03-13
-- Last update: 2016-04-25
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

entity regs is
  port (
      rst_n             : in    std_logic;
      clk               : in    std_logic;

      EPC_INTF_addr     : in    std_logic_vector(0 to 31);
      EPC_INTF_be       : in    std_logic_vector(0 to 3);
      EPC_INTF_burst    : in    std_logic;
      EPC_INTF_cs_n     : in    std_logic;
      EPC_INTF_data_i   : out   std_logic_vector(0 to 31);
      EPC_INTF_data_o   : in    std_logic_vector(0 to 31);
      EPC_INTF_rdy      : out   std_logic;
      EPC_INTF_rnw      : in    std_logic;  -- Write when '0'

      tmp               : out   std_logic;

  );
end regs;



architecture STRUCTURE of regs is

    type reg_arr is array(natural range <>) if std_logic_vector(31 downto 0);

    signal regs   : reg_arr(7 downto 0);
    signal addr   : std_logic_vector(31 downto 0);
    signal be     : std_logic_vector(3 downto 0);
    signal data_i : std_logic_vector(31 downto 0);
    signal data_o : std_logic_vector(31 downto 0);

begin

    -- Big endian to little endian
    addr            <= EPC_INTF_addr;
    be              <= EPC_INTF_be;
    data_o          <= EPC_INTF_data_o;
    -- Little endian to big endian
    EPC_INTF_data_i <= data_i;
    

    --
    process (rst_n, clk) is
    begin
    end process;


    
end STRUCTURE;
