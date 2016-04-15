-------------------------------------------------------------------------------
-- address_gen.vhd - entity/architecture pair
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
-- File          : address_gen.vhd
-- Company       : Xilinx
-- Version       : v1.00.a
-- Description   : External Peripheral Controller for AXI bus address generation
--                 logic
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
use IEEE.std_logic_arith.unsigned;
use IEEE.std_logic_arith.conv_integer;

library axi_epc_v2_0;
use axi_epc_v2_0.ld_arith_reg;

-------------------------------------------------------------------------------
--                     Definition of Generics                                --
-------------------------------------------------------------------------------
-- C_PRH_MAX_AWIDTH     -  Maximum of address bus width of all peripherals 
-- NO_PRH_DWIDTH_MATCH  -  Indication that no device is employing data width 
--                         matching
-- NO_PRH_SYNC          -  Indicates all devices are configured for
--                         asynchronous interface
-- NO_PRH_ASYNC         -  Indicates all devices are configured for
--                         synchronous interface
-- ADDRCNT_WIDTH        -  Width of counter generating address suffix in case
--                         of data width matching
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                     Definition of Ports                                   --
-------------------------------------------------------------------------------
-- Bus2IP_Clk            - IPIC clock
-- Bus2IP_Rst            - IPIC reset
-- Local_Clk             - Operational clock for peripheral interface
-- Local_Rst             - Rest for peripheral interface
-- Bus2IP_Addr           - Address bus from IPIC interface
-- Dev_fifo_access       - Indicates if the current access is to a FIFO like
--                       - structure within the external peripheral device
-- Dev_sync              - Indicates if the current device being accessed 
--                         is synchronous device
-- Dev_dwidth_match      - Indicates if the current device employs data 
--                         width matching
-- Dev_dbus_width        - Indicates decoded value for the data bus width
-- Async_addr_cnt_ld     - Load signal for the address suffix counter for 
--                         asynchronous interface
-- Async_addr_cnt_ce     - Enable for address suffix counter for asynchronous
--                         interface
-- Sync_addr_cnt_ld      - Load signal for the address suffix counter for 
--                         synchronous interface
-- Sync_addr_cnt_ce      - Enable for address suffix counter for synchronous
--                         interface
-- Addr_Int              - Internal address bus for peripheral interface
-- Addr_suffix           - Address suffix (lower bits of address bus) generated
--                         within this module when data width matching is 
--                         enabled
-------------------------------------------------------------------------------

entity address_gen is
  generic (
    C_PRH_MAX_AWIDTH    : integer;
    NO_PRH_DWIDTH_MATCH : integer;
    NO_PRH_SYNC         : integer;
    NO_PRH_ASYNC        : integer;
    ADDRCNT_WIDTH       : integer
  );
 
  port (
    Bus2IP_Clk         : in  std_logic;
    Bus2IP_Rst         : in  std_logic;

    Local_Clk          : in  std_logic;
    Local_Rst          : in  std_logic;

    Bus2IP_Addr        : in  std_logic_vector(0 to C_PRH_MAX_AWIDTH-1);

    Dev_fifo_access    : in  std_logic;
    Dev_sync           : in  std_logic;
    Dev_dwidth_match   : in  std_logic;
    Dev_dbus_width     : in  std_logic_vector(0 to 2);

    Async_addr_cnt_ld  : in  std_logic;
    Async_addr_cnt_ce  : in  std_logic;

    Sync_addr_cnt_ld   : in  std_logic;
    Sync_addr_cnt_ce   : in  std_logic;

    Addr_Int           : out std_logic_vector(0 to C_PRH_MAX_AWIDTH-1);
    Addr_suffix        : out std_logic_vector(0 to ADDRCNT_WIDTH-1)
    );
end entity address_gen;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture imp of address_gen is

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
constant ADDRCNT_RST  : std_logic_vector(0 to ADDRCNT_WIDTH-1) 
                      := (others => '0');

-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------
signal async_addr_cnt_i      : std_logic_vector(0 to ADDRCNT_WIDTH-1) := 
                               (others => '0');
signal async_addr_ld_cnt_val : std_logic_vector(0 to ADDRCNT_WIDTH-1) := 
                               (others => '0');

signal sync_addr_cnt_i       : std_logic_vector(0 to ADDRCNT_WIDTH-1) := 
                               (others => '0');
signal sync_addr_ld_cnt_val  : std_logic_vector(0 to ADDRCNT_WIDTH-1) := 
                               (others => '0');

signal async_addr_suffix     : std_logic_vector(0 to ADDRCNT_WIDTH-1) := 
                               (others => '0');
signal sync_addr_suffix      : std_logic_vector(0 to ADDRCNT_WIDTH-1) := 
                               (others => '0');
signal addr_suffix_i         : std_logic_vector(0 to ADDRCNT_WIDTH-1) := 
                               (others => '0');

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
begin

-------------------------------------------------------------------------------
-- NAME: NO_DEV_DWIDTH_MATCH_GEN
-------------------------------------------------------------------------------
-- Description: If no device employs data width matching, then generate 
--              default values
-------------------------------------------------------------------------------
NO_DEV_DWIDTH_MATCH_GEN: if NO_PRH_DWIDTH_MATCH = 1 generate

   Addr_suffix  <= (others => '0');
   Addr_Int <= Bus2IP_Addr;

end generate NO_DEV_DWIDTH_MATCH_GEN;

-------------------------------------------------------------------------------
-- NAME: DEV_DWIDTH_MATCH_GEN
-------------------------------------------------------------------------------
-- Description: If any device employs data width matching, then generate 
--              address suffix, peripheral address bus, async and sync cycle 
--              indications 
-------------------------------------------------------------------------------

DEV_DWIDTH_MATCH_GEN: if NO_PRH_DWIDTH_MATCH = 0 generate

  -----------------------------------------------------------------------------
  -- NAME: SOME_DEV_SYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: Some or all devices are configured as synchronous devices
  -----------------------------------------------------------------------------
  SOME_DEV_SYNC_GEN: if NO_PRH_SYNC = 0 generate

    ---------------------------------------------------------------------------
    -- Counter for address suffix generation for synchronous peripheral 
    -- interface 
    ---------------------------------------------------------------------------

    I_SYNC_ADDRCNT: entity axi_epc_v2_0.ld_arith_reg
    generic map ( C_ADD_SUB_NOT  => true,
                  C_REG_WIDTH    => ADDRCNT_WIDTH,
                  C_RESET_VALUE  => ADDRCNT_RST,
                  C_LD_WIDTH     => ADDRCNT_WIDTH,
                  C_LD_OFFSET    => 0,
                  C_AD_WIDTH     => 1,
                  C_AD_OFFSET    => 0
                )
    port map ( CK             => Local_Clk,
               RST            => Local_Rst,
               Q              => sync_addr_cnt_i,
               LD             => sync_addr_ld_cnt_val,
               AD             => "1",
               LOAD           => Sync_addr_cnt_ld,
               OP             => Sync_addr_cnt_ce
             );

    ---------------------------------------------------------------------------
    -- NAME : SYNC_ADDR_LD_VAL_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Initial load value for the address suffix counter
    ---------------------------------------------------------------------------
    SYNC_ADDR_LD_VAL_PROCESS: process(Dev_dbus_width, Bus2IP_Addr)
    begin
  
      sync_addr_ld_cnt_val <= (others => '0');
 
      case Dev_dbus_width is
        when "001" =>
          sync_addr_ld_cnt_val  <= 
            Bus2IP_Addr(C_PRH_MAX_AWIDTH-ADDRCNT_WIDTH to C_PRH_MAX_AWIDTH - 1);

        when "010" =>
          sync_addr_ld_cnt_val  <= '0' & 
            Bus2IP_Addr(C_PRH_MAX_AWIDTH-ADDRCNT_WIDTH to C_PRH_MAX_AWIDTH - 2);

        when "100" =>
          sync_addr_ld_cnt_val  <= (others => '0');

        when others =>
          sync_addr_ld_cnt_val  <= (others => '0');

      end case;
    end process SYNC_ADDR_LD_VAL_PROCESS;

    ---------------------------------------------------------------------------
    -- NAME : SYNC_ADDR_SUFFIX_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Address suffix generation for synchronous interface
    ---------------------------------------------------------------------------
    SYNC_ADDR_SUFFIX_PROCESS: process(Dev_dbus_width, sync_addr_cnt_i)
    begin

      sync_addr_suffix  <= (others => '0');

      case Dev_dbus_width is
        when "001" =>
          sync_addr_suffix   <= sync_addr_cnt_i;
        when "010" =>
          sync_addr_suffix   <= sync_addr_cnt_i(1 to ADDRCNT_WIDTH-1) & '0';
        when "100" =>
          sync_addr_suffix   <= (others => '0');
        when others =>
          sync_addr_suffix   <= (others => '0');
      end case;
    end process SYNC_ADDR_SUFFIX_PROCESS;

  end generate SOME_DEV_SYNC_GEN;

  -----------------------------------------------------------------------------
  -- NAME: SOME_DEV_ASYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: Some or all devices are configured as asynchronous devices
  -----------------------------------------------------------------------------
  SOME_DEV_ASYNC_GEN: if NO_PRH_ASYNC = 0 generate

    ---------------------------------------------------------------------------
    -- Counter for address suffix generation for asynchronous peripheral 
    -- interface 
    ---------------------------------------------------------------------------

    I_ASYNC_ADDRCNT: entity axi_epc_v2_0.ld_arith_reg
      generic map ( C_ADD_SUB_NOT  => true,
                    C_REG_WIDTH    => ADDRCNT_WIDTH,
                    C_RESET_VALUE  => ADDRCNT_RST,
                    C_LD_WIDTH     => ADDRCNT_WIDTH,
                    C_LD_OFFSET    => 0,
                    C_AD_WIDTH     => 1,
                    C_AD_OFFSET    => 0
                  )
      port map ( CK             => Bus2IP_Clk,
                 RST            => Bus2IP_Rst,
                 Q              => async_addr_cnt_i,
                 LD             => async_addr_ld_cnt_val,
                 AD             => "1",
                 LOAD           => Async_addr_cnt_ld,
                 OP             => Async_addr_cnt_ce
               );


    ---------------------------------------------------------------------------
    -- NAME : ASYNC_ADDR_LD_VAL_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Initial load value for the address suffix counter
    ---------------------------------------------------------------------------
    ASYNC_ADDR_LD_VAL_PROCESS: process(Dev_dbus_width, Bus2IP_Addr)
    begin
  
      async_addr_ld_cnt_val <= (others => '0');
 
      case Dev_dbus_width is
        when "001" =>
          async_addr_ld_cnt_val <= 
            Bus2IP_Addr(C_PRH_MAX_AWIDTH-ADDRCNT_WIDTH to C_PRH_MAX_AWIDTH - 1);

        when "010" =>
          async_addr_ld_cnt_val <= '0' & 
            Bus2IP_Addr(C_PRH_MAX_AWIDTH-ADDRCNT_WIDTH to C_PRH_MAX_AWIDTH - 2);

        when "100" =>
          async_addr_ld_cnt_val <= (others => '0');

        when others =>
          async_addr_ld_cnt_val <= (others => '0');

       end case;
    end process ASYNC_ADDR_LD_VAL_PROCESS;

    ---------------------------------------------------------------------------
    -- NAME : ASYNC_ADDR_SUFFIX_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Address suffix generation for asynchronous interface 
    ---------------------------------------------------------------------------
    ASYNC_ADDR_SUFFIX_PROCESS: process(Dev_dbus_width, async_addr_cnt_i)
    begin

      async_addr_suffix <= (others => '0');

      case Dev_dbus_width is
        when "001" =>
          async_addr_suffix  <= async_addr_cnt_i;
        when "010" =>
          async_addr_suffix  <= async_addr_cnt_i(1 to ADDRCNT_WIDTH-1) & '0';
        when "100" =>
          async_addr_suffix  <= (others => '0');
        when others =>
          async_addr_suffix  <= (others => '0');
      end case;
    end process ASYNC_ADDR_SUFFIX_PROCESS;

  end generate SOME_DEV_ASYNC_GEN;

  -----------------------------------------------------------------------------
  -- NAME: ALL_DEV_SYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: All devices are configured as synchronous devices
  -----------------------------------------------------------------------------
  ALL_DEV_SYNC_GEN: if NO_PRH_ASYNC = 1 generate

    addr_suffix_i <= sync_addr_suffix;

  end generate ALL_DEV_SYNC_GEN;

  -----------------------------------------------------------------------------
  -- NAME: ALL_DEV_ASYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: All devices are configured as asynchronous devices
  -----------------------------------------------------------------------------
  ALL_DEV_ASYNC_GEN: if NO_PRH_SYNC = 1 generate

    addr_suffix_i <= async_addr_suffix;

  end generate ALL_DEV_ASYNC_GEN;

  -----------------------------------------------------------------------------
  -- NAME: DEV_SYNC_AND_ASYNC_GEN
  -----------------------------------------------------------------------------
  -- Description: Some devices are configured as synchronous and some 
  --              asynchronous 
  -----------------------------------------------------------------------------
  DEV_SYNC_AND_ASYNC_GEN: if NO_PRH_SYNC = 0 and NO_PRH_ASYNC = 0 generate

    addr_suffix_i <= async_addr_suffix when dev_sync = '0'
                     else sync_addr_suffix;
  
  end generate DEV_SYNC_AND_ASYNC_GEN;

  Addr_suffix <= addr_suffix_i;

  Addr_Int <= Bus2IP_Addr when (Dev_dwidth_match = '0' or Dev_fifo_access = '1')
              else Bus2IP_Addr(0 to C_PRH_MAX_AWIDTH-ADDRCNT_WIDTH-1) 
                   & addr_suffix_i;


end generate DEV_DWIDTH_MATCH_GEN;

end architecture imp;
--------------------------------end of file------------------------------------
