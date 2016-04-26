-------------------------------------------------------------------------------
-- Title      : CLock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : regs.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-03-13
-- Last update: 2016-04-26
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Register interface to the EPC bus
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-03-13  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------
--
--              Address range: 0x8060_0000 - 0x8060_FFFF
--
-- 0x8060_000x  |            TSC LSB                            |
-- 
-- 0x8060_000x  |            TSC MSB                            |
--
-- 0x8060_000x  |           |         RPM           |  Fan pwm  |
--
-- 0x8060_000x  |           |   hour    |  min      |  sec      |
-- 
-- 0x8060_000x  |           |           |       DAC value       |
-- 
-- 0x8060_000x  |           |           |           |  disp pwm |
-- 
-- 0x8060_0100  |  digit 3  |  digit 2  |  digit 1  |  digit 0  |
-- 
-- 0x8060_0104  |  digit 7  |  digit 6  |  digit 5  |  digit 4  |
-- 
-- 0x8060_0108  |  digit 11 |  digit 10 |  digit 9  |  digit 8  |
-- 
-- 0x8060_010c  |  digit 15 |  digit 14 |  digit 13 |  digit 12 |
-- 
-- 0x8060_0110  |  digit 19 |  digit 18 |  digit 17 |  digit 16 |
-- 


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

      tmp               : out   std_logic

  );
end regs;



architecture STRUCTURE of regs is

    type reg_arr is array (natural range <>) of std_logic_vector(31 downto 0);

    signal regs   : reg_arr(7 downto 0);
    signal addr   : std_logic_vector(31 downto 0);
    signal be     : std_logic_vector(3 downto 0);
    signal data_i : std_logic_vector(31 downto 0);
    signal data_o : std_logic_vector(31 downto 0);

    signal cs_n_d  : std_logic_vector(1 downto 0);
    signal cs_dp_r : std_logic;
    signal cs_dp_w : std_logic;
    signal rnw     : std_logic;
    signal rdy_d   : std_logic_vector(1 downto 0);
    
begin

    -- Big endian to little endian
    addr            <= EPC_INTF_addr;
    be              <= EPC_INTF_be;
    data_o          <= EPC_INTF_data_o;
    -- Little endian to big endian
    EPC_INTF_data_i <= data_i;


    -- Chip select falling edge detect
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            rnw     <= '0';
            cs_n_d  <= (others => '1');
            cs_dp_r <= '0';
            cs_dp_w <= '0';
        elsif (clk'event and clk = '1') then
            rnw       <= not EPC_INTF_rnw;
            cs_n_d(0) <= EPC_INTF_cs_n;
            cs_n_d(1) <= cs_n_d(0);
            cs_dp_r   <= not cs_n_d(0) and cs_n_d(1) and not rnw;
            cs_dp_w   <= not cs_n_d(0) and cs_n_d(1) and     rnw;
        end if;
    end process;


    -- Ready signal generator, 3 cycles after delayed chip select
    -- Hold ready active until the chip select goes inactive
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            rdy_d        <= (others => '1');
            EPC_INTF_rdy <= '0';
        elsif (clk'event and clk = '1') then
            rdy_d(0)     <= cs_dp_r or cs_dp_w;
            rdy_d(1)     <= rdy_d(0);
            if (EPC_INTF_cs_n = '1') then
                EPC_INTF_rdy <= '0';
            elsif (rdy_d(1) = '1') then
                EPC_INTF_rdy <= '1';
            end if;
        end if;
    end process;



end STRUCTURE;
