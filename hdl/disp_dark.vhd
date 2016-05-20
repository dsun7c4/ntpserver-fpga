-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : disp_dark.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-19
-- Last update: 2016-05-19
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Display pdm dimmer
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-05-19  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.util_pkg.all;

entity disp_dark is
  port (
      rst_n             : in    std_logic;
      clk               : in    std_logic;

      tsc_1ppms         : in    std_logic;

      disp_pdm          : in    std_logic_vector(7 downto 0);

      disp_blank        : OUT   std_logic

  );
end disp_dark;



architecture rtl of disp_dark is

    signal pwm_div     : std_logic_vector(3 downto 0);
    signal pwm_ce      : std_logic;
    signal pwm_cnt     : std_logic_vector(7 downto 0);
    signal pwm_term    : std_logic;
    signal pwm_out     : std_logic;
    
begin

    -- First divider to generate clock enable for the PWM
    -- Divide by 13
    disp_pwmdiv:
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

            if (pwm_div = x"B") then
                pwm_ce   <= '1';
            else
                pwm_ce   <= '0';
            end if;
        end if;
    end process;


    -- Pulse width modulator counter
    disp_pwmcnt:
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
    disp_pwmout:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            pwm_out <= '0';
        elsif (clk'event and clk = '1') then
            if (pwm_ce = '1') then
                if (pwm_term = '1') then
                    pwm_out <= '1';
                elsif (pwm_cnt = disp_pdm) then
                    pwm_out <= '0';
                end if;
            end if;
        end if;
    end process;

    
    -- Final output register
    disp_oreg: delay_sig generic map (1) port map (rst_n, clk, pwm_out, disp_blank);

end rtl;
