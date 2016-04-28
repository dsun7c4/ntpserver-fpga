-------------------------------------------------------------------------------
-- Title      : CLock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : regs.vhd
-- Author     : Daniel Sun  <dcsun88osh@gmail.com>
-- Company    : 
-- Created    : 2016-03-13
-- Last update: 2016-04-27
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Register interface to the EPC bus
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-03-13  1.0      dcsun88osh  Created
-------------------------------------------------------------------------------
--
--              Address range: 0x8060_0000 - 0x8060_FFFF
--
-- 0x8060_0000  |            TSC LSB                            |
-- 
-- 0x8060_0004  |            TSC MSB                            |
--
-- 0x8060_0008  |           |   hour    |  min      |  sec      |
-- 
-- 0x8060_000c  |           |           |       DAC value       |
-- 
-- 0x8060_0100  |           |         RPM           |  Fan pwm  |
--
-- 0x8060_0200  |  digit 3  |  digit 2  |  digit 1  |  digit 0  |
-- 
-- 0x8060_0204  |  digit 7  |  digit 6  |  digit 5  |  digit 4  |
-- 
-- 0x8060_0208  |  digit 11 |  digit 10 |  digit 9  |  digit 8  |
-- 
-- 0x8060_020c  |  digit 15 |  digit 14 |  digit 13 |  digit 12 |
-- 
-- 0x8060_0210  |  digit 19 |  digit 18 |  digit 17 |  digit 16 |
-- 
-- 0x8060_0214  |           |           |           |  disp pdm |
-- 


library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity regs is
  port (
      rst_n             : in    std_logic;
      clk               : in    std_logic;

      EPC_INTF_addr     : in    std_logic_vector(0 to 31);
      EPC_INTF_be       : in    std_logic_vector(0 to 3);
      EPC_INTF_burst    : in    std_logic;
      EPC_INTF_cs_n     : in    std_logic;
      EPC_INTF_data_i   : out   std_logic_vector(0 to 31);
      EPC_INTF_data_o   : in    std_logic_vector(0 to 31);
      EPC_INTF_rdy      : out   std_logic;
      EPC_INTF_rnw      : in    std_logic;  -- Write when '0'

      tmp               : out   std_logic

  );
end regs;



architecture STRUCTURE of regs is

    type reg_arr is array (natural range <>) of std_logic_vector(31 downto 0);

    signal time_regs   : reg_arr(3 downto 0);
    signal fan_regs    : reg_arr(0 downto 0);
    signal disp_regs   : reg_arr(5 downto 0);

    signal addr        : std_logic_vector(31 downto 0);
    signal be          : std_logic_vector(3 downto 0);
    signal data_i      : std_logic_vector(31 downto 0);
    signal data_o      : std_logic_vector(31 downto 0);

    signal cs_n_d      : std_logic;
    signal cs_dp_r     : std_logic;
    signal cs_dp_w     : std_logic;
    signal rnw         : std_logic;
    signal rdy_d       : std_logic_vector(2 downto 0);
    
    signal decode      : std_logic_vector(3 downto 0);

    signal time_regs_mux  : std_logic_vector(31 downto 0);
    signal fan_regs_mux   : std_logic_vector(31 downto 0);
    signal disp_regs_mux  : std_logic_vector(31 downto 0);

begin

    -- Big endian to little endian
    addr            <= EPC_INTF_addr;
    be              <= EPC_INTF_be;
    data_o          <= EPC_INTF_data_o;
    -- Little endian to big endian
    EPC_INTF_data_i <= data_i;


    -- Chip select falling edge detect
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            rnw     <= '0';
            cs_n_d  <= '1';
            cs_dp_r <= '0';
            cs_dp_w <= '0';
        elsif (clk'event and clk = '1') then
            rnw       <= not EPC_INTF_rnw;
            cs_n_d    <= EPC_INTF_cs_n;
            cs_dp_r   <= not EPC_INTF_cs_n and cs_n_d and     EPC_INTF_rnw;
            cs_dp_w   <= not EPC_INTF_cs_n and cs_n_d and not EPC_INTF_rnw;
        end if;
    end process;


    -- First level decode
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            decode <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (EPC_INTF_cs_n = '0') then
                decode(conv_integer(addr(9 downto 8))) <= '1';
            else
                decode <= (others => '0');
            end if;
        end if;
    end process;


    -- Ready signal generator, 3 cycles after delayed chip select
    -- Hold ready active until the chip select goes inactive
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            rdy_d        <= (others => '1');
            EPC_INTF_rdy <= '0';
        elsif (clk'event and clk = '1') then
            rdy_d(0)     <= cs_dp_r or cs_dp_w;
            rdy_d(1)     <= rdy_d(0);
            rdy_d(2)     <= rdy_d(1);
            if (EPC_INTF_cs_n = '1') then
                EPC_INTF_rdy <= '0';
            elsif (rdy_d(2) = '1') then
                EPC_INTF_rdy <= '1';
            end if;
        end if;
    end process;


    -- Top decode read mux
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            data_i <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (decode(0) = '1') then
                data_i <= time_regs_mux;
            elsif (decode(1) = '1') then
                data_i <= fan_regs_mux;
            elsif (decode(2) = '1') then
                data_i <= disp_regs_mux;
            end if;
        end if;
    end process;


    -- Read Mux
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            time_regs_mux <= (others => '0');
            fan_regs_mux  <= (others => '0');
            disp_regs_mux <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (cs_n_d = '0') then
                case addr(5 downto 2) is
                    when "0000" =>
                        time_regs_mux <= time_regs(0);
                        fan_regs_mux  <= fan_regs(0);
                        disp_regs_mux <= disp_regs(0);
                    when "0001" =>
                        time_regs_mux <= time_regs(1);
                        fan_regs_mux  <= fan_regs_mux;
                        disp_regs_mux <= disp_regs(1);
                    when "0010" =>
                        time_regs_mux <= time_regs(2);
                        fan_regs_mux  <= fan_regs_mux;
                        disp_regs_mux <= disp_regs(2);
                    when "0011" =>
                        time_regs_mux <= time_regs(3);
                        fan_regs_mux  <= fan_regs_mux;
                        disp_regs_mux <= disp_regs(3);
                    when "0100" =>
                        time_regs_mux <= time_regs_mux;
                        fan_regs_mux  <= fan_regs_mux;
                        disp_regs_mux <= disp_regs(4);
                    when "1000" =>
                        time_regs_mux <= time_regs_mux;
                        fan_regs_mux  <= fan_regs_mux;
                        disp_regs_mux <= disp_regs(5);
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;


    -- time control registers
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            for i in 0 to 3 loop
                time_regs(i) <= (others => '0');
            end loop;
        elsif (clk'event and clk = '1') then
            if (cs_dp_w = '1' and decode(0) = '1') then
                case addr(5 downto 2) is
                    when "0000" =>
                        time_regs(0) <= data_o;
                    when "0001" =>
                        time_regs(1) <= data_o;
                    when "0010" =>
                        time_regs(2) <= data_o;
                    when "0011" =>
                        time_regs(3) <= data_o;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;


    -- Fan control registers
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            for i in 0 to 0 loop
                fan_regs(i) <= (others => '0');
            end loop;
        elsif (clk'event and clk = '1') then
            if (cs_dp_w = '1' and decode(1) = '1') then
                case addr(5 downto 2) is
                    when "0000" =>
                        fan_regs(0) <= data_o;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;


    -- disp control registers
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            for i in 0 to 5 loop
                disp_regs(i) <= (others => '0');
            end loop;
        elsif (clk'event and clk = '1') then
            if (cs_dp_w = '1' and decode(2) = '1') then
                case addr(5 downto 2) is
                    when "0000" =>
                        disp_regs(0) <= data_o;
                    when "0001" =>
                        disp_regs(1) <= data_o;
                    when "0010" =>
                        disp_regs(2) <= data_o;
                    when "0011" =>
                        disp_regs(3) <= data_o;
                    when "0100" =>
                        disp_regs(4) <= data_o;
                    when "1000" =>
                        disp_regs(5) <= data_o;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;


end STRUCTURE;
