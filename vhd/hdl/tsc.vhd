-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tsc.vhd
-- Author     : Daniel Sun  <dsun7c4osh@gmail.com>
-- Company    : 
-- Created    : 2016-04-29
-- Last update: 2017-06-08
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Time Stamp Counter
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-04-29  1.0      dsun7c4osh  Created
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
      pfd_resync        : in    std_logic;
      gps_1pps_d        : out   std_logic;
      tsc_1pps_d        : out   std_logic;
      pll_trig          : out   std_logic;
      pfd_status        : out   std_logic;

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

    signal pps_rst        : std_logic;
    signal tsc_1pps_dly   : std_logic_vector(2 downto 0);
    signal tsc_1pps_pulse : std_logic;

    type pfd_t is (pfd_idle,
                   pfd_lead,
                   pfd_lag,
                   pfd_trig,
                   pfd_sync,
                   pfd_tsc,
                   pfd_gps,
                   pfd_det_gps,
                   pfd_det_tsc,
                   pfd_wait_gps,
                   pfd_wait_tsc
                   );

    signal curr_state     : pfd_t;
    signal next_state     : pfd_t;
    

    constant CLKS_PER_SEC    : natural := 100000000;
    constant CLKS_PER_MS     : natural := CLKS_PER_SEC / 1000;
    constant CLKS_PER_US     : natural := CLKS_PER_MS  / 1000;
    constant CLKS_PER_SEC_2  : natural := CLKS_PER_SEC / 2;
    constant CLKS_PER_SEC_2N : integer := -CLKS_PER_SEC_2;

    signal lead       : std_logic;
    signal lag        : std_logic;
    signal trig       : std_logic;
    signal gt_half    : std_logic;
    signal clr_diff   : std_logic;
    signal clr_status : std_logic;
    signal set_status : std_logic;

    signal diff_cnt   : std_logic_vector(31 downto 0);
    signal pdiff      : std_logic_vector(31 downto 0);
    signal fdiff      : std_logic_vector(31 downto 0);

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
    
    
    -- Reset signal register for pulse per s, ms, us counters and PFD
    tsc_1pps_rst:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            pps_rst <= '0';
        elsif (clk'event and clk = '1') then
            pps_rst <= tsc_sync and gps_1pps_pulse;
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
            if (pps_cnt_term = '1' or pps_rst = '1') then
                pps_cnt      <= (others => '0');
            else
                pps_cnt <= pps_cnt + 1;
            end if;

            if (pps_rst = '1') then
                pps_cnt_term <= '0';
            elsif (pps_cnt = (CLKS_PER_SEC - 2)) then
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
            if (ppms_cnt_term = '1' or pps_cnt_term = '1' or pps_rst = '1') then
                ppms_cnt      <= (others => '0');
            else
                ppms_cnt      <= ppms_cnt + 1;
            end if;

            if (pps_cnt_term = '1' or pps_rst = '1') then
                ppms_cnt_term <= '0';
            elsif (ppms_cnt = (CLKS_PER_MS - 2)) then
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
            if (ppus_cnt_term = '1' or pps_cnt_term = '1' or pps_rst = '1') then
                ppus_cnt      <= (others => '0');
            else
                ppus_cnt      <= ppus_cnt + 1;
            end if;

            if (pps_cnt_term = '1' or pps_rst = '1') then
                ppus_cnt_term <= '0';
            elsif (ppus_cnt = (CLKS_PER_US - 2)) then
                ppus_cnt_term <= '1';
            else
                ppus_cnt_term <= '0';
            end if;
        end if;
    end process;

    tsc_1ppus <= ppus_cnt_term;

    
    -- ----------------------------------------------------------------------


    -- GPS 1 pulse per second input register
    -- Delay the ocxo 1pps pulse approximately the same amount as the gps 1pps
    tsc_pps_delay:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            gps_1pps_dly   <= (others => '0');
            gps_1pps_pulse <= '0';
            tsc_1pps_dly   <= (others => '0');
            tsc_1pps_pulse <= '0';
        elsif (clk'event and clk = '1') then
            gps_1pps_dly(0) <= gps_1pps;
            gps_1pps_dly(1) <= gps_1pps_dly(0);
            gps_1pps_dly(2) <= gps_1pps_dly(1);
            gps_1pps_pulse  <= not gps_1pps_dly(2) and gps_1pps_dly(1);

            if (pps_rst = '1') then
                tsc_1pps_dly   <= (others => '0');
                tsc_1pps_pulse <= '0';
            else
                tsc_1pps_dly(0) <= pps_cnt_term;
                tsc_1pps_dly(1) <= tsc_1pps_dly(0);
                tsc_1pps_dly(2) <= tsc_1pps_dly(1);
                tsc_1pps_pulse  <= tsc_1pps_dly(1);
            end if;
        end if;
    end process;

    gps_1pps_d <= gps_1pps_pulse;
    tsc_1pps_d <= tsc_1pps_pulse;
    

    -- Phase detector state machine register
    tsc_pfd_st:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            curr_state <= pfd_idle;
        elsif (clk'event and clk = '1') then
            curr_state <= next_state;
        end if;
    end process;


    -- Phase detector State diagram
    -- Set difference to zero for missing pps
    -- Automatically set the lead/lag phasing
    tsc_pfd_next:
    process (curr_state, tsc_1pps_pulse, gps_1pps_pulse, pfd_resync, gt_half) is
    begin
        -- outputs
        lead       <= '0';
        lag        <= '0';
        trig       <= '0';
        clr_diff   <= '0';
        clr_status <= '0';
        set_status <= '0';
        
        case curr_state is
            -- ------------------------------------------------------------
            -- ------------------------------------------------------------
            -- Phase detector
            -- Referenced to GPS PPS
            -- Negative phase if TSC is before GPS

            when pfd_idle =>
                -- Idle state 

                clr_status <= '1';

                if (tsc_1pps_pulse = '1' and gps_1pps_pulse = '1') then
                    next_state <= pfd_trig;
                elsif (tsc_1pps_pulse = '1') then
                    next_state <= pfd_lead;
                elsif (gps_1pps_pulse = '1' ) then
                    next_state <= pfd_lag;
                elsif (pfd_resync = '1') then
                    next_state <= pfd_sync;
                else
                    next_state <= pfd_idle;
                end if;

            when pfd_lead =>
                -- Got tsc pps before gps

                lead       <= '1'; -- Count down

                if (tsc_1pps_pulse = '1' or gt_half = '1') then
                    -- Missing gps pps
                    next_state <= pfd_sync;
                elsif (gps_1pps_pulse = '1' ) then
                    next_state <= pfd_trig;
                else
                    next_state <= pfd_lead;
                end if;

            when pfd_lag =>
                -- Got gps pps before tsc

                lag        <= '1'; -- Count up

                if (gps_1pps_pulse = '1' or gt_half = '1') then
                    -- Missing tsc pps
                    next_state <= pfd_sync;
                elsif (tsc_1pps_pulse = '1') then
                    next_state <= pfd_trig;
                else
                    next_state <= pfd_lag;
                end if;

            when pfd_trig =>
                -- Set the holding register

                trig       <= '1';

                next_state <= pfd_idle;


            -- ------------------------------------------------------------
            -- ------------------------------------------------------------
            -- Resync the phase detector

            when pfd_sync =>
                -- Resync the phase detector due to lost pulse or sw resync

                clr_diff   <= '1';
                set_status <= '1';

                if (tsc_1pps_pulse = '1' and gps_1pps_pulse = '1') then
                    next_state <= pfd_idle;
                elsif (tsc_1pps_pulse = '1') then
                    next_state <= pfd_tsc;
                elsif (gps_1pps_pulse = '1' ) then
                    next_state <= pfd_gps;
                else
                    next_state <= pfd_sync;
                end if;

            -- ------------------------------------------------------------
            -- tsc pulse detected first

            when pfd_tsc =>
                -- tsc pulse detected, measure time to gps pulse

                lag        <= '1'; -- Count up

                if (tsc_1pps_pulse = '1') then
                    next_state <= pfd_sync;
                elsif (gps_1pps_pulse = '1' ) then
                    next_state <= pfd_det_gps;
                else
                    next_state <= pfd_tsc;
                end if;

            when pfd_det_gps =>
                -- gps pulse detected, check tsc->gps time measurement

                if (gt_half = '1' ) then
                    next_state <= pfd_wait_gps;
                else
                    next_state <= pfd_idle;
                end if;

            when pfd_wait_gps =>
                -- Wait for next gps pulse to restart measurement

                if (tsc_1pps_pulse = '1' and gps_1pps_pulse = '1') then
                    next_state <= pfd_idle;
                elsif (gps_1pps_pulse = '1' ) then
                    next_state <= pfd_gps;
                else
                    next_state <= pfd_wait_gps;
                end if;

            -- ------------------------------------------------------------
            -- gps pulse detected first

            when pfd_gps =>
                -- gps pulse detected, measure time to tsc pulse

                lag        <= '1'; -- Count up

                if (gps_1pps_pulse = '1') then
                    next_state <= pfd_sync;
                elsif (tsc_1pps_pulse = '1' ) then
                    next_state <= pfd_det_tsc;
                else
                    next_state <= pfd_gps;
                end if;

            when pfd_det_tsc =>
                -- gps pulse detected, check gps->tsc time measurement

                if (gt_half = '1' ) then
                    next_state <= pfd_wait_tsc;
                else
                    next_state <= pfd_idle;
                end if;

            when pfd_wait_tsc =>
                -- Wait for next tsc pulse to restart measurement

                if (tsc_1pps_pulse = '1' and gps_1pps_pulse = '1') then
                    next_state <= pfd_idle;
                elsif (tsc_1pps_pulse = '1' ) then
                    next_state <= pfd_tsc;
                else
                    next_state <= pfd_wait_tsc;
                end if;

            -- ------------------------------------------------------------
            -- ------------------------------------------------------------
            when others =>
                next_state <= pfd_idle;
        end case;

    end process;

    pll_trig   <= trig;


    -- Difference measurement between GPS and OCXO
    tsc_ctrs:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            diff_cnt    <= (others => '0');
            gt_half     <= '0';
        elsif (clk'event and clk = '1') then
            if (lead = '0' and lag = '0') then
                diff_cnt    <= (others => '0');
                gt_half     <= '0';
            else
                if (lag = '1') then
                    diff_cnt    <= diff_cnt + 1;
                elsif (lead = '1') then
                    diff_cnt    <= diff_cnt - 1;
                end if;

                if (diff_cnt = CLKS_PER_SEC_2 or
                    diff_cnt = conv_std_logic_vector(CLKS_PER_SEC_2N, diff_cnt'length)) then
                    gt_half     <= '1';
                end if;
            end if;
        end if;
    end process;


    -- Count output for micro registers
    -- PFD sync state status register
    tsc_pfd_status:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            pdiff       <= (others => '0');
            fdiff       <= (others => '0');
            pfd_status  <= '0';
        elsif (clk'event and clk = '1') then
            if (clr_diff = '1') then
                pdiff       <= (others => '0');
                fdiff       <= (others => '0');
            elsif (trig = '1') then
                pdiff       <= diff_cnt;
                fdiff       <= diff_cnt - pdiff;
            end if;

            if (clr_status = '1') then
                pfd_status  <= '0';
            elsif (set_status = '1') then
                pfd_status  <= '1';
            end if;
        end if;
    end process;

    pdiff_1pps <= pdiff;
    fdiff_1pps <= fdiff;


end rtl;
