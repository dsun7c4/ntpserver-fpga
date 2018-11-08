------------------------------------------------------------------------------
-- async_cntl.vhd - entity/architecture pair
------------------------------------------------------------------------------
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

------------------------------------------------------------------------------
-- Filename:       async_cntl.vhd
-- Version:        v1.00.a
-- Description:    This is the top level file for "EPC asynch control logic",
--                 includes the logic of generation of asynch logic signals
-- VHDL-Standard:  VHDL'93
------------------------------------------------------------------------------
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
------------------------------------------------------------------------------
-- Author   : VB
-- History  :
--
--  VB           08-24-2010 --  v2_0 version for AXI
-- ^^^^^^
--            The core updated for AXI based on xps_epc_v1_02_a
-- ~~~~~~
------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                 "*_n"
--      clock signals:                      "clk", "clk_div#", "clk_#x"
--      reset signals:                      "rst", "rst_n"
--      generics:                           "C_*"
--      user defined types:                 "*_TYPE"
--      state machine next state:           "*_ns"
--      state machine current state:        "*_cs"
--      combinatorial signals:              "*_com"
--      pipelined or register delay signals:"*_d#"
--      counter signals:                    "*cnt*"
--      clock enable signals:               "*_ce"
--      internal version of output port     "*_i"
--      device pins:                        "*_pin"
--      ports:                              - Names begin with Uppercase
--      processes:                          "*_PROCESS"
--      component instantiations:           "<ENTITY_>I_<#|FUNC>
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.conv_std_logic_vector;
use IEEE.std_logic_misc.and_reduce;
use IEEE.std_logic_misc.or_reduce;

library axi_lite_ipif_v3_0;
library lib_pkg_v1_0;
use axi_lite_ipif_v3_0.ipif_pkg.INTEGER_ARRAY_TYPE;
use lib_pkg_v1_0.lib_pkg.max2;
use lib_pkg_v1_0.lib_pkg.log2;

library unisim;
use unisim.vcomponents.FDRE;


library axi_epc_v2_0;
use axi_epc_v2_0.async_statemachine;
use axi_epc_v2_0.async_counters;
------------------------------------------------------------------------------
-- Definition of Generics:
-----------------------------------------------------------------------------
--PRH_SYNC              --  To check the sync/async type of devices
--NO_PRH_SYNC           --  when = 1 : All the devices are asynchronous
--                      --  when = 0 : All the devices are synchronous
--C_SPLB_NATIVE_DWIDTH  --  PLB Bus Data Width
--C_NUM_PERIPHERALS     --  Number of peripherals present for particular case

--Note: consider x as 0  to C_NUM_PERIPHERALS-1
--C_PRHx_ADDR_TSU       --  Peripherl Device address set up time
--C_PRHx_ADDR_TH        --  Peripherl Device address hold time
--C_PRHx_WRN_WIDTH      --  Peripherl Device write control signal active width
--C_PRHx_DATA_TSU       --  Peripherl Device data set up time
--C_PRHx_RDN_WIDTH      --  Peripherl Device read control signal active width
--C_PRHx_DATA_TOUT      --  Peripherl Device data Data bus(PRH_Data) validity
--                      --  from falling edge of read signal(PRH_Rd_n)
--C_PRHx_DATA_TH        --  Device data bus(PRH_Data) hold with respect to
--                      --  rising edge of write signal(PRH_Wr_n)
--C_PRHx_DATA_TINV      --  Device data bus(PRH_Data) high impedance from
--                      --  rising edge of read (PRH_Rd_n)
--C_PRHx_RDY_TOUT       --  Device ready(PRH_Rdy)validity from the falling
--                      --  edge of read or write (PRH_Rd_n/PRH_Wr_n)
--C_PRHx_RDY_WIDTH      --  Maximum pulse width of device ready (PRH_Rdy)
--                      --  signal
--C_PRHx_ADS_WIDTH      --  Peripherl Device address strobe pulse width time
--C_PRHx_CSN_TSU        --  Peripherl Device chip select set up time
--C_PRHx_CSN_TH         --  Peripherl Device chip select hold time
--C_PRHx_WR_CYCLE       --  Peripherl Device cycle time for consecutive writes
--C_PRHx_RD_CYCLE       --  Peripherl Device cycle time for consecutive reads
--C_BUS_CLOCK_PERIOD_PS --  PLB clock period
--C_MAX_DWIDTH          --  Maximum of data bus width of all peripherals
--C_MAX_PERIPHERALS     --  Number of devices that can be connected

-----------------------------------------------------------------------------
-- Definition of Ports:
------------------------------------------------------------------------------
-- Definition of Input:
--Bus2IP_BE              --  Bus to IP byte enable
--Bus2IP_CS              --  Bus to IP chip select
--Bus2IP_RdCE            --  Bus to IP Read control enable
--Bus2IP_WrCE            --  Bus to IP Write control enable

--IPIC_Asynch_req        --  IPIC Asynch transaction request
--Dev_FIFO_access        --  Device FIFO Accress
--Dev_in_access          --  Device in access cycle

--Asynch_prh_rdy         --  Asynch Mode of Operation of external device
--Dev_dwidth_match       --  Peripherl Device Dwidth Match
--Dev_dbus_width         --  Peripherl Device Data Width
--Dev_bus_multiplexed    --  Peripherl Device address & data bus multiplexed
--Asynch_ce              --  Asynch chip enable
--Clk                    --  Input clock
--Rst                    --  Input Reset signal
-----------------------------------------------------------------------------
-- Definition of Output Ports:
-----------------------------------------------------------------------------
--Asynch_Wrack           -- asynchronous write acknowledge
--Asynch_Rdack           -- asynchronous read acknowledge
--Asynch_error           -- error acknowledge
--Asynch_Wr              --  Asynch write control signal
--Asynch_Rd              --  Asynch read control signal
--Asynch_en              --  Asynch enable to latch the read/write cycle data
--Asynch_addr_strobe     --  Asynch address latch(when bus is muxed)
--Asynch_addr_data_sel   --  Asynch address/data select(when bus is muxed)
--Asynch_chip_select     --  Asynchronous chip select
--Asynch_addr_cnt_ld     --  Asynch counter reset at the start/load for mux access
--Asynch_addr_cnt_en     --  Asynch address counter enable to increment next
-----------------------------------------------------------------------------

entity async_cntl is
  generic (

    PRH_SYNC            : std_logic_vector;
    NO_PRH_ASYNC        : integer;
    C_SPLB_NATIVE_DWIDTH: integer;
    ------------------------------------------
    C_PRH0_ADDR_TSU     : integer;
    C_PRH0_ADDR_TH      : integer;
    C_PRH0_WRN_WIDTH    : integer;
    C_PRH0_DATA_TSU     : integer;
    C_PRH0_RDN_WIDTH    : integer;
    C_PRH0_DATA_TOUT    : integer;
    C_PRH0_DATA_TH      : integer;
    C_PRH0_DATA_TINV    : integer;
    C_PRH0_RDY_TOUT     : integer;
    C_PRH0_RDY_WIDTH    : integer;
    C_PRH0_ADS_WIDTH    : integer;
    C_PRH0_CSN_TSU      : integer;
    C_PRH0_CSN_TH       : integer ;
    C_PRH0_WR_CYCLE     : integer ;
    C_PRH0_RD_CYCLE     : integer ;
     ------------------------------------------
    C_PRH1_ADDR_TSU     : integer ;
    C_PRH1_ADDR_TH      : integer ;
    C_PRH1_WRN_WIDTH    : integer ;
    C_PRH1_DATA_TSU     : integer ;
    C_PRH1_RDN_WIDTH    : integer ;
    C_PRH1_DATA_TOUT    : integer ;
    C_PRH1_DATA_TH      : integer ;
    C_PRH1_DATA_TINV    : integer ;
    C_PRH1_RDY_TOUT     : integer ;
    C_PRH1_RDY_WIDTH    : integer ;
    C_PRH1_ADS_WIDTH    : integer ;
    C_PRH1_CSN_TSU      : integer ;
    C_PRH1_CSN_TH       : integer ;
    C_PRH1_WR_CYCLE     : integer ;
    C_PRH1_RD_CYCLE     : integer ;
    ------------------------------------------
    C_PRH2_ADDR_TSU     : integer ;
    C_PRH2_ADDR_TH      : integer ;
    C_PRH2_WRN_WIDTH    : integer ;
    C_PRH2_DATA_TSU     : integer ;
    C_PRH2_RDN_WIDTH    : integer ;
    C_PRH2_DATA_TOUT    : integer ;
    C_PRH2_DATA_TH      : integer ;
    C_PRH2_DATA_TINV    : integer ;
    C_PRH2_RDY_TOUT     : integer ;
    C_PRH2_RDY_WIDTH    : integer ;
    C_PRH2_ADS_WIDTH    : integer ;
    C_PRH2_CSN_TSU      : integer ;
    C_PRH2_CSN_TH       : integer ;
    C_PRH2_WR_CYCLE     : integer ;
    C_PRH2_RD_CYCLE     : integer ;
    ------------------------------------------
    C_PRH3_ADDR_TSU     : integer ;
    C_PRH3_ADDR_TH      : integer ;
    C_PRH3_WRN_WIDTH    : integer ;
    C_PRH3_DATA_TSU     : integer ;
    C_PRH3_RDN_WIDTH    : integer ;
    C_PRH3_DATA_TOUT    : integer ;
    C_PRH3_DATA_TH      : integer ;
    C_PRH3_DATA_TINV    : integer ;
    C_PRH3_RDY_TOUT     : integer ;
    C_PRH3_RDY_WIDTH    : integer ;
    C_PRH3_ADS_WIDTH    : integer ;
    C_PRH3_CSN_TSU      : integer ;
    C_PRH3_CSN_TH       : integer ;
    C_PRH3_WR_CYCLE     : integer ;
    C_PRH3_RD_CYCLE     : integer ;
    ------------------------------------------
    C_BUS_CLOCK_PERIOD_PS : integer;
    --C_MAX_DWIDTH          : integer;
    C_NUM_PERIPHERALS     : integer;
    C_MAX_PERIPHERALS     : integer
    ------------------------------------------
    );
port (

      Bus2IP_CS           :  in std_logic_vector(0 to C_NUM_PERIPHERALS-1);
      Bus2IP_RdCE         :  in std_logic_vector(0 to C_NUM_PERIPHERALS-1);
      Bus2IP_WrCE         :  in std_logic_vector(0 to C_NUM_PERIPHERALS-1);
      Bus2IP_BE           :  in std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8 -1);
      Bus2IP_RNW          :  in std_logic;

      IPIC_Asynch_req     :  in std_logic;
      Dev_FIFO_access     :  in std_logic;
      Dev_in_access       :  in std_logic;

      Asynch_prh_rdy      :  in std_logic;
      Dev_dwidth_match    :  in std_logic;
      --Dev_dbus_width      :  in std_logic_vector(0 to 2);
      Dev_bus_multiplexed :  in std_logic;
      Asynch_ce           :  in std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8 -1);

      Asynch_Wrack        :  out std_logic;
      Asynch_Rdack        :  out std_logic;
      Asynch_error        :  out std_logic;

      Asynch_Wr           :  out std_logic;
      Asynch_Rd           :  out std_logic;
      Asynch_en           :  out std_logic;

      Asynch_addr_strobe  :  out std_logic;
      Asynch_addr_data_sel:  out std_logic;
      Asynch_data_sel     :  out std_logic;
      Asynch_chip_select  :  out std_logic_vector(0 to C_NUM_PERIPHERALS-1);
      Asynch_addr_cnt_ld  :  out std_logic;
      Asynch_addr_cnt_en  :  out std_logic;
-- Clocks and reset
      Clk                 :  in  std_logic;
      Rst                 :  in  std_logic
      );
end entity async_cntl;
------------------------------------------------------------------------------
architecture imp of async_cntl is

attribute ASYNC_REG : string;

------------------------------------------------------------------------------
-- Function : FindMaxWidth
-- This function is used by all calculations.
-- The main logic behind this function is, the max width of respective
-- parameters will be calculated, based upon whether the device is asynch
-- device or not.If the device is asynch device then only the parameter
-- of the respective array will be taken into consideration for further
-- calculation. The SYNC_ARRAY  will give the clear idea about the
-- type of devices (asynch/sync)

function FindMaxWidth(  no_of_devices  : integer;
                        prh_wait_width : INTEGER_ARRAY_TYPE;
                        sync_vector    : std_logic_vector
                        )
                        return integer is
variable temp_max : integer  := 1;
begin
for i in 0 to (no_of_devices-1) loop
    if sync_vector(i) = '0' then
       temp_max := max2(temp_max,prh_wait_width(i));
    end if;
end loop;
return temp_max;
end function FindMaxWidth;
------------------------------------------------------------------------------
-- Declaration of Constants
------------------------------------------------------------------------------
--ADDRESS HOLD TIME
--This calculation is applicable for devices with MUXed buses
--get the address hold up generics for all the peripherals
--the calculation is done by comparing 1 or C_PRHx_ADDR_TH/C_BUS_CLOCK_PERIOD_PS
--value. this gives precise values of the ADDRx_TH.

constant ADDR_TH0 : integer:=   (C_PRH0_ADDR_TH/C_BUS_CLOCK_PERIOD_PS)+1;
constant ADDR_TH1 : integer:=   (C_PRH1_ADDR_TH/C_BUS_CLOCK_PERIOD_PS)+1;
constant ADDR_TH2 : integer:=   (C_PRH2_ADDR_TH/C_BUS_CLOCK_PERIOD_PS)+1;
constant ADDR_TH3 : integer:=   (C_PRH3_ADDR_TH/C_BUS_CLOCK_PERIOD_PS)+1;

-- convert the generics into the integer to define the width of the counter
constant ADDR_TH0_WIDTH : integer := max2(1,log2(ADDR_TH0+1));
constant ADDR_TH1_WIDTH : integer := max2(1,log2(ADDR_TH1+1));
constant ADDR_TH2_WIDTH : integer := max2(1,log2(ADDR_TH2+1));
constant ADDR_TH3_WIDTH : integer := max2(1,log2(ADDR_TH3+1));

-- to make the width of counter independent of manual calculation
constant ADDR_TH_ARRAY : INTEGER_ARRAY_TYPE(0 to C_MAX_PERIPHERALS-1) :=
(
 ADDR_TH0_WIDTH,
 ADDR_TH1_WIDTH,
 ADDR_TH2_WIDTH,
 ADDR_TH3_WIDTH
);

constant MAX_ADDR_TH_CNT_WIDTH: integer :=
    FindMaxWidth(C_NUM_PERIPHERALS,ADDR_TH_ARRAY,PRH_SYNC);

constant ADDR_HOLD_CNTR0:std_logic_vector(0 to MAX_ADDR_TH_CNT_WIDTH-1)
:= conv_std_logic_vector(ADDR_TH0, MAX_ADDR_TH_CNT_WIDTH);

constant ADDR_HOLD_CNTR1:std_logic_vector(0 to MAX_ADDR_TH_CNT_WIDTH-1)
:= conv_std_logic_vector(ADDR_TH1, MAX_ADDR_TH_CNT_WIDTH);

constant ADDR_HOLD_CNTR2:std_logic_vector(0 to MAX_ADDR_TH_CNT_WIDTH-1)
:= conv_std_logic_vector(ADDR_TH2, MAX_ADDR_TH_CNT_WIDTH);

constant ADDR_HOLD_CNTR3:std_logic_vector(0 to MAX_ADDR_TH_CNT_WIDTH-1)
:= conv_std_logic_vector(ADDR_TH3, MAX_ADDR_TH_CNT_WIDTH);

-- this array stores the values for the adress hold up time for devices
type ADDR_HOLDCNT_ARRAY_TYPE is array (0 to C_MAX_PERIPHERALS-1) of
              std_logic_vector(0 to MAX_ADDR_TH_CNT_WIDTH-1);
constant ADDR_HOLDCNTR_ARRAY : ADDR_HOLDCNT_ARRAY_TYPE :=
  (
  ADDR_HOLD_CNTR0,
  ADDR_HOLD_CNTR1,
  ADDR_HOLD_CNTR2,
  ADDR_HOLD_CNTR3
  );
------------------------------------------------------------------------------
-- CHIP SELECT/DATA HOLD/ADDR HOLD calculation
-- ADDRESS HOLD TIME/DATA HOLD TIME/CHIP SELECT HOLD TIME
-- This calculation is applicable for NON-MUXed Asynch devices
-- This constant is applicable for DATA Hold and Chip Select and Address Hold
-- Time. It is a max of Chip select hold and Data Hold and Address Hold period
-- the calculation is done by comparing 1 or max of C_PRH0_DATA_TH,C_PRH0_CSN_TH
-- and C_PRH0_ADDR_TH divided by C_BUS_CLOCK_PERIOD_PS value.
-- this gives precise values of the ADDRx_TH.

constant ADDR_DATA_CS_TH0 : integer :=
(max2(1,
(max2
(max2(C_PRH0_DATA_TH,C_PRH0_CSN_TH),C_PRH0_ADDR_TH)/C_BUS_CLOCK_PERIOD_PS)+1));

constant ADDR_DATA_CS_TH1 : integer :=
(max2(1,
(max2
(max2(C_PRH1_DATA_TH,C_PRH1_CSN_TH),C_PRH1_ADDR_TH)/C_BUS_CLOCK_PERIOD_PS)+1));

constant ADDR_DATA_CS_TH2 : integer :=
(max2(1,
(max2
(max2(C_PRH2_DATA_TH,C_PRH2_CSN_TH),C_PRH2_ADDR_TH)/C_BUS_CLOCK_PERIOD_PS)+1));

constant ADDR_DATA_CS_TH3 : integer :=
(max2(1,
(max2
(max2(C_PRH3_DATA_TH,C_PRH3_CSN_TH),C_PRH3_ADDR_TH)/C_BUS_CLOCK_PERIOD_PS)+1));

-- convert the generics into the integer to define the width of the counter
constant ADDR_DATA_CS_TH0_WIDTH : integer := max2(1,log2(ADDR_DATA_CS_TH0+1));
constant ADDR_DATA_CS_TH1_WIDTH : integer := max2(1,log2(ADDR_DATA_CS_TH1+1));
constant ADDR_DATA_CS_TH2_WIDTH : integer := max2(1,log2(ADDR_DATA_CS_TH2+1));
constant ADDR_DATA_CS_TH3_WIDTH : integer := max2(1,log2(ADDR_DATA_CS_TH3+1));

-- to make the width of counter independent of manual calculation
-- Pass this array to FindMaxWidth function
constant ADDR_DATA_CS_TH_ARRAY :
        INTEGER_ARRAY_TYPE(0 to C_MAX_PERIPHERALS-1) :=
(
 ADDR_DATA_CS_TH0_WIDTH,
 ADDR_DATA_CS_TH1_WIDTH,
 ADDR_DATA_CS_TH2_WIDTH,
 ADDR_DATA_CS_TH3_WIDTH
);

-- the max value is calculated for those devices, which are asynch type
-- PRH_SYNC will be directly taken from the epc_core.vhd file
constant MAX_ADDR_DATA_CS_TH_CNT_WIDTH: integer :=
FindMaxWidth(C_NUM_PERIPHERALS,ADDR_DATA_CS_TH_ARRAY,PRH_SYNC);

constant ADDR_DATA_CS_HOLD_CNTR0:
    std_logic_vector(0 to MAX_ADDR_DATA_CS_TH_CNT_WIDTH-1)
    := conv_std_logic_vector(ADDR_DATA_CS_TH0, MAX_ADDR_DATA_CS_TH_CNT_WIDTH);

constant ADDR_DATA_CS_HOLD_CNTR1:
    std_logic_vector(0 to MAX_ADDR_DATA_CS_TH_CNT_WIDTH-1)
    := conv_std_logic_vector(ADDR_DATA_CS_TH1, MAX_ADDR_DATA_CS_TH_CNT_WIDTH);

constant ADDR_DATA_CS_HOLD_CNTR2:
    std_logic_vector(0 to MAX_ADDR_DATA_CS_TH_CNT_WIDTH-1)
    := conv_std_logic_vector(ADDR_DATA_CS_TH2, MAX_ADDR_DATA_CS_TH_CNT_WIDTH);

constant ADDR_DATA_CS_HOLD_CNTR3:
    std_logic_vector(0 to MAX_ADDR_DATA_CS_TH_CNT_WIDTH-1)
    := conv_std_logic_vector(ADDR_DATA_CS_TH3, MAX_ADDR_DATA_CS_TH_CNT_WIDTH);

-- this array stores the values for the data hold up time for devices
type ADDR_DATA_HOLD_CNT_ARRAY_TYPE is array (0 to C_MAX_PERIPHERALS-1) of
                  std_logic_vector(0 to MAX_ADDR_DATA_CS_TH_CNT_WIDTH-1);
constant ADDR_DATA_HOLD_CNTR_ARRAY : ADDR_DATA_HOLD_CNT_ARRAY_TYPE :=
  (
  ADDR_DATA_CS_HOLD_CNTR0,
  ADDR_DATA_CS_HOLD_CNTR1,
  ADDR_DATA_CS_HOLD_CNTR2,
  ADDR_DATA_CS_HOLD_CNTR3
  );
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- READ CONTROL SIGNAL
-- Read signal (PRH_RDn) low time is the maximum of C_PRHx_RDN_WIDTH and
-- C_PRHx_DATA_TOUT
-- the calculation is done by comparing 1 or max of C_PRH0_RDN_WIDTH
-- and C_PRH0_DATA_TOUT divided by C_BUS_CLOCK_PERIOD_PS value.
-- this gives precise values of the RDN_MAXx.

constant RDN_MAX0 : integer  :=
      (max2(1,
      (max2(C_PRH0_RDN_WIDTH,C_PRH0_DATA_TOUT)/C_BUS_CLOCK_PERIOD_PS)+1));
constant RDN_MAX1 : integer :=
      (max2(1,
      (max2(C_PRH1_RDN_WIDTH,C_PRH1_DATA_TOUT)/C_BUS_CLOCK_PERIOD_PS)+1));
constant RDN_MAX2 : integer :=
      (max2(1,
      (max2(C_PRH2_RDN_WIDTH,C_PRH2_DATA_TOUT)/C_BUS_CLOCK_PERIOD_PS)+1));
constant RDN_MAX3 : integer :=
      (max2(1,
      (max2(C_PRH3_RDN_WIDTH,C_PRH3_DATA_TOUT)/C_BUS_CLOCK_PERIOD_PS)+1));

constant RDN_CNT_WIDTH0: integer := max2(1,log2(RDN_MAX0+1));
constant RDN_CNT_WIDTH1: integer := max2(1,log2(RDN_MAX1+1));
constant RDN_CNT_WIDTH2: integer := max2(1,log2(RDN_MAX2+1));
constant RDN_CNT_WIDTH3: integer := max2(1,log2(RDN_MAX3+1));

constant RD_CNT_ARRAY : INTEGER_ARRAY_TYPE(0 to C_MAX_PERIPHERALS-1) :=
(
        RDN_CNT_WIDTH0,
        RDN_CNT_WIDTH1,
        RDN_CNT_WIDTH2,
        RDN_CNT_WIDTH3
 );

-- the max value is calculated for those devices, which are asynch type
-- PRH_SYNC will be directly taken from the epc_core.vhd file
constant MAX_RDN_CNT_WIDTH: integer :=
FindMaxWidth(C_NUM_PERIPHERALS,RD_CNT_ARRAY,PRH_SYNC);

------------------------------------------------------------------------------
-- WRITE CONTROL SIGNAL
-- Write signal (PRH_WRn) low time is the maximum of C_PRHx_WRN_WIDTH and
-- C_PRHx_DATA_TSU
-- the calculation is done by comparing 1 or max of C_PRH0_WRN_WIDTH
-- and C_PRH0_DATA_TSU divided by C_BUS_CLOCK_PERIOD_PS value.
-- this gives precise values of the WRN_MAXx.

constant WRN_MAX0 : integer
        :=(max2(1,
          (max2(C_PRH0_WRN_WIDTH,C_PRH0_DATA_TSU)/C_BUS_CLOCK_PERIOD_PS)+1));
constant WRN_MAX1 : integer
        :=(max2(1,
          (max2(C_PRH1_WRN_WIDTH,C_PRH1_DATA_TSU)/C_BUS_CLOCK_PERIOD_PS)+1));
constant WRN_MAX2 : integer
        :=(max2(1,
          (max2(C_PRH2_WRN_WIDTH,C_PRH2_DATA_TSU)/C_BUS_CLOCK_PERIOD_PS)+1));
constant WRN_MAX3 : integer
        :=(max2(1,
          (max2(C_PRH3_WRN_WIDTH,C_PRH3_DATA_TSU)/C_BUS_CLOCK_PERIOD_PS)+1));

constant WRN_CNT_WIDTH0 : integer := max2(1,log2(WRN_MAX0+1));
constant WRN_CNT_WIDTH1 : integer := max2(1,log2(WRN_MAX1+1));
constant WRN_CNT_WIDTH2 : integer := max2(1,log2(WRN_MAX2+1));
constant WRN_CNT_WIDTH3 : integer := max2(1,log2(WRN_MAX3+1));

constant WR_CNT_ARRAY : INTEGER_ARRAY_TYPE(0 to C_MAX_PERIPHERALS-1) :=
(
        WRN_CNT_WIDTH0,
        WRN_CNT_WIDTH1,
        WRN_CNT_WIDTH2,
        WRN_CNT_WIDTH3
 );

-- the max value is calculated for those devices, which are asynch type
-- PRH_SYNC will be directly taken from the epc_core.vhd file
constant MAX_WRN_CNT_WIDTH: integer :=
FindMaxWidth(C_NUM_PERIPHERALS,WR_CNT_ARRAY,PRH_SYNC);
------------------------------------------------------------------------------
--calculate the max width of Read and Write calculation
constant MAX_CONTROL_CNT_WIDTH : integer :=
max2(MAX_WRN_CNT_WIDTH,MAX_RDN_CNT_WIDTH);
------------------------------------------------------------------------------
constant TRDCNT_0 :
                std_logic_vector(0 to MAX_CONTROL_CNT_WIDTH-1)
                := conv_std_logic_vector(RDN_MAX0, MAX_CONTROL_CNT_WIDTH);

constant TRDCNT_1 :
                std_logic_vector(0 to MAX_CONTROL_CNT_WIDTH-1)
                := conv_std_logic_vector(RDN_MAX1, MAX_CONTROL_CNT_WIDTH);

constant TRDCNT_2 :
                std_logic_vector(0 to MAX_CONTROL_CNT_WIDTH-1)
                := conv_std_logic_vector(RDN_MAX2, MAX_CONTROL_CNT_WIDTH);

constant TRDCNT_3 :
                std_logic_vector(0 to MAX_CONTROL_CNT_WIDTH-1)
                := conv_std_logic_vector(RDN_MAX3, MAX_CONTROL_CNT_WIDTH);

--this array stores the values for read control signal activated period value
type RDCNT_ARRAY_TYPE is array (0 to C_MAX_PERIPHERALS-1) of
             std_logic_vector(0 to MAX_CONTROL_CNT_WIDTH-1);
constant TRD_CNTR_ARRAY : RDCNT_ARRAY_TYPE :=
        (
            TRDCNT_0,
            TRDCNT_1,
            TRDCNT_2,
            TRDCNT_3
        );
-----------------------------------------------------------------------------
-- convert the constants into std_logic_vector
constant TWRCNT_0 :
                std_logic_vector(0 to MAX_CONTROL_CNT_WIDTH-1)
                := conv_std_logic_vector(WRN_MAX0, MAX_CONTROL_CNT_WIDTH);
constant TWRCNT_1 :
                std_logic_vector(0 to MAX_CONTROL_CNT_WIDTH-1)
                := conv_std_logic_vector(WRN_MAX1, MAX_CONTROL_CNT_WIDTH);
constant TWRCNT_2 :
                std_logic_vector(0 to MAX_CONTROL_CNT_WIDTH-1)
                := conv_std_logic_vector(WRN_MAX2, MAX_CONTROL_CNT_WIDTH);
constant TWRCNT_3 :
                std_logic_vector(0 to MAX_CONTROL_CNT_WIDTH-1)
               := conv_std_logic_vector(WRN_MAX3, MAX_CONTROL_CNT_WIDTH);

-- define the array of the std_logic_vector. It should be 2 dimentional array
-- whose height is determined by the C_MAX_PERIPHERALS and the depth is -- --
-- defined by max of the width of the WR counters.
type WRCNT_ARRAY_TYPE is array (0 to C_MAX_PERIPHERALS-1) of
                  std_logic_vector(0 to MAX_CONTROL_CNT_WIDTH-1);
constant TWR_CNTR_ARRAY : WRCNT_ARRAY_TYPE :=
        (   TWRCNT_0,
            TWRCNT_1,
            TWRCNT_2,
            TWRCNT_3
        );
------------------------------------------------------------------------------
--ADDRESS STROBE
--This signal is used to define address strobe width, when the device is in
-- multiplexed mode
-- the calculation is done by comparing 1 or max of C_PRH0_ADDR_TSU
-- and C_PRH0_ADS_WIDTH,C_PRH0_CSN_TSU divided by C_BUS_CLOCK_PERIOD_PS value.
-- this gives precise values of the ADS_WDTHx.

constant ADS_WDTH0: integer :=
(max2(1,
(max2
(max2(C_PRH0_ADDR_TSU,C_PRH0_ADS_WIDTH),C_PRH0_CSN_TSU)/C_BUS_CLOCK_PERIOD_PS)
+1));

constant ADS_WDTH1: integer :=
(max2(1,
(max2
(max2(C_PRH1_ADDR_TSU,C_PRH1_ADS_WIDTH),C_PRH1_CSN_TSU)/C_BUS_CLOCK_PERIOD_PS)
+1));

constant ADS_WDTH2: integer :=
(max2(1,
(max2
(max2(C_PRH2_ADDR_TSU,C_PRH2_ADS_WIDTH),C_PRH2_CSN_TSU)/C_BUS_CLOCK_PERIOD_PS)
+1));

constant ADS_WDTH3: integer :=
(max2(1,
(max2
(max2(C_PRH3_ADDR_TSU,C_PRH3_ADS_WIDTH),C_PRH3_CSN_TSU)/C_BUS_CLOCK_PERIOD_PS)
+1));

constant ADS_CNT_WIDTH0: integer := max2(1,log2(ADS_WDTH0+1));
constant ADS_CNT_WIDTH1: integer := max2(1,log2(ADS_WDTH1+1));
constant ADS_CNT_WIDTH2: integer := max2(1,log2(ADS_WDTH2+1));
constant ADS_CNT_WIDTH3: integer := max2(1,log2(ADS_WDTH3+1));

constant ADS_CNT_ARRAY : INTEGER_ARRAY_TYPE(0 to C_MAX_PERIPHERALS-1) :=
(
        ADS_CNT_WIDTH0,
        ADS_CNT_WIDTH1,
        ADS_CNT_WIDTH2,
        ADS_CNT_WIDTH3
 );
-- the max value is calculated for those devices, which are asynch type
-- PRH_SYNC will be directly taken from the epc_core.vhd file
constant MAX_ADS_CNT_WIDTH: integer :=
FindMaxWidth(C_NUM_PERIPHERALS,ADS_CNT_ARRAY,PRH_SYNC);

constant TADS_CNT_0: std_logic_vector(0 to MAX_ADS_CNT_WIDTH-1)
        :=conv_std_logic_vector(ADS_WDTH0,MAX_ADS_CNT_WIDTH);

constant TADS_CNT_1: std_logic_vector(0 to MAX_ADS_CNT_WIDTH-1)
        :=conv_std_logic_vector(ADS_WDTH1,MAX_ADS_CNT_WIDTH);

constant TADS_CNT_2: std_logic_vector(0 to MAX_ADS_CNT_WIDTH-1)
        :=conv_std_logic_vector(ADS_WDTH2,MAX_ADS_CNT_WIDTH);

constant TADS_CNT_3: std_logic_vector(0 to MAX_ADS_CNT_WIDTH-1)
        :=conv_std_logic_vector(ADS_WDTH3,MAX_ADS_CNT_WIDTH);

-- this array stores the values for the address strobe time for devices
type TADS_CNT_ARRAY_TYPE is array (0 to C_MAX_PERIPHERALS-1) of
                   std_logic_vector(0 to MAX_ADS_CNT_WIDTH-1);
constant TADS_CNT_ARRAY : TADS_CNT_ARRAY_TYPE :=
  (
  TADS_CNT_0,
  TADS_CNT_1,
  TADS_CNT_2,
  TADS_CNT_3
  );
-------------------------------------------------------------------------------
-- RECOVERY
-- bus muxed            (types) -- write recovery time
--                                              -- read recovery time
-- bus non-muxed        (types) -- write recovery time
--                                              -- read recovery time
-- In parameter declaration, the Read and Write Cycle period should be always
-- more than Read and Write control width period
-------------------------------------------------------------------------------
-- common calculation for write and read recovery
constant PRH_Wr_n0 : integer :=
        (C_PRH0_WR_CYCLE-C_PRH0_WRN_WIDTH);
constant PRH_Wr_n1 : integer :=
        (C_PRH1_WR_CYCLE-C_PRH1_WRN_WIDTH);
constant PRH_Wr_n2 : integer :=
        (C_PRH2_WR_CYCLE-C_PRH2_WRN_WIDTH);
constant PRH_Wr_n3 : integer :=
        (C_PRH3_WR_CYCLE-C_PRH3_WRN_WIDTH);

constant PRH_Rd_n0 : integer:=
        (C_PRH0_Rd_CYCLE-C_PRH0_RDN_WIDTH);
constant PRH_Rd_n1 : integer :=
        (C_PRH1_Rd_CYCLE-C_PRH1_RDN_WIDTH);
constant PRH_Rd_n2 : integer :=
        (C_PRH2_Rd_CYCLE-C_PRH2_RDN_WIDTH);
constant PRH_Rd_n3 : integer :=
        (C_PRH3_Rd_CYCLE-C_PRH3_RDN_WIDTH);
--------------------------------------------------------------------------------
-- RECOVERY + BUS MUXED + WRITE
-- The recovery time is maximum
-- of C_PRHx_CSN_TH and C_PRHx_DATA_TH and
-- [(C_PRHx_WR_CYCLE)-(C_PRHx_WRN_WIDTH)]
-- (ADDRESS HOLD & DATA HOLD & PRH_Wr_n)
-- the calculation is done by comparing 1 or max of C_PRH0_CSN_TH
-- and C_PRH0_DATA_TH,PRH_Wr_n0 divided by C_BUS_CLOCK_PERIOD_PS value.
-- this gives precise values of the WR_REC_MUXEDx.

constant WR_REC_MUXED0 : integer :=
(max2(1,
(max2(max2(C_PRH0_CSN_TH,C_PRH0_DATA_TH),PRH_Wr_n0)/C_BUS_CLOCK_PERIOD_PS)+1));

constant WR_REC_MUXED1 : integer :=
(max2(1,
(max2(max2(C_PRH1_CSN_TH,C_PRH1_DATA_TH),PRH_Wr_n1)/C_BUS_CLOCK_PERIOD_PS)+1));

constant WR_REC_MUXED2 : integer :=
(max2(1,
(max2(max2(C_PRH2_CSN_TH,C_PRH2_DATA_TH),PRH_Wr_n2)/C_BUS_CLOCK_PERIOD_PS)+1));

constant WR_REC_MUXED3 : integer :=
(max2(1,
(max2(max2(C_PRH3_CSN_TH,C_PRH3_DATA_TH),PRH_Wr_n3)/C_BUS_CLOCK_PERIOD_PS)+1));

constant WR_REC_MUXED_WIDTH0 : integer := max2(1,log2(WR_REC_MUXED0+1));
constant WR_REC_MUXED_WIDTH1 : integer := max2(1,log2(WR_REC_MUXED1+1));
constant WR_REC_MUXED_WIDTH2 : integer := max2(1,log2(WR_REC_MUXED2+1));
constant WR_REC_MUXED_WIDTH3 : integer := max2(1,log2(WR_REC_MUXED3+1));

constant WR_REC_CNT_MUXED_ARRAY :
                          INTEGER_ARRAY_TYPE(0 to C_MAX_PERIPHERALS-1) :=
(
        WR_REC_MUXED_WIDTH0,
        WR_REC_MUXED_WIDTH1,
        WR_REC_MUXED_WIDTH2,
        WR_REC_MUXED_WIDTH3
 );

-- the max value is calculated for those devices, which are asynch type
-- PRH_SYNC will be directly taken from the epc_core.vhd file
constant MAX_WR_REC_MUXED_CNT_WIDTH: integer :=
FindMaxWidth(C_NUM_PERIPHERALS,WR_REC_CNT_MUXED_ARRAY,PRH_SYNC);

constant WR_REC_MUXED_CNT0:
        std_logic_vector(0 to MAX_WR_REC_MUXED_CNT_WIDTH-1)
        := conv_std_logic_vector(WR_REC_MUXED0, MAX_WR_REC_MUXED_CNT_WIDTH);
constant WR_REC_MUXED_CNT1:
        std_logic_vector(0 to MAX_WR_REC_MUXED_CNT_WIDTH-1)
        := conv_std_logic_vector(WR_REC_MUXED1, MAX_WR_REC_MUXED_CNT_WIDTH);
constant WR_REC_MUXED_CNT2:
        std_logic_vector(0 to MAX_WR_REC_MUXED_CNT_WIDTH-1)
        := conv_std_logic_vector(WR_REC_MUXED2, MAX_WR_REC_MUXED_CNT_WIDTH);
constant WR_REC_MUXED_CNT3:
        std_logic_vector(0 to MAX_WR_REC_MUXED_CNT_WIDTH-1)
        := conv_std_logic_vector(WR_REC_MUXED3, MAX_WR_REC_MUXED_CNT_WIDTH);

type WR_REC_MUXED_CNT_ARRAY_TYPE is array (0 to C_MAX_PERIPHERALS-1) of
std_logic_vector(0 to MAX_WR_REC_MUXED_CNT_WIDTH-1);
constant WR_REC_MUXED_CNTR_ARRAY : WR_REC_MUXED_CNT_ARRAY_TYPE :=
(
WR_REC_MUXED_CNT0,
WR_REC_MUXED_CNT1,
WR_REC_MUXED_CNT2,
WR_REC_MUXED_CNT3
);
-------------------------------------------------------------------------------
-- RECOVERY + BUS MUXED + READ
-- The recovery time is maximum
-- of C_PRHx_CSN_TH and C_PRHx_DATA_TINV and
-- [(C_PRHx_RD_CYCLE)-(C_PRHx_RDN_WIDTH)]
-- (ADDRESS HOLD & DATA HOLD & PRH_Rd_n)
-- the calculation is done by comparing 1 or max of C_PRH0_CSN_TH
-- and C_PRH0_DATA_TINV,PRH_Rd_n0 divided by C_BUS_CLOCK_PERIOD_PS value.
-- this gives precise values of the RD_REC_MUXEDx.

constant RD_REC_MUXED0 : integer :=
(max2(1,
(max2(max2(C_PRH0_CSN_TH,C_PRH0_DATA_TINV),PRH_Rd_n0)/C_BUS_CLOCK_PERIOD_PS)+1
));

constant RD_REC_MUXED1 : integer :=
(max2(1,
(max2(max2(C_PRH1_CSN_TH,C_PRH1_DATA_TINV),PRH_Rd_n1)/C_BUS_CLOCK_PERIOD_PS)+1
));

constant RD_REC_MUXED2 : integer :=
(max2(1,
(max2(max2(C_PRH2_CSN_TH,C_PRH2_DATA_TINV),PRH_Rd_n2)/C_BUS_CLOCK_PERIOD_PS)+1
));

constant RD_REC_MUXED3 : integer :=
(max2(1,
(max2(max2(C_PRH3_CSN_TH,C_PRH3_DATA_TINV),PRH_Rd_n3)/C_BUS_CLOCK_PERIOD_PS)+1
));

constant RD_REC_MUXED_WIDTH0 : integer := max2(1,log2(RD_REC_MUXED0+1));
constant RD_REC_MUXED_WIDTH1 : integer := max2(1,log2(RD_REC_MUXED1+1));
constant RD_REC_MUXED_WIDTH2 : integer := max2(1,log2(RD_REC_MUXED2+1));
constant RD_REC_MUXED_WIDTH3 : integer := max2(1,log2(RD_REC_MUXED3+1));

constant RD_REC_CNT_MUXED_ARRAY :
                INTEGER_ARRAY_TYPE(0 to C_MAX_PERIPHERALS-1) :=
(
        RD_REC_MUXED_WIDTH0,
        RD_REC_MUXED_WIDTH1,
        RD_REC_MUXED_WIDTH2,
        RD_REC_MUXED_WIDTH3
 );

-- the max value is calculated for those devices, which are asynch type
-- PRH_SYNC will be directly taken from the epc_core.vhd file
constant MAX_RD_REC_MUXED_CNT_WIDTH: integer :=
FindMaxWidth(C_NUM_PERIPHERALS,RD_REC_CNT_MUXED_ARRAY,PRH_SYNC);

constant RD_REC_MUXED_CNT0:
        std_logic_vector(0 to MAX_RD_REC_MUXED_CNT_WIDTH-1)
        := conv_std_logic_vector(RD_REC_MUXED0, MAX_RD_REC_MUXED_CNT_WIDTH);
constant RD_REC_MUXED_CNT1:
        std_logic_vector(0 to MAX_RD_REC_MUXED_CNT_WIDTH-1)
        := conv_std_logic_vector(RD_REC_MUXED1, MAX_RD_REC_MUXED_CNT_WIDTH);
constant RD_REC_MUXED_CNT2:
        std_logic_vector(0 to MAX_RD_REC_MUXED_CNT_WIDTH-1)
        := conv_std_logic_vector(RD_REC_MUXED2, MAX_RD_REC_MUXED_CNT_WIDTH);
constant RD_REC_MUXED_CNT3:
        std_logic_vector(0 to MAX_RD_REC_MUXED_CNT_WIDTH-1)
        := conv_std_logic_vector(RD_REC_MUXED3, MAX_RD_REC_MUXED_CNT_WIDTH);

type RD_REC_MUXED_CNT_ARRAY_TYPE is array (0 to C_MAX_PERIPHERALS-1) of
std_logic_vector(0 to MAX_RD_REC_MUXED_CNT_WIDTH-1);
constant RD_REC_MUXED_CNTR_ARRAY : RD_REC_MUXED_CNT_ARRAY_TYPE :=
(
RD_REC_MUXED_CNT0,
RD_REC_MUXED_CNT1,
RD_REC_MUXED_CNT2,
RD_REC_MUXED_CNT3
);
-------------------------------------------------------------------------------
-- RECOVERY + BUS NON-MUXED + WRITE
-- The recovery time is maximum
-- of C_PRHx_ADDR and C_PRHx_CSN_TH and C_PRHx_DATA_TH and
-- [(C_PRHx_WR_CYCLE)-(C_PRHx_WRN_WIDTH)]
-- (ADDRESS HOLD & DATA HOLD & PRH_Wr_n)
-- the calculation is done by comparing 1 or max of C_PRH0_CSN_TH
-- and C_PRH0_DATA_TH,C_PRH0_ADDR_TH, PRH_Wr_n0 divided by C_BUS_CLOCK_PERIOD_PS
-- value. this gives precise values of the WR_REC_NON_MUXEDx.

constant WR_REC_NON_MUXED0 : integer :=
(max2(1,
(max2(max2(C_PRH0_CSN_TH,C_PRH0_DATA_TH),
         max2(C_PRH0_ADDR_TH,PRH_Wr_n0))/C_BUS_CLOCK_PERIOD_PS)+1));

constant WR_REC_NON_MUXED1 : integer :=
(max2(1,
(max2(max2(C_PRH1_CSN_TH,C_PRH1_DATA_TH),
         max2(C_PRH1_ADDR_TH,PRH_Wr_n1))/C_BUS_CLOCK_PERIOD_PS)+1));

constant WR_REC_NON_MUXED2 : integer :=
(max2(1,
(max2(max2(C_PRH2_CSN_TH,C_PRH2_DATA_TH),
         max2(C_PRH1_ADDR_TH,PRH_Wr_n2))/C_BUS_CLOCK_PERIOD_PS)+1));

constant WR_REC_NON_MUXED3 : integer :=
(max2(1,
(max2(max2(C_PRH3_CSN_TH,C_PRH3_DATA_TH),
         max2(C_PRH3_ADDR_TH,PRH_Wr_n3))/C_BUS_CLOCK_PERIOD_PS)+1));

constant WR_REC_NON_MUXED_WIDTH0 : integer:= max2(1,log2(WR_REC_NON_MUXED0+1));
constant WR_REC_NON_MUXED_WIDTH1 : integer:= max2(1,log2(WR_REC_NON_MUXED1+1));
constant WR_REC_NON_MUXED_WIDTH2 : integer:= max2(1,log2(WR_REC_NON_MUXED2+1));
constant WR_REC_NON_MUXED_WIDTH3 : integer:= max2(1,log2(WR_REC_NON_MUXED3+1));

constant WR_REC_CNT_NON_MUXED_ARRAY :
                INTEGER_ARRAY_TYPE(0 to C_MAX_PERIPHERALS-1) :=
(
        WR_REC_NON_MUXED_WIDTH0,
        WR_REC_NON_MUXED_WIDTH1,
        WR_REC_NON_MUXED_WIDTH2,
        WR_REC_NON_MUXED_WIDTH3
 );

-- the max value is calculated for those devices, which are asynch type
-- PRH_SYNC will be directly taken from the epc_core.vhd file
constant MAX_WR_REC_NON_MUXED_CNT_WIDTH: integer :=
FindMaxWidth(C_NUM_PERIPHERALS,WR_REC_CNT_NON_MUXED_ARRAY,PRH_SYNC);


constant WR_REC_NON_MUXED_CNT0:
std_logic_vector(0 to MAX_WR_REC_NON_MUXED_CNT_WIDTH-1)
:= conv_std_logic_vector(WR_REC_NON_MUXED0, MAX_WR_REC_NON_MUXED_CNT_WIDTH);

constant WR_REC_NON_MUXED_CNT1:
std_logic_vector(0 to MAX_WR_REC_NON_MUXED_CNT_WIDTH-1)
:= conv_std_logic_vector(WR_REC_NON_MUXED1, MAX_WR_REC_NON_MUXED_CNT_WIDTH);

constant WR_REC_NON_MUXED_CNT2:
std_logic_vector(0 to MAX_WR_REC_NON_MUXED_CNT_WIDTH-1)
:= conv_std_logic_vector(WR_REC_NON_MUXED2, MAX_WR_REC_NON_MUXED_CNT_WIDTH);

constant WR_REC_NON_MUXED_CNT3:
std_logic_vector(0 to MAX_WR_REC_NON_MUXED_CNT_WIDTH-1)
:= conv_std_logic_vector(WR_REC_NON_MUXED3, MAX_WR_REC_NON_MUXED_CNT_WIDTH);

type WR_REC_NON_MUXED_CNT_ARRAY_TYPE is array (0 to C_MAX_PERIPHERALS-1) of
std_logic_vector(0 to MAX_WR_REC_NON_MUXED_CNT_WIDTH-1);
constant WR_REC_NON_MUXED_CNTR_ARRAY : WR_REC_NON_MUXED_CNT_ARRAY_TYPE :=
(
WR_REC_NON_MUXED_CNT0,
WR_REC_NON_MUXED_CNT1,
WR_REC_NON_MUXED_CNT2,
WR_REC_NON_MUXED_CNT3
);
-------------------------------------------------------------------------------
-- RECOVERY + BUS NON-MUXED + READ
-- The recovery time is maximum
-- of C_PRHx_CSN_TH and C_PRHx_DATA_TINV and
-- [(C_PRHx_RD_CYCLE)-(C_PRHx_RDN_WIDTH)]
-- (ADDRESS HOLD & DATA HOLD & PRH_Rd_n)
-- the calculation is done by comparing 1 or max of C_PRH0_CSN_TH
-- and C_PRH0_DATA_TINV,C_PRH0_ADDR_TH,PRH_Rd_n0 divided by C_BUS_CLOCK_PERIOD_PS
-- value. this gives precise values of the RD_REC_NON_MUXEDx.

constant RD_REC_NON_MUXED0 : integer :=
(max2(1,
(max2(max2(C_PRH0_CSN_TH,C_PRH0_DATA_TINV),
         max2(C_PRH0_ADDR_TH,PRH_Rd_n0))/C_BUS_CLOCK_PERIOD_PS)+1));

constant RD_REC_NON_MUXED1 : integer :=
(max2(1,
(max2(max2(C_PRH1_CSN_TH,C_PRH1_DATA_TINV),
         max2(C_PRH1_ADDR_TH,PRH_Rd_n1))/C_BUS_CLOCK_PERIOD_PS)+1));

constant RD_REC_NON_MUXED2 : integer :=
(max2(1,
(max2(max2(C_PRH2_CSN_TH,C_PRH2_DATA_TINV),
         max2(C_PRH2_ADDR_TH,PRH_Rd_n2))/C_BUS_CLOCK_PERIOD_PS)+1));

constant RD_REC_NON_MUXED3 : integer :=
(max2(1,
(max2(max2(C_PRH3_CSN_TH,C_PRH3_DATA_TINV),
         max2(C_PRH3_ADDR_TH,PRH_Rd_n3))/C_BUS_CLOCK_PERIOD_PS)+1));

constant RD_REC_NON_MUXED_WIDTH0 : integer:= max2(1,log2(RD_REC_NON_MUXED0+1));
constant RD_REC_NON_MUXED_WIDTH1 : integer:= max2(1,log2(RD_REC_NON_MUXED1+1));
constant RD_REC_NON_MUXED_WIDTH2 : integer:= max2(1,log2(RD_REC_NON_MUXED2+1));
constant RD_REC_NON_MUXED_WIDTH3 : integer:= max2(1,log2(RD_REC_NON_MUXED3+1));

constant RD_REC_CNT_NON_MUXED_ARRAY :
                INTEGER_ARRAY_TYPE(0 to C_MAX_PERIPHERALS-1) :=
(
        RD_REC_NON_MUXED_WIDTH0,
        RD_REC_NON_MUXED_WIDTH1,
        RD_REC_NON_MUXED_WIDTH2,
        RD_REC_NON_MUXED_WIDTH3
 );
-- the max value is calculated for those devices, which are asynch type
-- PRH_SYNC will be directly taken from the epc_core.vhd file
constant MAX_RD_REC_NON_MUXED_CNT_WIDTH: integer :=
        FindMaxWidth(C_NUM_PERIPHERALS,RD_REC_CNT_NON_MUXED_ARRAY,PRH_SYNC);

constant RD_REC_NON_MUXED_CNT0:
std_logic_vector(0 to MAX_RD_REC_NON_MUXED_CNT_WIDTH-1)
:= conv_std_logic_vector(RD_REC_NON_MUXED0, MAX_RD_REC_NON_MUXED_CNT_WIDTH);

constant RD_REC_NON_MUXED_CNT1:
std_logic_vector(0 to MAX_RD_REC_NON_MUXED_CNT_WIDTH-1)
:= conv_std_logic_vector(RD_REC_NON_MUXED1, MAX_RD_REC_NON_MUXED_CNT_WIDTH);

constant RD_REC_NON_MUXED_CNT2:
std_logic_vector(0 to MAX_RD_REC_NON_MUXED_CNT_WIDTH-1)
:= conv_std_logic_vector(RD_REC_NON_MUXED2, MAX_RD_REC_NON_MUXED_CNT_WIDTH);

constant RD_REC_NON_MUXED_CNT3:
std_logic_vector(0 to MAX_RD_REC_NON_MUXED_CNT_WIDTH-1)
:= conv_std_logic_vector(RD_REC_NON_MUXED3, MAX_RD_REC_NON_MUXED_CNT_WIDTH);

type RD_REC_NON_MUXED_CNT_ARRAY_TYPE is array (0 to C_MAX_PERIPHERALS-1) of
                    std_logic_vector(0 to MAX_RD_REC_NON_MUXED_CNT_WIDTH-1);

constant RD_REC_NON_MUXED_CNTR_ARRAY : RD_REC_NON_MUXED_CNT_ARRAY_TYPE :=
(
RD_REC_NON_MUXED_CNT0,
RD_REC_NON_MUXED_CNT1,
RD_REC_NON_MUXED_CNT2,
RD_REC_NON_MUXED_CNT3
);

------------------------------------------------------------------------------
--constant MAX_WR_M_NM_WIDTH: integer
--:= max2(MAX_WR_REC_MUXED_CNT_WIDTH,MAX_WR_REC_NON_MUXED_CNT_WIDTH);

--constant MAX_RD_M_NM_WIDTH: integer
--:= max2(MAX_RD_REC_MUXED_CNT_WIDTH,MAX_RD_REC_NON_MUXED_CNT_WIDTH);
-------------------------------------------------------------------------------
-- This calulation is for the Device Ready Validity from the activation
-- edge of the control signals
-- The control signals are activated and then it is required to check the
-- readyness of the device.The device ready validity time is the time
-- determined by C_PRHx_RDY_TOUT generics
-- the calculation is done by comparing 1 or max of C_PRH0_RDY_TOUT
-- divided by C_BUS_CLOCK_PERIOD_PS value.
-- this gives precise values of the RD_REC_NON_MUXEDx.

constant RDY_TOUT0  : integer :=
        (max2(1,
        (C_PRH0_RDY_TOUT/C_BUS_CLOCK_PERIOD_PS)+1));
constant RDY_TOUT1  : integer :=
        (max2(1,
        (C_PRH1_RDY_TOUT/C_BUS_CLOCK_PERIOD_PS)+1));
constant RDY_TOUT2  : integer :=
        (max2(1,
        (C_PRH2_RDY_TOUT/C_BUS_CLOCK_PERIOD_PS)+1));
constant RDY_TOUT3  : integer :=
        (max2(1,
        (C_PRH3_RDY_TOUT/C_BUS_CLOCK_PERIOD_PS)+1));

constant RDY_TOUT_CNT_WIDTH0 : integer := max2(1,log2(RDY_TOUT0+1));
constant RDY_TOUT_CNT_WIDTH1 : integer := max2(1,log2(RDY_TOUT1+1));
constant RDY_TOUT_CNT_WIDTH2 : integer := max2(1,log2(RDY_TOUT2+1));
constant RDY_TOUT_CNT_WIDTH3 : integer := max2(1,log2(RDY_TOUT3+1));

--for optimisation purpose the max width is calculated only for asynch devices

constant RDY_TOUT_CNT_ARRAY : INTEGER_ARRAY_TYPE(0 to C_MAX_PERIPHERALS-1) :=
(
 RDY_TOUT_CNT_WIDTH0,
 RDY_TOUT_CNT_WIDTH1,
 RDY_TOUT_CNT_WIDTH2,
 RDY_TOUT_CNT_WIDTH3
);
constant MAX_RDY_TOUT_CNT_WIDTH: integer :=
         FindMaxWidth(C_NUM_PERIPHERALS,RDY_TOUT_CNT_ARRAY,PRH_SYNC);

constant RDY_TOUT_CNT_0 :
        std_logic_vector(0 to MAX_RDY_TOUT_CNT_WIDTH-1)
        := conv_std_logic_vector(RDY_TOUT0, MAX_RDY_TOUT_CNT_WIDTH);
constant RDY_TOUT_CNT_1 :
        std_logic_vector(0 to MAX_RDY_TOUT_CNT_WIDTH-1)
        := conv_std_logic_vector(RDY_TOUT1, MAX_RDY_TOUT_CNT_WIDTH);
constant RDY_TOUT_CNT_2 :
        std_logic_vector(0 to MAX_RDY_TOUT_CNT_WIDTH-1)
        := conv_std_logic_vector(RDY_TOUT2, MAX_RDY_TOUT_CNT_WIDTH);
constant RDY_TOUT_CNT_3 :
        std_logic_vector(0 to MAX_RDY_TOUT_CNT_WIDTH-1)
        := conv_std_logic_vector(RDY_TOUT3, MAX_RDY_TOUT_CNT_WIDTH);

--RDY_TOUT_CNT_ARRAY_TYPE array stores the values for the device ready
--validity time with respect to assertion of control signals
type RDY_TOUT_CNT_ARRAY_TYPE is array (0 to C_MAX_PERIPHERALS-1) of
std_logic_vector(0 to MAX_RDY_TOUT_CNT_WIDTH-1);
constant TRDY_TOUT_CNTR_ARRAY : RDY_TOUT_CNT_ARRAY_TYPE :=
  (
  RDY_TOUT_CNT_0,
  RDY_TOUT_CNT_1,
  RDY_TOUT_CNT_2,
  RDY_TOUT_CNT_3
  );
------------------------------------------------------------------------------
-- This calulation is for the device ready period for communication with host,
-- which starts from the activation of the control signals
-- The device ready time is the time determined by C_PRHx_RDY_WIDTH generics
-- The constant is of integer type and not integer range 1 to 31
-- This is by assumption: the device ready period may be much longer
-- the calculation is done by comparing 1 or max of C_PRH0_RDY_WIDTH
-- divided by C_BUS_CLOCK_PERIOD_PS value.
-- this gives precise values of the RDY_WIDTHx.

constant RDY_WIDTH0 : integer :=
        (max2(1,
        (C_PRH0_RDY_WIDTH/C_BUS_CLOCK_PERIOD_PS)+1));
constant RDY_WIDTH1 : integer :=
        (max2(1,
        (C_PRH1_RDY_WIDTH/C_BUS_CLOCK_PERIOD_PS)+1));
constant RDY_WIDTH2 : integer :=
        (max2(1,
        (C_PRH2_RDY_WIDTH/C_BUS_CLOCK_PERIOD_PS)+1));
constant RDY_WIDTH3 : integer :=
        (max2(1,
        (C_PRH3_RDY_WIDTH/C_BUS_CLOCK_PERIOD_PS)+1));

constant RDY_WIDTH_CNT_WIDTH0 : integer := max2(1,log2(RDY_WIDTH0+1));
constant RDY_WIDTH_CNT_WIDTH1 : integer := max2(1,log2(RDY_WIDTH1+1));
constant RDY_WIDTH_CNT_WIDTH2 : integer := max2(1,log2(RDY_WIDTH2+1));
constant RDY_WIDTH_CNT_WIDTH3 : integer := max2(1,log2(RDY_WIDTH3+1));

constant PRH_WIDTH_ARRAY : INTEGER_ARRAY_TYPE(0 to C_MAX_PERIPHERALS-1) :=
(
 RDY_WIDTH_CNT_WIDTH0,
 RDY_WIDTH_CNT_WIDTH1,
 RDY_WIDTH_CNT_WIDTH2,
 RDY_WIDTH_CNT_WIDTH3
);

constant MAX_RDY_WIDTH_CNT_WIDTH: integer :=
         FindMaxWidth(C_NUM_PERIPHERALS,PRH_WIDTH_ARRAY,PRH_SYNC);

constant RDY_WIDTH_CNT_0  :
         std_logic_vector(0 to MAX_RDY_WIDTH_CNT_WIDTH-1)
         := conv_std_logic_vector(RDY_WIDTH0, MAX_RDY_WIDTH_CNT_WIDTH);
constant RDY_WIDTH_CNT_1  :
         std_logic_vector(0 to MAX_RDY_WIDTH_CNT_WIDTH-1)
         := conv_std_logic_vector(RDY_WIDTH1, MAX_RDY_WIDTH_CNT_WIDTH);
constant RDY_WIDTH_CNT_2  :
         std_logic_vector(0 to MAX_RDY_WIDTH_CNT_WIDTH-1)
         := conv_std_logic_vector(RDY_WIDTH2, MAX_RDY_WIDTH_CNT_WIDTH);
constant RDY_WIDTH_CNT_3  :
         std_logic_vector(0 to MAX_RDY_WIDTH_CNT_WIDTH-1)
         := conv_std_logic_vector(RDY_WIDTH3, MAX_RDY_WIDTH_CNT_WIDTH);
-- RDY_WIDTH_CNT_ARRAY_TYPE array stores the values for the device ready
-- validity time with respect to assertion of control signals
type RDY_WIDTH_CNT_ARRAY_TYPE is array (0 to C_MAX_PERIPHERALS-1) of
std_logic_vector(0 to MAX_RDY_WIDTH_CNT_WIDTH-1);
constant TRDY_WIDTH_CNTR_ARRAY : RDY_WIDTH_CNT_ARRAY_TYPE :=
  (
  RDY_WIDTH_CNT_0,
  RDY_WIDTH_CNT_1,
  RDY_WIDTH_CNT_2,
  RDY_WIDTH_CNT_3
  );
------------------------------------------------------------------------------
-- signal declaration
------------------------------------------------------------------------------
-- temporary output signals
signal  taddr_hold_data_i:
        std_logic_vector(0 to MAX_ADDR_TH_CNT_WIDTH-1);
-- address strobe signal when the bus is multipelxed
signal tads_data_i:
        std_logic_vector(0 to MAX_ADS_CNT_WIDTH-1);

-- control signal data
-- control width is the actual read or write signal counter width assigned
-- depedning upon the type of control activation
signal  tcontrol_width_data_i:
        std_logic_vector(0 to MAX_CONTROL_CNT_WIDTH-1);
-- device validation and max time taken by the device to be ready for the
-- communication std logic vector data
signal  tdev_valid_data_i:
        std_logic_vector(0 to MAX_RDY_TOUT_CNT_WIDTH-1);
signal  tdevrdy_width_data_i:
        std_logic_vector(0 to MAX_RDY_WIDTH_CNT_WIDTH-1);

signal taddr_data_cs_hold_count_i :
        std_logic_vector(0 to MAX_ADDR_DATA_CS_TH_CNT_WIDTH-1);

-- recovery signal data
signal trd_recovery_muxed_data_i :
                     std_logic_vector(0 to MAX_RD_REC_MUXED_CNT_WIDTH-1);
signal twr_recovery_muxed_data_i :
                     std_logic_vector(0 to MAX_WR_REC_MUXED_CNT_WIDTH-1);

signal trd_recovery_non_muxed_data_i :
                     std_logic_vector(0 to MAX_RD_REC_NON_MUXED_CNT_WIDTH-1);
signal twr_recovery_non_muxed_data_i :
                     std_logic_vector(0 to MAX_WR_REC_NON_MUXED_CNT_WIDTH-1);
------------------------------------------------------------------------------
signal asynch_rd_req_i       : std_logic;
signal asynch_wr_req_i       : std_logic;

signal taddr_hold_ld_i       : std_logic;
signal tdata_hold_ld_i       : std_logic;
signal tdev_rdy_ld_i         : std_logic;
signal tcontrol_ld_i         : std_logic;
signal tdev_valid_ld_i       : std_logic;
signal tads_ld_i             : std_logic;
signal twr_recovery_ld_i     : std_logic;
signal trd_recovery_ld_i     : std_logic;

signal taddr_hold_ld_ce_i    : std_logic;
signal tdata_hold_ld_ce_i    : std_logic;
signal tcontrol_ld_ce_i      : std_logic;
signal tdev_valid_ld_ce_i    : std_logic;
signal tdev_rdy_ld_ce_i      : std_logic;
signal tads_ld_ce_i          : std_logic;

signal twr_muxed_recovery_load_ce_i      : std_logic;
signal trd_muxed_recovery_load_ce_i      : std_logic;
signal twr_non_muxed_recovery_load_ce_i  : std_logic;
signal trd_non_muxed_recovery_load_ce_i  : std_logic;

signal asynch_prh_rdy_d1     : std_logic;
signal asynch_prh_rdy_d2     : std_logic;
signal asynch_prh_rdy_i      : std_logic;
signal async_cycle_bit_rst   : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8-1);
signal async_cycle_bit       : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8-1);
signal asynch_start_i        : std_logic;
signal asynch_cycle_i        : std_logic;

signal taddr_hold_cnt        : std_logic_vector(0 to MAX_ADDR_TH_CNT_WIDTH-1);
signal tcontrol_wdth_cnt     : std_logic_vector(0 to MAX_CONTROL_CNT_WIDTH-1);
signal tdevrdy_wdth_cnt      : std_logic_vector(0 to MAX_RDY_WIDTH_CNT_WIDTH-1);
signal tdev_valid_cnt        : std_logic_vector(0 to MAX_RDY_TOUT_CNT_WIDTH-1);
signal tads_cnt              : std_logic_vector(0 to MAX_ADS_CNT_WIDTH-1);
signal taddr_data_cs_hold_cnt: std_logic_vector
                                        (0 to MAX_ADDR_DATA_CS_TH_CNT_WIDTH-1);

signal twr_muxed_rec_cnt     :
                    std_logic_vector(0 to MAX_WR_REC_MUXED_CNT_WIDTH-1);
signal trd_muxed_rec_cnt      :
                    std_logic_vector(0 to MAX_RD_REC_MUXED_CNT_WIDTH-1);
signal twr_non_muxed_rec_cnt  :
                    std_logic_vector(0 to MAX_WR_REC_NON_MUXED_CNT_WIDTH-1);
signal trd_non_muxed_rec_cnt  :
                    std_logic_vector(0 to MAX_RD_REC_NON_MUXED_CNT_WIDTH-1);
--signal Asynch_Wrack_i, Asynch_rdack_i : std_logic;
------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
-- NAME: SOME_DEV_ASYNC_GEN
-------------------------------------------------------------------------------
-- Description: Some devices are configured as asynchronous devices
-------------------------------------------------------------------------------
SOME_DEV_ASYNC_GEN: if NO_PRH_ASYNC = 0 generate
attribute ASYNC_REG of REG_PRH_RDY: label is "TRUE";
begin
ASYNC_CYCLE_BIT_RST_GEN: for i in 0 to C_SPLB_NATIVE_DWIDTH/8-1 generate
 async_cycle_bit_rst(i) <= Rst or Asynch_ce(i);-- or Asynch_Wrack_i
                                               --or Asynch_Rdack_i;
end generate ASYNC_CYCLE_BIT_RST_GEN;

--Asynch_Wrack <= Asynch_Wrack_i;
--Asynch_Rdack <= Asynch_Rdack_i;

ASYNC_CYCLE_BIT_GEN: for i in 0 to C_SPLB_NATIVE_DWIDTH/8-1 generate
---------------------------------------------------------------------------
-- NAME: ASYNC_CYCLE_BIT_PROCESS
---------------------------------------------------------------------------
-- Description: Generate an indication for the byte lanes to be read during
--              a single transaction or during the last transfer of a burst
--              transaction
--              Assumes that the burst transfers are of same size
---------------------------------------------------------------------------
ASYNC_CYCLE_BIT_PROCESS: process (async_cycle_bit_rst, Clk)
begin
  if (async_cycle_bit_rst(i) = '1' ) then
    async_cycle_bit(i) <= '0';
  elsif (Clk'event and Clk = '1') then
    if (asynch_start_i = '1') then
      async_cycle_bit(i) <= Bus2IP_BE(i);
    end if;
  end if;
end process ASYNC_CYCLE_BIT_PROCESS;
end generate ASYNC_CYCLE_BIT_GEN;

asynch_cycle_i <= or_reduce(async_cycle_bit);

----------------------------------------------------
-- DEV_RDY_PROCESS : PROCESS
----------------------------------------------------
-- This process is used to double synch the incoming
-- peripheral ready (PRH_RDY) signal
----------------------------------------------------

REG_PRH_RDY: component FDRE
  port map (
            Q  => asynch_prh_rdy_d1,
            C  => Clk,
            CE => '1',
            D  => Asynch_prh_rdy,
            R  => Rst
          );

-- DEV_RDY_PROCESS:process(Clk)
-- begin
-- if (Clk'event and Clk = '1') then
--    if (Rst = '1') then
--         asynch_prh_rdy_d2     <=  '0';
--    else
--         asynch_prh_rdy_d2     <=  asynch_prh_rdy_d1;
--    end if;
-- end if;
-- end process DEV_RDY_PROCESS;

asynch_prh_rdy_i <=   asynch_prh_rdy_d1;
----------------------------------------------------

ADDR_TH_PROCESS:process (Bus2IP_CS)
begin
    taddr_hold_data_i <= (others => '0');
    for i in 0 to C_NUM_PERIPHERALS-1 loop
        if(Bus2IP_CS(i)='1')then
            taddr_hold_data_i <= ADDR_HOLDCNTR_ARRAY(i);
        end if;
    end loop;
end process ADDR_TH_PROCESS;
----------------------------------------------------
DATA_TH_PROCESS:process (Bus2IP_CS)
begin
    taddr_data_cs_hold_count_i<=  (others => '0');
    for i in 0 to C_NUM_PERIPHERALS-1 loop
        if(Bus2IP_CS(i)='1')then
            taddr_data_cs_hold_count_i<=  ADDR_DATA_HOLD_CNTR_ARRAY(i);
        end if;
    end loop;
end process DATA_TH_PROCESS;
----------------------------------------------------
ADS_DATA_PROCESS:process (Bus2IP_CS)
begin
    tads_data_i<=  (others => '0');
    for i in 0 to C_NUM_PERIPHERALS-1 loop
        if(Bus2IP_CS(i)='1')then
            tads_data_i<=  TADS_CNT_ARRAY(i);
        end if;
    end loop;
end process ADS_DATA_PROCESS;
----------------------------------------------------
DEV_VALID_DATA_PROCESS:process (Bus2IP_CS)
begin
    tdev_valid_data_i<=  (others => '0');
    for i in 0 to C_NUM_PERIPHERALS-1 loop
        if(Bus2IP_CS(i)='1')then
            tdev_valid_data_i<=  TRDY_TOUT_CNTR_ARRAY(i);
        end if;
    end loop;
end process DEV_VALID_DATA_PROCESS;
----------------------------------------------------
DEV_RDY_DATA_PROCESS:process (Bus2IP_CS)
begin
    tdevrdy_width_data_i<=  (others => '0');
    for i in 0 to C_NUM_PERIPHERALS-1 loop
        if(Bus2IP_CS(i)='1')then
            tdevrdy_width_data_i<=  TRDY_WIDTH_CNTR_ARRAY(i);
        end if;
    end loop;
end process DEV_RDY_DATA_PROCESS;

-------------------------------------------------------------------------------
RD_REC_DATA_PROCESS:process (Bus2IP_CS,Dev_bus_multiplexed)
begin
    trd_recovery_muxed_data_i<=  (others => '0');
    trd_recovery_non_muxed_data_i<=  (others => '0');

    for i in 0 to C_NUM_PERIPHERALS-1 loop
        if(Bus2IP_CS(i)='1')then
            if(Dev_bus_multiplexed='1') then
                trd_recovery_muxed_data_i<=  RD_REC_MUXED_CNTR_ARRAY(i);
            else
                trd_recovery_non_muxed_data_i<=  RD_REC_NON_MUXED_CNTR_ARRAY(i);
            end if;
        end if;
    end loop;
end process RD_REC_DATA_PROCESS;
-------------------------------------------------------------------------------
WR_REC_DATA_PROCESS:process (Bus2IP_CS,Dev_bus_multiplexed)
begin
    twr_recovery_muxed_data_i<=  (others => '0');
    twr_recovery_non_muxed_data_i<=  (others => '0');

    for i in 0 to C_NUM_PERIPHERALS-1 loop
        if(Bus2IP_CS(i)='1')then
            if(Dev_bus_multiplexed='1') then
                twr_recovery_muxed_data_i<=  WR_REC_MUXED_CNTR_ARRAY(i);
            else
                twr_recovery_non_muxed_data_i<=  WR_REC_NON_MUXED_CNTR_ARRAY(i);
            end if;
        end if;
    end loop;
end process WR_REC_DATA_PROCESS;
-------------------------------------------------------------------------------
CONTROL_DATA_PROCESS:process (Bus2IP_CS,
                              Bus2IP_RdCE,
                              Bus2IP_WrCE)
begin
    tcontrol_width_data_i<=  (others => '0');
    for i in 0 to C_NUM_PERIPHERALS-1 loop
        if(Bus2IP_CS(i)='1')then
            if(Bus2IP_RdCE(i) = '1')then
                tcontrol_width_data_i<=  TRD_CNTR_ARRAY(i);
            elsif(Bus2IP_WrCE(i) = '1')then
                tcontrol_width_data_i<=  TWR_CNTR_ARRAY(i);
            end if;
        end if;
    end loop;
end process CONTROL_DATA_PROCESS;
----------------------------------------------------
RD_REQ_GEN_PROCESS:process(Dev_in_access,
                           Bus2IP_RdCE,
                           IPIC_Asynch_req,
                           Bus2IP_CS
                           )
begin
    asynch_rd_req_i <= '0';
    for i in 0 to C_NUM_PERIPHERALS-1 loop
        if(Bus2IP_CS(i)='1' and Bus2IP_RdCE(i)='1')then
            asynch_rd_req_i <= Dev_in_access and IPIC_Asynch_req;
        end if;
    end loop;
end process RD_REQ_GEN_PROCESS;
----------------------------------------------------
WR_REQ_GEN_PROCESS:process(Dev_in_access,
                           Bus2IP_WrCE,
                           IPIC_Asynch_req,
                           Bus2IP_CS
                           )
begin
    asynch_wr_req_i <= '0';
    for i in 0 to C_NUM_PERIPHERALS-1 loop
        if(Bus2IP_CS(i)='1' and Bus2IP_WrCE(i)='1')then
            asynch_wr_req_i <= Dev_in_access and IPIC_Asynch_req;
        end if;
    end loop;
end process WR_REQ_GEN_PROCESS;
-------------------------------------------------------------------------------
-- component instantiation
-------------------------------------------------------------------------------
-- epc_asynch_statemachine
-------------------------------------------------------------------------------
ASYNC_STATEMACHINE_I: entity axi_epc_v2_0.async_statemachine
  generic map
        (
        C_ADDR_TH_CNT_WIDTH             =>  MAX_ADDR_TH_CNT_WIDTH,
        C_ADDR_DATA_CS_TH_CNT_WIDTH     =>  MAX_ADDR_DATA_CS_TH_CNT_WIDTH,
        C_CONTROL_CNT_WIDTH             =>  MAX_CONTROL_CNT_WIDTH,
        C_DEV_VALID_CNT_WIDTH           =>  MAX_RDY_TOUT_CNT_WIDTH,
        C_DEV_RDY_CNT_WIDTH             =>  MAX_RDY_WIDTH_CNT_WIDTH,
        C_ADS_CNT_WIDTH                 =>  MAX_ADS_CNT_WIDTH,
        C_WR_REC_NM_CNT_WIDTH           =>  MAX_WR_REC_NON_MUXED_CNT_WIDTH,
        C_RD_REC_NM_CNT_WIDTH           =>  MAX_RD_REC_NON_MUXED_CNT_WIDTH,
        C_WR_REC_M_CNT_WIDTH            =>  MAX_WR_REC_MUXED_CNT_WIDTH,
        C_RD_REC_M_CNT_WIDTH            =>  MAX_RD_REC_MUXED_CNT_WIDTH,
        C_NUM_PERIPHERALS               =>  C_NUM_PERIPHERALS
            )
port map(
-- inputs form async_cntl
        Bus2IP_CS                     =>  Bus2IP_CS,
        Bus2IP_RNW                    =>  Bus2IP_RNW,

        Asynch_rd_req                 =>  asynch_rd_req_i,
        Asynch_wr_req                 =>  asynch_wr_req_i,
        Dev_in_access                 =>  Dev_in_access,
        Dev_FIFO_access               =>  Dev_FIFO_access,
        Asynch_prh_rdy                =>  asynch_prh_rdy_i,
    -- inputs from top_level_file
        Dev_dwidth_match              =>  Dev_dwidth_match,
        Dev_bus_multiplexed           =>  Dev_bus_multiplexed,
    -- input from data steering logic
        Asynch_cycle                  =>  asynch_cycle_i,
    -- outputs to IPIF
        Asynch_Wrack                  =>  Asynch_Wrack,
        Asynch_Rdack                  =>  Asynch_Rdack,
        Asynch_error                  =>  Asynch_error,
        Asynch_start                  =>  asynch_start_i,
    -- outputs to counters
        Taddr_hold_load               =>  taddr_hold_ld_i,
        Tdata_hold_load               =>  tdata_hold_ld_i,
        Tcontrol_load                 =>  tcontrol_ld_i,
        Tdev_valid_load               =>  tdev_valid_ld_i,
        Tdev_rdy_load                 =>  tdev_rdy_ld_i,
        Tads_load                     =>  tads_ld_i,
        Twr_recovery_load             =>  twr_recovery_ld_i,
        Trd_recovery_load             =>  trd_recovery_ld_i,

        Taddr_hold_load_ce            => taddr_hold_ld_ce_i,
        Tdata_hold_load_ce            => tdata_hold_ld_ce_i,
        Tcontrol_load_ce              => tcontrol_ld_ce_i,
        Tdev_valid_load_ce            => tdev_valid_ld_ce_i,
        Tdev_rdy_load_ce              => tdev_rdy_ld_ce_i,
        Tads_load_ce                  => tads_ld_ce_i,
        Twr_muxed_recovery_load_ce    => twr_muxed_recovery_load_ce_i,
        Trd_muxed_recovery_load_ce    => trd_muxed_recovery_load_ce_i,
        Twr_non_muxed_recovery_load_ce=> twr_non_muxed_recovery_load_ce_i,
        Trd_non_muxed_recovery_load_ce=> trd_non_muxed_recovery_load_ce_i,

    -- output to data_steering_logic file
        Asynch_Rd                     =>  Asynch_Rd,
        Asynch_en                     =>  Asynch_en,
        Asynch_Wr                     =>  Asynch_Wr,
        Asynch_addr_strobe            =>  Asynch_addr_strobe,
        Asynch_addr_data_sel          =>  Asynch_addr_data_sel,
        Asynch_data_sel               =>  Asynch_data_sel,
        Asynch_chip_select            =>  Asynch_chip_select,
        Asynch_addr_cnt_ld            =>  Asynch_addr_cnt_ld,
        Asynch_addr_cnt_en            =>  Asynch_addr_cnt_en,

        Taddr_hold_cnt                => taddr_hold_cnt,
        Tcontrol_wdth_cnt             => tcontrol_wdth_cnt,
        Tdevrdy_wdth_cnt              => tdevrdy_wdth_cnt,
        Tdev_valid_cnt                => tdev_valid_cnt,
        Tads_cnt                      => tads_cnt,
        Twr_muxed_rec_cnt             => twr_muxed_rec_cnt,
        Trd_muxed_rec_cnt             => trd_muxed_rec_cnt,
        Twr_non_muxed_rec_cnt         => twr_non_muxed_rec_cnt,
        Trd_non_muxed_rec_cnt         => trd_non_muxed_rec_cnt,

        Taddr_data_cs_hold_cnt      => taddr_data_cs_hold_cnt,

    -- Clocks and reset
         Clk                 =>     Clk,
         Rst                 =>     Rst
       );
-------------------------------------------------------------------------------
-- component instantiation
-------------------------------------------------------------------------------
-- epc_counters
-------------------------------------------------------------------------------
ASYNC_CNTR_I: entity axi_epc_v2_0.async_counters
  generic map
        (
        C_ADDR_TH_CNT_WIDTH             =>  MAX_ADDR_TH_CNT_WIDTH,
        C_ADDR_DATA_CS_TH_CNT_WIDTH     =>  MAX_ADDR_DATA_CS_TH_CNT_WIDTH,
        C_CONTROL_CNT_WIDTH             =>  MAX_CONTROL_CNT_WIDTH,
        C_DEV_VALID_CNT_WIDTH           =>  MAX_RDY_TOUT_CNT_WIDTH,
        C_DEV_RDY_CNT_WIDTH             =>  MAX_RDY_WIDTH_CNT_WIDTH,
        C_ADS_CNT_WIDTH                 =>  MAX_ADS_CNT_WIDTH,
        C_WR_REC_NM_CNT_WIDTH           =>  MAX_WR_REC_NON_MUXED_CNT_WIDTH,
        C_RD_REC_NM_CNT_WIDTH           =>  MAX_RD_REC_NON_MUXED_CNT_WIDTH,
        C_WR_REC_M_CNT_WIDTH            =>  MAX_WR_REC_MUXED_CNT_WIDTH,
        C_RD_REC_M_CNT_WIDTH            =>  MAX_RD_REC_MUXED_CNT_WIDTH
        )
  port map
        (
     Taddr_hold_count                   =>  taddr_hold_data_i,
     Taddr_data_cs_hold_count           =>  taddr_data_cs_hold_count_i,
     Tcontrol_width_data                =>  tcontrol_width_data_i,
     Tdev_valid_data                    =>  tdev_valid_data_i,
     Tdevrdy_width_data                 =>  tdevrdy_width_data_i,
     Tads_data                          =>  tads_data_i,
     Twr_recovery_muxed_data            =>  twr_recovery_muxed_data_i,
     Twr_recovery_non_muxed_data        =>  twr_recovery_non_muxed_data_i,
     Trd_recovery_muxed_data            =>  trd_recovery_muxed_data_i,
     Trd_recovery_non_muxed_data        =>  trd_recovery_non_muxed_data_i,

     Taddr_hold_cnt                     =>  taddr_hold_cnt,
     Tcontrol_wdth_cnt                  =>  tcontrol_wdth_cnt,
     Tdevrdy_wdth_cnt                   =>  tdevrdy_wdth_cnt,
     Twr_muxed_rec_cnt                  =>  twr_muxed_rec_cnt,
     Trd_muxed_rec_cnt                  =>  trd_muxed_rec_cnt,
     Twr_non_muxed_rec_cnt              =>  twr_non_muxed_rec_cnt,
     Trd_non_muxed_rec_cnt              =>  trd_non_muxed_rec_cnt,

     Tdev_valid_cnt                     =>  tdev_valid_cnt,
     Tads_cnt                           =>  tads_cnt,
     Taddr_data_cs_hold_cnt             =>  taddr_data_cs_hold_cnt,

     Taddr_hold_load                    =>  taddr_hold_ld_i,
     Tdata_hold_load                    =>  tdata_hold_ld_i,
     Tcontrol_load                      =>  tcontrol_ld_i,
     Tdev_valid_load                    =>  tdev_valid_ld_i,
     Tdev_rdy_load                      =>  tdev_rdy_ld_i,
     Tads_load                          =>  tads_ld_i,
     Twr_recovery_load                  =>  twr_recovery_ld_i,
     Trd_recovery_load                  =>  trd_recovery_ld_i,

     Taddr_hold_load_ce                 =>  taddr_hold_ld_ce_i,
     Tdata_hold_load_ce                 =>  tdata_hold_ld_ce_i,
     Tcontrol_load_ce                   =>  tcontrol_ld_ce_i,
     Tdev_valid_load_ce                 =>  tdev_valid_ld_ce_i,
     Tdev_rdy_load_ce                   =>  tdev_rdy_ld_ce_i,
     Tads_load_ce                       =>  tads_ld_ce_i,
     Twr_muxed_recovery_load_ce         =>  twr_muxed_recovery_load_ce_i,
     Trd_muxed_recovery_load_ce         =>  trd_muxed_recovery_load_ce_i,
     Twr_non_muxed_recovery_load_ce     =>  twr_non_muxed_recovery_load_ce_i,
     Trd_non_muxed_recovery_load_ce     =>  trd_non_muxed_recovery_load_ce_i,

     Clk                                =>  Clk,
     Rst                                =>  rst
     );

end generate SOME_DEV_ASYNC_GEN;

-------------------------------------------------------------------------------
-- NAME: NO_DEV_ASYNC_GEN
-------------------------------------------------------------------------------
-- Description: All devices are configured as synchronous devices
-------------------------------------------------------------------------------
NO_DEV_ASYNC_GEN: if NO_PRH_ASYNC = 1 generate

  Asynch_Wrack        <= '0';
  Asynch_Rdack        <= '0';
  Asynch_error        <= '0';

  Asynch_Wr           <= '1';
  Asynch_Rd           <= '1';
  Asynch_en           <= '0';

  Asynch_addr_strobe  <= '0';
  Asynch_addr_data_sel<= '0';
  Asynch_data_sel     <= '0';
  Asynch_chip_select  <= (others => '1');
  Asynch_addr_cnt_ld  <= '0';
  Asynch_addr_cnt_en  <= '0';

end generate NO_DEV_ASYNC_GEN;

end imp;
------------------------------------------------------------------------------
-- End of async_cntl.vhd file
------------------------------------------------------------------------------
