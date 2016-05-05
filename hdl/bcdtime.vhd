-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : bcdtime.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-04
-- Last update: 2016-05-04
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: BCD Time counters ms resolution
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-05-04  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

--library work;
--use work.util_pkg.all;

entity bcdtime is
  port (
      rst_n             : in    std_logic;
      clk               : in    std_logic;

      tsc_1pps          : in    std_logic;
      tsc_1ppms         : in    std_logic;
      set               : in    std_logic;

      set_1s            : in    std_logic_vector(3 downto 0);
      set_10s           : in    std_logic_vector(3 downto 0);

      set_1m            : in    std_logic_vector(3 downto 0);
      set_10m           : in    std_logic_vector(3 downto 0);

      set_1h            : in    std_logic_vector(3 downto 0);
      set_10h           : in    std_logic_vector(3 downto 0);


      t_1ms             : out   std_logic_vector(3 downto 0);
      t_10ms            : out   std_logic_vector(3 downto 0);
      t_100ms           : out   std_logic_vector(3 downto 0);

      t_1s              : out   std_logic_vector(3 downto 0);
      t_10s             : out   std_logic_vector(3 downto 0);

      t_1m              : out   std_logic_vector(3 downto 0);
      t_10m             : out   std_logic_vector(3 downto 0);

      t_1h              : out   std_logic_vector(3 downto 0);
      t_10h             : out   std_logic_vector(3 downto 0)
  );
end bcdtime;



architecture rtl of bcdtime is

    SIGNAL dig_1ms        : std_logic_vector(3 downto 0);
    SIGNAL dig_10ms       : std_logic_vector(3 downto 0);
    SIGNAL dig_100ms      : std_logic_vector(3 downto 0);

    SIGNAL dig_1s         : std_logic_vector(3 downto 0);
    SIGNAL dig_10s        : std_logic_vector(3 downto 0);

    SIGNAL dig_1m         : std_logic_vector(3 downto 0);
    SIGNAL dig_10m        : std_logic_vector(3 downto 0);

    SIGNAL dig_1h         : std_logic_vector(3 downto 0);
    SIGNAL dig_10h        : std_logic_vector(3 downto 0);

    signal ms_carry       : std_logic;
    signal s_carry        : std_logic;
    signal m_carry        : std_logic;
    signal h_carry        : std_logic;
    
    signal sync_time      : std_logic;

begin

    -- Set latch
    time_set:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            sync_time <= '0';
        elsif (clk'event and clk = '1') then
            if (set = '1') then
                sync_time <= '1';
            elsif (tsc_1pps = '1') then
                sync_time <= '0';
            end if;
        end if;
    end process;


    -- Clock ms counters  0-999
    time_ms:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            dig_1ms   <= (others => '0');
            dig_10ms  <= (others => '0');
            dig_100ms <= (others => '0');
            ms_carry  <= '0';
        elsif (clk'event and clk = '1') then
            if (sync_time = '1' and tsc_1pps = '1') then
                dig_1ms   <= (others => '0');
                dig_10ms  <= (others => '0');
                dig_100ms <= (others => '0');
                ms_carry  <= '0';
            elsif (tsc_1ppms = '1') then
                if (dig_1ms = 9) then 
                    dig_1ms   <= (others => '0');
                else
                    dig_1ms   <= dig_1ms + 1;
                end if;
                
                if (dig_1ms = 9) then 
                    if (dig_10ms = 9) then 
                        dig_10ms  <= (others => '0');
                    else
                        dig_10ms  <= dig_10ms + 1;
                    end if;
                end if;

                if (dig_1ms = 9 and dig_10ms = 9) then 
                    if (dig_100ms = 9) then 
                        dig_100ms <= (others => '0');
                    else
                        dig_100ms <= dig_100ms + 1;
                    end if;
                end if;

                if (dig_1ms = 8 and dig_10ms = 9 and dig_100ms = 9) then 
                    ms_carry  <= '1';
                else
                    ms_carry  <= '0';
                end if;                    

            end if;
        end if;
    end process;


    -- Clock second counters 0 - 59
    time_s:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            dig_1s   <= (others => '0');
            dig_10s  <= (others => '0');
            s_carry  <= '0';
        elsif (clk'event and clk = '1') then
            if (sync_time = '1' and tsc_1pps = '1') then
                dig_1s   <= set_1s;
                dig_10s  <= set_10s;
                s_carry  <= '0';
            elsif (tsc_1ppms = '1' and ms_carry = '1') then
                if (dig_1s = 9) then 
                    dig_1s   <= (others => '0');
                else
                    dig_1s   <= dig_1s + 1;
                end if;
                
                if (dig_1s = 9) then 
                    if (dig_10s = 5) then 
                        dig_10s  <= (others => '0');
                    else
                        dig_10s  <= dig_10s + 1;
                    end if;
                end if;
                
                if (dig_1s = 8 and dig_10s = 5) then 
                    s_carry  <= '1';
                else
                    s_carry  <= '0';
                end if;                    

            end if;
        end if;
    end process;



    -- Clock minute counters 0 - 59
    time_m:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            dig_1m   <= (others => '0');
            dig_10m  <= (others => '0');
            m_carry  <= '0';
        elsif (clk'event and clk = '1') then
            if (sync_time = '1' and tsc_1pps = '1') then
                dig_1m   <= set_1m;
                dig_10m  <= set_10m;
                m_carry  <= '0';
            elsif (tsc_1ppms = '1' and s_carry = '1' and ms_carry ='1') then
                if (dig_1m = 9) then 
                    dig_1m   <= (others => '0');
                else
                    dig_1m   <= dig_1m + 1;
                end if;
                
                if (dig_1m = 9) then 
                    if (dig_10m = 5) then 
                        dig_10m  <= (others => '0');
                    else
                        dig_10m  <= dig_10m + 1;
                    end if;
                end if;

                if (dig_1m = 8 and dig_10m = 5) then 
                    m_carry  <= '1';
                else
                    m_carry  <= '0';
                end if;                    

            end if;
        end if;
    end process;



    -- Clock hour counters  0 - 23
    time_h:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            dig_1h   <= (others => '0');
            dig_10h  <= (others => '0');
            h_carry  <= '0';
        elsif (clk'event and clk = '1') then
            if (sync_time = '1' and tsc_1pps = '1') then
                dig_1h   <= set_1h;
                dig_10h  <= set_10h;
                h_carry  <= '0';
            elsif (tsc_1ppms = '1' and m_carry = '1' and s_carry = '1' and ms_carry = '1') then
                if (dig_1h = 9 or (dig_1h = 3 and dig_10h = 2)) then 
                    dig_1h   <= (others => '0');
                else
                    dig_1h   <= dig_1h + 1;
                end if;
                
                if (dig_1h = 9 or (dig_1h = 3 and dig_10h = 2)) then 
                    if (dig_1h = 3 and dig_10h = 2) then 
                        dig_10h  <= (others => '0');
                    else
                        dig_10h  <= dig_10h + 1;
                    end if;
                end if;

                if (dig_1h = 2 and dig_10h = 2) then 
                    h_carry  <= '1';
                else
                    h_carry  <= '0';
                end if;                    

            end if;
        end if;
    end process;


    t_1ms   <= dig_1ms;
    t_10ms  <= dig_10ms;
    t_100ms <= dig_100ms;
    t_1s    <= dig_1s;
    t_10s   <= dig_10s;
    t_1m    <= dig_1m;
    t_10m   <= dig_10m;
    t_1h    <= dig_1h;
    t_10n   <= dig_10h;


end rtl;

