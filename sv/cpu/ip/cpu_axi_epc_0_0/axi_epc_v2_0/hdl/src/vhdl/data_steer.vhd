-------------------------------------------------------------------------------
-- data_steer.vhd - entity/architecture pair
-------------------------------------------------------------------------------

-- ************************************************************************
-- ** DISCLAIMER OF LIABILITY                                            **
-- **                                                                    **
-- ** This file contains proprietary and confidential information of     **
-- ** Xilinx, Inc. ("Xilinx"), that is distributed under a license       **
-- ** from Xilinx, and may be used, copied and/or disclosed only         **
-- ** pursuant to the terms of a valid license agreement with Xilinx.    **
-- **                                                                    **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION              **
-- ** ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER         **
-- ** EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT                **
-- ** LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,          **
-- ** MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx      **
-- ** does not warrant that functions included in the Materials will     **
-- ** meet the requirements of Licensee, or that the operation of the    **
-- ** Materials will be uninterrupted or error-free, or that defects     **
-- ** in the Materials will be corrected. Furthermore, Xilinx does       **
-- ** not warrant or make any representations regarding use, or the      **
-- ** results of the use, of the Materials in terms of correctness,      **
-- ** accuracy, reliability or otherwise.                                **
-- **                                                                    **
-- ** Xilinx products are not designed or intended to be fail-safe,      **
-- ** or for use in any application requiring fail-safe performance,     **
-- ** such as life-support or safety devices or systems, Class III       **
-- ** medical devices, nuclear facilities, applications related to       **
-- ** the deployment of airbags, or any other applications that could    **
-- ** lead to death, personal injury or severe property or               **
-- ** environmental damage (individually and collectively, "critical     **
-- ** applications"). Customer assumes the sole risk and liability       **
-- ** of any use of Xilinx products in critical applications,            **
-- ** subject only to applicable laws and regulations governing          **
-- ** limitations on product liability.                                  **
-- **                                                                    **
-- ** Copyright 2005, 2006, 2008, 2009 Xilinx, Inc.                      **
-- ** All rights reserved.                                               **
-- **                                                                    **
-- ** This disclaimer and copyright notice must be retained as part      **
-- ** of this file at all times.                                         **
-- ************************************************************************

-------------------------------------------------------------------------------
-- File          : data_steer.vhd
-- Company       : Xilinx
-- Version       : v1.00.a
-- Description   : External Peripheral Controller for AXI data steering logic
-- Structure     : VHDL-93
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Structure:
--             axi_epc.vhd
--               -axi_lite_ipif
--               -epc_core.vhd
--               -ipic_if_decode.vhd
--               -sync_cntl.vhd
--               -async_cntl.vhd
--                  -- async_counters.vhd
--                  -- async_statemachine.vhd
--               -address_gen.vhd
--               -data_steer.vhd
--               -access_mux.vhd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Author   : VB
-- History  :
--
--  VB           08-24-2010 --  v2_0 version for AXI
-- ^^^^^^
--            The core updated for AXI based on xps_epc_v1_02_a
-- ~~~~~~
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.conv_std_logic_vector;

library unisim;
use unisim.vcomponents.FDRE;
-------------------------------------------------------------------------------
--                     Definition of Generics                                --
-------------------------------------------------------------------------------
-- C_SPLB_NATIVE_DWIDTH        -  Data bus width of PLB bus
-- C_PRH_MAX_DWIDTH     -  Maximum of data bus width of peripheral devices
-- ALL_PRH_DWIDTH_MATCH -  Indication that all devices are employing data width
--                         matching
-- NO_PRH_DWIDTH_MATCH  -  Indication that no device is employing data width
--                         matching
-- NO_PRH_SYNC          -  Indicates all devices are configured for
--                         asynchronous interface
-- NO_PRH_ASYNC         -  Indicates all devices are configured for
--                         synchronous interface
-- ADDRCNT_WIDTH        -  Width of address suffix generated by address
--                         generation logic
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                     Definition of Ports                                   --
-------------------------------------------------------------------------------
-- Bus2IP_Clk            - IPIC clock
-- Bus2IP_Rst            - IPIC reset
-- Local_Clk             - Operational clock for peripheral interface
-- Local_Rst             - Reset for peripheral interface
-- Bus2IP_RNW            - IPIC read/write control
-- Bus2IP_BE             - Byte enables from IPIC interface
-- Bus2IP_Data           - Data bus from IPIC interface
-- Dev_in_access         - Indication that peripheral interface is being
--                         accessed by the PLB master
-- Dev_sync              - Indicates if the current device being accessed
--                         is synchronous device
-- Dev_rnw               - Read/write control indication from IPIC interface
-- Dev_dwidth_match      - Indicates if the current device employs data width
--                       - matching
-- Dev_dbus_width        - Indicates decoded value for the data bus width
-- Addr_suffix           - Least significant address bits
-- Steer_index           - Index for data steering
-- Async_en              - Indication from asynchronous logic to latch the
--                         read data bus
-- Async_ce              - Indication of currently read bytes to asynchronous
--                         conrol logic
-- Sync_en               - Indication from synchronous logic to latch the
--                         read data bus
-- Sync_ce               - Indication of currently read bytes to synchronous
--                         conrol logic
-- PRH_Data_In           - Peripheral interface input bus for read access
-- PRH_BE                - Byte enables for external peripheral devices
-- Data_Int              - Internal peripheral data bus to be driven out
--                         to the external peripheral devices
-- IP2Bus_Data           - Data bus to the IPIC interface on a read access
-------------------------------------------------------------------------------

entity data_steer is
  generic (
     C_SPLB_NATIVE_DWIDTH : integer;
     C_PRH_MAX_DWIDTH     : integer;
     ALL_PRH_DWIDTH_MATCH : integer;
     NO_PRH_DWIDTH_MATCH  : integer;
     NO_PRH_SYNC          : integer;
     NO_PRH_ASYNC         : integer;
     ADDRCNT_WIDTH        : integer
  );

  port (
     Bus2IP_Clk        : in std_logic;
     Bus2IP_Rst        : in std_logic;

     Local_Clk         : in std_logic;
     Local_Rst         : in std_logic;

     Bus2IP_RNW        : in std_logic;
     Bus2IP_BE         : in std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8-1);
     Bus2IP_Data       : in std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1);
Dev_bus_multiplex        : in std_logic;
--dev_fifo_access        : in std_logic;
     Dev_in_access     : in std_logic;
     Dev_sync          : in std_logic;
     Dev_rnw           : in std_logic;
     Dev_dwidth_match  : in std_logic;
     Dev_dbus_width    : in std_logic_vector(0 to 2);

     Addr_suffix       : in  std_logic_vector(0 to ADDRCNT_WIDTH-1);
     Steer_index       : out std_logic_vector(0 to ADDRCNT_WIDTH-1);

     Async_en          : in  std_logic;
     Async_ce          : out std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8-1);

     Sync_en           : in  std_logic;
     Sync_ce           : out std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8-1);

     PRH_Data_In       : in  std_logic_vector(0 to C_PRH_MAX_DWIDTH-1);

     PRH_BE            : out std_logic_vector(0 to C_PRH_MAX_DWIDTH/8-1);
     Data_Int          : out std_logic_vector(0 to C_PRH_MAX_DWIDTH-1);

     IP2Bus_Data       : out std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1)
    );
end entity data_steer;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture imp of data_steer is

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
constant BYTE_SIZE : integer := 8;

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------
signal steer_index_i     : std_logic_vector(0 to ADDRCNT_WIDTH-1) :=
                         (others => '0');

signal steer_data_in     : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1) :=
                         (others => '0');
signal no_steer_data_in  : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1) :=
                         (others => '0');
signal data_in           : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1) :=
                         (others => '0');

signal async_ip2bus_data : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1) :=
                         (others => '0');
signal sync_ip2bus_data  : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1) :=
                         (others => '0');
signal ip2bus_data_int   : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1) :=
                         (others => '0');

signal no_steer_async_ce:
    std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1) := (others => '0');
signal steer_async_ce   :
    std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1) := (others => '0');
signal async_ce_i       :
    std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1) := (others => '0');

signal no_steer_sync_ce :
    std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1) := (others => '0');
signal steer_sync_ce    :
    std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1) := (others => '0');
signal sync_ce_i        :
    std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1) := (others => '0');

signal async_rd_ce      :
    std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1) := (others => '0');
signal sync_rd_ce       :
    std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1) := (others => '0');

signal steer_data       : std_logic_vector(0 to C_PRH_MAX_DWIDTH-1)
                        := (others => '0');
signal steer_be         : std_logic_vector(0 to C_PRH_MAX_DWIDTH/8-1)
                        := (others => '0');
--
signal prh_be_i         : std_logic_vector(0 to C_PRH_MAX_DWIDTH/8-1)
                        := (others => '0');
signal data_Int_i       : std_logic_vector(0 to C_PRH_MAX_DWIDTH-1)
                        := (others => '0');
--
signal sync_rd_ce_d1 :
    std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1) := (others => '0');

signal sync_rd_ce_int :
    std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1) := (others => '0');
-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
begin

--------------------------------
-- NAME: NO_DEV_DWIDTH_MATCH_GEN
-- Description: If no device employs data width matching, then generate
--              Data_Int, PRH_BE and IP2Bus_Data
----------------------------------------------------------------------

NO_DEV_DWIDTH_MATCH_GEN: if NO_PRH_DWIDTH_MATCH = 1 generate

  Async_ce     <= (others => '0');
  Sync_ce      <= (others => '0');
  Steer_index  <= (others => '0');

  -----------------
  -- For write path
  -----------------
  Data_Int <= Bus2IP_Data(0 to C_PRH_MAX_DWIDTH-1);

  prh_be_i   <= Bus2IP_BE(0 to C_PRH_MAX_DWIDTH/8-1);

  REG_PRH_SIGS2 : process(Local_Clk)
  begin
  if (Local_Clk'event and Local_Clk = '1')then
         PRH_BE <= prh_be_i;
  end if;
  end process REG_PRH_SIGS2;

  -----------------
  -- For read path
  -----------------
  ------------------------------------------
  -- NAME: PRH_MAX_DWIDTH_32_RD_NO_STEER_GEN
  -- Description: Generate data for PLB interface
  ------------------------------------------------
  PRH_MAX_DWIDTH_32_RD_NO_STEER_GEN: if C_PRH_MAX_DWIDTH = 32 generate
    ------------------------------
    -- NAME: NO_STEER_DATA_PROCESS
    -- Description: Generate data for PLB interface
    -----------------------------------------------
    NO_STEER_DATA_PROCESS: process(Dev_dbus_width, PRH_Data_In) is
    begin

      no_steer_data_in  <= (others => '0');

      case Dev_dbus_width is

        -- Device width is 8 bits
--      when "001"  =>
--      no_steer_data_in(0 to BYTE_SIZE-1)  <= PRH_Data_In(0 to BYTE_SIZE-1);

        -- Device width is 16 bits
--      when "010" =>
--      no_steer_data_in(0 to 2*BYTE_SIZE-1)<= PRH_Data_In(0 to 2*BYTE_SIZE-1);

        -- Device width is 32 bits
        when "100" =>
        no_steer_data_in(0 to 4*BYTE_SIZE-1)<= PRH_Data_In(0 to 4*BYTE_SIZE-1);
-- coverage off
        when others =>
         no_steer_data_in <= (others => '0');
-- coverage on
        end case;
    end process NO_STEER_DATA_PROCESS;

  end generate PRH_MAX_DWIDTH_32_RD_NO_STEER_GEN;

  ---------------------------------------------------------------------------
  -- NAME: PRH_MAX_DWIDTH_16_RD_NO_STEER_GEN
  ---------------------------------------------------------------------------
  -- Description: Generate data for PLB interface
  ---------------------------------------------------------------------------

  PRH_MAX_DWIDTH_16_RD_NO_STEER_GEN: if C_PRH_MAX_DWIDTH = 16 generate

    -------------------------------------------------------------------------
    -- NAME: NO_STEER_DATA_PROCESS
    -------------------------------------------------------------------------
    -- Description: Generate data for PLB interface
    -------------------------------------------------------------------------
    NO_STEER_DATA_PROCESS: process(Dev_dbus_width, PRH_Data_In)
    begin

      no_steer_data_in  <= (others => '0');

      case Dev_dbus_width is

        when "001"  =>
          no_steer_data_in(0 to BYTE_SIZE-1)
            <= PRH_Data_In(0 to BYTE_SIZE-1);

        when "010" =>
          no_steer_data_in(0 to 2*BYTE_SIZE-1)
            <= PRH_Data_In(0 to 2*BYTE_SIZE-1);

        when others =>
          no_steer_data_in <= (others => '0');

      end case;
    end process NO_STEER_DATA_PROCESS;

  end generate PRH_MAX_DWIDTH_16_RD_NO_STEER_GEN;

  ---------------------------------------------------------------------------
  -- NAME: PRH_MAX_DWIDTH_8_RD_NO_STEER_GEN
  ---------------------------------------------------------------------------
  -- Description: Generate data for PLB interface
  ---------------------------------------------------------------------------

  PRH_MAX_DWIDTH_8_RD_NO_STEER_GEN: if C_PRH_MAX_DWIDTH = 8 generate

    -------------------------------------------------------------------------
    -- NAME: NO_STEER_DATA_PROCESS
    -------------------------------------------------------------------------
    -- Description: Generate data for PLB interface
    -------------------------------------------------------------------------
    NO_STEER_DATA_PROCESS: process(Dev_dbus_width, PRH_Data_In)
    begin

      no_steer_data_in  <= (others => '0');

      case Dev_dbus_width is

        when "001"  =>
          no_steer_data_in(0 to BYTE_SIZE-1)
            <= PRH_Data_In(0 to BYTE_SIZE-1);

        when others =>
          no_steer_data_in <= (others => '0');

      end case;
    end process NO_STEER_DATA_PROCESS;

  end generate PRH_MAX_DWIDTH_8_RD_NO_STEER_GEN;


  -----------------------------------------------------------------------------
  -- NAME: SOME_DEV_SYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: Some or all devices are configured as synchronous devices
  -----------------------------------------------------------------------------
  SOME_DEV_SYNC_GEN: if NO_PRH_SYNC = 0 generate

    ---------------------------------------------------------------------------
    -- NAME: NO_STEER_SYNC_CE_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Generate data enables for PLB interface
    ---------------------------------------------------------------------------
    NO_STEER_SYNC_CE_PROCESS: process(Dev_dbus_width, Sync_en)
    begin

      no_steer_sync_ce       <= (others => '0');

      case Dev_dbus_width is
      -- coverage off
        when "001"  =>
          no_steer_sync_ce(0) <= Sync_en;

        when "010" =>
          for i in 0 to 1 loop
            no_steer_sync_ce(i) <= Sync_en;
          end loop;
      -- coverage on
        when "100" =>
          for i in 0 to 3 loop
            no_steer_sync_ce(i) <= Sync_en;
          end loop;

        when others =>
          no_steer_sync_ce   <= (others => '0');

      end case;
    end process NO_STEER_SYNC_CE_PROCESS;


    ---------------------------------------------------------------------------
    -- NAME: SYNC_RDREG_GEN
    ---------------------------------------------------------------------------
    -- Description: Generate input data registers
    ---------------------------------------------------------------------------
    SYNC_RDREG_GEN: for i in 0 to C_PRH_MAX_DWIDTH/BYTE_SIZE-1 generate
      -------------------------------------------------------------------------
      -- NAME: SYNC_RDREG_BYTE_GEN
      -------------------------------------------------------------------------
      -- Description: Generate input data registers
      -------------------------------------------------------------------------
      SYNC_RDREG_BYTE_GEN: for j in 0 to BYTE_SIZE-1 generate
        attribute ASYNC_REG : string;
        attribute ASYNC_REG of SYNC_RDREG_BIT: label is "TRUE";
        begin

        SYNC_RDREG_BIT: component FDRE
          port map (
                    Q  => Sync_ip2bus_data(i*BYTE_SIZE+j),
                    C  => Local_Clk,
                    CE => no_steer_sync_ce(i),
                    D  => PRH_Data_In(i*BYTE_SIZE+j),
                    R  => Local_Rst
                   );
      end generate SYNC_RDREG_BYTE_GEN;
    end generate SYNC_RDREG_GEN;

    ---------------------------------------------------------------------------
    -- NAME: PRH_DWIDTH_LT_PLB_DWIDTH_GEN
    ---------------------------------------------------------------------------
    -- Description: Tie the higher order bits of data to zero
    ---------------------------------------------------------------------------
  PRH_DWIDTH_LT_PLB_DWIDTH_GEN: if C_PRH_MAX_DWIDTH < C_SPLB_NATIVE_DWIDTH
                                                                        generate
    sync_ip2bus_data(C_PRH_MAX_DWIDTH to C_SPLB_NATIVE_DWIDTH-1) <=
                                                                (others => '0');
  end generate PRH_DWIDTH_LT_PLB_DWIDTH_GEN;

end generate SOME_DEV_SYNC_GEN;

  -----------------------------------------------------------------------------
  -- NAME: SOME_DEV_ASYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: Some or all devices are configured as asynchronous devices
  -----------------------------------------------------------------------------
  SOME_DEV_ASYNC_GEN: if NO_PRH_ASYNC = 0 generate

    ---------------------------------------------------------------------------
    -- NAME: NO_STEER_ASYNC_CE_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Generate data enables for PLB interface
    ---------------------------------------------------------------------------
    NO_STEER_ASYNC_CE_PROCESS: process(Dev_dbus_width, Async_en)
    begin

      no_steer_async_ce       <= (others => '0');

      case Dev_dbus_width is
-- coverage off
        when "001"  =>
          no_steer_async_ce(0) <= Async_en;

        when "010" =>
          for i in 0 to 1 loop
            no_steer_async_ce(i) <= Async_en;
          end loop;
-- coverage on
        when "100" =>
          for i in 0 to 3 loop
            no_steer_async_ce(i) <= Async_en;
          end loop;
-- coverage off
        when others =>
          no_steer_async_ce   <= (others => '0');
-- coverage on
      end case;
    end process NO_STEER_ASYNC_CE_PROCESS;

    ---------------------------------------------------------------------------
    -- NAME: ASYNC_RDREG_GEN
    ---------------------------------------------------------------------------
    -- Description: Generate input data registers
    ---------------------------------------------------------------------------
    ASYNC_RDREG_GEN: for i in 0 to C_PRH_MAX_DWIDTH/BYTE_SIZE-1 generate
      -------------------------------------------------------------------------
      -- NAME: ASYNC_RDREG_BYTE_GEN
      -------------------------------------------------------------------------
      -- Description: Generate input data registers
      -------------------------------------------------------------------------
      ASYNC_RDREG_BYTE_GEN: for j in 0 to BYTE_SIZE-1 generate
        attribute ASYNC_REG : string;
        attribute ASYNC_REG of ASYNC_RDREG_BIT: label is "TRUE";
        begin
        ASYNC_RDREG_BIT: component FDRE
          port map (
                    Q  => async_ip2bus_data(i*BYTE_SIZE+j),
                    C  => Bus2IP_Clk,
                    CE => no_steer_async_ce(i),
                    D  => PRH_Data_In(i*BYTE_SIZE+j),
                    R  => Bus2IP_Rst
                   );
      end generate ASYNC_RDREG_BYTE_GEN;
    end generate ASYNC_RDREG_GEN;

    ---------------------------------------------------------------------------
    -- NAME: PRH_DWIDTH_LT_PLB_DWIDTH_GEN
    ---------------------------------------------------------------------------
    -- Description: Tie the higher order bits of data to zero
    ---------------------------------------------------------------------------
    PRH_DWIDTH_LT_PLB_DWIDTH_GEN: if C_PRH_MAX_DWIDTH < C_SPLB_NATIVE_DWIDTH
                                                                        generate
      async_ip2bus_data(C_PRH_MAX_DWIDTH to C_SPLB_NATIVE_DWIDTH-1) <=
                                                                (others => '0');
    end generate PRH_DWIDTH_LT_PLB_DWIDTH_GEN;

  end generate SOME_DEV_ASYNC_GEN;

  -----------------------------------------------------------------------------
  -- NAME: ALL_DEV_SYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: All devices are configured as synchronous devices
  -----------------------------------------------------------------------------
  ALL_DEV_SYNC_GEN: if NO_PRH_ASYNC = 1 generate

    async_ip2bus_data <= (others => '0');
    ip2bus_data_int <= sync_ip2bus_data;

  end generate ALL_DEV_SYNC_GEN;

  -----------------------------------------------------------------------------
  -- NAME: ALL_DEV_ASYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: All devices are configured as asynchronous devices
  -----------------------------------------------------------------------------
  ALL_DEV_ASYNC_GEN: if NO_PRH_SYNC = 1 generate

    sync_ip2bus_data <= (others => '0');
    ip2bus_data_int <= async_ip2bus_data;

  end generate ALL_DEV_ASYNC_GEN;

  -----------------------------------------------------------------------------
  -- NAME: DEV_SYNC_AND_ASYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: Some devices are configured as synchronous and some
  --              asynchronous
  -----------------------------------------------------------------------------
  DEV_SYNC_AND_ASYNC_GEN: if NO_PRH_SYNC = 0 and NO_PRH_ASYNC = 0 generate

    ip2bus_data_int <= async_ip2bus_data when Dev_sync = '0'
                       else sync_ip2bus_data;

  end generate DEV_SYNC_AND_ASYNC_GEN;


  IP2Bus_Data <= ip2bus_data_int when (Bus2IP_RNW = '1' and Dev_in_access = '1')
                 else (others => '0');

end generate NO_DEV_DWIDTH_MATCH_GEN;


-------------------------------------------------------------------------------
-- NAME: DEV_DWIDTH_MATCH_GEN
-------------------------------------------------------------------------------
-- Description: If any device employs data width matching, then generate data
--              and byte steering logic for write and read path along with data
--              registering for read path
-------------------------------------------------------------------------------
DEV_DWIDTH_MATCH_GEN: if NO_PRH_DWIDTH_MATCH = 0 generate

  ---------------------------------------------------------------------------
  -- NAME: STEER_INDEX_PROCESS
  ---------------------------------------------------------------------------
  -- Description: Generate index for steering logic from the address suffix
  ---------------------------------------------------------------------------
  STEER_INDEX_PROCESS: process(Dev_dbus_width, Addr_suffix)
  begin

    steer_index_i   <= (others => '0');

    case Dev_dbus_width is
      when "001"  =>
        steer_index_i   <= Addr_suffix;
      when "010"  =>
        steer_index_i   <= '0' & Addr_suffix(0 to ADDRCNT_WIDTH-2);
      when "100"  =>
        steer_index_i   <= (others => '0');
      when others =>
        steer_index_i   <= (others => '0');
    end case;
  end process STEER_INDEX_PROCESS;

  Steer_index  <= steer_index_i;

  -----------------------------------------------------------------------------
  -- NAME: PRH_MAX_DWIDTH_32_WR_STEER_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate steering logic for write data path when the
  --              peripheral data bus is 32 bit
  -----------------------------------------------------------------------------

  PRH_MAX_DWIDTH_32_WR_STEER_GEN: if C_PRH_MAX_DWIDTH = 32 generate

    ---------------------------------------------------------------------------
    -- NAME: WR_32_STEER_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Generate steering logic for write path when the peripheral
    --              data bus width 32 bits
    ---------------------------------------------------------------------------
    WR_32_STEER_PROCESS: process(Dev_dbus_width, steer_index_i,
                                 Bus2IP_Data, Bus2IP_BE)
    begin

      steer_data  <= (others => '0');
      steer_be    <= (others => '0');

      case Dev_dbus_width is

      when "001"  =>
        for i in 0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE -1 loop
          if steer_index_i = conv_std_logic_vector(i, ADDRCNT_WIDTH) then
            steer_data(0 to BYTE_SIZE-1) <= Bus2IP_Data(i*BYTE_SIZE to
                                          i*BYTE_SIZE + BYTE_SIZE-1);
            steer_be(0) <= Bus2IP_BE(i);
          end if;
        end loop;

      when "010" =>
        for i in 0 to C_SPLB_NATIVE_DWIDTH/(BYTE_SIZE*2) -1 loop
          if steer_index_i = conv_std_logic_vector(i, ADDRCNT_WIDTH) then
            steer_data(0 to 2*BYTE_SIZE-1) <= Bus2IP_Data(i*BYTE_SIZE*2 to
                                            i*BYTE_SIZE*2 + 2*BYTE_SIZE-1);
            steer_be(0 to 1) <= Bus2IP_BE(i*2 to (i*2)+1);
          end if;
        end loop;

      when "100" =>

        steer_data <= Bus2IP_Data;
        steer_be   <= Bus2IP_BE;

      when others =>

        steer_data <= (others => '0');
        steer_be   <= (others => '0');

      end case;
    end process WR_32_STEER_PROCESS;


  end generate PRH_MAX_DWIDTH_32_WR_STEER_GEN;

  -----------------------------------------------------------------------------
  -- NAME: PRH_MAX_DWIDTH_16_WR_STEER_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate steering logic for write data path when the
  --              peripheral data bus is 16 bit
  -----------------------------------------------------------------------------

  PRH_MAX_DWIDTH_16_WR_STEER_GEN: if C_PRH_MAX_DWIDTH = 16 generate

    ---------------------------------------------------------------------------
    -- NAME: WR_16_STEER_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Generate steering logic for write path when the peripheral
    --              data bus width is 16 bits
    ---------------------------------------------------------------------------
    WR_16_STEER_PROCESS: process(Dev_dbus_width, steer_index_i,
                                 Bus2IP_Data, Bus2IP_BE)
    begin

      steer_data <= (others => '0');
      steer_be   <= (others => '0');

      case Dev_dbus_width is

      when "001"  =>
        for i in 0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE -1 loop
          if steer_index_i = conv_std_logic_vector(i, ADDRCNT_WIDTH) then
            steer_data(0 to BYTE_SIZE-1) <= Bus2IP_Data(i*BYTE_SIZE to
                                            i*BYTE_SIZE + BYTE_SIZE-1);
            steer_be(0) <= Bus2IP_BE(i);
          end if;
        end loop;

      when "010" =>
        for i in 0 to C_SPLB_NATIVE_DWIDTH/(BYTE_SIZE*2) -1 loop
          if steer_index_i = conv_std_logic_vector(i, ADDRCNT_WIDTH) then
            steer_data(0 to 2*BYTE_SIZE-1) <= Bus2IP_Data(i*BYTE_SIZE*2 to
                                              i*BYTE_SIZE*2 + 2*BYTE_SIZE-1);
            steer_be(0 to 1) <= Bus2IP_BE(i*2 to (i*2)+1);
          end if;
        end loop;

      when others =>
        steer_data <= (others => '0');
        steer_be   <= (others => '0');

      end case;
    end process WR_16_STEER_PROCESS;

  end generate PRH_MAX_DWIDTH_16_WR_STEER_GEN;

  -----------------------------------------------------------------------------
  -- NAME: PRH_MAX_DWIDTH_8_WR_STEER_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate steering logic for write data path when the
  --              peripheral data bus is 8 bit
  -----------------------------------------------------------------------------

  PRH_MAX_DWIDTH_8_WR_STEER_GEN: if C_PRH_MAX_DWIDTH = 8 generate

    ---------------------------------------------------------------------------
    -- NAME: WR_8_STEER_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Generate steering logic for write path when the
    --              peripheral data bus width is 8 bits
    ---------------------------------------------------------------------------
    WR_8_STEER_PROCESS: process(Dev_dbus_width, steer_index_i,
                                Bus2IP_Data, Bus2IP_BE)
    begin

      steer_data  <= (others => '0');
      steer_be    <= (others => '0');

      case Dev_dbus_width is

      when "001"  =>
        for i in 0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE -1 loop
          if steer_index_i = conv_std_logic_vector(i, ADDRCNT_WIDTH) then
            steer_data(0 to BYTE_SIZE-1) <= Bus2IP_Data(i*BYTE_SIZE to
                                          i*BYTE_SIZE + BYTE_SIZE-1);
            steer_be(0) <= Bus2IP_BE(i);
          end if;
        end loop;

      when others =>
        steer_data <= (others => '0');
        steer_be   <= (others => '0');

      end case;
    end process WR_8_STEER_PROCESS;

  end generate PRH_MAX_DWIDTH_8_WR_STEER_GEN;

  -- Generate data for peripheral interface
  Data_Int <=  Bus2IP_Data(0 to C_PRH_MAX_DWIDTH-1) when Dev_dwidth_match = '0'
                 else steer_data;

  --for STA only
  -- Generate BE for peripheral interface
  prh_be_i  <= Bus2IP_BE(0 to C_PRH_MAX_DWIDTH/8 -1) when Dev_dwidth_match = '0'
                 else steer_be;

REG_PRH_SIGS4 : process(Local_Clk)
begin
if (Local_Clk'event and Local_Clk = '1')then
    PRH_BE <= prh_be_i;
 end if;
end process REG_PRH_SIGS4;
  -----------------------------------------------------------------------------
  -- NAME: PRH_MAX_DWIDTH_32_RD_STEER_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate steering logic for read path when the
  --              peripheral data bus is 32 bit
  -----------------------------------------------------------------------------
  PRH_MAX_DWIDTH_32_RD_STEER_GEN: if C_PRH_MAX_DWIDTH = 32 generate

    ---------------------------------------------------------------------------
    -- NAME: RD_32_STEER_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Generate steering logic for read path when peripheral
    --              data bus width is 32 bits
    ---------------------------------------------------------------------------
    RD_32_STEER_PROCESS: process(Dev_dbus_width, PRH_Data_In)
    begin

      steer_data_in <= (others => '0');

      case Dev_dbus_width is

      when "001"  =>
        for i in 0 to C_PRH_MAX_DWIDTH/BYTE_SIZE-1 loop
          steer_data_in(i*BYTE_SIZE to i*BYTE_SIZE+BYTE_SIZE-1) <=
                             PRH_Data_In(0 to BYTE_SIZE-1);
        end loop;

      when "010" =>
        for i in 0 to C_PRH_MAX_DWIDTH/(BYTE_SIZE*2)-1 loop
          steer_data_in(i*BYTE_SIZE*2 to i*BYTE_SIZE*2+BYTE_SIZE*2-1) <=
                                 PRH_Data_In(0 to BYTE_SIZE*2-1);
        end loop;

      when "100" =>
        steer_data_in <= PRH_Data_In;

      when others =>
        steer_data_in <= (others => '0');

      end case;
    end process RD_32_STEER_PROCESS;

  end generate PRH_MAX_DWIDTH_32_RD_STEER_GEN;

  -----------------------------------------------------------------------------
  -- NAME: PRH_MAX_DWIDTH_16_RD_STEER_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate steering logic for read and write when the
  --              peripheral data bus is 16 bit
  -----------------------------------------------------------------------------
  PRH_MAX_DWIDTH_16_RD_STEER_GEN: if C_PRH_MAX_DWIDTH = 16 generate

    ---------------------------------------------------------------------------
    -- NAME: RD_16_STEER_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Generate steering logic for read path when the peripheral
    --              data bus width is 16 bits
    ---------------------------------------------------------------------------
    RD_16_STEER_PROCESS: process(Dev_dbus_width, PRH_Data_In)
    begin

      steer_data_in <= (others => '0');

      case Dev_dbus_width is

      when "001"  =>
        for i in 0 to C_PRH_MAX_DWIDTH/BYTE_SIZE-1 loop
          steer_data_in(i*BYTE_SIZE to i*BYTE_SIZE+BYTE_SIZE-1) <=
                             PRH_Data_In(0 to BYTE_SIZE-1);
        end loop;

      when "010" =>
        for i in 0 to C_PRH_MAX_DWIDTH/(BYTE_SIZE*2)-1 loop
          steer_data_in(i*BYTE_SIZE*2 to i*BYTE_SIZE*2+BYTE_SIZE*2-1) <=
                                 PRH_Data_In(0 to BYTE_SIZE*2-1);
         end loop;

      when others =>
        steer_data_in <= (others => '0');

      end case;
    end process RD_16_STEER_PROCESS;

  end generate PRH_MAX_DWIDTH_16_RD_STEER_GEN;

  -----------------------------------------------------------------------------
  -- NAME: PRH_MAX_DWIDTH_8_RD_STEER_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate steering logic for read and write when the
  --              peripheral data bus is 8 bit
  -----------------------------------------------------------------------------
  PRH_MAX_DWIDTH_8_RD_STEER_GEN: if C_PRH_MAX_DWIDTH = 8 generate

    ---------------------------------------------------------------------------
    -- NAME: RD_8_STEER_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Generate steering logic for read path when the
    --              peripheral data bus width is 8 bits
    ---------------------------------------------------------------------------
    RD_8_STEER_PROCESS: process(Dev_dbus_width, PRH_Data_In)
    begin

      steer_data_in <= (others => '0');

      case Dev_dbus_width is

      when "001"  =>
        for i in 0 to C_PRH_MAX_DWIDTH/BYTE_SIZE-1 loop
          steer_data_in(i*BYTE_SIZE to i*BYTE_SIZE+BYTE_SIZE-1) <=
                             PRH_Data_In(0 to BYTE_SIZE-1);
        end loop;

      when others =>
        steer_data_in <= (others => '0');

      end case;
    end process RD_8_STEER_PROCESS;

  end generate PRH_MAX_DWIDTH_8_RD_STEER_GEN;

  ------------------------------------------------------------------------------
  -- NAME: ALL_DEV_DWIDTH_MATCH_GEN
  ------------------------------------------------------------------------------
  -- Description: If not all device employs data width matching, then generate
  --              data in without steering
  ------------------------------------------------------------------------------

  ALL_DEV_DWIDTH_MATCH_GEN: if ALL_PRH_DWIDTH_MATCH = 0 generate

    ---------------------------------------------------------------------------
    -- NAME: PRH_MAX_DWIDTH_32_RD_NO_STEER_GEN
    ---------------------------------------------------------------------------
    -- Description: Generate data for PLB interface without steering
    ---------------------------------------------------------------------------

    PRH_MAX_DWIDTH_32_RD_NO_STEER_GEN: if C_PRH_MAX_DWIDTH = 32 generate

      -------------------------------------------------------------------------
      -- NAME: NO_STEER_DATA_PROCESS
      -------------------------------------------------------------------------
      -- Description: Generate data for PLB interface without steering
      -------------------------------------------------------------------------
      NO_STEER_DATA_PROCESS: process(Dev_dbus_width, PRH_Data_In)
      begin

        no_steer_data_in  <= (others => '0');

        case Dev_dbus_width is

          when "001"  =>
            no_steer_data_in(0 to BYTE_SIZE-1)
               <= PRH_Data_In(0 to BYTE_SIZE-1);

          when "010" =>
            no_steer_data_in(0 to 2*BYTE_SIZE-1)
              <= PRH_Data_In(0 to 2*BYTE_SIZE-1);

          when "100" =>
            no_steer_data_in(0 to 4*BYTE_SIZE-1)
              <= PRH_Data_In(0 to 4*BYTE_SIZE-1);

          when others =>
            no_steer_data_in <= (others => '0');

        end case;
      end process NO_STEER_DATA_PROCESS;

    end generate PRH_MAX_DWIDTH_32_RD_NO_STEER_GEN;

    ---------------------------------------------------------------------------
    -- NAME: PRH_MAX_DWIDTH_16_RD_NO_STEER_GEN
    ---------------------------------------------------------------------------
    -- Description: Generate data for PLB interface without steering
    ---------------------------------------------------------------------------

    PRH_MAX_DWIDTH_16_RD_NO_STEER_GEN: if C_PRH_MAX_DWIDTH = 16 generate

      -------------------------------------------------------------------------
      -- NAME: NO_STEER_DATA_PROCESS
      -------------------------------------------------------------------------
      -- Description: Generate data for PLB interface without steering
      -------------------------------------------------------------------------
      NO_STEER_DATA_PROCESS: process(Dev_dbus_width, PRH_Data_In)
      begin

        no_steer_data_in  <= (others => '0');

        case Dev_dbus_width is

          when "001"  =>
            no_steer_data_in(0 to BYTE_SIZE-1)
              <= PRH_Data_In(0 to BYTE_SIZE-1);

          when "010" =>
            no_steer_data_in(0 to 2*BYTE_SIZE-1)
              <= PRH_Data_In(0 to 2*BYTE_SIZE-1);

          when others =>
            no_steer_data_in <= (others => '0');

        end case;
      end process NO_STEER_DATA_PROCESS;

    end generate PRH_MAX_DWIDTH_16_RD_NO_STEER_GEN;

    ---------------------------------------------------------------------------
    -- NAME: PRH_MAX_DWIDTH_8_RD_NO_STEER_GEN
    ---------------------------------------------------------------------------
    -- Description: Generate data for PLB interface without steering
    ---------------------------------------------------------------------------

    PRH_MAX_DWIDTH_8_RD_NO_STEER_GEN: if C_PRH_MAX_DWIDTH = 8 generate

      -------------------------------------------------------------------------
      -- NAME: NO_STEER_DATA_PROCESS
      -------------------------------------------------------------------------
      -- Description: Generate data for PLB interface without steering
      -------------------------------------------------------------------------
      NO_STEER_DATA_PROCESS: process(Dev_dbus_width, PRH_Data_In)
      begin

        no_steer_data_in  <= (others => '0');

        case Dev_dbus_width is

          when "001"  =>
            no_steer_data_in(0 to BYTE_SIZE-1)
              <= PRH_Data_In(0 to BYTE_SIZE-1);

          when others =>
            no_steer_data_in <= (others => '0');

        end case;
      end process NO_STEER_DATA_PROCESS;

    end generate PRH_MAX_DWIDTH_8_RD_NO_STEER_GEN;

  end generate ALL_DEV_DWIDTH_MATCH_GEN;

  ------------------------------------------------------------------------------
  -- NAME: NOT_ALL_DEV_DWIDTH_MATCH_GEN
  ------------------------------------------------------------------------------
  -- Description: If all device employs data width matching, then
  --              non-steered data is not required
  ------------------------------------------------------------------------------

  NOT_ALL_DEV_DWIDTH_MATCH_GEN: if ALL_PRH_DWIDTH_MATCH = 1 generate

    no_steer_data_in <= (others => '0');

  end generate NOT_ALL_DEV_DWIDTH_MATCH_GEN;

  data_in <=  no_steer_data_in  when Dev_dwidth_match = '0' else steer_data_in;

  -----------------------------------------------------------------------------
  -- NAME: SOME_DEV_SYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: Some or all devices are configured as synchronous devices
  -----------------------------------------------------------------------------
  SOME_DEV_SYNC_GEN: if NO_PRH_SYNC = 0 generate

    -------------------------------------------------------------------------
    -- NAME: STEER_SYNC_CE_PROCESS
    --------------------------------------------------------------------------
    -- Description: Generate data enables for synchronous interface
    --              after steering to the appropriate byte lane
    -------------------------------------------------------------------------
    STEER_SYNC_CE_PROCESS: process(Dev_dbus_width, steer_index_i, Sync_en)
    begin

      steer_sync_ce <= (others => '0');

      case Dev_dbus_width is

      when "001"  =>
        for i in 0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE -1 loop
          if steer_index_i = conv_std_logic_vector(i, ADDRCNT_WIDTH) then
            steer_sync_ce(i) <= Sync_en;
          end if;
        end loop;

      when "010" =>
         for i in 0 to C_SPLB_NATIVE_DWIDTH/(BYTE_SIZE*2)-1 loop
           if steer_index_i = conv_std_logic_vector(i, ADDRCNT_WIDTH) then
             steer_sync_ce(i*2)   <= Sync_en;
             steer_sync_ce(i*2+1) <= Sync_en;
           end if;
         end loop;

      when "100" =>
        for i in 0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1 loop
          steer_sync_ce(i) <= Sync_en;
        end loop;

      when others =>
        steer_sync_ce <= (others => '0');

      end case;
    end process STEER_SYNC_CE_PROCESS;

    ---------------------------------------------------------------------------
    -- NAME: ALL_DEV_DWIDTH_MATCH_GEN
    ---------------------------------------------------------------------------
    -- Description: If not all device employs data width matching, then
    --              generate data enables without steering
    ---------------------------------------------------------------------------

    ALL_DEV_DWIDTH_MATCH_GEN: if ALL_PRH_DWIDTH_MATCH = 0 generate

      -------------------------------------------------------------------------
      -- NAME: NO_STEER_SYNC_CE_PROCESS
      -------------------------------------------------------------------------
      -- Description: Generate data enables without steering for synchronous
      --              interface
      -------------------------------------------------------------------------
      NO_STEER_SYNC_CE_PROCESS: process(Dev_dbus_width, Sync_en)
      begin

        no_steer_sync_ce       <= (others => '0');

        case Dev_dbus_width is

          when "001"  =>
            no_steer_sync_ce(0) <= Sync_en;

          when "010" =>
            for i in 0 to 1 loop
              no_steer_sync_ce(i) <= Sync_en;
            end loop;

          when "100" =>
            for i in 0 to 3 loop
              no_steer_sync_ce(i) <= Sync_en;
            end loop;

          when others =>
            no_steer_sync_ce   <= (others => '0');

        end case;
      end process NO_STEER_SYNC_CE_PROCESS;

    end generate ALL_DEV_DWIDTH_MATCH_GEN;

    ---------------------------------------------------------------------------
    -- NAME: NOT_ALL_DEV_DWIDTH_MATCH_GEN
    ---------------------------------------------------------------------------
    -- Description: If all device employs data width matching, then
    --              non-steered data enables are not required
    ---------------------------------------------------------------------------

    NOT_ALL_DEV_DWIDTH_MATCH_GEN: if ALL_PRH_DWIDTH_MATCH = 1 generate

      no_steer_sync_ce <= (others => '0');

    end generate NOT_ALL_DEV_DWIDTH_MATCH_GEN;

    -- Generate data enable for the current device
    sync_ce_i <= no_steer_sync_ce  when Dev_dwidth_match = '0'
                                   else steer_sync_ce;

    Sync_ce <= sync_ce_i;

    ---------------------------------------------------------------------------
    -- NAME: SYNC_RD_CE_GEN
    ---------------------------------------------------------------------------
    -- Description: Qualify the data enable for the current device with the
    --              read signal for registering read data from synchronous
    --              interface
    ---------------------------------------------------------------------------
    SYNC_RD_CE_GEN: for i in 0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1 generate
      sync_rd_ce(i) <= sync_ce_i(i) and Dev_rnw;
    end generate SYNC_RD_CE_GEN;

  REG_SYNC_RD_CE : process(Local_Clk)
  begin
  if (Local_Clk'event and Local_Clk = '1')then
        sync_rd_ce_d1 <= sync_rd_ce;
  end if;
  end process REG_SYNC_RD_CE;

  SYNC_RD_PROCESS: process (Dev_bus_multiplex, sync_rd_ce_d1, sync_rd_ce)
  begin
        if (Dev_bus_multiplex='0') then
                sync_rd_ce_int <= sync_rd_ce_d1;
        else
                sync_rd_ce_int <= sync_rd_ce;
        end if;
  end process SYNC_RD_PROCESS;

--  sync_rd_ce_int <= sync_rd_ce_d1 when (Dev_dwidth_match='0') else
--                    sync_rd_ce;
    ---------------------------------------------------------------------------
    -- NAME: SYNC_RDREG_PLBWIDTH_GEN
    ---------------------------------------------------------------------------
    -- Description: Generate read registers for synchronous interface
    ---------------------------------------------------------------------------
  SYNC_RDREG_PLBWIDTH_GEN: for i in 0 to C_SPLB_NATIVE_DWIDTH/C_PRH_MAX_DWIDTH-1
                           generate
      -------------------------------------------------------------------------
      -- NAME: SYNC_RDREG_PRHWIDTH_GEN
      -------------------------------------------------------------------------
      -- Description: Generate read registers for synchronous interface
      -------------------------------------------------------------------------
      SYNC_RDREG_PRHWIDTH_GEN: for j in 0 to C_PRH_MAX_DWIDTH/BYTE_SIZE-1
                               generate
        -----------------------------------------------------------------------
        -- NAME: SYNC_RDREG_BYTE_GEN
        -----------------------------------------------------------------------
        -- Description: Generate read registers for synchronous interface
        -----------------------------------------------------------------------
        SYNC_RDREG_BYTE_GEN: for k in 0 to BYTE_SIZE-1 generate
        attribute ASYNC_REG : string;
        attribute ASYNC_REG of SYNC_RDREG_BIT: label is "TRUE";
        begin

          SYNC_RDREG_BIT: component FDRE
            port map (
                      Q  => sync_ip2bus_data(i*C_PRH_MAX_DWIDTH+j*BYTE_SIZE+k),
                      C  => Local_Clk,
                      CE => sync_rd_ce_int(i*C_PRH_MAX_DWIDTH/BYTE_SIZE+j),
                      D  => data_in(j*BYTE_SIZE+k),
                      R  => Local_Rst
                     );
        end generate SYNC_RDREG_BYTE_GEN;
      end generate SYNC_RDREG_PRHWIDTH_GEN;
    end generate SYNC_RDREG_PLBWIDTH_GEN;

  end generate SOME_DEV_SYNC_GEN;

  -----------------------------------------------------------------------------
  -- NAME: SOME_DEV_ASYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: Some or all devices are configured as asynchronous devices
  -----------------------------------------------------------------------------
  SOME_DEV_ASYNC_GEN: if NO_PRH_ASYNC = 0 generate

    -------------------------------------------------------------------------
    -- NAME: STEER_ASYNC_CE_PROCESS
    -------------------------------------------------------------------------
    -- Description: Generate data enables for asynchronous interface
    --              after steering to the appropriate byte lane
    -------------------------------------------------------------------------
    STEER_ASYNC_CE_PROCESS: process(Dev_dbus_width, steer_index_i, Async_en)
    begin

      steer_async_ce <= (others => '0');

      case Dev_dbus_width is

        when "001"  =>
          for i in 0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE -1 loop
            if steer_index_i = conv_std_logic_vector(i, ADDRCNT_WIDTH) then
              steer_async_ce(i) <= Async_en;
            end if;
          end loop;

        when "010" =>
           for i in 0 to C_SPLB_NATIVE_DWIDTH/(BYTE_SIZE*2) -1 loop
             if steer_index_i = conv_std_logic_vector(i, ADDRCNT_WIDTH) then
               steer_async_ce(i*2)   <= Async_en;
               steer_async_ce(i*2+1) <= Async_en;
             end if;
           end loop;

        when "100" =>
          for i in 0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1 loop
            steer_async_ce(i) <= Async_en;
          end loop;

        when others =>
          steer_async_ce <= (others => '0');
      end case;
    end process STEER_ASYNC_CE_PROCESS;


    ---------------------------------------------------------------------------
    -- NAME: ALL_DEV_DWIDTH_MATCH_GEN
    ---------------------------------------------------------------------------
    -- Description: If not all device employs data width matching, then
    --              generate data enables without steering
    ---------------------------------------------------------------------------

    ALL_DEV_DWIDTH_MATCH_GEN: if ALL_PRH_DWIDTH_MATCH = 0 generate

      -------------------------------------------------------------------------
      -- NAME: NO_STEER_ASYNC_CE_PROCESS
      -------------------------------------------------------------------------
      -- Description: Generate data enables without steering for asynchronous
      --              interface
      -------------------------------------------------------------------------
      NO_STEER_ASYNC_CE_PROCESS: process(Dev_dbus_width, Async_en)
      begin

        no_steer_async_ce       <= (others => '0');

        case Dev_dbus_width is

          when "001"  =>
            no_steer_async_ce(0) <= Async_en;

          when "010" =>
            for i in 0 to 1 loop
              no_steer_async_ce(i) <= Async_en;
            end loop;

          when "100" =>
            for i in 0 to 3 loop
              no_steer_async_ce(i) <= Async_en;
            end loop;

          when others =>
            no_steer_async_ce   <= (others => '0');

        end case;
      end process NO_STEER_ASYNC_CE_PROCESS;

    end generate ALL_DEV_DWIDTH_MATCH_GEN;

    ---------------------------------------------------------------------------
    -- NAME: NOT_ALL_DEV_DWIDTH_MATCH_GEN
    -------- ------------------------------------------------------------------
    -- Description: If all device employs data width matching, then
    --              non-steered data enables are not required
    ---------------------------------------------------------------------------

    NOT_ALL_DEV_DWIDTH_MATCH_GEN: if ALL_PRH_DWIDTH_MATCH = 1 generate

      no_steer_async_ce <= (others => '0');

    end generate NOT_ALL_DEV_DWIDTH_MATCH_GEN;


    -- Generate data enables for the current device
    async_ce_i <= no_steer_async_ce when Dev_dwidth_match = '0'
                  else steer_async_ce;

    Async_ce <= async_ce_i;

    ---------------------------------------------------------------------------
    -- NAME: ASYNC_RD_CE_GEN
    ---------------------------------------------------------------------------
    -- Description: Qualify the data enables for the current device with the
    --              read signal for registering read data from asynchronous
    --              interface
    ---------------------------------------------------------------------------
    ASYNC_RD_CE_GEN: for i in 0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1 generate
      async_rd_ce(i) <= async_ce_i(i) and Dev_rnw;
    end generate ASYNC_RD_CE_GEN;

    ---------------------------------------------------------------------------
    -- NAME: ASYNC_RDREG_PLBWIDTH_GEN
    ---------------------------------------------------------------------------
    -- Description: Generate read registers for asynchronous interface
    ---------------------------------------------------------------------------
 ASYNC_RDREG_PLBWIDTH_GEN: for i in 0 to C_SPLB_NATIVE_DWIDTH/C_PRH_MAX_DWIDTH-1
                              generate
      -------------------------------------------------------------------------
      -- NAME: ASYNC_RDREG_PRHWIDTH_GEN
      -------------------------------------------------------------------------
      -- Description: Generate read registers for asynchronous interface
      -------------------------------------------------------------------------
      ASYNC_RDREG_PRHWIDTH_GEN: for j in 0 to C_PRH_MAX_DWIDTH/BYTE_SIZE-1
                                generate
        -----------------------------------------------------------------------
        -- NAME: ASYNC_RDREG_BYTE_GEN
        -----------------------------------------------------------------------
        -- Description: Generate read registers for asynchronous interface
        -----------------------------------------------------------------------
        ASYNC_RDREG_BYTE_GEN: for k in 0 to BYTE_SIZE-1 generate
        attribute ASYNC_REG : string;
        attribute ASYNC_REG of ASYNC_RDREG_BIT: label is "TRUE";
        begin
          ASYNC_RDREG_BIT: component FDRE
            port map (
                      Q  => async_ip2bus_data(i*C_PRH_MAX_DWIDTH+j*BYTE_SIZE+k),
                      C  => Bus2IP_Clk,
                      CE => async_rd_ce(i*C_PRH_MAX_DWIDTH/BYTE_SIZE+j),
                      D  => data_in(j*BYTE_SIZE+k),
                      R  => Bus2IP_Rst
                     );
        end generate ASYNC_RDREG_BYTE_GEN;
      end generate ASYNC_RDREG_PRHWIDTH_GEN;
    end generate ASYNC_RDREG_PLBWIDTH_GEN;

  end generate SOME_DEV_ASYNC_GEN;

  -----------------------------------------------------------------------------
  -- NAME: ALL_DEV_SYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: All devices are configured as synchronous devices
  -----------------------------------------------------------------------------
  ALL_DEV_SYNC_GEN: if NO_PRH_ASYNC = 1 generate

    ip2bus_data_int <= sync_ip2bus_data;
    Async_ce <= (others => '0');

  end generate ALL_DEV_SYNC_GEN;

  -----------------------------------------------------------------------------
  -- NAME: ALL_DEV_ASYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: All devices are configured as asynchronous devices
  -----------------------------------------------------------------------------
  ALL_DEV_ASYNC_GEN: if NO_PRH_SYNC = 1 generate

    ip2bus_data_int <= async_ip2bus_data;
    Sync_ce <= (others => '0');

  end generate ALL_DEV_ASYNC_GEN;

  -----------------------------------------------------------------------------
  -- NAME: DEV_SYNC_AND_ASYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: Some devices are configured as synchronous and some
  --              asynchronous
  -----------------------------------------------------------------------------
  DEV_SYNC_AND_ASYNC_GEN: if NO_PRH_SYNC = 0 and NO_PRH_ASYNC = 0 generate

    ip2bus_data_int <= async_ip2bus_data when Dev_sync = '0'
                       else sync_ip2bus_data;

  end generate DEV_SYNC_AND_ASYNC_GEN;


  IP2Bus_Data <= ip2bus_data_int when (Bus2IP_RNW = '1' and Dev_in_access = '1')
                 else (others => '0');

end generate DEV_DWIDTH_MATCH_GEN;

end architecture imp;
--------------------------------end of file------------------------------------
