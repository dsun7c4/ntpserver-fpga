-------------------------------------------------------------------------------
-- Title      : Clock
-- Project    :
-------------------------------------------------------------------------------
-- File       : io.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    :
-- Created    : 2016-05-21
-- Last update: 2016-08-17
-- Platform   :
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: GPIO tri-state buffer and clock domain transfer
-------------------------------------------------------------------------------
-- Copyright (c) 2016
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-05-21  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------
--
--              Address range: 0x412_0000 - 0x4120_0004
--             |  1        |         0         |
--             |5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
-- default      T T T T T T T T 0 0 T 1 T T 1 1
--
-- 0x4120_0000 |     gpio      |d|a| |g| |l|p|o|  Read/Write
--                              | |   |   | | |
--                              | |   |   | | OCXO enable (power)  R/W
--                              | |   |   | PLL reset bar          R/W
--                              | |   |   PLL Locked               R
--                              | |   GPS enable (power)           R/W
--                              | DAC Controller enable            R/W
--                              Display controller enable          R/W
--
-- 0x4120_0004 |               |               |  Tri state control
--

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.util_pkg.all;

entity io is
  port (
      fclk_rst_n        : in    std_logic;
      fclk              : in    std_logic;
      rst_n             : in    std_logic;
      clk               : in    std_logic;

      -- fclk
      GPIO_tri_i        : out   std_logic_vector (15 downto 0);
      GPIO_tri_o        : in    std_logic_vector (15 downto 0);
      GPIO_tri_t        : in    std_logic_vector (15 downto 0);

      -- clk
      locked            : in    std_logic;
      dac_ena           : out   std_logic;
      dac_tri           : out   std_logic;
      disp_ena          : out   std_logic;

      -- fclk
      pll_rst_n         : out   std_logic;
      ocxo_ena          : inout std_logic;
      gps_ena           : inout std_logic;
      gps_tri           : out   std_logic;
      gpio              : inout std_logic_vector (7 DOWNTO 0)

  );
end io;



architecture rtl of io is

    component IOBUF is
        port (
            I : in STD_LOGIC;
            O : out STD_LOGIC;
            T : in STD_LOGIC;
            IO : inout STD_LOGIC
            );
    end component IOBUF;


    signal gpio_o_d        : std_logic_vector (15 downto 0);
    signal gpio_t_d        : std_logic_vector (15 downto 0);
    signal reset_n         : std_logic;

    signal ocxo_ena_tri    : std_logic;

    signal ocxo_pwr_ena    : std_logic;
    signal ocxo_pwr_on     : std_logic;
    signal ocxo_on_ctr     : std_logic_vector(12 downto 0);  -- 25 us turn on

    signal gps_ena_tri     : std_logic;

    signal gps_pwr_ena     : std_logic;
    signal gps_pwr_on      : std_logic;
    signal gps_on_ctr      : std_logic_vector(12 downto 0);

    attribute keep : string;
    attribute keep of gps_pwr_ena : signal is "true";

begin

    -- Generic gpio interface output register
    io_oreg: delay_vec generic map (1) port map (fclk_rst_n, fclk, GPIO_tri_o, gpio_o_d);
    io_treg: delay_vec generic map (1) port map (fclk_rst_n, fclk, GPIO_tri_t, gpio_t_d);


    -- gpio control interface
    -- gpio(0)
    ocxo_ena      <= gpio_o_d(0)  when gpio_t_d(0)  = '0' else 'Z';
    xtal_ena: delay_sig generic map (1) port map (fclk_rst_n, fclk, ocxo_ena, GPIO_tri_i(0));
    xtal_pwr: delay_sig generic map (2) port map (rst_n, clk, GPIO_tri_o(0), ocxo_pwr_ena);

    -- gpio(1)
    reset_n       <= gpio_o_d(1) and fclk_rst_n;
    GPIO_tri_i(1) <= reset_n;
    pll_rst_n     <= reset_n;

    -- gpio(2)
    pll_lock: delay_sig generic map (2) port map (fclk_rst_n, fclk, locked, GPIO_tri_i(2));

    -- gpio(3)
    GPIO_tri_i(3) <= '0';

    -- gpio(4)
    gps_ena       <= gpio_o_d(4)  when gpio_t_d(4)  = '0' else 'Z';
    loc_ena: delay_sig generic map (1) port map (fclk_rst_n, fclk, gps_ena, GPIO_tri_i(4));

    -- gpio(5)
    GPIO_tri_i(5) <= '0';

    -- gpio(6)
    gpio_dac_ena: delay_sig generic map (2) port map (rst_n, clk, GPIO_tri_o(6), dac_ena);
    GPIO_tri_i(6) <= GPIO_tri_o(6);

    -- gpio(7)
    gpio_disp_ena: delay_sig generic map (2) port map (rst_n, clk, GPIO_tri_o(7), disp_ena);
    GPIO_tri_i(7) <= GPIO_tri_o(7);


    -- gpio(15 downto 8)
    io_tri: for i in 8 to 15 generate
    begin
        --io_tri_iobuf: component IOBUF
        --    port map (
        --        I => GPIO_tri_o(i),
        --        IO => gpio(i),
        --        O => GPIO_tri_i(i),
        --        T => GPIO_tri_t(i)
        --        );

        gpio(i - 8) <= gpio_o_d(i) when gpio_t_d(i) = '0' else 'Z';
    end generate;

    io_ireg: delay_vec generic map (1) port map (fclk_rst_n, fclk, gpio, GPIO_tri_i(15 downto 8));

    --gpio(0)       <= gpio_o_d(8)  when gpio_t_d(8)  = '0' else 'Z';
    --gpio(1)       <= gpio_o_d(9)  when gpio_t_d(9)  = '0' else 'Z';
    --gpio(2)       <= gpio_o_d(10) when gpio_t_d(10) = '0' else 'Z';
    --gpio(3)       <= gpio_o_d(11) when gpio_t_d(11) = '0' else 'Z';
    --gpio(4)       <= gpio_o_d(12) when gpio_t_d(12) = '0' else 'Z';
    --gpio(5)       <= gpio_o_d(13) when gpio_t_d(13) = '0' else 'Z';
    --gpio(6)       <= gpio_o_d(14) when gpio_t_d(14) = '0' else 'Z';
    --gpio(7)       <= gpio_o_d(15) when gpio_t_d(15) = '0' else 'Z';


    -- The ocxo dac 50 us tristate enable delay
    ocxo_tristate:
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            ocxo_on_ctr <= conv_std_logic_vector(5000, ocxo_on_ctr'length);
            ocxo_pwr_on <= '0';
            dac_tri     <= '1';
        elsif (clk'event and clk = '1') then
            if (ocxo_pwr_ena = '0' or ocxo_pwr_on = '1') then
                ocxo_on_ctr  <= conv_std_logic_vector(5000, ocxo_on_ctr'length);
            else
                ocxo_on_ctr  <= ocxo_on_ctr - 1;
            end if;

            if (ocxo_pwr_ena = '0') then
                ocxo_pwr_on <= '0';
            elsif (ocxo_on_ctr = 1) then
                ocxo_pwr_on <= '1';
            else
                ocxo_pwr_on <= '0';
            end if;
                
            if (ocxo_pwr_ena = '0') then
                dac_tri     <= '1';
            elsif (ocxo_pwr_on = '1') then
                dac_tri     <= '0';
            end if;
                
        end if;
    end process;


    --loc_pwr: delay_sig generic map (1) port map (fclk_rst_n, fclk, GPIO_tri_o(4), gps_pwr_ena);
    -- Duplicate output buffer for enable
    gps_ena_dup:
    process (fclk_rst_n, fclk) is
    begin
        if (fclk_rst_n = '0') then
            gps_pwr_ena <= '0';
        elsif (fclk'event and fclk = '1') then
            gps_pwr_ena <= GPIO_tri_o(4);
        end if;
    end process;


    -- The gps rs232 tx 50 us tristate enable delay
    gps_tristate:
    process (fclk_rst_n, fclk) is
    begin
        if (fclk_rst_n = '0') then
            gps_on_ctr <= conv_std_logic_vector(5000, gps_on_ctr'length);
            gps_pwr_on <= '0';
            gps_tri    <= '1';
        elsif (fclk'event and fclk = '1') then
            if (gps_pwr_ena = '0' or gps_pwr_on = '1') then
                gps_on_ctr  <= conv_std_logic_vector(5000, gps_on_ctr'length);
            else
                gps_on_ctr <= gps_on_ctr - 1;
            end if;

            if (gps_pwr_ena = '0') then
                gps_pwr_on <= '0';
            elsif (gps_on_ctr = 1) then
                gps_pwr_on <= '1';
            else
                gps_pwr_on <= '0';
            end if;
                
            if (gps_pwr_ena = '0') then
                gps_tri     <= '1';
            elsif (gps_pwr_on = '1') then
                gps_tri     <= '0';
            end if;
                
        end if;
    end process;


end rtl;
