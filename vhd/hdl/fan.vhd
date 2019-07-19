-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fan.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-04-28
-- Last update: 2018-06-27
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Pulse width/density modulator
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-04-28  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.util_pkg.all;

entity fan is
  port (
      rst_n             : in    std_logic;
      clk               : in    std_logic;

      tsc_1ppms         : in    std_logic;
      tsc_1ppus         : in    std_logic;

      fan_pct           : in    std_logic_vector(7 downto 0);
      fan_tach          : in    std_logic;

      fan_pwm           : out   std_logic;
      fan_uspr          : out   std_logic_vector(19 downto 0)

  );
end fan;



architecture rtl of fan is

    signal pwm_div     : std_logic_vector(4 downto 0);
    signal pwm_ce      : std_logic;
    signal pwm_cnt     : std_logic_vector(7 downto 0);
    signal pwm_term    : std_logic;
    signal pwm_out     : std_logic;
    
    signal tach_dly    : std_logic_vector(2 downto 0);
    signal tach_pulse  : std_logic;
    signal tach_meas   : std_logic_vector(19 downto 0);
    signal tach_msout  : std_logic_vector(19 downto 0);

begin

    -- First divider to generate clock enable for the PWM
    -- Divide by 32
    -- Generate PWM at clk / (32 * 256) rate (24414.0625Hz)
    fan_pwmdiv:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            pwm_div  <= (others => '0');
            pwm_ce   <= '0';
        elsif (clk'event and clk = '1') then
            if (pwm_ce   = '1') then
                pwm_div  <= (others => '0');
            else
                pwm_div  <= pwm_div + 1;
            end if;

            if (pwm_div = x"1E") then
                pwm_ce   <= '1';
            else
                pwm_ce   <= '0';
            end if;
        end if;
    end process;


    -- Pulse width modulator counter
    fan_pwmcnt:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            pwm_cnt  <= (others => '0');
            pwm_term <= '0';
        elsif (clk'event and clk = '1') then
            if (pwm_ce = '1') then
                pwm_cnt  <= pwm_cnt + 1;
                
                if (pwm_cnt = x"FE") then
                    pwm_term <= '1';
                else
                    pwm_term <= '0';
                end if;
            end if;
        end if;
    end process;


    -- Pulse width modulator output
    fan_pwmout:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            pwm_out <= '0';
        elsif (clk'event and clk = '1') then
            if (pwm_ce = '1') then
                if (pwm_term = '1') then
                    pwm_out <= '1';
                elsif (pwm_cnt = fan_pct) then
                    pwm_out <= '0';
                end if;
            end if;
        end if;
    end process;

    
    -- Final output register
    fan_oreg: delay_sig generic map (1) port map (rst_n, clk, pwm_out, fan_pwm);

    -- ----------------------------------------------------------------------
    -- Tach measurement reference is 1 us

    -- Tach input buffer and rising edge detector
    fan_ireg:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            tach_dly    <= (others => '0');
            tach_pulse  <= '0';
        elsif (clk'event and clk = '1') then
            tach_dly(0) <= fan_tach;  -- input register
            if (tsc_1ppus = '1') then
                tach_dly(1) <= tach_dly(0);
                tach_dly(2) <= tach_dly(1);
                tach_pulse  <= not tach_dly(2) and tach_dly(1);
            end if;
        end if;
    end process;

    
    -- Measure time between tach pulses
    fan_meas:
    process (rst_n, clk) is
        variable tach_add    : std_logic_vector(tach_meas'left + 1 downto 0);
    begin
        if (rst_n = '0') then
            tach_meas  <= (others => '0');
            tach_msout <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (tsc_1ppus = '1') then
                if (tach_pulse = '1') then
                    tach_meas    <= (others => '0');
                    tach_meas(0) <= '1';   -- Start measurement at one
                else
                    -- saturating up counter
                    tach_add := ('0' & tach_meas) + 1;
                    if (tach_add(tach_add'left) = '0') then
                        tach_meas  <= tach_add(tach_meas'range);
                    end if;
                end if;

                -- Output at next pulse or overflow
                if (tach_pulse = '1' or tach_add(tach_add'left) = '1') then
                    tach_msout <= tach_meas;
                end if;

            end if;
        end if;
    end process;

    fan_uspr <= tach_msout;


end rtl;
