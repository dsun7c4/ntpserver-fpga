-------------------------------------------------------------------------------
-- Title      : CLock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : disp.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-05-14
-- Last update: 2018-01-20
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Display controller
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-05-14  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.types_pkg.all;

entity disp is
  port (
      rst_n             : in    std_logic;
      clk               : in    std_logic;

      tsc_1pps          : in    std_logic;
      tsc_1ppms         : in    std_logic;
      tsc_1ppus         : in    std_logic;

      disp_ena          : in    std_logic;
      disp_pdm          : in    std_logic_vector(7 downto 0);
      stat_src          : in    std_logic_vector(3 downto 0);
      stat              : in    std_logic_vector(15 downto 0);
      dp                : in    std_logic_vector(31 downto 0);

      -- Display memory
      sram_addr         : in    std_logic_vector(9 downto 0);
      sram_we           : in    std_logic;
      sram_datao        : in    std_logic_vector(31 downto 0);
      sram_datai        : out   std_logic_vector(31 downto 0);

      -- Time of day
      cur_time          : in    time_ty;

      -- Output to tlc59282 LED driver
      disp_sclk         : OUT   std_logic;
      disp_blank        : OUT   std_logic;
      disp_lat          : OUT   std_logic;
      disp_sin          : OUT   std_logic;
      disp_status       : OUT   std_logic

      );
end disp;



architecture rtl of disp is

    component disp_sr
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
    end component;


    component disp_lut
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            sram_addr         : in    std_logic_vector(9 downto 0);
            sram_we           : in    std_logic;
            sram_datao        : in    std_logic_vector(31 downto 0);
            sram_datai        : out   std_logic_vector(31 downto 0);

            lut_addr          : in    std_logic_vector(11 downto 0);
            lut_data          : out   std_logic_vector(7 downto 0)
            );
    end component;


    component disp_dark
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
    end component;


    component disp_ctl
        port (
            rst_n             : in    std_logic;
            clk               : in    std_logic;

            tsc_1ppms         : in    std_logic;

            disp_ena          : in    std_logic;
            dp                : in    std_logic_vector(31 downto 0);

            -- Time of day
            cur_time          : in    time_ty;

            -- Block memory display buffer and lut
            lut_addr          : out   std_logic_vector(11 downto 0);
            lut_data          : in    std_logic_vector(7 downto 0);

            -- Segment driver data
            disp_data         : out   std_logic_vector(255 downto 0)
            );
    end component;


    SIGNAL disp_data    : std_logic_vector(255 downto 0);

    SIGNAL lut_addr     : std_logic_vector(11 downto 0);
    SIGNAL lut_data     : std_logic_vector(7 downto 0);


begin

    disp_sr_i : disp_sr
        port map (
            rst_n             => rst_n,
            clk               => clk,

            tsc_1pps          => tsc_1pps,
            tsc_1ppms         => tsc_1ppms,
            tsc_1ppus         => tsc_1ppus,

            disp_data         => disp_data,

            disp_sclk         => disp_sclk,
            disp_lat          => disp_lat,
            disp_sin          => disp_sin
            );

    disp_lut_i : disp_lut
        port map (
            rst_n             => rst_n,
            clk               => clk,

            sram_addr         => sram_addr,
            sram_we           => sram_we,
            sram_datao        => sram_datao,
            sram_datai        => sram_datai,

            lut_addr          => lut_addr,
            lut_data          => lut_data
            );


    disp_dark_i : disp_dark
        port map (
            rst_n             => rst_n,
            clk               => clk,

            tsc_1ppus         => tsc_1ppus,
            stat_src          => stat_src,
            stat              => stat,

            disp_pdm          => disp_pdm,

            disp_blank        => disp_blank,
            disp_status       => disp_status
            );


    disp_ctl_i : disp_ctl
        port map (
            rst_n             => rst_n,
            clk               => clk,

            tsc_1ppms         => tsc_1ppms,

            disp_ena          => disp_ena,
            dp                => dp,

            -- Time of day
            cur_time          => cur_time,

            -- Block memory display buffer and lut
            lut_addr          => lut_addr,
            lut_data          => lut_data,

            -- Segment driver data
            disp_data         => disp_data
            );
end rtl;

