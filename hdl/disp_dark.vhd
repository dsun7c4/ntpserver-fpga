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

    signal pdm_ce      : std_logic;
    signal pdm_cnt     : std_logic_vector(7 downto 0);
    signal pdm_term    : std_logic;
    
begin

    pdm_ce <= tsc_1ppms;

    -- Pulse width modulator counter
    disp_pdmcnt:
    process (rst_n, clk) is
        variable pdm_sum : std_logic_vector(8 downto 0);
    begin
        if (rst_n = '0') then
            pdm_cnt  <= (others => '0');
            pdm_term <= '0';
        elsif (clk'event and clk = '1') then
            if (pdm_ce = '1') then
                pdm_sum  := '0' & pdm_cnt + disp_pdm;

                pdm_cnt  <= pdm_sum(pdm_cnt'range);
                pdm_term <= pdm_sum(pdm_sum'left);
            end if;
        end if;
    end process;


    -- Final output register
    disp_oreg: delay_sig generic map (1) port map (rst_n, clk, pdm_term, disp_blank);

end rtl;
