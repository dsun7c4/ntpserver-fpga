-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tsc.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-04-29
-- Last update: 2016-08-23
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
      gps_3dfix_d       : in    std_logic;
      tsc_read          : in    std_logic;
      tsc_sync          : in    std_logic;
      gps_1pps_d        : out   std_logic;

      pdiff_1pps        : out   std_logic_vector(31 downto 0);
      fdiff_1pps        : out   std_logic_vector(31 downto 0);

      tsc_cnt           : out   std_logic_vector(63 downto 0);
      tsc_cnt1          : out   std_logic_vector(63 downto 0);
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

    signal pfd_rst        : std_logic;
    signal pfd_rst_d      : std_logic;
    signal tsc_1pps_pulse : std_logic;
    signal lead           : std_logic;
    signal lag            : std_logic;
    signal trig           : std_logic;

    signal diff_cnt       : std_logic_vector(31 downto 0);
    signal pdiff          : std_logic_vector(31 downto 0);
    signal fdiff          : std_logic_vector(31 downto 0);

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
    -- Output count at one second
    tsc_oreg:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            tsc_cnt  <= (others => '0');
            tsc_cnt1 <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (tsc_read = '1') then
                tsc_cnt  <= counter;
            end if;
            if (pps_cnt_term = '1') then
                tsc_cnt1 <= counter;
            end if;
        end if;
    end process;


    -- ----------------------------------------------------------------------
    
    
    -- One pulse pulse per second
    tsc_1pps_ctr:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            pps_cnt      <= (others => '0');
            pps_cnt_term <= '0';
        elsif (clk'event and clk = '1') then
            if (pps_cnt_term = '1' or (tsc_sync = '1' and gps_1pps_pulse = '1')) then
                pps_cnt      <= (others => '0');
            else
                pps_cnt <= pps_cnt + 1;
            end if;
            --if (pps_cnt = x"5F5E0FE") then
            if (pps_cnt = (100000000 - 2) or (tsc_sync = '1' and gps_1pps_pulse = '1')) then
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

    
    -- ----------------------------------------------------------------------


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


    gps_1pps_d <= gps_1pps_pulse;
    

    -- Delay the ocxo 1pps pulse approximately the same amount as the gps 1pps
    tsc_pps_i:  delay_sig generic map (3) port map (rst_n, clk, pps_cnt_term, tsc_1pps_pulse);
    pfd_rst <= tsc_sync and gps_1pps_pulse;
    tsc_pfd_rst_i:  delay_pulse generic map (10) port map (rst_n, clk, pfd_rst, pfd_rst_d);
    
    
    -- Phase detector
    tsc_phase:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            lead <= '0';
            lag  <= '0';
            trig <= '0';
        elsif (clk'event and clk = '1') then
            trig <= '0';

            -- Reset phase detector on sync
            if (pfd_rst_d = '1') then
                lead <= '0';
                lag  <= '0';
                trig <= '0';
            -- (lead & lag & tsc_1pps_pulse & gps_1pps_pulse)
            -- 0010
            elsif (lead = '0' and lag = '0' and
                tsc_1pps_pulse = '1' and gps_1pps_pulse = '0' ) then
                lead <= '1';
            -- 1001
            elsif (lead = '1' and lag = '0' and
                   tsc_1pps_pulse = '0' and gps_1pps_pulse = '1' ) then
                lead <= '0';
                trig <= '1';

            -- 0001
            elsif (lead = '0' and lag = '0' and
                   tsc_1pps_pulse = '0' and gps_1pps_pulse = '1' ) then
                lag  <= '1';
            -- 0110
            elsif (lead = '0' and lag = '1' and
                   tsc_1pps_pulse = '1' and gps_1pps_pulse = '0' ) then
                lag  <= '0';
                trig <= '1';

            -- 0011
            -- 0111
            -- 1011
            -- 1100
            -- 1101
            -- 1110
            -- 1111
            elsif ((lead = '1' and lag = '1') or 
                   (tsc_1pps_pulse = '1' and gps_1pps_pulse = '1')) then
                lead <= '0';
                lag  <= '0';
                trig <= '1';
            end if;

            -- 0000
            -- 0100  Measure lag
            -- 0101
            -- 1000  Measure lead
            -- 1010
        end if;
    end process;



    -- Difference measurement between GPS and OCXO
    tsc_meas:
    process (rst_n, clk) is
        variable diff_add : std_logic_vector(diff_cnt'left downto 0);
        variable diff_sub : std_logic_vector(diff_cnt'left downto 0);
    begin
        if (rst_n = '0') then
            diff_cnt    <= (others => '0');
            pdiff       <= (others => '0');
            fdiff       <= (others => '0');
        elsif (clk'event and clk = '1') then
            diff_add  := diff_cnt + 1;
            diff_sub  := diff_cnt - 1;

            if ((lead = '0' and lag = '0') or
                (tsc_1pps_pulse = '1' and gps_1pps_pulse = '1')) then
                diff_cnt    <= (others => '0');
            else
                if (lag = '1') then
                    -- Saturate at 2^31-1
                    if (diff_add(diff_add'left) = '0') then
                        diff_cnt    <= diff_add(diff_cnt'range);
                    end if;
                elsif (lead = '1') then
                    -- Saturate at -2^31
                    if (diff_sub(diff_sub'left) = '1') then
                        diff_cnt    <= diff_sub(diff_cnt'range);
                    end if;                        
                end if;
            end if;

            if (trig = '1') then
                pdiff       <= diff_cnt;
                fdiff       <= diff_cnt - pdiff;
            end if;
        end if;
    end process;


    pdiff_1pps <= pdiff;
    fdiff_1pps <= fdiff;

    
end rtl;
