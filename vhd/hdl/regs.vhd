-------------------------------------------------------------------------------
-- Title      : CLock
-- Project    :
-------------------------------------------------------------------------------
-- File       : regs.vhd
-- Author     : Daniel Sun  <dsun7c4osh@gmail.com>
-- Company    :
-- Created    : 2016-03-13
-- Last update: 2018-04-22
-- Platform   :
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Register interface to the EPC bus
-------------------------------------------------------------------------------
-- Copyright (c) 2016
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2016-03-13  1.0      dsun7c4osh  Created
-------------------------------------------------------------------------------
--
--              Address range: 0x8060_0000 - 0x8060_FFFF
--             | 3 |         2         |         1         |         0         |
--             |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
--
-- 0x8060_0000 |                GIT Abbreviated Commit Hash                    |
--
-- 0x8060_0004 | Hr 10 | Hr 1  | Min 10| Min 1 |         Build                 |
--
-- 0x8060_0008 | Year  | Year  | Year  | Year  | Mon 10| Mon 1 | Day 10| Day 1 |
--
--
-- -----------------------------------------------------------------------------
--             | 3 |         2         |         1         |         0         |
--             |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
--
-- 0x8060_0100 |                            TSC LSB                            |
--
-- 0x8060_0104 |                            TSC MSB                            |
--
-- 0x8060_0108 |                     TSC LSB @ last second                     |
--
-- 0x8060_010c |                     TSC MSB @ last second                     |
--
-- 0x8060_0110 |                        1PPS Phase Error                       |
--
-- 0x8060_0114 |                        1PPS Frequency Error                   |
--
-- 0x8060_0118 |                         GPS 1PPS Count                        |
--
-- 0x8060_011c | 10 h  | 1 h   | 10 m  |  1 m  | 10 s  |  1 s  | 100 ms| 10 ms |
--
-- 0x8060_0120 |               | 10 h  | 1 h   | 10 m  |  1 m  | 10 s  |  1 s  |
--
-- 0x8060_0124 | |             | | | | |       |            DAC value          |
--              |               |   | |
--              GPS 3D Fix      |   | Sync clock
--                              |   Sync PFD
--                              |
--                              PFD Status
--
-- 0x8060_0128 |                                                           | | |
--                                                                          | |
--                                                            GPS PPS IRQ ENA |
--                                                              TSC PPS IRQ ENA
--
-- 0x8060_012c | |                                                         | | |
--              |                                                           | |
--              PPS IRQ Status                                    GPS PPS IRQ |
--                                                                  TSC PPS IRQ
--
-- 0x8060_0130 |                                                         | | | |
--                                                                        | | |
--                                                      PFD trigger IRQ ENA | |
--                                                        PFD GPS PPS IRQ ENA |
--                                                          PFD TSC PPS IRQ ENA
--
-- 0x8060_0134 | |                                                       | | | |
--              |                                                         | | |
--              PLL IRQ Status                              PFD trigger IRQ | |
--                                                            PFD GPS PPS IRQ |
--                                                              PFD TSC PPS IRQ
--
--
-- -----------------------------------------------------------------------------
--             | 3 |         2         |         1         |         0         |
--             |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
--
-- 0x8060_0200 |             uSPR                      |       |    Fan pwm    |
--
--
-- -----------------------------------------------------------------------------
--             | 3 |         2         |         1         |         0         |
--             |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
--
-- 0x8060_0300 |               |   disp page   |       | stat  |    disp pdm   |
--
--
-- -----------------------------------------------------------------------------
--             | 3 |         2         |         1         |         0         |
--             |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
--
-- 0x8060_1000 |      xor 1    |    digit 1    |      xor 0    |    digit 0    |
--
-- 0x8060_1004 |      xor 3    |    digit 3    |      xor 2    |    digit 2    |
--
-- 0x8060_1008 |      xor 5    |    digit 5    |      xor 4    |    digit 4    |
--
-- 0x8060_100c |      xor 7    |    digit 7    |      xor 6    |    digit 6    |
--
-- 0x8060_1010 |      xor 9    |    digit 9    |      xor 8    |    digit 8    |
--
-- 0x8060_1014 |      xor 11   |    digit 11   |      xor 10   |    digit 10   |
--
-- 0x8060_1018 |      xor 13   |    digit 13   |      xor 12   |    digit 12   |
--
-- 0x8060_101c |      xor 15   |    digit 15   |      xor 14   |    digit 14   |
--
-- 0x8060_1020 |      xor 17   |    digit 17   |      xor 16   |    digit 16   |
--
-- 0x8060_1024 |      xor 19   |    digit 19   |      xor 18   |    digit 18   |
--
-- 0x8060_1028 |      xor 21   |    digit 21   |      xor 20   |    digit 20   |
--
-- 0x8060_102c |      xor 23   |    digit 23   |      xor 22   |    digit 22   |
--
-- 0x8060_1030 |      xor 25   |    digit 25   |      xor 24   |    digit 24   |
--
-- 0x8060_1034 |      xor 27   |    digit 27   |      xor 26   |    digit 26   |
--
-- 0x8060_1038 |      xor 29   |    digit 29   |      xor 28   |    digit 28   |
--
-- 0x8060_103c |      xor 31   |    digit 31   |      xor 30   |    digit 30   |
--
-- 0x8060_1040 |                              RAM Page 1                       |
-- 0x8060_1080 |                              RAM Page 2                       |
--             |                              ...                              |
-- 0x8060_1080 |                              RAM Page 1f                      |
-- 0x8060_17FC |                              RAM                              |
--
-- 0x8060_1800 |     lut  3    |     lut  2    |     lut  1    |     lut  0    |
--
-- 0x8060_1804 |     lut  7    |     lut  6    |     lut  5    |     lut  4    |
--
-- 0x8060_1808 |     lut  11   |     lut  10   |     lut  9    |     lut  8    |
--
-- 0x8060_180c |     lut  15   |     lut  14   |     lut  13   |     lut  12   |
--
-- 0x8060_1810 |     lut  19   |     lut  18   |     lut  17   |     lut  16   |
--
--
-- 0x8060_187C |     lut 127   |     lut 126   |     lut 125   |     lut 124   |
--
-- 0x8060_1880 |                              RAM                              |
-- 0x8060_1FFC |                              RAM                              |
--


library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library work;
use work.types_pkg.all;
use work.version_pkg.all;

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

        -- Time stamp counter
        tsc_cnt           : in    std_logic_vector(63 downto 0);
        tsc_cnt1          : in    std_logic_vector(63 downto 0);
        tsc_read          : out   std_logic;

        -- Time setting
        cur_time          : in    time_ty;
        set               : out   std_logic;
        set_time          : out   time_ty;

        -- PLL control
        gps_3dfix_d       : in    std_logic;
        gps_1pps_d        : in    std_logic;
        tsc_1pps_d        : in    std_logic;
        pll_trig          : in    std_logic;
        pfd_status        : in    std_logic;
        pdiff_1pps        : in    std_logic_vector(31 downto 0);
        fdiff_1pps        : in    std_logic_vector(31 downto 0);
        tsc_sync          : out   std_logic;
        pfd_resync        : out   std_logic;
        dac_val           : out   std_logic_vector(15 downto 0);
        pps_irq           : out   std_logic;
        pll_irq           : out   std_logic;

        -- Fan us per revolution, percent speed
        fan_uspr          : in    std_logic_vector(19 downto 0);
        fan_pct           : out   std_logic_vector(7 downto 0);

        -- Display memory
        sram_addr         : out   std_logic_vector(9 downto 0);
        sram_we           : out   std_logic;
        sram_datao        : out   std_logic_vector(31 downto 0);
        sram_datai        : in    std_logic_vector(31 downto 0);

        stat_src          : out   std_logic_vector(3 downto 0);
        disp_page         : out   std_logic_vector(7 downto 0);
        disp_pdm          : out   std_logic_vector(7 downto 0)
        );
end regs;



architecture rtl of regs is

    type reg_arr is array (natural range <>) of std_logic_vector(31 downto 0);

    signal time_regs      : reg_arr(13 downto 0);
    signal fan_regs       : reg_arr(0 downto 0);
    signal disp_regs      : reg_arr(0 downto 0);

    signal addr           : std_logic_vector(31 downto 0);
    signal be             : std_logic_vector(3 downto 0);
    signal data_i         : std_logic_vector(31 downto 0);
    signal data_o         : std_logic_vector(31 downto 0);

    signal cs_n_d         : std_logic;
    signal cs_dp_r        : std_logic;
    signal cs_dp_w        : std_logic;
    signal rnw            : std_logic;
    signal rdy_d          : std_logic_vector(2 downto 0);

    signal decode         : std_logic_vector(3 downto 0);
    signal sram           : std_logic;

    SIGNAL gps_1pps_cnt   : std_logic_vector(31 downto 0);

    signal ver_regs_mux   : std_logic_vector(31 downto 0);
    signal time_regs_mux  : std_logic_vector(31 downto 0);
    signal fan_regs_mux   : std_logic_vector(31 downto 0);
    signal disp_regs_mux  : std_logic_vector(31 downto 0);
    signal sram_regs_mux  : std_logic_vector(31 downto 0);

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
            cs_dp_r <= '0';   -- Chip select read pulse
            cs_dp_w <= '0';   -- Chip select write pulse
            decode  <= (others => '0');
            sram    <= '0';
        elsif (clk'event and clk = '1') then
            rnw       <= not EPC_INTF_rnw;
            cs_n_d    <= EPC_INTF_cs_n;
            cs_dp_r   <= not EPC_INTF_cs_n and cs_n_d and     EPC_INTF_rnw;
            cs_dp_w   <= not EPC_INTF_cs_n and cs_n_d and not EPC_INTF_rnw;

            -- First level decode
            if (EPC_INTF_cs_n = '0') then
                if (addr(12) = '1') then
                    decode <= (others => '0');
                    sram   <= '1';
                else
                    decode(conv_integer(addr(9 downto 8))) <= '1';
                    sram   <= '0';
                end if;
            else
                decode <= (others => '0');
                sram   <= '0';
            end if;
        end if;
    end process;


    -- Ready signal generator, 4 cycles after delayed chip select
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
            if (sram = '1') then
                data_i <= sram_regs_mux;
            elsif (decode(0) = '1') then
                data_i <= ver_regs_mux;
            elsif (decode(1) = '1') then
                data_i <= time_regs_mux;
            elsif (decode(2) = '1') then
                data_i <= fan_regs_mux;
            elsif (decode(3) = '1') then
                data_i <= disp_regs_mux;
            end if;
        end if;
    end process;


    -- Read Mux
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            ver_regs_mux  <= (others => '0');
            fan_regs_mux  <= (others => '0');
            disp_regs_mux <= (others => '0');
            sram_regs_mux <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (cs_n_d = '0') then
                sram_regs_mux <= sram_datai;
                case addr(5 downto 2) is
                    when "0000" =>
                        ver_regs_mux  <= GIT_COMMIT;
                        fan_regs_mux  <= fan_regs(0);
                        fan_regs_mux(31 downto 12) <= fan_uspr;
                        disp_regs_mux <= disp_regs(0);
                    when "0001" =>
                        ver_regs_mux  <= TIME_CODE;
                        fan_regs_mux  <= (others => '0');
                        disp_regs_mux <= (others => '0');
                    when "0010" =>
                        ver_regs_mux  <= DATE_CODE;
                        fan_regs_mux  <= (others => '0');
                        disp_regs_mux <= (others => '0');
                    when others =>
                        ver_regs_mux  <= (others => '0');
                        fan_regs_mux  <= (others => '0');
                        disp_regs_mux <= (others => '0');
                end case;
            end if;
        end if;
    end process;


    -- Read Mux (time_regs)
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            time_regs_mux <= (others => '0');
            tsc_read      <= '0';
        elsif (clk'event and clk = '1') then
            if (cs_n_d = '0') then
                case addr(5 downto 2) is
                    when "0000" =>
                        time_regs_mux <= tsc_cnt(31 downto 0);
                    when "0001" =>
                        time_regs_mux <= tsc_cnt(63 downto 32);
                    when "0010" =>
                        time_regs_mux <= tsc_cnt1(31 downto 0);
                    when "0011" =>
                        time_regs_mux <= tsc_cnt1(63 downto 32);
                    when "0100" =>
                        time_regs_mux <= pdiff_1pps;
                    when "0101" =>
                        time_regs_mux <= fdiff_1pps;
                    when "0110" =>
                        time_regs_mux <= gps_1pps_cnt;
                    when "0111" =>
                        time_regs_mux <= cur_time.t_10h   & cur_time.t_1h   &
                                         cur_time.t_10m   & cur_time.t_1m   &
                                         cur_time.t_10s   & cur_time.t_1s   &
                                         cur_time.t_100ms & cur_time.t_10ms;
                    when "1000" =>
                        time_regs_mux <= time_regs(8);
                    when "1001" =>
                        time_regs_mux <= time_regs(9);
                        time_regs_mux(31) <= gps_3dfix_d;
                        time_regs_mux(23) <= pfd_status;
                    when "1010" =>
                        time_regs_mux <= time_regs(10);
                    when "1011" =>
                        time_regs_mux <= time_regs(11);
                    when "1100" =>
                        time_regs_mux <= time_regs(12);
                    when "1101" =>
                        time_regs_mux <= time_regs(13);
                    when others =>
                        time_regs_mux <= (others => '0');
                end case;
            end if;

            -- Latch tsc value on LSW read
            if (cs_dp_r = '1' and decode(1) = '1' and addr(5 downto 2) = "0000") then
                tsc_read      <= '1';
            else
                tsc_read      <= '0';
            end if;

        end if;
    end process;


    -- time control registers
    process (rst_n, clk) is
        variable pps_irq_status : std_logic;
        variable pll_irq_status : std_logic;
    begin
        if (rst_n = '0') then
            for i in time_regs'range loop
                time_regs(i) <= (others => '0');
            end loop;
            pps_irq <= '0';
            pll_irq <= '0';
            set     <= '0';
            time_regs(9)(15 downto 0) <= x"8000";
        elsif (clk'event and clk = '1') then
            if (cs_dp_w = '1' and decode(1) = '1') then
                case addr(5 downto 2) is
                    when "0000" =>
                        time_regs(0) <= data_o;
                    when "0001" =>
                        time_regs(1) <= data_o;
                    when "0010" =>
                        time_regs(2) <= data_o;
                    when "0011" =>
                        time_regs(3) <= data_o;
                    when "0100" =>
                        time_regs(4) <= data_o;
                    when "0101" =>
                        time_regs(5) <= data_o;
                    when "0110" =>
                        time_regs(6) <= data_o;
                    when "0111" =>
                        time_regs(7) <= data_o;
                    when "1000" =>
                        time_regs(8) <= data_o;
                    when "1001" =>
                        time_regs(9) <= data_o;
                    when "1010" =>
                        time_regs(10) <= data_o;
                    when "1011" =>
                        time_regs(11)(30 downto 2) <= data_o(30 downto 2);
                        -- Clear interrupt with 1 is written back
                        if (data_o(1) = '1') then
                            time_regs(11)(1) <= '0';
                        end if;
                        if (data_o(0) = '1') then
                            time_regs(11)(0) <= '0';
                        end if;
                    when "1100" =>
                        time_regs(12) <= data_o;
                    when "1101" =>
                        time_regs(13)(30 downto 3) <= data_o(30 downto 3);
                        -- Clear interrupt with 1 is written back
                        if (data_o(2) = '1') then
                            time_regs(13)(2) <= '0';
                        end if;
                        if (data_o(1) = '1') then
                            time_regs(13)(1) <= '0';
                        end if;
                        if (data_o(0) = '1') then
                            time_regs(13)(0) <= '0';
                        end if;
                    when others =>
                        null;
                end case;
            end if;

            pps_irq_status    := (time_regs(10)(1) and time_regs(11)(1)) or
                                 (time_regs(10)(0) and time_regs(11)(0));
            pps_irq           <= pps_irq_status;
            time_regs(11)(31) <= pps_irq_status;
            -- Set interrupt on incoming pps pulses
            -- Higher priority than clear (above)
            if (gps_1pps_d = '1') then
                time_regs(11)(1) <= '1';
            end if;
            if (tsc_1pps_d = '1') then
                time_regs(11)(0) <= '1';
            end if;
            
            pll_irq_status    := (time_regs(12)(2) and time_regs(13)(2)) or
                                 (time_regs(12)(1) and time_regs(13)(1)) or
                                 (time_regs(12)(0) and time_regs(13)(0));
            pll_irq           <= pll_irq_status;
            time_regs(13)(31) <= pll_irq_status;
            -- Set interrupt on incoming pps pulses and pll trigger
            -- Higher priority than clear (above)
            if (pll_trig = '1') then
                time_regs(13)(2) <= '1';
            end if;
            if (gps_1pps_d = '1') then
                time_regs(13)(1) <= '1';
            end if;
            if (tsc_1pps_d = '1') then
                time_regs(13)(0) <= '1';
            end if;
            
            -- Trigger time set
            if (cs_dp_w = '1' and decode(1) = '1' and addr(5 downto 2) = "1000") then
                set <= '1';
            else
                set <= '0';
            end if;

            -- Clear the sync flag after its done
            if (gps_1pps_d = '1' and time_regs(9)(20) = '1') then
                time_regs(9)(20) <= '0';
            end if;
            -- Clear the pfd sync control when the PFD is in the sync state
            if (pfd_status = '1') then
                time_regs(9)(21) <= '0';
            end if;
        end if;
    end process;

    set_time.t_1ms   <= (others => '0');
    set_time.t_10ms  <= (others => '0');
    set_time.t_100ms <= (others => '0');
    set_time.t_1s    <= time_regs(8)(3 downto 0);
    set_time.t_10s   <= time_regs(8)(7 downto 4);
    set_time.t_1m    <= time_regs(8)(11 downto 8);
    set_time.t_10m   <= time_regs(8)(15 downto 12);
    set_time.t_1h    <= time_regs(8)(19 downto 16);
    set_time.t_10h   <= time_regs(8)(23 downto 20);

    dac_val    <= time_regs(9)(15 downto 0);
    tsc_sync   <= time_regs(9)(20);
    pfd_resync <= time_regs(9)(21);


    -- Fan control registers
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            for i in 0 to 0 loop
                fan_regs(i) <= (others => '0');
            end loop;
            fan_regs(0)(7 downto 0) <= x"ff";
        elsif (clk'event and clk = '1') then
            if (cs_dp_w = '1' and decode(2) = '1') then
                case addr(5 downto 2) is
                    when "0000" =>
                        fan_regs(0) <= data_o;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    fan_pct <= fan_regs(0)(7 downto 0);


    -- disp control registers
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            for i in 0 to 0 loop
                disp_regs(i) <= (others => '0');
            end loop;
            disp_regs(0)(7 downto 0) <= x"ff";
            sram_addr  <= (others => '0');
            sram_we    <= '0';
            sram_datao <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (cs_dp_w = '1' and decode(3) = '1') then
                case addr(5 downto 2) is
                    when "0000" =>
                        disp_regs(0) <= data_o;
                    when others =>
                        null;
                end case;
            end if;
            sram_addr  <= addr(11 downto 2);
            sram_we    <= sram and cs_dp_w;
            sram_datao <= data_o;
        end if;
    end process;

    disp_pdm <= disp_regs(0)(7 downto 0);
    stat_src <= disp_regs(0)(11 downto 8);
    disp_page <= disp_regs(0)(23 downto 16);


    -- GPS 1pps count register
    process (rst_n, clk) is
    begin
        if (rst_n = '0') then
            gps_1pps_cnt <= (others => '0');
        elsif (clk'event and clk = '1') then
            if (gps_1pps_d = '1') then
                gps_1pps_cnt <= gps_1pps_cnt + 1;
            end if;
        end if;
    end process;


end rtl;
