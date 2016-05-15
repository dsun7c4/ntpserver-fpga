-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tsc.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-04-29
-- Last update: 2016-05-15
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Time Stamp Counter
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-04-29  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.util_pkg.all;

entity tsc is
  port (
      rst_n             : in    std_logic;
      clk               : in    std_logic;

      gps_1pps          : in    std_logic;
      tsc_read          : in    std_logic;
      tsc_sync          : in    std_logic;

      diff_1pps         : out   std_logic_vector(31 downto 0);

      tsc_cnt           : out   std_logic_vector(63 downto 0);
      tsc_1pps          : out   std_logic;
      tsc_1ppms         : out   std_logic;
      tsc_1ppus         : out   std_logic
  );
end tsc;



architecture rtl of tsc is

    signal counter        : std_logic_vector(63 downto 0);

    signal pps_cnt        : std_logic_vector(27 downto 0);
    signal pps_cnt_term   : std_logic;

    signal ppms_cnt       : std_logic_vector(16 downto 0);
    signal ppms_cnt_term  : std_logic;

    signal ppus_cnt       : std_logic_vector(6 downto 0);
    signal ppus_cnt_term  : std_logic;

    signal gps_1pps_dly   : std_logic_vector(2 downto 0);
    signal gps_1pps_pulse : std_logic;

    signal diff_cnt       : std_logic_vector(31 downto 0);

begin

    -- The TSC counter 64 bit running at 100MHz
    tsc_counter:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            counter <= (others => '0');
        elsif (clk'event and clk = '1') then
            counter <= counter + 1;
        end if;
    end process;


    -- Output read sample register
    tsc_oreg:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            tsc_cnt <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (tsc_read = '1') then
                tsc_cnt <= counter;
            end if;
        end if;
    end process;

    
    -- One pulse pulse per second
    tsc_1pps_ctr:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            pps_cnt      <= (others => '0');
            pps_cnt_term <= '0';
        elsif (clk'event and clk = '1') then
            if (pps_cnt_term = '1') then
                pps_cnt      <= (others => '0');
            else
                pps_cnt <= pps_cnt + 1;
            end if;
            --if (pps_cnt = x"5F5E0FE") then
            if (pps_cnt = (100000000 - 2)) then
                pps_cnt_term <= '1';
            else
                pps_cnt_term <= '0';
            end if;
        end if;
    end process;

    tsc_1pps <= pps_cnt_term;


    -- Millisecond pulse generator synchronized to pps
    tsc_1ppms_ctr:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            ppms_cnt      <= (others => '0');
            ppms_cnt_term <= '0';
        elsif (clk'event and clk = '1') then
            if (ppms_cnt_term = '1' or pps_cnt_term = '1') then
                ppms_cnt      <= (others => '0');
            else
                ppms_cnt      <= ppms_cnt + 1;
            end if;

            if (ppms_cnt = (100000 - 2) and pps_cnt_term = '0') then
                ppms_cnt_term <= '1';
            else
                ppms_cnt_term <= '0';
            end if;
        end if;
    end process;

    tsc_1ppms <= ppms_cnt_term;

    
    -- Microsecond pulse generator synchronized to pps
    tsc_1ppus_ctr:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            ppus_cnt      <= (others => '0');
            ppus_cnt_term <= '0';
        elsif (clk'event and clk = '1') then
            if (ppus_cnt_term = '1' or pps_cnt_term = '1') then
                ppus_cnt      <= (others => '0');
            else
                ppus_cnt      <= ppus_cnt + 1;
            end if;

            if (ppus_cnt = (100 - 2) and pps_cnt_term = '0') then
                ppus_cnt_term <= '1';
            else
                ppus_cnt_term <= '0';
            end if;
        end if;
    end process;

    tsc_1ppus <= ppus_cnt_term;

    
    -- GPS 1 pulse per second input register
    tsc_gps_ireg:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            gps_1pps_dly   <= (others => '0');
            gps_1pps_pulse <= '0';
        elsif (clk'event and clk = '1') then
            gps_1pps_dly(0) <= gps_1pps;
            gps_1pps_dly(1) <= gps_1pps_dly(0);
            gps_1pps_dly(2) <= gps_1pps_dly(1);
            gps_1pps_pulse  <= not gps_1pps_dly(2) and gps_1pps_dly(1);
        end if;
    end process;

    
    
    -- Difference measurement between GPS and OCXO
    tsc_meas:
    process (rst_n, clk) is
        variable diff_add : std_logic_vector(diff_cnt'left + 1 downto 0);
    begin
        if (rst_n = '0') then
            diff_cnt   <= (others => '0');
            diff_1pps  <= (others => '0');
        elsif (clk'event and clk = '1') then
            diff_add  := ('0' & diff_cnt) + 1;

            if (gps_1pps_pulse = '1') then
                diff_cnt   <= (others => '0');
            else
                -- Saturate at 2^32-1
                if (diff_add(diff_add'left) = '0') then
                    diff_cnt <= diff_add(diff_cnt'range);
                end if;
            end if;

            if (pps_cnt_term = '1') then
                diff_1pps  <= diff_cnt;
            end if;
        end if;
    end process;


end rtl;
