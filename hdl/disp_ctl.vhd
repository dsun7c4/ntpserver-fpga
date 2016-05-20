-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : disp_ctl.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-19
-- Last update: 2016-05-19
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Display controler
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

--library work;
--use work.util_pkg.all;

entity disp_ctl is
  port (
      rst_n             : in    std_logic;
      clk               : in    std_logic;

      tsc_1ppms         : in    std_logic;

      dp                : in    std_logic_vector(31 downto 0);

      -- Time of day
      t_1ms             : in    std_logic_vector(3 downto 0);
      t_10ms            : in    std_logic_vector(3 downto 0);
      t_100ms           : in    std_logic_vector(3 downto 0);

      t_1s              : in    std_logic_vector(3 downto 0);
      t_10s             : in    std_logic_vector(3 downto 0);

      t_1m              : in    std_logic_vector(3 downto 0);
      t_10m             : in    std_logic_vector(3 downto 0);

      t_1h              : in    std_logic_vector(3 downto 0);
      t_10h             : in    std_logic_vector(3 downto 0);

      -- Block memory display buffer and lut
      lut_addr          : out   std_logic_vector(11 downto 0);
      lut_data          : in    std_logic_vector(7 downto 0);

      -- Segment driver data
      disp_data         : out   std_logic_vector(255 downto 0)
      );
end disp_ctl;



architecture rtl of disp_ctl is

    signal ce             : std_logic;

    signal cnt            : std_logic_vector(4 downto 0);
    signal cnt_term       : std_logic;

    signal dchar          : std_logic_vector(7 downto 0);
    signal char           : std_logic_vector(7 downto 0);

    signal seg            : std_logic_vector(7 downto 0);
    type out_arr_t is array (natural range <>) of std_logic_vector(7 downto 0);
    signal disp_sr        : out_arr_t(31 downto 0);

    signal rst_addr       : std_logic;
    signal inc_addr       : std_logic;
    signal disp_mem       : std_logic;
    signal data_val       : std_logic;
    signal lut_val        : std_logic;
    signal out_reg        : std_logic;

    type ctl_t is (ctl_idle,
                   ctl_rd,
                   ctl_disp,
                   ctl_proc0,
                   ctl_proc1,
                   ctl_proc2,
                   ctl_lut,
                   ctl_ins
                   );

    signal curr_state     : ctl_t;
    signal next_state     : ctl_t;
    
begin

    -- Clock enable generator
    -- Once every other clock synchronized to ms pulse.
    disp_ctl_ce:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            ce <= '0';
        elsif (clk'event and clk = '1') then
            if (tsc_1ppms = '1') then
                ce <= '0';
            else
                ce <= not ce;
            end if;
            ce <= '1';  -- leave enabled for now
        end if;
    end process;


    -- Character counter
    disp_cnt:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            cnt       <= (others => '0');
            cnt_term  <= '0';
        elsif (clk'event and clk = '1') then
            if (rst_addr = '0') then
                cnt <= (others => '0');
            elsif (ce = '1') then
                cnt <= cnt + 1;
            end if;

            if (rst_addr = '1') then
                cnt_term <= '0';
            elsif (ce = '1' and cnt = 30)  then
                cnt_term <= '1';
            else
                cnt_term <= '0';
            end if;
        end if;
    end process;


    -- Display data for lookup table
    disp_lut_data:
    process (rst_n, clk) is
        variable digit : std_logic_vector(3 downto 0);
    begin
        if (rst_n = '0') then
            dchar <= (others => '0');
            char  <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (ce = '1') then
                if (data_val = '1') then
                    dchar <= lut_data;
                end if;

                case dchar(3 downto 0) is
                    when "0000" =>
                        digit := t_1ms;
                    when "0001" =>
                        digit := t_10ms;
                    when "0010" =>
                        digit := t_100ms;
                    when "0011" =>
                        digit := t_1s;
                    when "0100" =>
                        digit := t_10s;
                    when "0101" =>
                        digit := t_1m;
                    when "0110" =>
                        digit := t_10m;
                    when "0111" =>
                        digit := t_1h;
                    when "1000" =>
                        digit := t_10h;
                    when others =>
                        digit := (others => '0');
                end case;

                if (dchar(7) = '1') then
                    char  <= digit + x"30";
                else
                    char  <= '0' & dchar(6 downto 0);
                end if;
            end if;
        end if;
    end process;


    -- Address mux
    disp_amux:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            lut_addr <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (ce = '1') then
                if (disp_mem = '1') then
                    lut_addr <= "0000000" & cnt;
                else
                    lut_addr <= "1000" & char;
                end if;
            end if;
        end if;
    end process;


    -- Output register
    disp_out:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            seg <= (others => '0');
            for i in 0 to 31 loop
                disp_sr(i) <= (others => '0');
            end loop;
        elsif (clk'event and clk = '1') then
            if (ce = '1') then
                if (lut_val = '1') then
                    seg <= lut_data;
                end if;
                
                if (out_reg = '1') then
                    disp_sr(conv_integer(cnt)) <= seg;
                end if;
            end if;
        end if;
    end process;


    -- Clock enable generator
    -- Once every other clock synchronized to ms pulse.
    disp_ctl_st:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            curr_state <= ctl_idle;
        elsif (clk'event and clk = '1') then
            if (ce = '1') then
                curr_state <= next_state;
            end if;
        end if;
    end process;


    -- State diagram
    -- For now just a shift register, use a state machine in case a more
    -- complex sequence is needed.
    disp_ctl_next:
    process (tsc_1ppms, cnt_term) is
    begin
        -- outputs
        rst_addr <= '0';
        inc_addr <= '0';
        disp_mem <= '0';
        data_val <= '0';
        lut_val  <= '0';
        out_reg  <= '0';
        inc_addr <= '0';
        
        case curr_state is
            when ctl_idle =>
                -- Start building the shift register data every ms
                rst_addr <= '1';
                
                if (tsc_1ppms = '1') then
                    next_state <= ctl_rd;
                else
                    next_state <= ctl_idle;
                end if;

            when ctl_rd =>
                -- Read the display memory
                disp_mem <= '1';

                next_state <= ctl_disp;

            when ctl_disp =>
                -- Register the display memory data
                data_val <= '1';

                next_state <= ctl_proc0;

            when ctl_proc0 =>
                -- Processing

                next_state <= ctl_proc1;

            when ctl_proc1 =>
                -- Processing

                next_state <= ctl_proc2;

            when ctl_proc2 =>
                -- Processing

                next_state <= ctl_lut;

            when ctl_lut =>
                -- Lookup 7 seg output
                lut_val  <= '1';

                next_state <= ctl_ins;

            when ctl_ins =>
                -- Insert data into output register
                -- Increment display memory address
                out_reg  <= '1';
                inc_addr <= '1';
                
                if (cnt_term = '1') then
                    next_state <= ctl_idle;
                else
                    next_state <= ctl_rd;
                end if;
                    
            when others =>
                next_state <= ctl_idle;
        end case;

    end process;


    out_map:
    for i in 0 to 31 generate
        disp_data(i * 8 + 7 downto i * 8 + 1) <= disp_sr(i)(7 downto 1);
        disp_data(i * 8)                      <= dp(i);
    end generate;

end rtl;

