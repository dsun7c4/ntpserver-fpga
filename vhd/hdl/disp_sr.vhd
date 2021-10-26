-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    :
-------------------------------------------------------------------------------
-- File       : disp_sr.vhd
-- Author     : Daniel Sun  <dsun7c4osh@gmail.com>
-- Company    :
-- Created    : 2016-05-15
-- Last update: 2018-04-21
-- Platform   :
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Display shift register
-------------------------------------------------------------------------------
-- Copyright (c) 2016
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-05-15  1.0      dsun7c4osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.util_pkg.all;

entity disp_sr is
  port (
      rst_n             : in    std_logic;
      clk               : in    std_logic;

      tsc_1pps          : in    std_logic;
      tsc_1ppms         : in    std_logic;
      tsc_1ppus         : in    std_logic;

      disp_data         : in    std_logic_vector(255 downto 0);

      disp_sclk         : OUT   std_logic;
      disp_lat          : OUT   std_logic;
      disp_sin          : OUT   std_logic

      );
end disp_sr;



architecture rtl of disp_sr is

    signal trig           : std_logic;
    signal trig_arm       : std_logic;

    SIGNAL bit_sr         : std_logic_vector(255 downto 0);
    SIGNAL bit_cnt        : std_logic_vector(8 downto 0);
    signal finish         : std_logic;

    signal lat            : std_logic;
    signal sclk           : std_logic;
    signal sin            : std_logic;

begin

    --
    --                  __
    -- disp_lat    ____|  |_____________  ______________________
    --             _______ _____ _____ _  __ _____ _____ _______
    -- disp_sin    _______X_____X_____X_  __X_____X_____X_______
    --                        __    __    __    __    __
    -- disp_sclk   __________|  |__|  |_    |__|  |__|  |_______
    --
    -- Bit                 255   254    ..     1     0
    --


    -- Start triggering
    disp_trig:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            trig     <= '0';
            trig_arm <= '0';
        elsif (clk'event and clk = '1') then
            if (tsc_1ppms = '1') then
                trig_arm <= '1';
            elsif (tsc_1ppus = '1') then
                trig_arm <= '0';
            end if;

            if (tsc_1ppus = '1' and trig_arm = '1') then
                trig     <= '1';
            elsif (finish = '1') then
                trig     <= '0';
            end if;
        end if;
    end process;


    -- bit counter
    disp_cnt:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            bit_cnt <= (others => '0');
            finish  <= '0';
        elsif (clk'event and clk = '1') then
            if (trig = '0') then
                bit_cnt <= (others => '0');
            elsif (tsc_1ppus = '1' and trig = '1') then
                bit_cnt <= bit_cnt + 1;
            end if;

            if (tsc_1ppus = '1' and bit_cnt = 511)  then
                finish <= '1';
            else
                finish <= '0';
            end if;
        end if;
    end process;


    -- Generate DISP control signals
    disp_shift:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            bit_sr <= (others => '0');
            bit_sr( 7 downto  0) <= x"1c";
            bit_sr(15 downto  8) <= x"ce";
            bit_sr(23 downto 16) <= x"bc";
            lat    <= '0';
            sclk   <= '0';
            sin    <= '0';
        elsif (clk'event and clk = '1') then
            if (tsc_1ppms = '1') then
                bit_sr <= disp_data;
            elsif (tsc_1ppus = '1' and bit_cnt(0) = '1') then
                bit_sr <= bit_sr(bit_sr'left - 1 downto 0) & '0';
            end if;
                
            if (tsc_1ppus = '1') then
                lat    <= trig_arm;
                sclk   <= bit_cnt(0);
                sin    <= bit_sr(bit_sr'left);
            end if;
        end if;
    end process;


    -- Final output register
    disp_olat:  delay_sig generic map (1) port map (rst_n, clk, lat,  disp_lat);
    disp_osclk: delay_sig generic map (1) port map (rst_n, clk, sclk, disp_sclk);
    disp_osin:  delay_sig generic map (1) port map (rst_n, clk, sin,  disp_sin);


end rtl;

