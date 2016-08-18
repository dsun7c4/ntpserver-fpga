-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : clock_.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-03-13
-- Last update: 2016-08-17
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top level entity for clock fpga
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-03-13  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity clock is
  port (
      DDR_addr          : INOUT std_logic_vector (14 DOWNTO 0);
      DDR_ba            : INOUT std_logic_vector (2 DOWNTO 0);
      DDR_cas_n         : INOUT std_logic;
      DDR_ck_n          : INOUT std_logic;
      DDR_ck_p          : INOUT std_logic;
      DDR_cke           : INOUT std_logic;
      DDR_cs_n          : INOUT std_logic;
      DDR_dm            : INOUT std_logic_vector (3 DOWNTO 0);
      DDR_dq            : INOUT std_logic_vector (31 DOWNTO 0);
      DDR_dqs_n         : INOUT std_logic_vector (3 DOWNTO 0);
      DDR_dqs_p         : INOUT std_logic_vector (3 DOWNTO 0);
      DDR_odt           : INOUT std_logic;
      DDR_ras_n         : INOUT std_logic;
      DDR_reset_n       : INOUT std_logic;
      DDR_we_n          : INOUT std_logic;

      FIXED_IO_ddr_vrn  : INOUT std_logic;
      FIXED_IO_ddr_vrp  : INOUT std_logic;
      FIXED_IO_mio      : INOUT std_logic_vector (53 DOWNTO 0);
      FIXED_IO_ps_clk   : INOUT std_logic;
      FIXED_IO_ps_porb  : INOUT std_logic;
      FIXED_IO_ps_srstb : INOUT std_logic;

      Vp_Vn_v_n         : in    std_logic;
      Vp_Vn_v_p         : in    std_logic;

      rtc_scl           : INOUT std_logic;
      rtc_sda           : INOUT std_logic;

      ocxo_ena          : INOUT std_logic;
      ocxo_clk          : IN    std_logic;
      ocxo_scl          : INOUT std_logic;
      ocxo_sda          : INOUT std_logic;

      dac_sclk          : OUT   std_logic;
      dac_cs_n          : OUT   std_logic;
      dac_sin           : OUT   std_logic;

      gps_ena           : INOUT std_logic;
      gps_rxd           : IN    std_logic;
      gps_txd           : OUT   std_logic;
      gps_3dfix         : IN    std_logic;
      gps_1pps          : IN    std_logic;

      temp_scl          : INOUT std_logic;
      temp_sda          : INOUT std_logic;

      disp_sclk         : OUT   std_logic;
      disp_blank        : OUT   std_logic;
      disp_lat          : OUT   std_logic;
      disp_sin          : OUT   std_logic;

      fan_tach          : IN    std_logic;
      fan_pwm           : OUT   std_logic;

      gpio              : INOUT std_logic_vector (7 DOWNTO 0)

  );
end clock;

