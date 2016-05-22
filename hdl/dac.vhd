-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    :
-------------------------------------------------------------------------------
-- File       : dac.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    :
-- Created    : 2016-05-05
-- Last update: 2016-05-21
-- Platform   :
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: DAC driver
-------------------------------------------------------------------------------
-- Copyright (c) 2016
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author     Description
-- 2016-05-05  1.0      dcsun88osh Created
-------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.util_pkg.all;

entity dac is
  port (
      rst_n             : in    std_logic;
      clk               : in    std_logic;

      tsc_1pps          : in    std_logic;
      tsc_1ppms         : in    std_logic;

      dac_ena           : in    std_logic;
      dac_val           : in    std_logic_vector(15 downto 0);

      dac_sclk          : OUT   std_logic;
      dac_cs_n          : OUT   std_logic;
      dac_sin           : OUT   std_logic
  );
end dac;



architecture rtl of dac is

    signal trig           : std_logic;

    SIGNAL bit_sr         : std_logic_vector(15 downto 0);
    SIGNAL bit_cnt        : std_logic_vector(4 downto 0);
    signal finish         : std_logic;

    signal cs             : std_logic;
    signal sclk           : std_logic;
    signal sin            : std_logic;

begin

    --
    --            _______                               ______
    -- dac_cs_n          |_____________  ______________|
    --            _______ _____ _____ _  __ _____ _____ _______
    -- dac_sin    _______X_____X_____X_  __X_____X_____X_______
    --                       __    __    __    __    __
    -- dac_sclk   __________|  |__|  |_    |__|  |__|  |_______
    --
    -- Bit                 15    14    ..     1     0
    --

    -- Start triggering
    dac_trig:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            trig <= '0';
        elsif (clk'event and clk = '1') then
            if (tsc_1ppms = '1') then
                if (tsc_1pps = '1' and dac_ena = '1') then
                    trig <= '1';
                elsif (finish = '1') then
                    trig <= '0';
                end if;
            end if;
        end if;
    end process;


    -- bit counter
    dac_cnt:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            bit_cnt <= (others => '0');
            finish  <= '0';
        elsif (clk'event and clk = '1') then
            if (tsc_1ppms = '1') then
                if (trig = '0') then
                    bit_cnt <= (others => '0');
                else
                    bit_cnt <= bit_cnt + 1;
                end if;

                if (trig = '0') then
                    finish <= '0';
                elsif (bit_cnt = 30)  then
                    finish <= '1';
                else
                    finish <= '0';
                end if;
            end if;
        end if;
    end process;


    -- Generate DAC control signals
    dac_sr:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            bit_sr <= (others => '0');
            cs     <= '1';
            sclk   <= '0';
            sin    <= '0';
        elsif (clk'event and clk = '1') then
            if (tsc_1ppms = '1') then
                if (tsc_1pps = '1') then
                    bit_sr <= dac_val;
                elsif (bit_cnt(0) = '1') then
                    bit_sr <= bit_sr(bit_sr'left - 1 downto 0) & '0';
                end if;
                
                cs     <= not trig;
                sclk   <= bit_cnt(0);
                sin    <= bit_sr(bit_sr'left);
            end if;
        end if;
    end process;


    -- Final output register
    dac_ocs:   delay_sig generic map (1) port map (rst_n, clk, cs,   dac_cs_n);
    dac_osclk: delay_sig generic map (1) port map (rst_n, clk, sclk, dac_sclk);
    dac_osin:  delay_sig generic map (1) port map (rst_n, clk, sin,  dac_sin);


end rtl;

