-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fan.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-04-28
-- Last update: 2016-04-28
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

      fan_pct           : in    std_logic_vector(7 downto 0);
      fan_tach          : in    std_logic;

      fan_pwm           : out   std_logic;
      fan_mspr          : out   std_logic_vector(15 downto 0)

  );
end fan;



architecture rtl of fan is

    signal pwm_cnt     : std_logic_vector(11 downto 0);
    signal pwm_term    : std_logic;
    signal pwm_out     : std_logic;
    
    signal tach_dly    : std_logic_vector(2 downto 0);
    signal tach_pulse  : std_logic;
    signal tach_cnt    : std_logic_vector(16 downto 0);
    signal tach_ms     : std_logic;
    signal tach_meas   : std_logic_vector(15 downto 0);
    signal tach_msout  : std_logic_vector(15 downto 0);

begin

    -- Pulse width modulator counter
    fan_pwmcnt:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            pwm_cnt  <= (others => '0');
            pwm_term <= '0';
        elsif (clk'event and clk = '1') then
            if (pwm_term = '1') then
                pwm_cnt  <= (others => '0');
            else
                pwm_cnt  <= pwm_cnt + 1;
            end if;

            if (pwm_cnt = x"d03") then
                pwm_term <= '1';
            else
                pwm_term <= '0';
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
            if (pwm_cnt = (fan_pct & "1111")) then
                pwm_out <= '0';
            elsif (pwm_term = '1') then
                pwm_out <= '1';
            end if;
        end if;
    end process;

    
    -- Final output register
    fan_oreg: delay_sig generic map (1) port map (rst_n, clk, pwm_out, fan_pwm);



    -- Tach input buffer and rising edge detector
    fan_ireg:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            tach_dly    <= (others => '0');
            tach_pulse  <= '0';
        elsif (clk'event and clk = '1') then
            tach_dly(0) <= fan_tach;
            tach_dly(1) <= tach_dly(0);
            tach_dly(2) <= tach_dly(1);
            tach_pulse  <= not tach_dly(2) and tach_dly(1);
        end if;
    end process;

    
    -- Tach millisecond pulse generator
    fan_ms:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            tach_cnt  <= (others => '0');
            tach_ms   <= '0';
        elsif (clk'event and clk = '1') then
            if (tach_ms = '1' or tach_pulse = '1') then
                tach_cnt  <= (others => '0');
            else
                tach_cnt  <= tach_cnt + 1;
            end if;

            if (tach_cnt = (100000 - 2) and tach_pulse = '0') then
                tach_ms   <= '1';
            else
                tach_ms   <= '0';
            end if;
        end if;
    end process;

    
    -- Measure time between tach pulses
    fan_meas:
    process (rst_n, clk) is
        variable tach_add    : std_logic_vector(16 downto 0);
    begin
        if (rst_n = '0') then
            tach_meas  <= (others => '0');
            tach_msout <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (tach_pulse = '1') then
                tach_msout <= tach_meas;
            end if;

            tach_add := ('0' & tach_meas) + 1;
            
            if (tach_pulse = '1') then
                tach_meas  <= (others => '0');
                tach_meas(0) <= '1';   -- Start measurement at one
            else
                -- saturating up counter
                if (tach_add(tach_add'left) = '0' and tach_ms = '1') then
                    tach_meas  <= tach_add(tach_meas'range);
                end if;
            end if;
        end if;
    end process;

    fan_mspr <= tach_msout;


end rtl;
