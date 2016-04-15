-------------------------------------------------------------------------------
-- async_counters.vhd - entity/architecture pair
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

-------------------------------------------------------------------------
-- Filename:   async_counters.vhd
-- Version:    v1.00.a
-- Description:This file contains all of the counters for the EPC Async design
--
-- VHDL-Standard: VHDL'93
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
-- Author   : VB
-- History  :
--
--  VB           08-24-2010 --  v2_0 version for AXI
-- ^^^^^^
--            The core updated for AXI based on xps_epc_v1_02_a
-- ~~~~~~
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                    "_n"
--      clock signals:                         "clk", "clk_div#", "clk_#x"
--      reset signals:                         "rst", "rst_n"
--      generics:                              "C_*"
--      user defined types:                    "*_TYPE"
--      state machine next state:              "*_ns"
--      state machine current state:           "*_cs"
--      combinatorial signals:                 "*_com"
--      pipelined or register delay signals:   "*_d#"
--      counter signals:                       "*cnt*"
--      clock enable signals:                  "*_ce"
--      internal version of output port        "*_i"
--      device pins:                           "*_pin"
--      ports:                                 -Names begin with Uppercase
--      processes:                             "*_PROCESS"
--      component instantiations:              "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

library axi_epc_v2_0;
use axi_epc_v2_0.ld_arith_reg;

-------------------------------------------------------------------------------
-- Definition of Ports:
-------------------------------------------------------------------------------
------------Declaration of GENERICs which will go directly counters------------
-------------------------------------------------------------------------------
--C_ADDR_TH_CNT_WIDTH   -- Address hold time counter data width
--C_ADDR_DATA_CS_TH_CNT_WIDTH --Address/Data/Chip select hold counter data width
--C_CONTROL_CNT_WIDTH   -- Control signal counter width
--C_DEV_VALID_CNT_WIDTH -- Device valid signal width
--C_DEV_RDY_CNT_WIDTH   -- Control siganl assert activate counter width
--C_ADS_CNT_WIDTH       -- Address Strobe counter width
--C_WR_REC_NM_CNT_WIDTH --Non Muxed Recovery signal assert(wr)activate cntr wdth
--C_RD_REC_NM_CNT_WIDTH --Non Muxed Recovery signal assert(rd)activate cntr wdth
--C_WR_REC_M_CNT_WIDTH  -- Muxed Recovery siganl assert(write)activate cntr wdth
--C_RD_REC_M_CNT_WIDTH  -- Muxed Recovery siganl assert(read)activate cntr wdth
------------------------------------------------------------------------------
--***All inputs***
------------------------------------------------------------------------------
-- Taddr_hold_count         -- address counter width
-- Taddr_data_cs_hold_count -- address data chip select hold count
-- Tcontrol_width_data      -- control width count
-- Tdev_valid_data          -- device valid count
-- Tdevrdy_width_data       -- device ready count
-- Tads_data                -- address strobe/chip select/data set up count

-- Twr_recovery_muxed_data  -- muxed write recovery count
-- Twr_recovery_non_muxed_data  -- non muxed write recovery count
-- Trd_recovery_muxed_data  -- muxed read recovery count
-- Trd_recovery_non_muxed_data  -- non muxed read recovery count

-- Taddr_hold_load   -- Load the counter to hold the address lines
-- Tdata_hold_load   -- Load the counter to hold the data lines
-- Tcontrol_load     -- Load the counter to maintain the control signal
-- Tdev_valid_load   -- Load the device valid counter
-- Tdev_rdy_load     -- Load the device ready counter
-- Tads_load         -- Load the address strobe counter
-- Twr_recovery_load -- Load the write recovery counter
-- Trd_recovery_load -- Load the read recovery counter

-- Taddr_hold_load_ce  -- Address hold load counter enable
-- Tdata_hold_load_ce  -- Data hold load counter enable
-- Tcontrol_load_ce    -- Control load counter enable
-- Tdev_valid_load_ce  -- Device valid load counter enable
-- Tdev_rdy_load_ce    -- Device ready load counter enable
-- Tads_load_ce        -- Address Strobe load counter enable

-- Twr_muxed_recovery_load_ce -- Muxed Write recovery load counter enable
-- Trd_muxed_recovery_load_ce -- Muxed Read recovery load counter enable
-- Twr_non_muxed_recovery_load_ce --Non muxed Write recovery load counter enable
-- Trd_non_muxed_recovery_load_ce --Non muxed read recovery load counter enable
------------------------------------------------------------------------------
-- ***All outputs***
------------------------------------------------------------------------------
--Taddr_hold_cnt            -- output of address hold count
--Tcontrol_wdth_cnt         -- output of control width count
--Tdevrdy_wdth_cnt          -- output of device ready count
--Tdev_valid_cnt            -- output of device valid count
--Tads_cnt                  -- output of address-strobe/data,adress set up count
--Taddr_data_cs_hold_cnt    -- output of address,data,chip select hold count

--Twr_muxed_rec_cnt         -- output of muxed write recovery count
--Trd_muxed_rec_cnt         -- output of muxed read recovery count
--Twr_non_muxed_rec_cnt     -- output of non muxed write recovery count
--Trd_non_muxed_rec_cnt     -- output of non muxed read recovery count

------------------------------------------------------------------------------
-- ***Clocks and reset***
------------------------------------------------------------------------------
--      Clk                 -- AXI Clk
--      Rst                 -- AXI Reset
------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
entity async_counters is
  generic
        (
        C_ADDR_TH_CNT_WIDTH             : integer;
        C_ADDR_DATA_CS_TH_CNT_WIDTH     : integer;
        C_CONTROL_CNT_WIDTH             : integer;
        C_DEV_VALID_CNT_WIDTH           : integer;
        C_DEV_RDY_CNT_WIDTH             : integer;
        C_ADS_CNT_WIDTH                 : integer;
        C_WR_REC_NM_CNT_WIDTH           : integer;
        C_RD_REC_NM_CNT_WIDTH           : integer;
        C_WR_REC_M_CNT_WIDTH            : integer;
        C_RD_REC_M_CNT_WIDTH            : integer
        );
  port
        (
-- inputs from asynch_cntrl
    Taddr_hold_count        : in std_logic_vector(0 to C_ADDR_TH_CNT_WIDTH-1);
    Taddr_data_cs_hold_count: in std_logic_vector
                                          (0 to C_ADDR_DATA_CS_TH_CNT_WIDTH-1);
    Tcontrol_width_data     : in std_logic_vector(0 to C_CONTROL_CNT_WIDTH-1);
    Tdev_valid_data         : in std_logic_vector(0 to C_DEV_VALID_CNT_WIDTH-1);
    Tdevrdy_width_data      : in std_logic_vector(0 to C_DEV_RDY_CNT_WIDTH-1);
    Tads_data               : in std_logic_vector(0 to C_ADS_CNT_WIDTH-1);
    
    Twr_recovery_muxed_data     : in std_logic_vector
                                                  (0 to C_WR_REC_M_CNT_WIDTH-1);
    Twr_recovery_non_muxed_data : in std_logic_vector
                                                 (0 to C_WR_REC_NM_CNT_WIDTH-1);
    Trd_recovery_muxed_data     : in std_logic_vector
                                                  (0 to C_RD_REC_M_CNT_WIDTH-1);
    Trd_recovery_non_muxed_data : in std_logic_vector
                                                 (0 to C_RD_REC_NM_CNT_WIDTH-1);
    
    Taddr_hold_cnt         : out std_logic_vector(0 to C_ADDR_TH_CNT_WIDTH-1);
    Tcontrol_wdth_cnt      : out std_logic_vector(0 to C_CONTROL_CNT_WIDTH-1);
    Tdevrdy_wdth_cnt       : out std_logic_vector(0 to C_DEV_RDY_CNT_WIDTH-1);
    
    Twr_muxed_rec_cnt      : out std_logic_vector(0 to C_WR_REC_M_CNT_WIDTH-1);
    Trd_muxed_rec_cnt      : out std_logic_vector(0 to C_RD_REC_M_CNT_WIDTH-1);
    Twr_non_muxed_rec_cnt  : out std_logic_vector(0 to C_WR_REC_NM_CNT_WIDTH-1);
    Trd_non_muxed_rec_cnt  : out std_logic_vector(0 to C_RD_REC_NM_CNT_WIDTH-1);
    
    Tdev_valid_cnt         : out std_logic_vector(0 to C_DEV_VALID_CNT_WIDTH-1);
    Tads_cnt               : out std_logic_vector(0 to C_ADS_CNT_WIDTH-1);
    Taddr_data_cs_hold_cnt : out std_logic_vector
                                           (0 to C_ADDR_DATA_CS_TH_CNT_WIDTH-1);
    -- inputs from asynch_statemachine
    Taddr_hold_load        : in std_logic;
    Tdata_hold_load        : in std_logic;
    Tcontrol_load          : in std_logic;
    Tdev_valid_load        : in std_logic;
    Tdev_rdy_load          : in std_logic;
    Tads_load              : in std_logic;
    Twr_recovery_load      : in std_logic;
    Trd_recovery_load      : in std_logic;
    
    Taddr_hold_load_ce     : in std_logic;
    Tdata_hold_load_ce     : in std_logic;
    Tcontrol_load_ce       : in std_logic;
    Tdev_valid_load_ce     : in std_logic;
    Tdev_rdy_load_ce       : in std_logic;
    Tads_load_ce           : in std_logic;
    
    Twr_muxed_recovery_load_ce    : in std_logic;
    Trd_muxed_recovery_load_ce    : in std_logic;
    Twr_non_muxed_recovery_load_ce: in std_logic;
    Trd_non_muxed_recovery_load_ce: in std_logic;

-- Clocks and reset
    Clk               :in std_logic;
    Rst               :in std_logic
      );
end entity async_counters;
------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------
architecture imp of async_counters is
------------------------------------------------------------------------------
-- Constant declarations
------------------------------------------------------------------------------
-- reset values
-- addr hold
constant ADDR_TH_CNTR2_RST: std_logic_vector(0 to C_ADDR_TH_CNT_WIDTH-1)
          := (others => '0');
-- control hold
constant CONTROL_TH_CNTR3_RST: std_logic_vector(0 to C_CONTROL_CNT_WIDTH-1)
          := (others => '0');
-- dev rdy pulse width
constant DEV_RDY_CNTR4_RST: std_logic_vector(0 to C_DEV_RDY_CNT_WIDTH-1)
          := (others => '0');
-- device set up pulse width
constant DEV_VALID_CNTR7_RST: std_logic_vector(0 to C_DEV_VALID_CNT_WIDTH-1)
          := (others => '0');
-- address strobe counter
constant ADS_CNTR8_RST: std_logic_vector(0 to C_ADS_CNT_WIDTH-1)
          := (others => '0');
-- address,data, chip select hold width
constant ADDR_DATA_CS_TH_CNTR12_RST
          :std_logic_vector(0 to C_ADDR_DATA_CS_TH_CNT_WIDTH-1)
          := (others => '0');
-- read recovery pulse width

constant RD_MUXED_RECOVERY_CNTR9_RST:
          std_logic_vector(0 to C_RD_REC_M_CNT_WIDTH-1)
          := (others => '0');
constant RD_NON_MUXED_RECOVERY_CNTR9_RST:
          std_logic_vector(0 to C_RD_REC_NM_CNT_WIDTH-1)
          := (others => '0');

-- write recovery pulse width

constant WR_MUXED_RECOVERY_CNTR5_RST:
          std_logic_vector(0 to C_WR_REC_M_CNT_WIDTH-1)
          := (others => '0');
constant WR_NON_MUXED_RECOVERY_CNTR5_RST:
          std_logic_vector(0 to C_WR_REC_NM_CNT_WIDTH-1)
          := (others => '0');

-----------------------------------------------------------------------------
-- Signal declarations
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
-- Architecture start
-----------------------------------------------------------------------------
begin
-- Note: All the counters are down counters
------------------------------------------------------------------------------
-- component instantiation
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- component instantiation
------------------------------------------------------------------------------
--LD_ARITH_REG_I_CNTR2: The max time counter for address hold
------------------------------------------------------------------------------

LD_ARITH_REG_I_CNTR2: entity axi_epc_v2_0.ld_arith_reg
    generic map (
          C_ADD_SUB_NOT         => false,
          C_REG_WIDTH           => C_ADDR_TH_CNT_WIDTH,
          C_RESET_VALUE         => ADDR_TH_CNTR2_RST,
          C_LD_WIDTH            => C_ADDR_TH_CNT_WIDTH,
          C_LD_OFFSET           => 0,
          C_AD_WIDTH            => 1,
          C_AD_OFFSET           => 0
          )
    port map     (
          CK                    => Clk,
          RST                   => Rst,
          Q                     => Taddr_hold_cnt,
          LD                    => Taddr_hold_count,
          AD                    => "1",
          LOAD                  => Taddr_hold_load,
          OP                    => Taddr_hold_load_ce
          );
------------------------------------------------------------------------------
-- component instantiation
------------------------------------------------------------------------------
--LD_ARITH_REG_I_CNTR3: The max time counter for control width
------------------------------------------------------------------------------
LD_ARITH_REG_I_CNTR3: entity axi_epc_v2_0.ld_arith_reg
    generic map (
          C_ADD_SUB_NOT         => false,
          C_REG_WIDTH           => C_CONTROL_CNT_WIDTH,
          C_RESET_VALUE         => CONTROL_TH_CNTR3_RST,
          C_LD_WIDTH            => C_CONTROL_CNT_WIDTH,
          C_LD_OFFSET           => 0,
          C_AD_WIDTH            => 1,
          C_AD_OFFSET           => 0
          )
    port map     (
          CK                    => Clk,
          RST                   => Rst,
          Q                     => Tcontrol_wdth_cnt,
          LD                    => Tcontrol_width_data,
          AD                    => "1",
          LOAD                  => Tcontrol_load,
          OP                    => Tcontrol_load_ce
          );
------------------------------------------------------------------------------
-- component instantiation
------------------------------------------------------------------------------
--LD_ARITH_REG_I_CNTR4: The max time counter till device become ready for
--communication
-----------------------------------------------------------------------------
--The counter is a down counter and will be loaded with initial values.
--The initial value will be loaded from the asynch_cntl level file.
--these values are modified as per the device requirements.
--Once the counter reaches to '1', then disable signal will be activated which
--in turn "deactivates" the control signals in the state machine.Ulitmately this
--becomes the max time counter till device responds
------------------------------------------------------------------------------

LD_ARITH_REG_I_CNTR4: entity axi_epc_v2_0.ld_arith_reg
    generic map (
          C_ADD_SUB_NOT         => false,
          C_REG_WIDTH           => C_DEV_RDY_CNT_WIDTH,
          C_RESET_VALUE         => DEV_RDY_CNTR4_RST,
          C_LD_WIDTH            => C_DEV_RDY_CNT_WIDTH,
          C_LD_OFFSET           => 0,
          C_AD_WIDTH            => 1,
          C_AD_OFFSET           => 0
                     )
    port map     (
          CK                    => Clk,
          RST                   => Rst,
          Q                     => Tdevrdy_wdth_cnt,
          LD                    => Tdevrdy_width_data,
          AD                    => "1",
          LOAD                  => Tdev_rdy_load,
          OP                    => Tdev_rdy_load_ce
          );
------------------------------------------------------------------------------
-- component instantiation
------------------------------------------------------------------------------
-- LD_ARITH_REG_I_CNTR7: This counter is used to measure period for
-- device in to valid state
------------------------------------------------------------------------------

LD_ARITH_REG_I_CNTR7: entity axi_epc_v2_0.ld_arith_reg
    generic map (
          C_ADD_SUB_NOT         => false,
          C_REG_WIDTH           => C_DEV_VALID_CNT_WIDTH,
          C_RESET_VALUE         => DEV_VALID_CNTR7_RST,
          C_LD_WIDTH            => C_DEV_VALID_CNT_WIDTH,
          C_LD_OFFSET           => 0,
          C_AD_WIDTH            => 1,
          C_AD_OFFSET           => 0
                     )
    port map     (
          CK                    => Clk,
          RST                   => Rst,
          Q                     => Tdev_valid_cnt,
          LD                    => Tdev_valid_data,
          AD                    => "1",
          LOAD                  => Tdev_valid_load,
          OP                    => Tdev_valid_load_ce
          );

------------------------------------------------------------------------------
-- component instantiation
------------------------------------------------------------------------------
-- LD_ARITH_REG_I_CNTR8: This counter is used to measure period for
-- address strobe
------------------------------------------------------------------------------

LD_ARITH_REG_I_CNTR8: entity axi_epc_v2_0.ld_arith_reg
    generic map (
          C_ADD_SUB_NOT         => false,
          C_REG_WIDTH           => C_ADS_CNT_WIDTH,
          C_RESET_VALUE         => ADS_CNTR8_RST,
          C_LD_WIDTH            => C_ADS_CNT_WIDTH,
          C_LD_OFFSET           => 0,
          C_AD_WIDTH            => 1,
          C_AD_OFFSET           => 0
                     )
    port map     (
          CK                    => Clk,
          RST                   => Rst,
          Q                     => Tads_cnt,
          LD                    => Tads_data,
          AD                    => "1",
          LOAD                  => Tads_load,
          OP                    => Tads_load_ce
          );
------------------------------------------------------------------------------
-- component instantiation
-------------------------------------------------------------------------------
--LD_ARITH_REG_I_CNTR12: The max time counter for address,data,chip select hold
-------------------------------------------------------------------------------
LD_ARITH_REG_I_CNTR12: entity axi_epc_v2_0.ld_arith_reg
    generic map (
          C_ADD_SUB_NOT         => false,
          C_REG_WIDTH           => C_ADDR_DATA_CS_TH_CNT_WIDTH,
          C_RESET_VALUE         => ADDR_DATA_CS_TH_CNTR12_RST,
          C_LD_WIDTH            => C_ADDR_DATA_CS_TH_CNT_WIDTH,
          C_LD_OFFSET           => 0,
          C_AD_WIDTH            => 1,
          C_AD_OFFSET           => 0
          )
    port map     (
          CK                    => Clk,
          RST                   => Rst,
          Q                     => Taddr_data_cs_hold_cnt,
          LD                    => Taddr_data_cs_hold_count,
          AD                    => "1",
          LOAD                  => Tdata_hold_load,
          OP                    => Tdata_hold_load_ce
          );
------------------------------------------------------------------------------
-- component instantiation
------------------------------------------------------------------------------
--LD_ARITH_REG_I_MUXED_CNTR5: The max time counter for the write muxed recovery.
------------------------------------------------------------------------------
--This counter enabled the write recovery non-muxed time period data is loaded
--when write recovery muxed signal is asserted.
--The counter is a down counter and will be loaded with initial values.
--The initial value will be loaded from the asynch_cntl level file. these
--values are modified as per the device requirements.
--Once the counter reaches to '1', then assert signal will be activated
--Ulitmately this becomes the max time counter for the next transition to start
------------------------------------------------------------------------------
LD_ARITH_REG_I_MUXED_CNTR5: entity axi_epc_v2_0.ld_arith_reg
    generic map (
          C_ADD_SUB_NOT         => false,
          C_REG_WIDTH           => C_WR_REC_M_CNT_WIDTH,
          C_RESET_VALUE         => WR_MUXED_RECOVERY_CNTR5_RST,
          C_LD_WIDTH            => C_WR_REC_M_CNT_WIDTH,
          C_LD_OFFSET           => 0,
          C_AD_WIDTH            => 1,
          C_AD_OFFSET           => 0
                     )
    port map     (
          CK                    => Clk,
          RST                   => Rst,
          Q                     => Twr_muxed_rec_cnt,
          LD                    => Twr_recovery_muxed_data,
          AD                    => "1",
          LOAD                  => Twr_recovery_load,
          OP                    => Twr_muxed_recovery_load_ce
          );

------------------------------------------------------------------------------
-- component instantiation
------------------------------------------------------------------------------
--LD_ARITH_REG_I_NON_MUXED_CNTR5: The max time counter for the write non-muxed
--                                recovery.
------------------------------------------------------------------------------
--This counter enabled the write recovery non-muxed time period data is loaded
--when write recovery non-muxed signal is asserted.
--The counter is a down counter and will be loaded with initial values.
--The initial value will be loaded from the asynch_cntl level file. these
--values are modified as per the device requirements.
--Once the counter reaches to '1', then assert signal will be activated
--Ulitmately this becomes the max time counter for the next transition to start
------------------------------------------------------------------------------
LD_ARITH_REG_I_NON_MUXED_CNTR5: entity axi_epc_v2_0.ld_arith_reg
    generic map (
          C_ADD_SUB_NOT         => false,
          C_REG_WIDTH           => C_WR_REC_NM_CNT_WIDTH,
          C_RESET_VALUE         => WR_NON_MUXED_RECOVERY_CNTR5_RST,
          C_LD_WIDTH            => C_WR_REC_NM_CNT_WIDTH,
          C_LD_OFFSET           => 0,
          C_AD_WIDTH            => 1,
          C_AD_OFFSET           => 0
                     )
    port map     (
          CK                    => Clk,
          RST                   => Rst,
          Q                     => Twr_non_muxed_rec_cnt,
          LD                    => Twr_recovery_non_muxed_data,
          AD                    => "1",
          LOAD                  => Twr_recovery_load,
          OP                    => Twr_non_muxed_recovery_load_ce
          );
------------------------------------------------------------------------------
-- component instantiation
------------------------------------------------------------------------------
-- LD_ARITH_REG_I_MUXED_CNTR9: This counter is used to measure period for
-- read muxed recovery period
------------------------------------------------------------------------------
--This counter enabled the read recovery muxed time period data is loaded
--when read recovery muxed signal is asserted.
--The counter is a down counter and will be loaded with initial values.
--The initial value will be loaded from the asynch_cntl level file. these
--values are modified as per the device requirements.
--Once the counter reaches to '1', then assert signal will be activated
--Ulitmately this becomes the max time counter for the next transition to start
--LD_ARITH_REG_I_MUXED_CNTR9: The max time counter for the read muxed recovery
-------------------------------------------------------------------------------
LD_ARITH_REG_I_MUXED_CNTR9: entity axi_epc_v2_0.ld_arith_reg
    generic map (
          C_ADD_SUB_NOT         => false,
          C_REG_WIDTH           => C_RD_REC_M_CNT_WIDTH,
          C_RESET_VALUE         => RD_MUXED_RECOVERY_CNTR9_RST,
          C_LD_WIDTH            => C_RD_REC_M_CNT_WIDTH,
          C_LD_OFFSET           => 0,
          C_AD_WIDTH            => 1,
          C_AD_OFFSET           => 0
                     )
    port map     (
          CK                    => Clk,
          RST                   => Rst,
          Q                     => Trd_muxed_rec_cnt,
          LD                    => Trd_recovery_muxed_data,
          AD                    => "1",
          LOAD                  => Trd_recovery_load,
          OP                    => Trd_muxed_recovery_load_ce
          );
------------------------------------------------------------------------------
-- component instantiation
------------------------------------------------------------------------------
-- LD_ARITH_REG_I_NON_MUXED_CNTR9: This counter is used to measure period for
-- read non muxed recovery period
------------------------------------------------------------------------------
--This counter enabled the read recovery non muxed time period data is loaded
--when read recovery non-muxed signal is asserted.
--The counter is a down counter and will be loaded with initial values.
--The initial value will be loaded from the asynch_cntl level file. these
--values are modified as per the device requirements.
--Once the counter reaches to '1', then assert signal will be activated
--Ulitmately this becomes the max time counter for the next transition to start
--LD_ARITH_REG_I_NON_MUXED_CNTR9: The max time counter for the read
--non muxed recovery
-------------------------------------------------------------------------------
LD_ARITH_REG_I_NON_MUXED_CNTR9: entity axi_epc_v2_0.ld_arith_reg
    generic map (
          C_ADD_SUB_NOT         => false,
          C_REG_WIDTH           => C_RD_REC_NM_CNT_WIDTH,
          C_RESET_VALUE         => RD_NON_MUXED_RECOVERY_CNTR9_RST,
          C_LD_WIDTH            => C_RD_REC_NM_CNT_WIDTH,
          C_LD_OFFSET           => 0,
          C_AD_WIDTH            => 1,
          C_AD_OFFSET           => 0
                     )
    port map     (
          CK                    => Clk,
          RST                   => Rst,
          Q                     => Trd_non_muxed_rec_cnt,
          LD                    => Trd_recovery_non_muxed_data,
          AD                    => "1",
          LOAD                  => Trd_recovery_load,
          OP                    => Trd_non_muxed_recovery_load_ce
          );
------------------------------------------------------------------------------
end imp;
------------------------------------------------------------------------------
-- End of async_counters.vhd file
------------------------------------------------------------------------------
