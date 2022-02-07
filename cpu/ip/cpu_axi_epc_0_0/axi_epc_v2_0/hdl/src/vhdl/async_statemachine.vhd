-----------------------------------------------------------------------------
-- async_statemachine.vhd - entity/architecture pair
-----------------------------------------------------------------------------
--
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

-----------------------------------------------------------------------------
-- Filename:      async_statemachine.vhd
-- Version:        v1.00.a
-- Description:    This state machine generates the control signal for --
--                     asynchronous logic of the axi_epc.
-- VHDL-Standard:  VHDL'93
-----------------------------------------------------------------------------
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
-----------------------------------------------------------------------------
-- Author   : VB
-- History  :
--
--  VB           08-24-2010 --  v2_0 version for AXI
-- ^^^^^^
--            The core updated for AXI based on xps_epc_v1_02_a
-- ~~~~~~
-----------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                   "*_n"
--      clock signals:                        "clk", "clk_div#", "clk_#x"
--      reset signals:                        "rst", "rst_n"
--      generics:                             "C_*"
--      user defined types:                   "*_TYPE"
--      state machine next state:             "*_ns"
--      state machine current state:          "*_cs"
--      combinatorial signals:                "*_com"
--      pipelined or register delay signals:  "*_d#"
--      counter signals:                      "*cnt*"
--      clock enable signals:                 "*_ce"
--      internal version of output port       "*_i"
--      device pins:                          "*_pin"
--      ports:                                - Names begin with Uppercase
--      processes:                            "*_PROCESS"
--      component instantiations:             "<ENTITY_>I_<#|FUNC>
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.conv_std_logic_vector;

library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.RESET_ACTIVE;

-----------------------------------------------------------------------------
-- Definition of Ports:
-----------------------------------------------------------------------------
-- Definition of Generics
-----------------------------------------------------------------------------
--C_ADDR_TH_CNT_WIDTH           -- Address hold counter width generic
--C_ADDR_DATA_CS_TH_CNT_WIDTH   -- Address,Data,Chip Select hold width generic
--C_CONTROL_CNT_WIDTH           -- Control width generic
--C_DEV_VALID_CNT_WIDTH         -- Device valid counter width generic
--C_DEV_RDY_CNT_WIDTH           -- Device ready counter width generic
--C_ADS_CNT_WIDTH               -- Address strobe counter width generic
--C_WR_REC_CNT_WIDTH            -- Write recovery counter width generic
--C_RD_REC_CNT_WIDTH            -- Read Recovery counter width generic
--C_NUM_PERIPHERALS             -- Number of external peripherals
-----------------------------------------------------------------------------
--      --Inputs
-----------------------------------------------------------------------------
--  BUS2IP_CS                   -- BUS-to-IP chip select
--  BUS2IP_RNW                  -- BUS-to-IP Read/Write control signal
--  Asynch_rd_req               -- asynch read request
--  Asynch_wr_req               -- asynch write request
--  Dev_in_access               -- Device in access mode with chip-select
--  Dev_FIFO_access             -- Device FIFO access
--  Asynch_prh_rdy              -- Asynch peripheral ready for communication
--  Dev_dwidth_match            -- peripheral device data width match
--  Dev_dbus_width              -- peripheral device data width
--  Dev_bus_multiplexed         -- peripheral device addr-data bus muxed
--  Asynch_cycle                -- Indication of current cycle of Asynch mode
-----------------------------------------------------------------------------
--  -- outputs
-----------------------------------------------------------------------------
-- *_load command to load the value in the counter
--    Taddr_hold_load           -- address hold counter load
--    Tdata_hold_load           -- data hold counter load
--    Tdev_valid_load           -- device validity check counter
--    Tdev_rdy_load             -- peripheral device ready counter load
--    Tcontrol_load             -- control width cntr load(in asserted state)
--    Tads_load                 -- address strobe counter load
--    Trd_recovery_load         -- read recovery counter load
--    Twr_recovery_load         -- write recovery counter load

-- *_load_ce command to start the counter operation
--    Taddr_hold_load_ce       -- address hold counter start
--    Tdata_hold_load_ce       -- data hold up counter start
--    Tcontrol_load_ce         -- control width counter start
--    Tdev_valid_load_ce       -- device validity counter start
--    Tdev_rdy_load_ce         -- device ready counter start
--    Tads_load_ce             -- address strobe counter start
--    Twr_recovery_load_ce     -- Write recovery counter start
--    Trd_muxed_recovery_load_ce     -- Read recovery counter start

--    Asynch_Rd                -- asynch read
--    Asynch_en                -- Asynch enable to latch the rd/wr cycle data
--    Asynch_Wr                -- asynch write
--    Asynch_addr_strobe       -- Address Address Latch Signal(Strobe)
--    Asynch_addr_data_sel     -- Address/Data selector
--    Asynch_data_sel          -- asynch data select mode
--    Asynch_chip_select       -- Asynch chip select
--    Asynch_addr_cnt_ld       -- asynch address latch load/Reset
--    Asynch_addr_cnt_en       -- asynch address latch enable
--    Asynch_Wrack             -- asynchronous write acknowledge
--    Asynch_Rdack             -- asynchronous read acknowledge
--    Asynch_error         -- error acknowledge
--    -- Clocks and reset
--    Clk
--    Rst
-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------
entity async_statemachine is
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
      C_RD_REC_M_CNT_WIDTH            : integer;
      C_NUM_PERIPHERALS               : integer
      );
port (
  -- inputs form asynch_cntl
     Bus2IP_CS               : in std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     Bus2IP_RNW              : in std_logic;

     Asynch_rd_req                 : in std_logic;
     Asynch_wr_req                 : in std_logic;
     Dev_in_access                 : in std_logic;
     Dev_FIFO_access               : in std_logic;
     Asynch_prh_rdy                : in std_logic;
  -- inputs from top_level_file
     Dev_dwidth_match              : in std_logic;
     Dev_bus_multiplexed           : in std_logic;
  -- input from IPIF
  -- input from data steering logic
     Asynch_cycle                  : in std_logic;
  -- outputs to IPIF
     Asynch_Wrack                  : out std_logic;
     Asynch_Rdack                  : out std_logic;
     Asynch_error                  : out std_logic;
     Asynch_start                  : out std_logic;
  -- outputs to counters
     Taddr_hold_load               : out std_logic;
     Tdata_hold_load               : out std_logic;
     Tdev_valid_load               : out std_logic;
     Tdev_rdy_load                 : out std_logic;
     Tcontrol_load                 : out std_logic;
     Tads_load                     : out std_logic;
     Twr_recovery_load             : out std_logic;
     Trd_recovery_load             : out std_logic;

     Taddr_hold_load_ce            : out std_logic;
     Tdata_hold_load_ce            : out std_logic;
     Tcontrol_load_ce              : out std_logic;
     Tdev_valid_load_ce            : out std_logic;
     Tdev_rdy_load_ce              : out std_logic;
     Tads_load_ce                  : out std_logic;
     Twr_muxed_recovery_load_ce    : out std_logic;
     Trd_muxed_recovery_load_ce    : out std_logic;
     Twr_non_muxed_recovery_load_ce: out std_logic;
     Trd_non_muxed_recovery_load_ce: out std_logic;
  -- output to data_steering_logic file
     Asynch_Rd             : out std_logic;
     Asynch_en             : out std_logic;
     Asynch_Wr             : out std_logic;
     Asynch_addr_strobe    : out std_logic;
     Asynch_addr_data_sel  : out std_logic;
     Asynch_data_sel       : out std_logic;
     Asynch_chip_select    : out std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     Asynch_addr_cnt_ld    : out std_logic;
     Asynch_addr_cnt_en    : out std_logic;

     Taddr_hold_cnt        : in std_logic_vector(0 to C_ADDR_TH_CNT_WIDTH-1);
     Tcontrol_wdth_cnt     : in std_logic_vector(0 to C_CONTROL_CNT_WIDTH-1);
     Tdevrdy_wdth_cnt      : in std_logic_vector(0 to C_DEV_RDY_CNT_WIDTH-1);

     Twr_muxed_rec_cnt     : in std_logic_vector(0 to C_WR_REC_M_CNT_WIDTH-1);
     Trd_muxed_rec_cnt     : in std_logic_vector(0 to C_RD_REC_M_CNT_WIDTH-1);
     Twr_non_muxed_rec_cnt : in std_logic_vector(0 to C_WR_REC_NM_CNT_WIDTH-1);
     Trd_non_muxed_rec_cnt : in std_logic_vector(0 to C_RD_REC_NM_CNT_WIDTH-1);

     Tdev_valid_cnt        : in std_logic_vector(0 to C_DEV_VALID_CNT_WIDTH-1);
     Tads_cnt              : in std_logic_vector(0 to C_ADS_CNT_WIDTH-1);
     Taddr_data_cs_hold_cnt: in std_logic_vector
                                          (0 to C_ADDR_DATA_CS_TH_CNT_WIDTH-1);
  -- Clocks and reset
     Clk                     : in  std_logic;
     Rst                     : in  std_logic
    );
end entity async_statemachine;
-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------
architecture imp of async_statemachine is
-- all outputs temp signals
signal taddr_hold_load_i        : std_logic;
signal tdev_valid_load_i        : std_logic;
signal tdev_rdy_load_i          : std_logic;
signal tads_load_i              : std_logic;
--signal tdata_hold_load_i        : std_logic;
signal tcontrol_load_i          : std_logic;
signal twr_recovery_load_i      : std_logic;
signal trd_recovery_load_i      : std_logic;

signal taddr_hold_load_ce_i     : std_logic;
signal tdata_hold_load_ce_i     : std_logic;
signal tcontrol_load_ce_i       : std_logic;
signal tdev_valid_load_ce_i     : std_logic;
signal tdev_rdy_load_ce_i       : std_logic;
signal tads_load_ce_i           : std_logic;

signal twr_muxed_recovery_ld_ce_i     : std_logic;
signal trd_muxed_recovery_ld_ce_i     : std_logic;
signal trd_non_muxed_recovery_ld_ce_i : std_logic;
signal twr_non_muxed_recovery_ld_ce_i : std_logic;

signal asynch_Rd_i              : std_logic;
signal asynch_en_i              : std_logic;-- this signal latches the data
                                        --at every read and write operation
signal asynch_Wr_i              : std_logic;
signal asynch_addr_strobe_i     : std_logic;
signal asynch_addr_data_sel_i   : std_logic;
signal asynch_chip_select_i     : std_logic;
signal asynch_chip_select_n     : std_logic_vector(0 to C_NUM_PERIPHERALS-1);
signal asynch_addr_cnt_ld_i     : std_logic;
signal asynch_addr_cnt_en_i     : std_logic;

signal asynch_Wrack_i           : std_logic;
signal asynch_Rdack_i           : std_logic;
signal asynch_error_i           : std_logic;

signal asynch_start_i           : std_logic;--start of asynch cycle
signal data_sel                 : std_logic;--asynch address phase indicator
signal asynch_data_sel_i        : std_logic;

-- The counter will start decrementing the value loaded, at the next clock. so,
-- here one clock is required to start decrementing the counter. To maintain the
-- exact count, the final value of the counter is set to '1' instaed of '0'.
constant ADDR_TH_CNTR2_END:
          std_logic_vector(0 to C_ADDR_TH_CNT_WIDTH-1)
          := conv_std_logic_vector(1,C_ADDR_TH_CNT_WIDTH);
-- control hold end count
constant CONTROL_TH_CNTR3_END:
          std_logic_vector(0 to C_CONTROL_CNT_WIDTH-1)
          := conv_std_logic_vector(1,C_CONTROL_CNT_WIDTH);
-- dev rdy pulse width end count
constant DEV_RDY_CNTR4_END:
          std_logic_vector(0 to C_DEV_RDY_CNT_WIDTH-1)
          := conv_std_logic_vector(1,C_DEV_RDY_CNT_WIDTH);
-- data set up pulse width
constant DEV_VALID_CNTR7_END
          : std_logic_vector(0 to C_DEV_VALID_CNT_WIDTH-1)
          := conv_std_logic_vector(1,C_DEV_VALID_CNT_WIDTH);
-- address strobe counter end value
constant ADS_CNTR8_END
          : std_logic_vector(0 to C_ADS_CNT_WIDTH-1)
          := conv_std_logic_vector(1,C_ADS_CNT_WIDTH);

-- address,data, chip select hold width
constant ADDR_DATA_CS_TH_CNTR12_END:
          std_logic_vector(0 to C_ADDR_DATA_CS_TH_CNT_WIDTH-1)
          := conv_std_logic_vector(1,C_ADDR_DATA_CS_TH_CNT_WIDTH);

-- read recovery pulse width end count

constant RD_MUXED_RECOVERY_CNTR9_END:
          std_logic_vector(0 to C_RD_REC_M_CNT_WIDTH-1)
          := conv_std_logic_vector(1,C_RD_REC_M_CNT_WIDTH);

constant RD_NON_MUXED_RECOVERY_CNTR9_END:
          std_logic_vector(0 to C_RD_REC_NM_CNT_WIDTH-1)
          := conv_std_logic_vector(1,C_RD_REC_NM_CNT_WIDTH);
-- write recovery pulse width end count
constant WR_MUXED_RECOVERY_CNTR5_END:
          std_logic_vector(0 to C_WR_REC_M_CNT_WIDTH-1)
          := conv_std_logic_vector(1,C_WR_REC_M_CNT_WIDTH);

constant WR_NON_MUXED_RECOVERY_CNTR5_END:
          std_logic_vector(0 to C_WR_REC_NM_CNT_WIDTH-1)
          := conv_std_logic_vector(1,C_WR_REC_NM_CNT_WIDTH);


-----------------------------------------------------------------------------
-- type declaration
type INTEGER_ARRAY is array (natural range <>) of integer;
-----------------------------------------------------------------------------
type COMMAND_STATE_TYPE is (
            IDLE,DUMMY_ADS,START_STATE,
            DUMMY_ST,
            ADS_ASSERT,             -- address set up time/ strobe time
            NM_CONTROL_ASSERT,      -- non-muxed control assert
            M_CONTROL_ASSERT,       -- muxed control assert
            DEV_VALID,              -- device valid in non-mux case
            DEV_RDY,                -- device ready check in non-mux case
            DEV_VALID_M,            -- device valid check in muxed case
            DEV_RDY_M,              -- multiplexed device ready check state
            CONTROL_DEASSERT,       -- control deassert
            ACK_GEN_NON_MUXED,      -- non-muxed acknowledge generation
            ACK_GEN_MUXED,          -- muxed acknowledge generation
            WR_MUXED_RECOVERY,      -- muxed write recovery
            WR_NON_MUXED_RECOVERY,  -- non muxed write recovery
            RD_MUXED_RECOVERY,      -- muxed read recovery
            RD_NON_MUXED_RECOVERY   -- non muxed read recovery
            );
signal command_ns        : COMMAND_STATE_TYPE;
signal command_cs        : COMMAND_STATE_TYPE;
-----------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
-- COMMAND_ASYNCH_REG: process for asynch state next state flip-flop logic
-------------------------------------------------------------------------------
COMMAND_ASYNCH_REG: process (Clk)
begin
    if (Clk'event and Clk = '1') then
        if (Rst = RESET_ACTIVE) then
            command_cs <= IDLE;
        else
            command_cs <= command_ns;
        end if;
    end if;
end process COMMAND_ASYNCH_REG;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- CMB_ASYNCH_PROCESS
-----------------------------------------------------------------------------
-- This process generates the control signals, which will communicate with
-- other part of logic. The control signals include write, read, acknowledge,
-- error acknowledge and variouos load enable signals for the epc_counter.vhd
-----------------------------------------------------------------------------
CMB_ASYNCH_PROCESS: process (
          command_cs,
          Dev_in_access,
          Dev_FIFO_access,
          Asynch_rd_req,
          Asynch_wr_req,
          Asynch_prh_rdy,
          Asynch_cycle,
          Dev_dwidth_match,
          Dev_bus_multiplexed,
          Taddr_hold_cnt,
          Tcontrol_wdth_cnt,
          Tdevrdy_wdth_cnt,
          Twr_muxed_rec_cnt,
          Trd_muxed_rec_cnt,
          Twr_non_muxed_rec_cnt,
          Trd_non_muxed_rec_cnt,
          Tdev_valid_cnt,
          Tads_cnt,
          Taddr_data_cs_hold_cnt
          )
begin
--- default signal conditions
        --these signals are activated only for single clock cycle
        asynch_Wrack_i          <= '0';
        asynch_Rdack_i          <= '0';
        asynch_error_i          <= '0';

        asynch_start_i          <= '0';
        asynch_addr_cnt_en_i    <= '0';
        asynch_addr_cnt_ld_i    <= '0';
        asynch_addr_data_sel_i  <= '0';
        asynch_addr_strobe_i    <= '0';
        asynch_chip_select_i    <= '1';
        data_sel                <= '0';
        asynch_en_i             <= '0';
        asynch_wr_i             <= '0';
        asynch_rd_i             <= '0';

        tads_load_ce_i          <= '0';
        taddr_hold_load_ce_i    <= '0';
        tcontrol_load_ce_i      <= '0';
        tdev_valid_load_ce_i    <= '0';
        tdata_hold_load_ce_i    <= '0';
        tdev_rdy_load_ce_i      <= '0';

        trd_muxed_recovery_ld_ce_i    <= '0';
        twr_muxed_recovery_ld_ce_i    <= '0';
        trd_non_muxed_recovery_ld_ce_i<= '0';
        twr_non_muxed_recovery_ld_ce_i<= '0';

        taddr_hold_load_i       <= '0';
        tdev_valid_load_i       <= '0';
        tdev_rdy_load_i         <= '0';
        tads_load_i             <= '0';
        command_ns              <= IDLE;

        tcontrol_load_i         <= '0';
        trd_recovery_load_i     <= '0';
        twr_recovery_load_i     <= '0';
       asynch_addr_cnt_ld_i     <= '0';
case command_cs is
-------------------------- IDLE --------------------------
-------------------------- IDLE --------------------------
 when IDLE =>
 -- Determines the conditional signal generation

        -- the counters should be loaded with the final value always
        -- these counters are downcounters
        taddr_hold_load_i        <= '1';
        tdev_valid_load_i        <= '1';
        tdev_rdy_load_i          <= '1';
        tads_load_i              <= '1';

        tcontrol_load_i          <= '1';
        twr_recovery_load_i      <= '1';
        trd_recovery_load_i      <= '1';

        asynch_wr_i              <= '0';
        asynch_rd_i              <= '0';
        asynch_en_i              <= '0';
        asynch_addr_strobe_i     <= '0';
        asynch_addr_data_sel_i   <= '0';
        data_sel                 <= '0';
        asynch_chip_select_i     <= '1';
        asynch_addr_cnt_ld_i     <= '1';--reset signal for cntr load
-- check if access is given and if the device is multiplexed.
-- if yes, start the address load signal. this will initialize the address
-- counter and jump to START_STATE
 if(Dev_in_access='1')then
    if (Asynch_rd_req = '1' or Asynch_wr_req = '1') then
         asynch_chip_select_i     <= '1';
         if (Dev_bus_multiplexed= '1') then
             asynch_addr_data_sel_i  <= '1';
         else
             asynch_addr_data_sel_i  <= '0';
         end if;
        command_ns         <= START_STATE;
    else
        command_ns         <= IDLE;
    end if;
else
        command_ns         <= IDLE;
end if;

-- START_STATE -- from this state onwards start the proper execution of core.
-- enable the following signals : address strobe, chip select, asynch start,
--                                asynch cntr,    address select signals

when START_STATE =>
    asynch_chip_select_i     <= '0';
    asynch_start_i           <= '1';
    if (Dev_bus_multiplexed= '1') then
        tdev_valid_load_ce_i    <= '1';-- start the device valid counter
        tdev_rdy_load_ce_i      <= '1';-- start the device max wait time countr
        asynch_addr_data_sel_i  <= '1';
        command_ns              <= DEV_VALID_M;
    else
        tads_load_ce_i          <= '1';
        command_ns              <= NM_CONTROL_ASSERT;
    end if;

-- below is non multiplexed part of the code...
-------------------------------------------------------------------------------
-- NM_CONTROL_ASSERT -> Generates the write/read control signal in non-mxed mode
-- It will check for the address hold counter to be over.
-- If the address hold cntr is asserted then the "address data select"
-- line will indicate the data phase.
-- Also starts device valid and device ready counter
-------------------------------------------------------------------------------
when NM_CONTROL_ASSERT =>
         asynch_chip_select_i     <= '0';
         tads_load_ce_i           <= '1';
         if(Tads_cnt = ADS_CNTR8_END)then
              tads_load_ce_i       <= '0';
              asynch_wr_i          <= Asynch_wr_req;
              asynch_rd_i          <= Asynch_rd_req;
              data_sel                <= '1';
              tdev_valid_load_ce_i    <= '1';
              tdev_rdy_load_ce_i      <= '1';
              command_ns              <= DEV_VALID;
         else
              command_ns              <= NM_CONTROL_ASSERT;
         end if;
-------------------------- DEV_VALID --------------------------
-- DEV_VALID -> Decides the state of the device.if the device is in valid state
-- then further communication with the device starts
-- If the device does not respond with in the given time, then state machine
-- will enter into the device ready check state.In the device ready check state
-- the design will wait till the end of device ready period. else the
-- communication is abruptly terminated and the
-- state machine will reset to IDLE state.
when DEV_VALID=>

         asynch_chip_select_i    <= '0';
         data_sel                <= '1';
         asynch_wr_i             <= Asynch_wr_req;
         asynch_rd_i             <= Asynch_rd_req;
         tdev_valid_load_ce_i    <= '1';
         tdev_rdy_load_ce_i      <= '1';
        if ((Tdev_valid_cnt = DEV_VALID_CNTR7_END)) then
             tdev_valid_load_ce_i  <= '0';
             --asynch_en_i           <= Asynch_prh_rdy;
             tdev_rdy_load_ce_i    <= '1';
             command_ns            <= DEV_RDY;
         else
             command_ns            <= DEV_VALID;
         end if;

-- DEV_RDY : is meant for confirmation that the device is ready
when DEV_RDY=>

         asynch_chip_select_i    <= '0';
         data_sel                <= '1';
         asynch_wr_i             <= Asynch_wr_req;
         asynch_rd_i             <= Asynch_rd_req;
         tdev_rdy_load_ce_i      <= '1';
         taddr_hold_load_i       <= '1';
        if (Asynch_prh_rdy='1') then
            asynch_en_i          <= '1';
            tcontrol_load_ce_i   <= '1';
            command_ns           <= CONTROL_DEASSERT;
        elsif((Tdevrdy_wdth_cnt=DEV_RDY_CNTR4_END)and(Asynch_prh_rdy='0'))then
            tdev_rdy_load_ce_i   <= '0';
            asynch_error_i       <= '1';--generate error
            asynch_Wrack_i       <= Asynch_wr_req;--generate wr ack
            asynch_Rdack_i       <= Asynch_rd_req;--generate rd ack
            asynch_chip_select_i <= '1';--deactivate chip select

            asynch_wr_i          <= '0';--deactivate control signal
            asynch_rd_i          <= '0';--deactivate control signal
            command_ns           <= IDLE;
        else
            command_ns           <= DEV_RDY;
        end if;

-------------------------- CONTROL_DEASSERT --------------------------
-- Deactivates the control signal depending upon the assertion of the signals
-- from the epc_counter.vhd. this is common state for mux and non-mux design.
-- starts the chip select deasert counter.
when CONTROL_DEASSERT =>
         asynch_chip_select_i   <= '0';
         data_sel               <= '1';
         asynch_en_i            <= '1';
         asynch_wr_i            <= Asynch_wr_req;
         asynch_rd_i            <= Asynch_rd_req;
         tcontrol_load_ce_i     <= '1';
        if((Tcontrol_wdth_cnt=CONTROL_TH_CNTR3_END)) then 
            tcontrol_load_ce_i  <= '0';
            tdata_hold_load_ce_i<= '1';
            asynch_wr_i         <= '0';
            asynch_rd_i         <= '0';
            asynch_en_i         <= '0';
            if(Dev_bus_multiplexed= '1') then
            --    asynch_en_i     <= '1';
                command_ns      <= ACK_GEN_MUXED;
            else
            --  asynch_en_i     <= '0';
                command_ns      <= ACK_GEN_NON_MUXED;
            end if;
        else
            command_ns          <= CONTROL_DEASSERT;
        end if;

--  ACK_GEN_NON_MUXED  -------------------------------
when ACK_GEN_NON_MUXED =>

         asynch_chip_select_i     <= '0';
         tdata_hold_load_ce_i     <= '1';
         data_sel                 <= '1';

         tdev_valid_load_i        <= '1';--load the device valid counter
         tads_load_i              <= '1';--load the ads counter
         trd_recovery_load_i      <= '1';--load the rd recovery cntr
         twr_recovery_load_i      <= '1';--load the wr recovery counter
         tcontrol_load_i          <= '1';--load the control width counter

         if(Taddr_data_cs_hold_cnt =  ADDR_DATA_CS_TH_CNTR12_END) then
                tdata_hold_load_ce_i <= '0';
                if(Asynch_cycle = '1' and Dev_dwidth_match = '1') then
                        asynch_addr_cnt_en_i  <= '1';
                        data_sel              <= '0';
                else
                        asynch_addr_cnt_en_i  <= '0';
                        asynch_Wrack_i        <= Asynch_wr_req;
                        asynch_Rdack_i        <= Asynch_rd_req;
                        data_sel              <= '0';
                end if;
                if(Asynch_wr_req = '1') then
                    twr_non_muxed_recovery_ld_ce_i <= '1';
                    command_ns                     <= WR_NON_MUXED_RECOVERY;
                elsif(Asynch_rd_req = '1') then
                    trd_non_muxed_recovery_ld_ce_i <= '1';
                    command_ns                     <= RD_NON_MUXED_RECOVERY;
                end if;
        else
                command_ns                         <= ACK_GEN_NON_MUXED;
        end if;

-- READ NON-MUXED RECOVERY state ->  this is the recovery period between 
----------------------------------  two consecutive reads in non-mux mode
when RD_NON_MUXED_RECOVERY =>
         trd_non_muxed_recovery_ld_ce_i <= '1';
         asynch_chip_select_i           <= '0';
         if (Trd_non_muxed_rec_cnt = RD_NON_MUXED_RECOVERY_CNTR9_END) then
                trd_non_muxed_recovery_ld_ce_i  <= '0';
                if(Asynch_cycle = '1' and Dev_dwidth_match = '1') then
                        asynch_chip_select_i    <= '0';
                        tads_load_ce_i          <= '1';
                        command_ns              <= NM_CONTROL_ASSERT;
                else
                        command_ns              <= IDLE;
                end if;
         else
            command_ns               <= RD_NON_MUXED_RECOVERY;
         end if;

-- WR_NON_MUXED_RECOVERY : this is the recovery period between two consecutive
------------------------   writes in non-mux mode
when WR_NON_MUXED_RECOVERY =>
         twr_non_muxed_recovery_ld_ce_i <= '1';
         asynch_chip_select_i           <= '0';
         if (Twr_non_muxed_rec_cnt = WR_NON_MUXED_RECOVERY_CNTR5_END) then
                twr_non_muxed_recovery_ld_ce_i  <= '0';
                if(Asynch_cycle = '1' and Dev_dwidth_match = '1') then
                        asynch_chip_select_i    <= '0';
                        tads_load_ce_i          <= '1';
                        command_ns              <=NM_CONTROL_ASSERT;
                else
                        command_ns              <= IDLE;
                end if;
         else
                command_ns                    <= WR_NON_MUXED_RECOVERY;
         end if;

-- below is part of multiplexed code
------------------------------------
-------------------------------------------------------------------------------
-- if the address set up counter ends then check whether strobe counter width
-- is over, then the address strobe signal is deasserted and address hold sgnl
-- is enabled.
when ADS_ASSERT =>

         asynch_addr_data_sel_i     <= '1';
         asynch_addr_strobe_i       <= '1';
         asynch_chip_select_i       <= '0';
         tads_load_ce_i             <= '1';
         if(Tads_cnt = ADS_CNTR8_END)then
            tads_load_ce_i       <= '0';
            asynch_addr_strobe_i <= '0';

            command_ns           <= DUMMY_ADS;
         else
            command_ns           <= ADS_ASSERT;
         end if;
-----------------------------------------------
when DUMMY_ADS =>
         asynch_addr_data_sel_i <= '0';
         asynch_chip_select_i   <= '0';
         taddr_hold_load_ce_i   <= '1';
         command_ns             <= M_CONTROL_ASSERT;

-- M_CONTROL_ASSERT state -> this state generates the multiplexed control sign
-- al
when M_CONTROL_ASSERT =>

         asynch_addr_data_sel_i <= '0';
         asynch_chip_select_i   <= '0';
         taddr_hold_load_ce_i   <= '1';
         if((Taddr_hold_cnt = ADDR_TH_CNTR2_END))then
            asynch_wr_i             <= Asynch_wr_req;
            asynch_rd_i             <= Asynch_rd_req;
            asynch_addr_data_sel_i  <= '0';

            taddr_hold_load_ce_i    <= '0';
            data_sel                <= '1';
            
            if(Asynch_wr_req = '1') then
                asynch_en_i         <= '1';
                tcontrol_load_ce_i  <= '1';
                command_ns          <= CONTROL_DEASSERT;
            elsif(Asynch_rd_req = '1') then
                 command_ns         <= DUMMY_ST;
            end if;
            
         else
            command_ns              <= M_CONTROL_ASSERT;
         end if;

---------------------------------------------------------
when DUMMY_ST =>
         asynch_chip_select_i    <= '0';
         asynch_wr_i             <= Asynch_wr_req;
         asynch_rd_i             <= Asynch_rd_req;
         asynch_en_i             <= '1';
         tcontrol_load_ce_i      <= '1';
         data_sel                <= '1';
         command_ns              <= CONTROL_DEASSERT;         

------------------------------------------------------------------------------

when ACK_GEN_MUXED =>

         asynch_chip_select_i <= '0';
         tdata_hold_load_ce_i <= '1';
         data_sel             <= '1';

         tads_load_i          <= '1';
         tdev_valid_load_i    <= '1';
         trd_recovery_load_i  <= '1';
         twr_recovery_load_i  <= '1';
         tcontrol_load_i      <= '1';
         taddr_hold_load_i    <= '1';

         if(Taddr_data_cs_hold_cnt =  ADDR_DATA_CS_TH_CNTR12_END) then
            tdata_hold_load_ce_i     <= '0';
            if(Asynch_cycle = '1' and Dev_dwidth_match = '1') then
              data_sel               <= '0';
            else
              asynch_addr_cnt_en_i   <= '0';
              asynch_Wrack_i         <= Asynch_wr_req;
              asynch_Rdack_i         <= Asynch_rd_req;
              data_sel               <= '0';
              --asynch_chip_select_i<= not(Dev_FIFO_access);
            end if;
            if(Asynch_wr_req = '1') then
              twr_muxed_recovery_ld_ce_i <= '1';
              command_ns                 <= WR_MUXED_RECOVERY;
            elsif(Asynch_rd_req = '1') then
              trd_muxed_recovery_ld_ce_i <= '1';
              command_ns                 <= RD_MUXED_RECOVERY;
            end if;
            tads_load_i              <= '1';

         else
            command_ns                <= ACK_GEN_MUXED;
         end if;

-- RD_MUXED_RECOVERY STATE ->
-- Determines the recovery time of the transaction
-- Depending upon the data width, will jump to the idle state or,
-- will generate the next write/read cycles and at the end generates
-- acknowledge to IPIF.

-- READ MUXED RECOVERY
-----------------------
when RD_MUXED_RECOVERY =>

         trd_muxed_recovery_ld_ce_i     <= '1';
         asynch_chip_select_i           <= '0';

         if (Trd_muxed_rec_cnt = RD_MUXED_RECOVERY_CNTR9_END) then
            trd_muxed_recovery_ld_ce_i  <= '0';
            if(Asynch_cycle = '1' and Dev_dwidth_match = '1') then
                if(Dev_FIFO_access = '1') then
                  taddr_hold_load_ce_i   <= '1';
                  asynch_addr_cnt_en_i   <= '1';
                  command_ns             <= M_CONTROL_ASSERT;
                else
                  tdev_rdy_load_ce_i     <= '1';
                  tdev_valid_load_ce_i   <= '1';
                  asynch_addr_cnt_en_i   <= '1';
                  asynch_addr_data_sel_i <= '1';
                  command_ns             <= DEV_VALID_M;
                end if;
            else
               command_ns               <= IDLE;
            end if;
         else
            command_ns     <= RD_MUXED_RECOVERY;
         end if;

-- These are muxed and non muxed write recovery states. Depending upon the
-- configured device mux and non mux property, particular state will be
-- executed.

-- WR_MUXED_RECOVERY
--------------------
when WR_MUXED_RECOVERY =>

         twr_muxed_recovery_ld_ce_i     <= '1';
         asynch_chip_select_i           <= '0';

         if (Twr_muxed_rec_cnt = WR_MUXED_RECOVERY_CNTR5_END) then
            twr_muxed_recovery_ld_ce_i  <= '0';
            if(Asynch_cycle = '1' and Dev_dwidth_match = '1') then
                if(Dev_FIFO_access = '1') then
                  taddr_hold_load_ce_i     <= '1';
                  asynch_addr_cnt_en_i     <= '1';
                  command_ns               <= M_CONTROL_ASSERT;
                else
                  tdev_rdy_load_ce_i       <= '1';
                  tdev_valid_load_ce_i     <= '1';
                  asynch_addr_cnt_en_i     <= '1';
                  asynch_addr_data_sel_i   <= '1';
                  command_ns               <= DEV_VALID_M;
                end if;
            else
                command_ns               <= IDLE;
            end if;
         else
            command_ns   <= WR_MUXED_RECOVERY;
         end if;

-- DEV_VALID_M state : In case of multiplexing logic, check first if the device
-- is ready for communication. this is required as the same data lines carry the
-- address (in initial phase) and data (in later phase). the external device
-- should register the address first before the lines swith over to data.
-- this is confirm check for device ready signal.
when DEV_RDY_M =>
       asynch_addr_data_sel_i  <= '1';       --address selection on common line
       asynch_chip_select_i    <= '0';       --assert chip select
       tdev_rdy_load_ce_i      <= '1';       --device ready max time counter
                                               --active signal
       if(Asynch_prh_rdy='1') then
            asynch_addr_strobe_i <= '1';--enable address strobe sig
            tads_load_ce_i       <= '1';--start the ads counter
            tdev_rdy_load_ce_i   <= '0';-- deactivate the dev max
                                                   -- time cntr,as its not
                                                   -- required now
            command_ns           <= ADS_ASSERT;

       elsif((Tdevrdy_wdth_cnt=DEV_RDY_CNTR4_END)and(Asynch_prh_rdy='0'))then
            tdev_rdy_load_ce_i      <= '0'; -- deactivate the dev max time cntr
            asynch_error_i          <= '1';          --generate error
            asynch_Wrack_i          <= Asynch_wr_req;--generate wr ack
            asynch_Rdack_i          <= Asynch_rd_req;--generate rd ack
            asynch_chip_select_i    <= '1';          --deactivate chip select
            command_ns              <= IDLE;
       else
            command_ns              <= DEV_RDY_M;
       end if;

-- DEV_VALID_M: This state validates the readiness of the device in multiplexing
-- mode
when DEV_VALID_M =>
         asynch_addr_data_sel_i  <= '1';    --address selection on common line
         asynch_chip_select_i    <= '0';    --assert chip select
         tdev_valid_load_ce_i    <= '1';    --dev valid counter is active till
                                            --the counter exits and the
                                            --external device is not ready
         tdev_rdy_load_ce_i      <= '1';    --device ready max time counter
                                            --active signal
         -- the below condition checks that the device valid counter has ended
         -- when the device is not ready
        if((Tdev_valid_cnt = DEV_VALID_CNTR7_END)or(Asynch_prh_rdy='1')) then
                tdev_valid_load_ce_i     <= '0';--deactive dev valid counter
                tdev_rdy_load_ce_i   <= '1';
                command_ns           <= DEV_RDY_M;
        else
                command_ns           <= DEV_VALID_M;
        end if;
-----------------------------------------------------------------------------
-- coverage off
when others => command_ns   <=IDLE;
-- coverage on
end case;
end process CMB_ASYNCH_PROCESS;

-----------------------------------------------------------------------------
-- NAME: ASYNC_CS_SEL_PROCESS
-----------------------------------------------------------------------------
-- Description: Drives an internal signal (ASYNC_CS_N) from the asynchronous
--              control logic to be used as the chip select for the external
--              peripheral device
-----------------------------------------------------------------------------
ASYNC_CS_SEL_PROCESS: process (Bus2IP_CS,asynch_chip_select_i) is
begin
  asynch_chip_select_n <= (others => '1');
  for i in 0 to C_NUM_PERIPHERALS-1 loop
    if (Bus2IP_CS(i) = '1') then
      asynch_chip_select_n(i) <= not(Bus2IP_CS(i) and 
                                                 (not asynch_chip_select_i));
    end if;
  end loop;
end process ASYNC_CS_SEL_PROCESS;
-----------------------------------------------------------------------------

asynch_data_sel_i <= asynch_addr_data_sel_i or (data_sel and (not BUS2IP_RNW));
-----------------------------------------------------------------------------

REGISTERED_OP: process (Clk)
begin
    if (Clk'event and Clk = '1') then
        Taddr_hold_load_ce              <= taddr_hold_load_ce_i;
        Tdata_hold_load_ce              <= tdata_hold_load_ce_i;
        Tcontrol_load_ce                <= tcontrol_load_ce_i;
        Tdev_valid_load_ce              <= tdev_valid_load_ce_i;
        Tdev_rdy_load_ce                <= tdev_rdy_load_ce_i;
        Tads_load_ce                    <= tads_load_ce_i;

        Twr_muxed_recovery_load_ce      <= twr_muxed_recovery_ld_ce_i;
        Trd_muxed_recovery_load_ce      <= trd_muxed_recovery_ld_ce_i;
        Twr_non_muxed_recovery_load_ce  <= twr_non_muxed_recovery_ld_ce_i;
        Trd_non_muxed_recovery_load_ce  <= trd_non_muxed_recovery_ld_ce_i;

        Asynch_Rd                       <= not(asynch_Rd_i);
        Asynch_Wr                       <= not(asynch_Wr_i);
        Asynch_en                       <= asynch_en_i;
        Asynch_chip_select              <= asynch_chip_select_n;
        Asynch_addr_strobe              <= asynch_addr_strobe_i;
        Asynch_addr_data_sel            <= asynch_addr_data_sel_i;
        Asynch_data_sel                 <= asynch_data_sel_i;
    end if;
end process REGISTERED_OP;
------------------------------------------------------------------------------

Tdata_hold_load                 <= '1';
Tcontrol_load                   <= tcontrol_load_i;
Trd_recovery_load               <= trd_recovery_load_i;
Twr_recovery_load               <= twr_recovery_load_i;
Taddr_hold_load                 <= taddr_hold_load_i;
Tdev_valid_load                 <= tdev_valid_load_i;
Tdev_rdy_load                   <= tdev_rdy_load_i;
Tads_load                       <= tads_load_i;

Asynch_addr_cnt_en              <= asynch_addr_cnt_en_i;
Asynch_addr_cnt_ld              <= asynch_addr_cnt_ld_i;
Asynch_Wrack                    <= asynch_Wrack_i;
Asynch_Rdack                    <= asynch_Rdack_i;
Asynch_error                    <= asynch_error_i;
Asynch_start                    <= asynch_start_i;
end imp;
------------------------------------------------------------------------------
--End of File async_statemachine.vhd
------------------------------------------------------------------------------
