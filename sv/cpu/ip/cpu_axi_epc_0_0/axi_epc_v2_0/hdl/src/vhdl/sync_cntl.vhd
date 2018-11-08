-------------------------------------------------------------------------------
-- sync_cntl.vhd - entity/architecture pair
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
--
-------------------------------------------------------------------------------
-- File          : sync_cntl.vhd
-- Company       : Xilinx
-- Version       : v1.00.a
-- Description   : External Peripheral Controller for AXI bus sync logic
-- Standard      : VHDL-93
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
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.or_reduce;

library axi_lite_ipif_v3_0;
library lib_pkg_v1_0;
library axi_epc_v2_0;
use axi_lite_ipif_v3_0.ipif_pkg.INTEGER_ARRAY_TYPE;
use axi_epc_v2_0.ld_arith_reg;
use lib_pkg_v1_0.lib_pkg.log2;
use lib_pkg_v1_0.lib_pkg.max2;


library unisim;
use unisim.vcomponents.FDRE;

-------------------------------------------------------------------------------
--                     Definition of Generics                                --
-------------------------------------------------------------------------------
-- C_SPLB_NATIVE_DWIDTH           -  Data bus width of OPB bus.
-- C_NUM_PERIPHERALS      -  No of peripherals.
-- C_PRH_CLK_SUPPORT      -  Indication of whether the synchronous interface
--                           operates on peripheral clock or on OPB clock
-- C_PRH(0:3)_ADDR_TSU    -  External device (0:3) address setup time with
--                           respect  to rising edge of address strobe
--                           (for multiplexed address and data bus)
-- C_PRH(0:3)_ADDR_TH     -  External device (0:3) address hold time with
--                           respect to rising edge of address strobe
--                           (for multiplexed address and data bus)
-- C_PRH(0:3)_ADS_WIDTH   -  Minimum pulse width of address strobe
-- C_PRH(0:3)_RDY_WIDTH   -  Maximum wait period for external device ready
--                           signal assertion
-- LOCAL_CLK_PERIOD_PS    -  The clock period of operational clock of
--                           peripheral interface in  picoseconds
-- MAX_PERIPHERALS        -  Maximum number of peripherals supported by the
--                           external peripheral controller
-- ADDRCNT_WIDTH          -  Width of counter generating address suffix (low
--                           order address bits) in case of data width matching
-- NO_PRH_SYNC            -  Indicates all devices are configured for
--                           asynchronous interface
-- PRH_SYNC               -  Indicates if the devices are configured for
--                           asynchronous or synchronous interface
-- NO_PRH_DWIDTH_MATCH    -  Indication that no device is employing data width
--                           matching
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                     Definition of Ports                                   --
-------------------------------------------------------------------------------
-- Bus2IP_Clk            - OPB Clock
-- Bus2IP_Rst            - OPB Reset
-- Local_Clk             - Operational clock for peripheral interface
-- Local_Rst             - Reset for peripheral interface
-- Bus2IP_BE             - Byte enables from IPIC interface
-- Dev_id                - The decoded identification vector for the currently
--                       - selected device
-- Dev_in_access         - Indicates if any of the synchronous peripheral device
--                         is currently being accessed
-- Dev_fifo_access       - Indicates if the current access is to a FIFO
--                         within the external peripheral device
-- Dev_rnw               - Read/write control indication from IPIC interface
-- Dev_bus_multiplex     - Indicates if the currently selected device employs
--                         multiplexed bus
-- Dev_dwidth_match      - Indicates if the current device employs data
--                         width matching
-- Dev_dbus_width        - Indicates decoded value for the data bus width
-- IPIC_sync_req         - Request from the IPIC interface for an access to be
--                         generated for a synchronous peripheral
-- IP_sync_req_rst       - Request reset to the IPIC control logic
-- IP_sync_ack           - Acknowledgement to the IPIC control logic
-- IPIC_sync_ack_rst     - Acknowledgement reset from the IPIC control logic
-- IP_sync_addrack       - Address acknowledgement for synchronous access
-- IP_sync_errack        - Transaction error indication for synchronous access
-- Sync_addr_cnt_ld      - Load signal for the address suffix counter for
--                         synchronous peripheral accesses
-- Sync_addr_cnt_ce      - Enable for address suffix counter for synchronous
--                         synchronous peripheral accesses
-- Sync_en               - Indication to data steering logic to latch the
--                         read data bus
-- Sync_ce               - Indication of currently read bytes from the data
--                         steering logic
-- Steer_index           - Index for data steering
-- Dev_Rdy               - Currently selected device ready indication
--                         (Decoded from multiple PRH_RDY signal)
-- Sync_ADS              - Address strobe for synchronous access
-- Sync_CS_n             - Chip select signals for synchronous peripheral
--                         devices
-- Sync_RNW              - Read/Write control for synchronous access
-- Sync_Burst            - Burst indication for synchronous access
-- Sync_addr_ph          - Address phase indication for synchronous access
--                         in case of multiplexed address and data bus
-- Sync_data_oe          - Data bus output enable for synchronous access
-------------------------------------------------------------------------------

entity sync_cntl is
  generic (
    C_SPLB_NATIVE_DWIDTH     : integer;
    C_NUM_PERIPHERALS        : integer;
    C_PRH_CLK_SUPPORT        : integer;

    C_PRH0_ADDR_TSU          : integer;
    C_PRH1_ADDR_TSU          : integer;
    C_PRH2_ADDR_TSU          : integer;
    C_PRH3_ADDR_TSU          : integer;

    C_PRH0_ADDR_TH           : integer;
    C_PRH1_ADDR_TH           : integer;
    C_PRH2_ADDR_TH           : integer;
    C_PRH3_ADDR_TH           : integer;

    C_PRH0_ADS_WIDTH         : integer;
    C_PRH1_ADS_WIDTH         : integer;
    C_PRH2_ADS_WIDTH         : integer;
    C_PRH3_ADS_WIDTH         : integer;

    C_PRH0_RDY_WIDTH         : integer;
    C_PRH1_RDY_WIDTH         : integer;
    C_PRH2_RDY_WIDTH         : integer;
    C_PRH3_RDY_WIDTH         : integer;

    LOCAL_CLK_PERIOD_PS      : integer;
    MAX_PERIPHERALS          : integer;
    ADDRCNT_WIDTH            : integer;
    NO_PRH_SYNC              : integer;
    PRH_SYNC                 : std_logic_vector;
    NO_PRH_DWIDTH_MATCH      : integer
  );

  port (
     Bus2IP_Clk         : in  std_logic;
     Bus2IP_Rst         : in  std_logic;

     Local_Clk          : in  std_logic;
     Local_Rst          : in  std_logic;

     Bus2IP_BE          : in  std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8 -1);

     Dev_id             : in  std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     Dev_in_access      : in  std_logic;
     Dev_fifo_access    : in  std_logic;
     Dev_rnw            : in  std_logic;
     Dev_bus_multiplex  : in  std_logic;
     Dev_dwidth_match   : in  std_logic;
     Dev_dbus_width     : in  std_logic_vector(0 to 2);

     IPIC_sync_req      : in  std_logic;
     IP_sync_req_rst    : out std_logic;

     IP_sync_Wrack      : out std_logic;
     IP_sync_Rdack      : out std_logic;
     IPIC_sync_ack_rst  : in  std_logic;

     IP_sync_errack     : out std_logic;

     Sync_addr_cnt_ld   : out std_logic;
     Sync_addr_cnt_ce   : out std_logic;

     Sync_en            : out std_logic;
     Sync_ce            : in  std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8 -1);

     Steer_index        : in  std_logic_vector(0 to ADDRCNT_WIDTH-1);

     Dev_Rdy            : in  std_logic;

     Sync_ADS           : out std_logic;
     Sync_CS_n          : out std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     Sync_RNW           : out std_logic;
     Sync_Burst         : out std_logic;

     Sync_addr_ph       : out std_logic;
     Sync_data_oe       : out std_logic

    );
end entity sync_cntl;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture imp of sync_cntl is

attribute ASYNC_REG : string;

-------------------------------------------------------------------------------
-- Function Declarations
-------------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- NAME: find_effective_max
  -----------------------------------------------------------------------------
  -- Description: Given an array and an std_logic_vector indicating if
  --              the elements of the array corresponds to synchronous
  --              access, returns the maximum of those array elements that
  --              corresponds to synchronous access.
  -----------------------------------------------------------------------------
  function find_effective_max (array_size : integer;
                               sync_identify : std_logic_vector;
                               int_array : INTEGER_ARRAY_TYPE)
                               return integer is
  variable temp : integer := 1;
  begin

    for i in 0 to (array_size-1) loop
      if sync_identify(i) = '1' then
        if int_array(i) >= temp then
          temp := int_array(i);
        end if;
      end if;
    end loop;

    return temp;
  end function find_effective_max;

  -----------------------------------------------------------------------------
  -- NAME: find_effective_cnt
  -----------------------------------------------------------------------------
  -- Description: Given a signal indicating if the current access is for
  --              synchronous device and a value,  returns the effective value
  --              corresponding to the device access.  The effective value is
  --              the  input value if the access corresponds to a synchronous
  --              device else zero.
  -----------------------------------------------------------------------------
  function find_effective_cnt(sync_identify : std_logic;
                              value : integer)
                              return integer is
  variable temp : integer := 0;
  begin

    if sync_identify = '1' then
      temp := value;
    else
      temp := 0;
    end if;

    return temp;
  end function find_effective_cnt;

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------

constant BYTE_SIZE: integer := 8;

constant ADS_ASSERT_CNT0: integer :=
         (max2((C_PRH0_ADDR_TSU/LOCAL_CLK_PERIOD_PS),
              (C_PRH0_ADS_WIDTH/LOCAL_CLK_PERIOD_PS)));
constant ADS_ASSERT_CNT1: integer :=
         (max2((C_PRH1_ADDR_TSU/LOCAL_CLK_PERIOD_PS),
              (C_PRH1_ADS_WIDTH/LOCAL_CLK_PERIOD_PS)));
constant ADS_ASSERT_CNT2: integer :=
         (max2((C_PRH2_ADDR_TSU/LOCAL_CLK_PERIOD_PS),
              (C_PRH2_ADS_WIDTH/LOCAL_CLK_PERIOD_PS)));
constant ADS_ASSERT_CNT3: integer :=
         (max2((C_PRH3_ADDR_TSU/LOCAL_CLK_PERIOD_PS),
              (C_PRH3_ADS_WIDTH/LOCAL_CLK_PERIOD_PS)));

constant ADS_ASSERT_CNT_WIDTH0: integer := max2(1,log2(ADS_ASSERT_CNT0+1));
constant ADS_ASSERT_CNT_WIDTH1: integer := max2(1,log2(ADS_ASSERT_CNT1+1));
constant ADS_ASSERT_CNT_WIDTH2: integer := max2(1,log2(ADS_ASSERT_CNT2+1));
constant ADS_ASSERT_CNT_WIDTH3: integer := max2(1,log2(ADS_ASSERT_CNT3+1));

constant ADS_ASSERT_CNT_WIDTH_ARRAY:
         INTEGER_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
         ( find_effective_cnt(PRH_SYNC(0),ADS_ASSERT_CNT_WIDTH0),
           find_effective_cnt(PRH_SYNC(1),ADS_ASSERT_CNT_WIDTH1),
           find_effective_cnt(PRH_SYNC(2),ADS_ASSERT_CNT_WIDTH2),
           find_effective_cnt(PRH_SYNC(3),ADS_ASSERT_CNT_WIDTH3)
         );

constant MAX_ADS_ASSERT_CNT_WIDTH: integer :=
         find_effective_max(C_NUM_PERIPHERALS,
                            PRH_SYNC,
                            ADS_ASSERT_CNT_WIDTH_ARRAY);

type SLV_ADS_ASSERT_ARRAY_TYPE is array (natural range <>) of
                        std_logic_vector(0 to MAX_ADS_ASSERT_CNT_WIDTH-1);

constant ADS_ASSERT_DELAY_CNT_ARRAY:
         SLV_ADS_ASSERT_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
         ( conv_std_logic_vector(ADS_ASSERT_CNT0, MAX_ADS_ASSERT_CNT_WIDTH),
           conv_std_logic_vector(ADS_ASSERT_CNT1, MAX_ADS_ASSERT_CNT_WIDTH),
           conv_std_logic_vector(ADS_ASSERT_CNT2, MAX_ADS_ASSERT_CNT_WIDTH),
           conv_std_logic_vector(ADS_ASSERT_CNT3, MAX_ADS_ASSERT_CNT_WIDTH)
         );

constant DEV_ADS_ASSERT_ADDRCNT_RST_VAL:
         std_logic_vector(0 to MAX_ADS_ASSERT_CNT_WIDTH-1) := (others => '0');

----------------------------------------------------------------------------
constant ADS_DEASSERT_CNT0: integer := (C_PRH0_ADDR_TH/LOCAL_CLK_PERIOD_PS)+1;
constant ADS_DEASSERT_CNT1: integer := (C_PRH1_ADDR_TH/LOCAL_CLK_PERIOD_PS)+1;
constant ADS_DEASSERT_CNT2: integer := (C_PRH2_ADDR_TH/LOCAL_CLK_PERIOD_PS)+1;
constant ADS_DEASSERT_CNT3: integer := (C_PRH3_ADDR_TH/LOCAL_CLK_PERIOD_PS)+1;

constant ADS_DEASSERT_CNT_WIDTH0: integer := max2(1,log2(ADS_DEASSERT_CNT0+1));
constant ADS_DEASSERT_CNT_WIDTH1: integer := max2(1,log2(ADS_DEASSERT_CNT1+1));
constant ADS_DEASSERT_CNT_WIDTH2: integer := max2(1,log2(ADS_DEASSERT_CNT2+1));
constant ADS_DEASSERT_CNT_WIDTH3: integer := max2(1,log2(ADS_DEASSERT_CNT3+1));

constant ADS_DEASSERT_CNT_WIDTH_ARRAY:
         INTEGER_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
         ( find_effective_cnt(PRH_SYNC(0),ADS_DEASSERT_CNT_WIDTH0),
           find_effective_cnt(PRH_SYNC(1),ADS_DEASSERT_CNT_WIDTH1),
           find_effective_cnt(PRH_SYNC(2),ADS_DEASSERT_CNT_WIDTH2),
           find_effective_cnt(PRH_SYNC(3),ADS_DEASSERT_CNT_WIDTH3)
         );

constant MAX_ADS_DEASSERT_CNT_WIDTH: integer :=
         find_effective_max(C_NUM_PERIPHERALS,
                            PRH_SYNC,
                            ADS_DEASSERT_CNT_WIDTH_ARRAY);

type SLV_ADS_DEASSERT_ARRAY_TYPE is array (natural range <>) of
                        std_logic_vector(0 to MAX_ADS_DEASSERT_CNT_WIDTH-1);

constant ADS_DEASSERT_DELAY_CNT_ARRAY:
         SLV_ADS_DEASSERT_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
         ( conv_std_logic_vector(ADS_DEASSERT_CNT0, MAX_ADS_DEASSERT_CNT_WIDTH),
           conv_std_logic_vector(ADS_DEASSERT_CNT1, MAX_ADS_DEASSERT_CNT_WIDTH),
           conv_std_logic_vector(ADS_DEASSERT_CNT2, MAX_ADS_DEASSERT_CNT_WIDTH),
           conv_std_logic_vector(ADS_DEASSERT_CNT3, MAX_ADS_DEASSERT_CNT_WIDTH)
         );


constant DEV_ADS_DEASSERT_ADDRCNT_RST_VAL:
         std_logic_vector(0 to MAX_ADS_DEASSERT_CNT_WIDTH-1) := (others => '0');
------------------------------------------------------------------------------
constant RDY_CNT0: integer := (C_PRH0_RDY_WIDTH/LOCAL_CLK_PERIOD_PS)+1;
constant RDY_CNT1: integer := (C_PRH1_RDY_WIDTH/LOCAL_CLK_PERIOD_PS)+1;
constant RDY_CNT2: integer := (C_PRH2_RDY_WIDTH/LOCAL_CLK_PERIOD_PS)+1;
constant RDY_CNT3: integer := (C_PRH3_RDY_WIDTH/LOCAL_CLK_PERIOD_PS)+1;

constant RDY_CNT_WIDTH0: integer := max2(1,log2(RDY_CNT0+1));
constant RDY_CNT_WIDTH1: integer := max2(1,log2(RDY_CNT1+1));
constant RDY_CNT_WIDTH2: integer := max2(1,log2(RDY_CNT2+1));
constant RDY_CNT_WIDTH3: integer := max2(1,log2(RDY_CNT3+1));

constant RDY_CNT_WIDTH_ARRAY: INTEGER_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
         ( find_effective_cnt(PRH_SYNC(0),RDY_CNT_WIDTH0),
           find_effective_cnt(PRH_SYNC(1),RDY_CNT_WIDTH1),
           find_effective_cnt(PRH_SYNC(2),RDY_CNT_WIDTH2),
           find_effective_cnt(PRH_SYNC(3),RDY_CNT_WIDTH3)
         );

constant MAX_RDY_CNT_WIDTH: integer :=
         find_effective_max(C_NUM_PERIPHERALS, PRH_SYNC, RDY_CNT_WIDTH_ARRAY);


type SLV_RDY_ARRAY_TYPE is array (natural range <>) of
                        std_logic_vector(0 to MAX_RDY_CNT_WIDTH-1);

constant RDY_DELAY_CNT_ARRAY : SLV_RDY_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
         ( conv_std_logic_vector(RDY_CNT0, MAX_RDY_CNT_WIDTH),
           conv_std_logic_vector(RDY_CNT1, MAX_RDY_CNT_WIDTH),
           conv_std_logic_vector(RDY_CNT2, MAX_RDY_CNT_WIDTH),
           conv_std_logic_vector(RDY_CNT3, MAX_RDY_CNT_WIDTH)
         );

constant DEV_RDY_ADDRCNT_RST_VAL : std_logic_vector(0 to MAX_RDY_CNT_WIDTH-1)
                                 := (others => '0');

-------------------------------------------------------------------------------
-- Type Declarations
-------------------------------------------------------------------------------
type SYNC_SM_TYPE is (
                      IDLE,             -- common state
                      -----
                      ADS_ASSERT,       -- used for muxed logic
                      ADS_DEASSERT,     -- used for muxed logic
                      ADS_PRE_DATA_PHASE,--new addition to seperate muxed logic
                      ADS_DATA_PHASE,   --new addition
                      ADS_TURN_AROUND,  -- used for muxed logic
                      ---
                      PRE_DATA_PHASE,   -- used for non-muxed logic
                      DATA_PHASE,       -- used for non-muxed logic
                      ---
                      ACK_GEN,          -- common state
                      ERRACK_GEN,       -- common state
                      TURN_AROUND       -- common state
                      );

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------

signal state_ns              : SYNC_SM_TYPE := IDLE;
signal state_cs              : SYNC_SM_TYPE;

signal sync_ads_i            : std_logic:='0';
signal sync_cs_i             : std_logic:='0';
signal sync_cs_n_i           : std_logic_vector(0 to C_NUM_PERIPHERALS-1) :=
                               (others => '0');

signal sync_burst_en         : std_logic:='0';
signal sync_burst_i          : std_logic:='0';

signal sync_en_i             : std_logic:='0';
signal sync_wr               : std_logic:='0';

signal next_addr_ph          : std_logic:='0';
signal next_pre_data_ph      : std_logic:='0';
signal next_data_ph          : std_logic:='0';

signal sync_data_oe_i        : std_logic:='0';

signal sync_start            : std_logic:='0';
signal sync_cycle_bit_rst    :std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8-1):=
                               (others => '0');
signal sync_cycle_bit        :std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8-1):=
                               (others => '0');
signal sync_cycle_en         : std_logic:='0';
signal sync_cycle            : std_logic:='0';

signal ack                   : std_logic:='0';
signal sync_ack              : std_logic:='0';
signal ip_sync_ack_i         : std_logic:='0';
signal local_sync_ack        : std_logic:='0';
signal local_sync_ack_rst    : std_logic:='0';
signal local_sync_ack_d1     : std_logic:='0';
signal local_sync_ack_d2     : std_logic:='0';
signal local_sync_ack_d3     : std_logic:='0';

signal errack                : std_logic:='0';
signal sync_errack           : std_logic:='0';
signal local_sync_errack     : std_logic:='0';
signal local_sync_errack_rst : std_logic:='0';
signal local_sync_errack_d1  : std_logic:='0';
signal local_sync_errack_d2  : std_logic:='0';
signal local_sync_errack_d3  : std_logic:='0';

signal dev_rdy_addrcnt_ld    : std_logic:='0';
signal dev_rdy_addrcnt_ce    : std_logic:='0';
signal dev_rdy_addrcnt       : std_logic_vector(0 to MAX_RDY_CNT_WIDTH-1) :=
                               (others => '0');
signal dev_rdy_ld_val        : std_logic_vector(0 to MAX_RDY_CNT_WIDTH-1) :=
                               (others => '0');

signal dev_ads_assert_addrcnt_ld    : std_logic:='0';
signal dev_ads_assert_addrcnt_ce    : std_logic:='0';
signal dev_ads_assert_addrcnt       :
       std_logic_vector(0 to MAX_ADS_ASSERT_CNT_WIDTH-1) := (others => '0');
                --conv_std_logic_vector(1,MAX_ADS_ASSERT_CNT_WIDTH);
signal dev_ads_assert_ld_val        :
       std_logic_vector(0 to MAX_ADS_ASSERT_CNT_WIDTH-1) := (others => '0');

constant DEV_ADS_ASSERT_ADDRCNT_ZERO:
         std_logic_vector(0 to MAX_ADS_ASSERT_CNT_WIDTH-1) :=
                          conv_std_logic_vector(1,MAX_ADS_ASSERT_CNT_WIDTH);
constant DEV_ADS_DEASSERT_ADDRCNT_ZERO:
         std_logic_vector(0 to MAX_ADS_DEASSERT_CNT_WIDTH-1) :=
                           conv_std_logic_vector(1,MAX_ADS_DEASSERT_CNT_WIDTH);
constant DEV_RDY_ADDRCNT_ZERO : std_logic_vector(0 to MAX_RDY_CNT_WIDTH-1)
                              := conv_std_logic_vector(0,MAX_RDY_CNT_WIDTH);


signal dev_ads_deassert_addrcnt_ld  : std_logic:='0';
signal dev_ads_deassert_addrcnt_ce  : std_logic:='0';
signal dev_ads_deassert_addrcnt     :
       std_logic_vector(0 to MAX_ADS_DEASSERT_CNT_WIDTH-1) := (others => '0');
signal dev_ads_deassert_ld_val      :
       std_logic_vector(0 to MAX_ADS_DEASSERT_CNT_WIDTH-1) := (others => '0');
signal sig1: std_logic;
signal sig2: std_logic;
signal temp_1_rst: std_logic;
-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
begin

-------------------------------------------------------------------------------
-- NAME: NO_DEV_SYNC_GEN
-------------------------------------------------------------------------------
-- Description: All devices are configured as asynchronous devices
-------------------------------------------------------------------------------
NO_DEV_SYNC_GEN: if NO_PRH_SYNC = 1 generate

  IP_sync_req_rst   <= '1';
  IP_sync_Wrack     <= '0';
  IP_sync_Rdack     <= '0';
  IP_sync_errack    <= '0';

  Sync_addr_cnt_ld  <= '0';
  Sync_addr_cnt_ce  <= '0';

  Sync_en           <= '0';

  Sync_ADS          <= '0';
  Sync_CS_n         <= (others => '1');
  Sync_RNW          <= '1';
  Sync_Burst        <= '0';
  Sync_addr_ph      <= '0';
  Sync_data_oe      <= '0';

end generate NO_DEV_SYNC_GEN;


-------------------------------------------------------------------------------
-- NAME: SOME_DEV_SYNC_GEN
-------------------------------------------------------------------------------
-- Description: Some devices are configured as synchronous devices
-------------------------------------------------------------------------------
SOME_DEV_SYNC_GEN: if NO_PRH_SYNC = 0 generate

attribute ASYNC_REG : string;
attribute ASYNC_REG of I_SYNC_DEV_RDY_CNT: label is "TRUE";
begin
  -----------------------------------------------------------------------------
  -- NAME: SYNC_SM_CMB_PROCESS
  -----------------------------------------------------------------------------
  -- Description: Combinational logic for state machine.
  -----------------------------------------------------------------------------
  SYNC_SM_CMB_PROCESS : process (state_cs, Dev_bus_multiplex,
                                 Dev_dwidth_match, sync_cycle,
                                 Dev_in_access, Dev_fifo_access,
                                 IPIC_sync_req,
                                 dev_ads_assert_addrcnt,
                                 dev_ads_deassert_addrcnt,
                                 Dev_Rdy, dev_rdy_addrcnt)
  begin

    state_ns <= IDLE;

    sync_start <= '0';                     -- Assigned when next state is IDLE
    sync_en_i  <= '0';                     -- Assinged when current state is
                                           -- DATA_PHASE and Rdy is asserted

    ack <= '0';                            -- Assigned when current state is
                                           -- ACK_GEN or ERRACK_GEN
    errack <= '0';                         -- Assigned when current state is
                                           -- ERRACK_GEN

    sync_ads_i <= '0';                     -- Assigned when next state is
                                           -- ADS_ASSERT
    next_addr_ph   <= '0';                 -- Assigned when next state is
                                           -- ADS_ASSERT and ADS_DEASSERT
    next_pre_data_ph   <= '0';             -- Assigned when next state is
                                           -- PRE_DATA_PHASE

    sync_cs_i  <= '0';                     -- Assigned when next state is
    next_data_ph   <= '0';                 -- DATA_PHASE

    Sync_addr_cnt_ld  <= '0';              -- Assigned when current state is
                                           -- IDLE and next state is
                                           -- ADS_ASSERT or DATA_PHASE
    Sync_addr_cnt_ce  <= '0';              -- Assigned when current state is
                                           -- DATA_PHASE and device is ready

    dev_rdy_addrcnt_ld  <= '0';            -- Assigned when  next state is
                                           -- DATA_PHASE and not both current
                                           -- state DATA_PHASE and device not
                                           -- ready is true
    dev_rdy_addrcnt_ce  <= '0';            -- Assigned when the current state
                                           -- state is DATA_PHASE and device
                                           -- not ready

    dev_ads_assert_addrcnt_ld  <= '0';     -- Assigned when next state is
                                           -- ADS_ASSERT and the current state
                                           -- is not ADS_ASSERT
    dev_ads_assert_addrcnt_ce  <= '0';     -- Assigned when the current state
                                           -- is next state is ADS_ASSERT and
                                           -- current state is ADS_ASSERT

    dev_ads_deassert_addrcnt_ld  <= '0';   -- Assigned when next state is
                                           -- ADS_DEASSERT and the current
                                           -- state is not ADS_DEASSERT
    dev_ads_deassert_addrcnt_ce  <= '0';   -- Assigned when the next state
                                           -- is ADS_DEASSERT and current
                                           -- state is ADS_DEASSERT

    case state_cs is

      when IDLE =>
      dev_ads_assert_addrcnt_ld    <= '1';
      dev_ads_deassert_addrcnt_ld  <= '1';
      Sync_addr_cnt_ld <= '1';
        if (IPIC_sync_req = '1' and Dev_bus_multiplex = '1' and
                                                       Dev_in_access = '1')then
          sync_cs_i  <= '1'; -- added 6/26/2009
          sync_ads_i <= '1';
          next_addr_ph <= '1';
          state_ns <= ADS_ASSERT;
        elsif (IPIC_sync_req = '1' and Dev_bus_multiplex = '0' and
                                                       Dev_in_access = '1')then
          next_pre_data_ph <= '1';
          --sync_cs_i  <= '1'; -- added 6/26/2009
          dev_rdy_addrcnt_ld <= '1';
          state_ns <= PRE_DATA_PHASE;
        else
          sync_start <= '1';
          state_ns <= IDLE;
        end if;
-------------------------------
--multiplexing mode FSM states - ADS_ASSERT,ADS_DEASSERT,ADS_PRE_DATA_PHASE and
-------------------------------  ADS_DATA_PHASE
      when ADS_ASSERT =>
            sync_cs_i  <= '1'; -- added 6/26/2009
            sync_ads_i <= '1';
            next_addr_ph <= '1';
            dev_ads_assert_addrcnt_ce  <= '1';
            if (dev_ads_assert_addrcnt = DEV_ADS_ASSERT_ADDRCNT_ZERO) then
                next_addr_ph <= '1';
                dev_ads_assert_addrcnt_ce  <= '0';
                sync_ads_i <= '0'; -- added on 19th June, 09
                state_ns <= ADS_DEASSERT;
            else
                dev_ads_assert_addrcnt_ce  <= '1';
                state_ns <= ADS_ASSERT;
            end if;

      when ADS_DEASSERT =>
          sync_cs_i  <= '1'; -- added 6/26/2009
          if (dev_ads_deassert_addrcnt = DEV_ADS_DEASSERT_ADDRCNT_ZERO) then
              next_pre_data_ph <= '1';
              dev_rdy_addrcnt_ld <= '1';
              sync_cs_i  <= '0'; -- added 7/15/2009
              state_ns <= ADS_PRE_DATA_PHASE; --PRE_DATA_PHASE;
          else
             dev_ads_deassert_addrcnt_ce  <= '1';
             next_addr_ph <= '1';
             state_ns <= ADS_DEASSERT;
          end if;

      when ADS_PRE_DATA_PHASE =>
             next_data_ph <= '1';
             sync_cs_i  <= '1';
             state_ns <= ADS_DATA_PHASE;

      when ADS_DATA_PHASE =>
            sync_cs_i  <= '1';
            if (Dev_Rdy = '0') then -- Device not ready
               sync_en_i  <= '0';
               dev_rdy_addrcnt_ce  <= '1';
               if (dev_rdy_addrcnt = DEV_RDY_ADDRCNT_ZERO) then
                        state_ns <= ERRACK_GEN;
               else
                        sync_cs_i  <= '1';
                        next_data_ph <= '1';
                        state_ns <= ADS_DATA_PHASE;
               end if;
            else  -- Device ready
              sync_en_i  <= '1';
              Sync_addr_cnt_ce  <= '1';
              if (Dev_dwidth_match = '1' and sync_cycle = '1') then
                if (Dev_bus_multiplex = '1' and Dev_fifo_access = '0') then
                sync_cs_i  <= '0';
                  state_ns <= ADS_TURN_AROUND;
                else
                  dev_rdy_addrcnt_ld  <= '1';
                  sync_cs_i  <= '1';
                  next_data_ph <= '1';
                  state_ns <= ADS_DATA_PHASE;
                end if;
              else
                 state_ns <= ACK_GEN;
              end if;
           end if;

      when ADS_TURN_AROUND =>
          dev_ads_assert_addrcnt_ld  <= '1';
          dev_ads_deassert_addrcnt_ld  <= '1';
          sync_cs_i  <= '1';
          sync_ads_i <= '1';
          next_addr_ph <= '1';
          state_ns <= ADS_ASSERT;

-------------------------------
--Non-multiplexing mode FSM states-PRE_DATA_PHASE,DATA_PHASE,ADS_TURN_AROUND,
-------------------------------
      when PRE_DATA_PHASE =>
          sync_cs_i  <= '1';
          next_data_ph <= '1';
          state_ns <= DATA_PHASE;

      when DATA_PHASE =>
        -- Master abort
            if (Dev_Rdy = '0') then -- Device not ready
               sync_en_i  <= '0';
               dev_rdy_addrcnt_ce  <= '1';
               if (dev_rdy_addrcnt = DEV_RDY_ADDRCNT_ZERO) then
                        state_ns <= ERRACK_GEN;
               else
                        sync_cs_i  <= '1';
                        next_data_ph <= '1';
                        state_ns <= DATA_PHASE;
               end if;

            else  -- Device ready
              sync_en_i  <= '1';
              Sync_addr_cnt_ce  <= '1';

              if (Dev_dwidth_match = '1' and sync_cycle = '1') then
                --if (Dev_bus_multiplex = '1' and Dev_fifo_access = '0') then
                --  state_ns <= ADS_TURN_AROUND;
                --else
                  dev_rdy_addrcnt_ld  <= '1';
                  sync_cs_i  <= '1';
                  next_data_ph <= '1';
                  state_ns <= DATA_PHASE;
                --end if;
              else
                 state_ns <= ACK_GEN;
              end if;
           end if;
-- common to multiplexing and non-multiplexing states
      when ACK_GEN =>
        ack <= '1';
        state_ns <= TURN_AROUND;

      when ERRACK_GEN =>
        ack <= '1';
        errack <= '1';
        state_ns <= TURN_AROUND;

      when TURN_AROUND =>
        sync_start <= '1';
        state_ns <= IDLE;

      when others =>
    end case;
  end process SYNC_SM_CMB_PROCESS;
--------------------------------------------

  Sync_en <= sync_en_i;
  sync_wr        <= (not Dev_rnw) and next_data_ph;
  sync_data_oe_i <= Dev_in_access and ( next_addr_ph or
                                        (not Dev_rnw and next_pre_data_ph) or
                                        (not Dev_rnw and next_data_ph)
                                      );

  -----------------------------------------------------------------------------
  -- NAME: SYNC_CS_SEL_PROCESS
  -----------------------------------------------------------------------------
  -- Description: Drives an internal signal (SYNC_CS_N) from the synchronous
  --              control logic to be used as the chip select for the external
  --              peripheral device
  -----------------------------------------------------------------------------
  SYNC_CS_SEL_PROCESS: process (Dev_id,sync_cs_i) is
  begin
    sync_cs_n_i <= (others => '1');
    for i in 0 to C_NUM_PERIPHERALS-1 loop
      if (Dev_id(i) = '1') then
        sync_cs_n_i(i) <= not sync_cs_i;
      end if;
    end loop;
  end process SYNC_CS_SEL_PROCESS;

  -----------------------------------------------------------------------------
  -- NAME: SYNC_SM_REG_PROCESS
  -----------------------------------------------------------------------------
  -- Description: Register state machine outputs
  -----------------------------------------------------------------------------
  SYNC_SM_REG_PROCESS : process (Local_Clk)
  begin
    if (Local_Clk'event and Local_Clk = '1') then
      if (Local_Rst = '1') then
         Sync_ADS     <= '0';
         Sync_Burst   <= '0';
         Sync_CS_n    <= (others => '1');
         Sync_RNW     <= '1';
         Sync_addr_ph <= '0';
         Sync_data_oe <= '0';
         state_cs     <= IDLE;
      else
         Sync_ADS     <= sync_ads_i;
         Sync_CS_n    <= sync_cs_n_i;
         Sync_RNW     <= not sync_wr;
         Sync_Burst   <= sync_burst_i;
         Sync_addr_ph <= next_addr_ph;
         Sync_data_oe <= sync_data_oe_i;
         state_cs     <= state_ns;
      end if;
    end if;
  end process SYNC_SM_REG_PROCESS;


  -----------------------------------------------------------------------------
  -- NAME: NO_PRH_DWIDTH_MATCH_GEN
  -----------------------------------------------------------------------------
  -- Description: If no device employs data width matching, then generate
  --              default values for SYNC_CYCLE and SYNC_BURST_I signals
  -----------------------------------------------------------------------------
  NO_PRH_DWIDTH_MATCH_GEN : if NO_PRH_DWIDTH_MATCH = 1 generate
    sync_cycle   <= '0';
    sync_burst_i <= '0';
  end generate NO_PRH_DWIDTH_MATCH_GEN;

  -----------------------------------------------------------------------------
  -- NAME: PRH_DWIDTH_MATCH_GEN
  -----------------------------------------------------------------------------
  -- Description: If any device employs data width matching, then generate
  --              SYNC_CYCLE and SYNC_BURST_I signals
  -----------------------------------------------------------------------------
  PRH_DWIDTH_MATCH_GEN : if NO_PRH_DWIDTH_MATCH = 0 generate

    ---------------------------------------------------------------------------
    -- NAME: SYNC_CYCLE_BIT_RST_GEN
    ---------------------------------------------------------------------------
    -- Generate reset for synchronous cycle bit.
    ---------------------------------------------------------------------------

    SYNC_CYCLE_BIT_RST_GEN: for i in 0 to C_SPLB_NATIVE_DWIDTH/8-1 generate
      sync_cycle_bit_rst(i) <= Local_Rst or Sync_ce(i);
    end generate SYNC_CYCLE_BIT_RST_GEN;

    ---------------------------------------------------------------------------
    -- NAME: SYNC_CYCLE_BIT_GEN
    ---------------------------------------------------------------------------
    -- Description: Generate an indication for the byte lanes read
    ---------------------------------------------------------------------------

    SYNC_CYCLE_BIT_GEN: for i in 0 to C_SPLB_NATIVE_DWIDTH/8-1 generate
      -------------------------------------------------------------------------
      -- NAME: SYNC_CYCLE_BIT_PROCESS
      -------------------------------------------------------------------------
      -- Description: Generate an indication for the byte lanes read
      -------------------------------------------------------------------------
      SYNC_CYCLE_BIT_PROCESS: process (Local_Clk)
      begin
        if (Local_Clk'event and Local_Clk = '1') then
          if (sync_cycle_bit_rst(i) = '1' ) then
            sync_cycle_bit(i) <= '0';
          elsif (sync_start = '1') then
            sync_cycle_bit(i) <= Bus2IP_BE(i);
          end if;
        end if;
      end process SYNC_CYCLE_BIT_PROCESS;
    end generate SYNC_CYCLE_BIT_GEN;

    ---------------------------------------------------------------------------
    -- NAME: SYNC_CYCLE_EN_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Generate enable for sync cycle
    --              Enable for sync cycle is generated when the next data
    --              is to be flushed to the device. For the last access
    --              sync cycle enable will remain zero
    ---------------------------------------------------------------------------
    SYNC_CYCLE_EN_PROCESS: process(Dev_dbus_width, Steer_index,
                                   sync_cycle_bit, sync_en_i)

    variable next_access : integer;
    variable next_to_next: integer;

    variable cycle_on : std_logic;
    variable next_cycle_on : std_logic;

    begin

      sync_cycle_en <= '0';
      sync_burst_en <= '0';

      case Dev_dbus_width is

      when "001"  =>
        for i in 0 to C_SPLB_NATIVE_DWIDTH/BYTE_SIZE-1 loop
          if steer_index = conv_std_logic_vector(i, ADDRCNT_WIDTH) then

             next_access := i+1;
             next_to_next := i+2;

             if (next_access < C_SPLB_NATIVE_DWIDTH/BYTE_SIZE) then
               cycle_on := or_reduce(sync_cycle_bit(next_access to C_SPLB_NATIVE_DWIDTH/8-1));
             else
               cycle_on := '0';
             end if;

             if (next_to_next < C_SPLB_NATIVE_DWIDTH/BYTE_SIZE) then
               next_cycle_on := or_reduce(sync_cycle_bit(next_to_next  to C_SPLB_NATIVE_DWIDTH/8-1));
             else
               next_cycle_on := '0';
             end if;

             sync_cycle_en <= cycle_on;
             sync_burst_en <= cycle_on and ((not sync_en_i) or
                                            (sync_en_i and next_cycle_on));
          end if;
        end loop;

      when "010" =>
        for i in 0 to (C_SPLB_NATIVE_DWIDTH/BYTE_SIZE)/2-1 loop
          if steer_index = conv_std_logic_vector(i, ADDRCNT_WIDTH) then

             next_access := (i+1) * 2;
             next_to_next := (i+2) * 2;

             if (next_access < C_SPLB_NATIVE_DWIDTH/BYTE_SIZE) then
               cycle_on := sync_cycle_bit(next_access) or
                           sync_cycle_bit(next_access+1);
             else
               cycle_on := '0';
             end if;
             -- coverage off
             if (next_to_next < C_SPLB_NATIVE_DWIDTH/BYTE_SIZE) then
               next_cycle_on := sync_cycle_bit(next_to_next) or
                                sync_cycle_bit(next_to_next+1);
             else
             -- coverage on
               next_cycle_on := '0';
             -- coverage off
             end if;
             -- coverage on
             sync_cycle_en <= cycle_on;
             sync_burst_en <= cycle_on and ((not sync_en_i) or
                                            (sync_en_i and next_cycle_on));

          end if;
        end loop;

      when others =>
        sync_cycle_en <= '0';
        sync_burst_en <= '0';

      end case;
    end process SYNC_CYCLE_EN_PROCESS;

    sync_cycle   <= sync_cycle_en and Dev_dwidth_match;
    sync_burst_i <= sync_burst_en and next_data_ph and Dev_dwidth_match and
                    (not Dev_bus_multiplex or Dev_fifo_access);


  end generate PRH_DWIDTH_MATCH_GEN;


  -----------------------------------------------------------------------------
  -- NAME: SYNC_ACK_NO_PRH_CLK_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate data ack and error ack when the synchronous logic
  --              operates on OPB Clock. IP_SYNC_REQ_RST will not be used
  --              by ipic_if_decode logic. Drive it to default value
  -----------------------------------------------------------------------------
  SYNC_ACK_NO_PRH_CLK_GEN: if C_PRH_CLK_SUPPORT = 0 generate


    IP_sync_req_rst <= '1';

    ---------------------------------------------------------------------------
    -- NAME: SYNC_ACK_NO_PRH_CLK_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Generate data ack and error ack when the synchronous logic
    --              operates on OPB Clock.
    ---------------------------------------------------------------------------

    SYNC_ACK_NO_PRH_CLK_PROCESS : process (Local_Clk)
    begin
      if (Local_Clk'event and Local_Clk = '1') then
        if (Local_Rst = '1') then
          ip_sync_ack_i <= '0';
          IP_sync_errack <= '0';
        else
          ip_sync_ack_i <= ack;
          IP_sync_errack <= errack;
        end if;
      end if;
    end process  SYNC_ACK_NO_PRH_CLK_PROCESS;


  end generate SYNC_ACK_NO_PRH_CLK_GEN;

  -----------------------------------------------------------------------------
  -- NAME: SYNC_ACK_PRH_CLK_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate data ack, error ack and reset for synchronos
  --              request when the synchronous logic operates on peripheral
  --              clock
  -----------------------------------------------------------------------------
  SYNC_ACK_PRH_CLK_GEN: if C_PRH_CLK_SUPPORT = 1 generate

    attribute ASYNC_REG of REG_SYNC_ACK: label is "TRUE";
    attribute ASYNC_REG of REG_SYNC_ERRACK: label is "TRUE";

  begin

   ----------------------------------------------------------------------------
   -- NAME: SYNC_REQ_RST_PROCESS
   ----------------------------------------------------------------------------
   -- Description: Generate reset for synchronous request when the synchronous
   --              control operates on peripheral clock.
   ----------------------------------------------------------------------------
   SYNC_REQ_RST_PROCESS : process (state_cs)
   begin
     if (state_cs = ACK_GEN or state_cs = ERRACK_GEN) then
       IP_sync_req_rst <= '1';
     else
       IP_sync_req_rst <= '0';
     end if;
   end process SYNC_REQ_RST_PROCESS;

    ---------------------------------------------------------------------------
    -- NAME: SYNC_ACK_PRH_CLK_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Generate data ack and error ack when the synchronous logic
    --              operates on peripheral clock.
    ---------------------------------------------------------------------------
    SYNC_ACK_PRH_CLK_PROCESS : process (Local_Clk)
    begin
      if (Local_Clk'event and Local_Clk = '1') then
        if (Local_Rst = '1') then
          sync_ack <= '0';
          sync_errack <= '0';
        else
          sync_ack <= ack;
          sync_errack <= errack;
        end if;
      end if;
    end process  SYNC_ACK_PRH_CLK_PROCESS;

    ---------------------------------------------------------------------------
    -- NAME: ACK_HOLD_GEN_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Latch in the synchronous data ack until it is reset by the
    --              ipic_if_decode logic
    ---------------------------------------------------------------------------
    temp_1_rst <= Bus2IP_Rst or IPIC_sync_ack_rst;

    ACK_HOLD_GEN_PROCESS : process (Bus2IP_Clk)
    begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(temp_1_rst = '1') then
                sig1 <= '0';
        elsif(sync_ack = '1') then
                sig1 <= '1';
        end if;
      end if;
    end process ACK_HOLD_GEN_PROCESS;
local_sync_ack <= sync_ack or ( sig1 and (not temp_1_rst));
--------------------------------------------------------------------------------
    local_sync_ack_rst <= Bus2IP_Rst or IPIC_sync_ack_rst;

    REG_SYNC_ACK: component FDRE
      port map (
                 Q  => local_sync_ack_d1,
                 C  => Bus2IP_Clk,
                 CE => '1',
                 D  => local_sync_ack,
                 R  => local_sync_ack_rst
               );


    ---------------------------------------------------------------------------
    -- NAME: ERRACK_HOLD_GEN_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Latch in the synchronous error ack until it is reset by the
    --              ipic_if_decode logic
    ---------------------------------------------------------------------------
    ERRACK_HOLD_GEN_PROCESS : process (Bus2IP_Clk)
    begin
      if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if(temp_1_rst = '1') then
                sig2 <= '0';
        elsif(sync_errack = '1') then
                sig2 <= '1';
        end if;
      end if;
    end process ERRACK_HOLD_GEN_PROCESS;
local_sync_errack <= sync_errack or (sig2 and (not temp_1_rst));
--------------------------------------------------------------------------------

    REG_SYNC_ERRACK: component FDRE
      port map (
                 Q  => local_sync_errack_d1,
                 C  => Bus2IP_Clk,
                 CE => '1',
                 D  => local_sync_errack,
                 R  => local_sync_ack_rst
               );

    ---------------------------------------------------------------------------
    -- NAME: DOUBLE_SYNC_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Double synchronize data ack and error ack
    ---------------------------------------------------------------------------
    DOUBLE_SYNC_PROCESS: process(Bus2IP_Clk)
    begin

      if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
        if (local_sync_ack_rst = '1') then
          local_sync_ack_d2 <= '0';
          local_sync_ack_d3 <= '0';

          local_sync_errack_d2 <= '0';
          local_sync_errack_d3 <= '0';
        else
          local_sync_ack_d2 <= local_sync_ack_d1;
          local_sync_ack_d3 <= local_sync_ack_d2;

          local_sync_errack_d2 <= local_sync_errack_d1;
          local_sync_errack_d3 <= local_sync_errack_d2;
        end if;
      end if;
    end process DOUBLE_SYNC_PROCESS;

    -- Generate a pulse for data ack and error ack when the synchronous
    -- logic operates on peripheral clock
    ip_sync_ack_i <= local_sync_ack_d2 and not local_sync_ack_d3;
    IP_sync_errack <= local_sync_errack_d2 and not local_sync_errack_d3;

  end generate SYNC_ACK_PRH_CLK_GEN;

  -----------------------------------------------------------------------------
  -- NAME: DEV_ADS_ASSERT_CNT_SEL_PROCESS
  -----------------------------------------------------------------------------
  -- Description: Selects the device ADS assert width count for the currently
  --              selected device
  -----------------------------------------------------------------------------
  DEV_ADS_ASSERT_CNT_SEL_PROCESS: process (Dev_id) is
  begin
    dev_ads_assert_ld_val <= (others => '0');
    for i in 0 to C_NUM_PERIPHERALS-1 loop
      if (Dev_id(i) = '1') then
         dev_ads_assert_ld_val <= ADS_ASSERT_DELAY_CNT_ARRAY(i);
      end if;
    end loop;
  end process DEV_ADS_ASSERT_CNT_SEL_PROCESS;

  -- Generate a counter for device ADS assert delay count
  I_SYNC_DEV_ADS_ASSERT_CNT: entity axi_epc_v2_0.ld_arith_reg
    generic map ( C_ADD_SUB_NOT  => false,
                  C_REG_WIDTH    => MAX_ADS_ASSERT_CNT_WIDTH,
                  C_RESET_VALUE  => DEV_ADS_ASSERT_ADDRCNT_RST_VAL,
                  C_LD_WIDTH     => MAX_ADS_ASSERT_CNT_WIDTH,
                  C_LD_OFFSET    => 0,
                  C_AD_WIDTH     => 1,
                  C_AD_OFFSET    => 0
              )
    port map ( CK             => Local_Clk,
               RST            => Local_Rst,
               Q              => dev_ads_assert_addrcnt,
               LD             => dev_ads_assert_ld_val,
               AD             => "1",
               LOAD           => dev_ads_assert_addrcnt_ld,
               OP             => dev_ads_assert_addrcnt_ce
              );


  -----------------------------------------------------------------------------
  -- NAME: DEV_ADS_DEASSERT_CNT_SEL_PROCESS
  -----------------------------------------------------------------------------
  -- Description: Selects the device ADS deassert width count for the currently
  --              selected device
  -----------------------------------------------------------------------------
  DEV_ADS_DEASSERT_CNT_SEL_PROCESS: process (Dev_id) is
  begin
    dev_ads_deassert_ld_val <= (others => '0');
    for i in 0 to C_NUM_PERIPHERALS-1 loop
      if (Dev_id(i) = '1') then
         dev_ads_deassert_ld_val <= ADS_DEASSERT_DELAY_CNT_ARRAY(i);
      end if;
    end loop;
  end process DEV_ADS_DEASSERT_CNT_SEL_PROCESS;

  -- Generate a counter for device ADS deassert delay count
  I_SYNC_DEV_ADS_DEASSERT_CNT: entity axi_epc_v2_0.ld_arith_reg
    generic map ( C_ADD_SUB_NOT  => false,
                  C_REG_WIDTH    => MAX_ADS_DEASSERT_CNT_WIDTH,
                  C_RESET_VALUE  => DEV_ADS_DEASSERT_ADDRCNT_RST_VAL,
                  C_LD_WIDTH     => MAX_ADS_DEASSERT_CNT_WIDTH,
                  C_LD_OFFSET    => 0,
                  C_AD_WIDTH     => 1,
                  C_AD_OFFSET    => 0
              )
    port map ( CK             => Local_Clk,
               RST            => Local_Rst,
               Q              => dev_ads_deassert_addrcnt,
               LD             => dev_ads_deassert_ld_val,
               AD             => "1",
               LOAD           => dev_ads_deassert_addrcnt_ld,
               OP             => dev_ads_deassert_addrcnt_ce
              );


  -----------------------------------------------------------------------------
  -- NAME: DEV_RDY_CNT_SEL_PROCESS
  -----------------------------------------------------------------------------
  -- Description: Selects the device ready width count for the currently
  --              selected device
  -----------------------------------------------------------------------------
  DEV_RDY_CNT_SEL_PROCESS: process (Dev_id) is
  begin
    dev_rdy_ld_val <= (others => '0');
    for i in 0 to C_NUM_PERIPHERALS-1 loop
      if (Dev_id(i) = '1') then
         dev_rdy_ld_val <= RDY_DELAY_CNT_ARRAY(i);
      end if;
    end loop;
  end process DEV_RDY_CNT_SEL_PROCESS;

  -- Generate a counter for device ready delay count
  I_SYNC_DEV_RDY_CNT: entity axi_epc_v2_0.ld_arith_reg
    generic map ( C_ADD_SUB_NOT  => false,
                  C_REG_WIDTH    => MAX_RDY_CNT_WIDTH,
                  C_RESET_VALUE  => DEV_RDY_ADDRCNT_RST_VAL,
                  C_LD_WIDTH     => MAX_RDY_CNT_WIDTH,
                  C_LD_OFFSET    => 0,
                  C_AD_WIDTH     => 1,
                  C_AD_OFFSET    => 0
              )
    port map ( CK             => Local_Clk,
               RST            => Local_Rst,
               Q              => dev_rdy_addrcnt,
               LD             => dev_rdy_ld_val,
               AD             => "1",
               LOAD           => dev_rdy_addrcnt_ld,
               OP             => dev_rdy_addrcnt_ce
              );

------------------------------------------------------------------------------
-- Qualify the PLB read and write ack

IP_sync_Wrack <= ip_sync_ack_i and (not Dev_rnw);
IP_sync_Rdack <= (ip_sync_ack_i and Dev_rnw);
------------------------------------------------------------------------------
end generate SOME_DEV_SYNC_GEN;
------------------------------------------------------------------------------

end architecture imp;
------------------------------------------------------------------------------
