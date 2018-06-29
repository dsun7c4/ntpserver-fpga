-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : disp_dark.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-19
-- Last update: 2018-06-28
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

      tsc_1ppus         : in    std_logic;
      stat_src          : in    std_logic_vector(3 downto 0);
      stat              : in    std_logic_vector(15 downto 0);

      disp_pdm          : in    std_logic_vector(7 downto 0);

      disp_blank        : OUT   std_logic;
      disp_status       : OUT   std_logic

  );
end disp_dark;



architecture rtl of disp_dark is

    signal pdm_ce_div  : std_logic_vector(0 downto 0);
    signal pdm_ce      : std_logic;
    signal pdm_cnt     : std_logic_vector(7 downto 0);
    signal pdm_term    : std_logic;
    signal pdm_status  : std_logic;

    signal status_mux  : std_logic;
    signal status      : std_logic;

    
begin

    -- Divider to run pdm at 2 us intervals
    disp_div:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            pdm_ce_div <= (others => '0');
            pdm_ce     <= '0';
        elsif (clk'event and clk = '1') then
            if (tsc_1ppus = '1') then
                pdm_ce_div <= pdm_ce_div + 1;
            end if;

            if (tsc_1ppus = '1' and pdm_ce_div = 0) then
                pdm_ce <= '1';
            else
                pdm_ce <= '0';
            end if;
        end if;
    end process;

    
    -- Pulse width modulator counter 512uS cycle
    disp_pdmcnt:
    process (rst_n, clk) is
        variable pdm_sum : std_logic_vector(8 downto 0);
    begin
        if (rst_n = '0') then
            pdm_cnt  <= (others => '0');
            pdm_term <= '1';
        elsif (clk'event and clk = '1') then
            if (pdm_ce = '1') then
                pdm_sum  := '0' & pdm_cnt + disp_pdm;

                pdm_cnt  <= pdm_sum(pdm_cnt'range);
                pdm_term <= not pdm_sum(pdm_sum'left);
            end if;
        end if;
    end process;


    -- Status LED mux, generate minimum 10 mS pulse for status
    disp_stat_sel:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            status_mux <= '0';
        elsif (clk'event and clk = '1') then
            status_mux <= stat(conv_integer(stat_src));
        end if;
    end process;
    st: pulse_stretch generic map (2000000) port map (rst_n, clk, status_mux, status);


    -- Final output register
    disp_oreg: delay_sig generic map (1) port map (rst_n, clk, pdm_term, disp_blank);
    pdm_status <= not pdm_term and status;
    disp_status_oreg: delay_sig generic map (1) port map (rst_n, clk, pdm_status, disp_status);

end rtl;
