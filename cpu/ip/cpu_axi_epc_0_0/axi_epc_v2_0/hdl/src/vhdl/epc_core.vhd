
-------------------------------------------------------------------------------
-- epc_core.vhd - entity/architecture pair
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
-- File          : epc_core.vhd
-- Company       : Xilinx
-- Version       : v1.00.a
-- Description   : External Peripheral Controller for AXI epc core interface
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

library axi_lite_ipif_v3_0;
use axi_lite_ipif_v3_0.ipif_pkg.INTEGER_ARRAY_TYPE;


library axi_epc_v2_0;


-------------------------------------------------------------------------------
--                     Definition of Generics :                              --
-------------------------------------------------------------------------------
-- C_SPLB_CLK_PERIOD_PS      -  The clock period of PLB Clock in picoseconds
-- C_SPLB_AWIDTH            -  Address width of PLB BUS.
-- C_SPLB_DWIDTH            -  Data width of PLB BUS.
-- C_FAMILY                 -  FPGA Family for which the external peripheral
--                             controller is targeted
-- C_NUM_PERIPHERALS        -  Number of external devices connected to XPS EPC
-- C_PRH_MAX_AWIDTH         -  Maximum of address bus width of all peripherals
-- C_PRH_MAX_DWIDTH         -  Maximum of data bus width of all peripherals
-- C_PRH_MAX_ADWIDTH        -  Maximum of data bus width of all peripherals
--                             and address bus width of peripherals employing
--                             multiplexed address/data bus
-- C_PRH_CLK_SUPPORT        -  Indication of whether the synchronous interface
--                             operates on peripheral clock or on XPSclock
-- C_PRH_BURST_SUPPORT      -  Indicates if the XPS EPC supports burst
-- C_PRH(0:3)_FIFO_ACCESS   -  Indicates if the support for accessing FIFO
--                             like structure within external device is
--                             required
-- C_PRH(0:3)_FIFO_OFFSET   -  Byte offset of FIFO from the base address
--                             assigned to peripheral
-- C_PRH(0:3)_AWIDTH        -  External peripheral (0:3) address bus width
-- C_PRH(0:3)_DWIDTH        -  External peripheral (0:3) data bus width
-- C_PRH(0:3)_DWIDTH_MATCH  -  Indication of whether external peripheral (0:3)
--                             supports multiple access cycle on the
--                             peripheral interface for a single XPScycle
--                             when the peripheral data bus width is less than
--                             that of XPSbus data width
-- C_PRH(0:3)_SYNC          -  Indicates if the external device (0:3) uses
--                             synchronous or asynchronous interface
-- C_PRH(0:3)_BUS_MULTIPLEX -  Indicates if the external device (0:3) uses a
--                             multiplexed or non-multiplexed device
-- C_PRH(0:3)_ADDR_TSU      -  External device (0:3) address setup time with
--                             respect  to rising edge of address strobe
--                             (multiplexed address and data bus) or falling
--                             edge of  read/write signal (non-multiplexed
--                             address/data bus)
-- C_PRH(0:3)_ADDR_TH       -  External device (0:3) address hold time with
--                             respect to rising edge of address strobe
--                             (multiplexed address and data bus) or rising
--                             edge of  read/write signal (non-multiplexed
--                             address/data bus)
-- C_PRH(0:3)_ADS_WIDTH     -  Minimum pulse width of address strobe
-- C_PRH(0:3)_CSN_TSU       -  External device (0:3) chip select setup time
--                             with  respect to falling edge of read/write
--                             signal
-- C_PRH(0:3)_CSN_TH        -  External device (0:3) chip select hold time with
--                             respect to rising edge of read/write signal
-- C_PRH(0:3)_WRN_WIDTH     -  External device (0:3) write signal minimum
--                             pulse width
-- C_PRH(0:3)_WR_CYCLE      -  External device (0:3) write cycle time
-- C_PRH(0:3)_DATA_TSU      -  External device (0:3) data bus setup with
--                             respect to rising edge of write signal
-- C_PRH(0:3)_DATA_TH       -  External device (0:3) data bus hold  with
--                             respect to rising edge of write signal
-- C_PRH(0:3)_RDN_WIDTH     -  External device (0:3) read signal minimum
--                             pulse width
-- C_PRH(0:3)_RD_CYCLE      -  External device (0:3) read cycle time
-- C_PRH(0:3)_DATA_TOUT     -  External device (0:3) data bus validity with
--                             respect to falling edge of read signal
-- C_PRH(0:3)_DATA_TINV     -  External device (0:3) data bus high impedence
--                             with respect to rising edge of read signal
-- C_PRH(0:3)_RDY_TOUT      -  External device (0:3) device ready validity from
--                             falling edge of read/write signal
-- C_PRH(0:3)_RDY_WIDTH     -  Maximimum wait period for external device (0:3)
--                             ready signal assertion
-- LOCAL_CLK_PERIOD_PS      -  The clock period of operating clock for
--                             synchronous interface in picoseconds
-- MAX_PERIPHERALS          -  Maximum number of peripherals supported by the
--                             external peripheral controller
-- PRH(0:3)_FIFO_ADDRESS    -  The address of external peripheral device FIFO
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                     Definition of Ports                                   --
-------------------------------------------------------------------------------
----------------------------------------
-- IPIC INTERFACE
----------------------------------------
-- Bus2IP_Clk            - IPIC clock
-- Bus2IP_Rst            - IPIC reset
-- Bus2IP_CS             - IPIC chip select signals
-- Bus2IP_RdCE           - IPIC read transaction chip enables
-- Bus2IP_WrCE           - IPIC write transaction chip enables
-- Bus2IP_Addr           - IPIC address
-- Bus2IP_RNW            - IPIC read/write indication
-- Bus2IP_BE             - IPIC byte enables
-- Bus2IP_Data           - IPIC write data

-- IP2Bus_Data           - Read data from IP to IPIC interface
-- IP2Bus_WrAck          - Write Data acknowledgment from IP to IPIC interface
-- IP2Bus_RdAck          - Read Data acknowledgment from IP to IPIC interface
-- IP2Bus_Error          - Error indication from IP to IPIC interface
----------------------------------------
-- PERIPHERAL INTERFACE
----------------------------------------
-- Local_Clk             - Operational clock for peripheral interface
-- Local_Rst             - Reset for peripheral interface
-- PRH_CS_n              - Peripheral interface chip select
-- PRH_Addr              - Peripheral interface address bus
-- PRH_ADS               - Peripheral interface address strobe
-- PRH_BE                - Peripheral interface byte enables
-- PRH_RNW               - Peripheral interface read/write control for
--                         synchronous interface
-- PRH_Rd_n              - Peripheral interface read strobe for asynchronous
--                         interface
-- PRH_Wr_n              - Peripheral interface write strobe for asynchronous
--                         interface
-- PRH_Burst             - Peripheral interface burst indication signal
-- PRH_Rdy               - Peripheral interface device ready signal
-- PRH_Data_I            - Peripheral interface input data bus
-- PRH_Data_O            - Peripehral interface output data bus
-- PRH_Data_T            - 3-state control for peripheral interface output data
--                         bus
-------------------------------------------------------------------------------

entity epc_core is
  generic (
      C_SPLB_CLK_PERIOD_PS   : integer;
      LOCAL_CLK_PERIOD_PS   : integer;
      ----------------      -------------------------
      C_SPLB_AWIDTH         : integer;
      C_SPLB_DWIDTH         : integer;
      C_SPLB_NATIVE_DWIDTH  : integer;
      C_FAMILY              : string;
      ----------------      -------------------------
      C_NUM_PERIPHERALS     : integer;
      C_PRH_MAX_AWIDTH      : integer;
      C_PRH_MAX_DWIDTH      : integer;
      C_PRH_MAX_ADWIDTH     : integer;
      C_PRH_CLK_SUPPORT     : integer;
      C_PRH_BURST_SUPPORT   : integer;
      ----------------      -------------------------
      C_PRH0_FIFO_ACCESS    : integer;
      C_PRH0_AWIDTH         : integer;
      C_PRH0_DWIDTH         : integer;
      C_PRH0_DWIDTH_MATCH   : integer;
      C_PRH0_SYNC           : integer;
      C_PRH0_BUS_MULTIPLEX  : integer;
      C_PRH0_ADDR_TSU       : integer;
      C_PRH0_ADDR_TH        : integer;
      C_PRH0_ADS_WIDTH      : integer;
      C_PRH0_CSN_TSU        : integer;
      C_PRH0_CSN_TH         : integer;
      C_PRH0_WRN_WIDTH      : integer;
      C_PRH0_WR_CYCLE       : integer;
      C_PRH0_DATA_TSU       : integer;
      C_PRH0_DATA_TH        : integer;
      C_PRH0_RDN_WIDTH      : integer;
      C_PRH0_RD_CYCLE       : integer;
      C_PRH0_DATA_TOUT      : integer;
      C_PRH0_DATA_TINV      : integer;
      C_PRH0_RDY_TOUT       : integer;
      C_PRH0_RDY_WIDTH      : integer;
      ----------------      -------------------------
      C_PRH1_FIFO_ACCESS    : integer;
      C_PRH1_AWIDTH         : integer;
      C_PRH1_DWIDTH         : integer;
      C_PRH1_DWIDTH_MATCH   : integer;
      C_PRH1_SYNC           : integer;
      C_PRH1_BUS_MULTIPLEX  : integer;
      C_PRH1_ADDR_TSU       : integer;
      C_PRH1_ADDR_TH        : integer;
      C_PRH1_ADS_WIDTH      : integer;
      C_PRH1_CSN_TSU        : integer;
      C_PRH1_CSN_TH         : integer;
      C_PRH1_WRN_WIDTH      : integer;
      C_PRH1_WR_CYCLE       : integer;
      C_PRH1_DATA_TSU       : integer;
      C_PRH1_DATA_TH        : integer;
      C_PRH1_RDN_WIDTH      : integer;
      C_PRH1_RD_CYCLE       : integer;
      C_PRH1_DATA_TOUT      : integer;
      C_PRH1_DATA_TINV      : integer;
      C_PRH1_RDY_TOUT       : integer;
      C_PRH1_RDY_WIDTH      : integer;
      ----------------      -------------------------
      C_PRH2_FIFO_ACCESS    : integer;
      C_PRH2_AWIDTH         : integer;
      C_PRH2_DWIDTH         : integer;
      C_PRH2_DWIDTH_MATCH   : integer;
      C_PRH2_SYNC           : integer;
      C_PRH2_BUS_MULTIPLEX  : integer;
      C_PRH2_ADDR_TSU       : integer;
      C_PRH2_ADDR_TH        : integer;
      C_PRH2_ADS_WIDTH      : integer;
      C_PRH2_CSN_TSU        : integer;
      C_PRH2_CSN_TH         : integer;
      C_PRH2_WRN_WIDTH      : integer;
      C_PRH2_WR_CYCLE       : integer;
      C_PRH2_DATA_TSU       : integer;
      C_PRH2_DATA_TH        : integer;
      C_PRH2_RDN_WIDTH      : integer;
      C_PRH2_RD_CYCLE       : integer;
      C_PRH2_DATA_TOUT      : integer;
      C_PRH2_DATA_TINV      : integer;
      C_PRH2_RDY_TOUT       : integer;
      C_PRH2_RDY_WIDTH      : integer;
      ----------------      -------------------------
      C_PRH3_FIFO_ACCESS    : integer;
      C_PRH3_AWIDTH         : integer;
      C_PRH3_DWIDTH         : integer;
      C_PRH3_DWIDTH_MATCH   : integer;
      C_PRH3_SYNC           : integer;
      C_PRH3_BUS_MULTIPLEX  : integer;
      C_PRH3_ADDR_TSU       : integer;
      C_PRH3_ADDR_TH        : integer;
      C_PRH3_ADS_WIDTH      : integer;
      C_PRH3_CSN_TSU        : integer;
      C_PRH3_CSN_TH         : integer;
      C_PRH3_WRN_WIDTH      : integer;
      C_PRH3_WR_CYCLE       : integer;
      C_PRH3_DATA_TSU       : integer;
      C_PRH3_DATA_TH        : integer;
      C_PRH3_RDN_WIDTH      : integer;
      C_PRH3_RD_CYCLE       : integer;
      C_PRH3_DATA_TOUT      : integer;
      C_PRH3_DATA_TINV      : integer;
      C_PRH3_RDY_TOUT       : integer;
      C_PRH3_RDY_WIDTH      : integer;
      ----------------      -------------------------
      MAX_PERIPHERALS       : integer;
      PRH0_FIFO_ADDRESS     : std_logic_vector;
      PRH1_FIFO_ADDRESS     : std_logic_vector;
      PRH2_FIFO_ADDRESS     : std_logic_vector;
      PRH3_FIFO_ADDRESS     : std_logic_vector
      ----------------      -------------------------
    );

  port (

     Bus2IP_Clk        : in  std_logic;
     Bus2IP_Rst        : in  std_logic;
     -- IPIC interface
     Bus2IP_CS         : in std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     Bus2IP_RdCE       : in std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     Bus2IP_WrCE       : in std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     Bus2IP_Addr       : in std_logic_vector(0 to C_PRH_MAX_AWIDTH-1);
     Bus2IP_RNW        : in std_logic;
     Bus2IP_BE         : in std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8-1);
     Bus2IP_Data       : in std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1);

     IP2Bus_Data       : out std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH-1);
     IP2Bus_WrAck      : out std_logic;
     IP2Bus_RdAck      : out std_logic;
     IP2Bus_Error      : out std_logic;

     -- Clock and Reset for peripheral interface
     Local_Clk         : in std_logic;
     Local_Rst         : in std_logic;

     -- Peripheral interface
     PRH_CS_n          : out std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     PRH_Addr          : out std_logic_vector(0 to C_PRH_MAX_AWIDTH-1);
     PRH_ADS           : out std_logic;
     PRH_BE            : out std_logic_vector(0 to C_PRH_MAX_DWIDTH/8-1);
     PRH_RNW           : out std_logic;
     PRH_Rd_n          : out std_logic;
     PRH_Wr_n          : out std_logic;
     PRH_Burst         : out std_logic;

     PRH_Rdy           : in std_logic_vector(0 to C_NUM_PERIPHERALS-1);

     PRH_Data_I        : in std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1);
     PRH_Data_O        : out std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1);
     PRH_Data_T        : out std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1)
    );
end entity epc_core;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture imp of epc_core is

-------------------------------------------------------------------------------
-- Function Declaration
-------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- NAME: all_zeros
-----------------------------------------------------------------------------
-- Description: Given an array returns an integer value of '1' if all elements
--              of the array are zero. Returns '0' otherwise
-----------------------------------------------------------------------------
function all_zeros ( array_size : integer;
                     int_array : INTEGER_ARRAY_TYPE) return integer is
variable temp : integer := 1;
begin

  for i in 0 to  (array_size-1) loop
    if int_array(i) = 1 then 
    	temp := 0;
    end if;
  end loop;

  return temp;
end function all_zeros;

-----------------------------------------------------------------------------
-- NAME: all_ones
-----------------------------------------------------------------------------
-- Description: Given an array returns an integer value of '1' if all elements
--              of the array are one. Returns '0' otherwise
-----------------------------------------------------------------------------
function all_ones ( array_size : integer;
                    int_array : INTEGER_ARRAY_TYPE) return integer is
variable temp : integer := 1;
begin

  for i in 0 to  (array_size-1) loop
    if int_array(i) = 0 then 
    	temp := 0;
    end if;
  end loop;

  return temp;
end function all_ones;

-----------------------------------------------------------------------------
-- NAME: IntArray_to_StdLogicVec
-----------------------------------------------------------------------------
-- Description: Given an array returns an std_logic_vector, where each
--              element of the vector represents a value of '0' if the
--              corresponding integer in the array is 0. Else, the vector
--              value denotes a '1'
-----------------------------------------------------------------------------
function IntArray_to_StdLogicVec ( array_size : integer;
                                   int_array : INTEGER_ARRAY_TYPE)
                                   return std_logic_vector is
variable temp : std_logic_vector(0 to array_size-1);
begin

  for i in 0 to  (array_size - 1) loop
    if int_array(i) = 0 then 
    	temp(i) := '0';
    else 
    	temp(i) := '1';
    end if;
  end loop;

  return temp;
end function IntArray_to_StdLogicVec;

-------------------------------------------------------------------------------
-- Type Declarations
-------------------------------------------------------------------------------
type SLV32_ARRAY_TYPE is array (natural range <>) of
                     std_logic_vector(0 to C_SPLB_AWIDTH-1);

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
constant ADDRCNT_WIDTH : integer := 2;

constant PRH_SYNC_ARRAY : INTEGER_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
         ( C_PRH0_SYNC,
           C_PRH1_SYNC,
           C_PRH2_SYNC,
           C_PRH3_SYNC
         );

constant NO_PRH_SYNC  : integer := all_zeros(C_NUM_PERIPHERALS, PRH_SYNC_ARRAY);
constant NO_PRH_ASYNC : integer := all_ones(C_NUM_PERIPHERALS, PRH_SYNC_ARRAY);

constant PRH_SYNC : std_logic_vector :=
                    IntArray_to_StdLogicVec(MAX_PERIPHERALS,
                                            PRH_SYNC_ARRAY);

constant PRH_BUS_MULTIPLEX_ARRAY : INTEGER_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
         ( C_PRH0_BUS_MULTIPLEX,
           C_PRH1_BUS_MULTIPLEX,
           C_PRH2_BUS_MULTIPLEX,
           C_PRH3_BUS_MULTIPLEX
         );

constant NO_PRH_BUS_MULTIPLEX : integer := all_zeros(C_NUM_PERIPHERALS,
                                                     PRH_BUS_MULTIPLEX_ARRAY);
constant PRH_BUS_MULTIPLEX : std_logic_vector :=
                             IntArray_to_StdLogicVec(MAX_PERIPHERALS,
                                                     PRH_BUS_MULTIPLEX_ARRAY);

constant PRH_DWIDTH_MATCH_ARRAY: INTEGER_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
         ( C_PRH0_DWIDTH_MATCH,
           C_PRH1_DWIDTH_MATCH,
           C_PRH2_DWIDTH_MATCH,
           C_PRH3_DWIDTH_MATCH
         );

constant NO_PRH_DWIDTH_MATCH  : integer := all_zeros(C_NUM_PERIPHERALS,
                                                     PRH_DWIDTH_MATCH_ARRAY);
constant ALL_PRH_DWIDTH_MATCH : integer := all_ones(C_NUM_PERIPHERALS,
                                                    PRH_DWIDTH_MATCH_ARRAY);
constant PRH_DWIDTH_MATCH : std_logic_vector :=
                            IntArray_to_StdLogicVec(MAX_PERIPHERALS,
                                                    PRH_DWIDTH_MATCH_ARRAY);

constant PRH_FIFO_ACCESS_ARRAY : INTEGER_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
         ( C_PRH0_FIFO_ACCESS,
           C_PRH1_FIFO_ACCESS,
           C_PRH2_FIFO_ACCESS,
           C_PRH3_FIFO_ACCESS
         );

constant PRH_FIFO_ADDRESS_ARRAY : SLV32_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
         ( PRH0_FIFO_ADDRESS,
           PRH1_FIFO_ADDRESS,
           PRH2_FIFO_ADDRESS,
           PRH3_FIFO_ADDRESS
         );

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------

signal ipic_sync_req       : std_logic;
signal ip_sync_req_rst     : std_logic;
signal ipic_async_req      : std_logic;

signal ip_sync_Wrack       : std_logic;
signal ip_sync_Rdack       : std_logic;
signal ipic_sync_ack_rst   : std_logic;
signal ip_async_Wrack      : std_logic;
signal ip_async_Rdack      : std_logic;

signal ip_sync_error       : std_logic;
signal ip_async_error      : std_logic;

signal dev_id              : std_logic_vector(0 to C_NUM_PERIPHERALS-1);
signal dev_in_access       : std_logic;
signal dev_sync_in_access  : std_logic;
signal dev_async_in_access : std_logic;
signal dev_sync            : std_logic;
signal dev_rnw             : std_logic;
signal dev_bus_multiplex   : std_logic;
signal dev_dwidth_match    : std_logic;
signal dev_dbus_width      : std_logic_vector(0 to 2);

signal async_addr_cnt_ld   : std_logic;
signal async_addr_cnt_ce   : std_logic;
signal sync_addr_cnt_ld    : std_logic;
signal sync_addr_cnt_ce    : std_logic;
signal async_en            : std_logic;
signal async_ce            : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8-1);
signal sync_en             : std_logic;
signal sync_ce             : std_logic_vector(0 to C_SPLB_NATIVE_DWIDTH/8-1);
signal addr_suffix         : std_logic_vector(0 to ADDRCNT_WIDTH-1);
signal steer_index         : std_logic_vector(0 to ADDRCNT_WIDTH-1);

signal dev_rdy             : std_logic;
signal sync_ads            : std_logic;
signal sync_cs_n           : std_logic_vector(0 to C_NUM_PERIPHERALS-1);
signal sync_rnw            : std_logic;
signal sync_burst          : std_logic;
signal sync_addr_ph        : std_logic;
signal sync_data_oe        : std_logic;

signal async_ads           : std_logic;
signal async_cs_n          : std_logic_vector(0 to C_NUM_PERIPHERALS-1);
signal async_rd_n          : std_logic;
signal async_wr_n          : std_logic;
signal async_addr_ph       : std_logic;
signal async_data_oe       : std_logic;

signal addr_int            : std_logic_vector(0 to C_PRH_MAX_AWIDTH-1);
signal data_int            : std_logic_vector(0 to C_PRH_MAX_DWIDTH-1);
signal prh_data_in         : std_logic_vector(0 to C_PRH_MAX_DWIDTH-1);

signal fifo_access         : std_logic := '0';
signal dev_fifo_access     : std_logic := '0';

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
begin

IPIC_DECODE_I : entity axi_epc_v2_0.ipic_if_decode

  generic map (
    C_SPLB_DWIDTH           => C_SPLB_DWIDTH,

    C_NUM_PERIPHERALS       => C_NUM_PERIPHERALS,
    C_PRH_CLK_SUPPORT       => C_PRH_CLK_SUPPORT,
    -----------------------------------------
    C_PRH0_DWIDTH_MATCH     => C_PRH0_DWIDTH_MATCH,
    C_PRH1_DWIDTH_MATCH     => C_PRH1_DWIDTH_MATCH,
    C_PRH2_DWIDTH_MATCH     => C_PRH2_DWIDTH_MATCH,
    C_PRH3_DWIDTH_MATCH     => C_PRH3_DWIDTH_MATCH,
    -----------------------------------------
    C_PRH0_DWIDTH           => C_PRH0_DWIDTH,
    C_PRH1_DWIDTH           => C_PRH1_DWIDTH,
    C_PRH2_DWIDTH           => C_PRH2_DWIDTH,
    C_PRH3_DWIDTH           => C_PRH3_DWIDTH,
    -----------------------------------------
    MAX_PERIPHERALS         => MAX_PERIPHERALS,
    NO_PRH_SYNC             => NO_PRH_SYNC,
    NO_PRH_ASYNC            => NO_PRH_ASYNC,
    PRH_SYNC                => PRH_SYNC,
    -----------------------------------------
    NO_PRH_BUS_MULTIPLEX    => NO_PRH_BUS_MULTIPLEX,
    PRH_BUS_MULTIPLEX       => PRH_BUS_MULTIPLEX,
    NO_PRH_DWIDTH_MATCH     => NO_PRH_DWIDTH_MATCH,
    PRH_DWIDTH_MATCH        => PRH_DWIDTH_MATCH
  )

  port map (
    Bus2IP_Clk              => Bus2IP_Clk,
    Bus2IP_Rst              => Bus2IP_Rst,
    ------------------------------------------
    Local_Clk               => Local_Clk,
    Local_Rst               => Local_Rst,
    ------------------------------------------
    Bus2IP_CS               => Bus2IP_CS,
    Bus2IP_RNW              => Bus2IP_RNW,
    ------------------------------------------
    IP2Bus_WrAck            => IP2Bus_WrAck,
    IP2Bus_RdAck            => IP2Bus_RdAck,
    IP2Bus_Error            => IP2Bus_Error,
    ------------------------------------------
    FIFO_access             => fifo_access,
    ------------------------------------------
    Dev_id                  => dev_id,
    Dev_fifo_access         => dev_fifo_access,
    Dev_in_access           => dev_in_access,
    Dev_sync_in_access      => dev_sync_in_access,
    Dev_async_in_access     => dev_async_in_access,
    Dev_sync                => dev_sync,
    Dev_rnw                 => dev_rnw,
    Dev_bus_multiplex       => dev_bus_multiplex,
    Dev_dwidth_match        => dev_dwidth_match,
    Dev_dbus_width          => dev_dbus_width,
    ------------------------------------------
    IPIC_sync_req           => ipic_sync_req,
    IPIC_async_req          => ipic_async_req,
    IP_sync_req_rst         => ip_sync_req_rst,
    ------------------------------------------
    IP_sync_Wrack           => ip_sync_Wrack,
    IP_sync_Rdack           => ip_sync_Rdack,
    IPIC_sync_ack_rst       => ipic_sync_ack_rst,
    ------------------------------------------
    IP_async_Wrack          => ip_async_Wrack,
    IP_async_Rdack          => ip_async_Rdack,
    ------------------------------------------
    IP_sync_error           => ip_sync_error,
    IP_async_error          => ip_async_error
   );

SYNC_CNTL_I : entity axi_epc_v2_0.sync_cntl

  generic map (
    C_SPLB_NATIVE_DWIDTH    => C_SPLB_NATIVE_DWIDTH,
    C_NUM_PERIPHERALS       => C_NUM_PERIPHERALS,
    C_PRH_CLK_SUPPORT       => C_PRH_CLK_SUPPORT,
    -----------------------------------------
    C_PRH0_ADDR_TSU         => C_PRH0_ADDR_TSU,
    C_PRH1_ADDR_TSU         => C_PRH1_ADDR_TSU,
    C_PRH2_ADDR_TSU         => C_PRH2_ADDR_TSU,
    C_PRH3_ADDR_TSU         => C_PRH3_ADDR_TSU,
    -----------------------------------------
    C_PRH0_ADDR_TH          => C_PRH0_ADDR_TH,
    C_PRH1_ADDR_TH          => C_PRH1_ADDR_TH,
    C_PRH2_ADDR_TH          => C_PRH2_ADDR_TH,
    C_PRH3_ADDR_TH          => C_PRH3_ADDR_TH,
    -----------------------------------------
    C_PRH0_ADS_WIDTH        => C_PRH0_ADS_WIDTH,
    C_PRH1_ADS_WIDTH        => C_PRH1_ADS_WIDTH,
    C_PRH2_ADS_WIDTH        => C_PRH2_ADS_WIDTH,
    C_PRH3_ADS_WIDTH        => C_PRH3_ADS_WIDTH,
    -----------------------------------------
    C_PRH0_RDY_WIDTH        => C_PRH0_RDY_WIDTH,
    C_PRH1_RDY_WIDTH        => C_PRH1_RDY_WIDTH,
    C_PRH2_RDY_WIDTH        => C_PRH2_RDY_WIDTH,
    C_PRH3_RDY_WIDTH        => C_PRH3_RDY_WIDTH,
    -----------------------------------------
    LOCAL_CLK_PERIOD_PS     => LOCAL_CLK_PERIOD_PS,
    MAX_PERIPHERALS         => MAX_PERIPHERALS,
    ADDRCNT_WIDTH           => ADDRCNT_WIDTH,
    NO_PRH_SYNC             => NO_PRH_SYNC,
    PRH_SYNC                => PRH_SYNC,
    NO_PRH_DWIDTH_MATCH     => NO_PRH_DWIDTH_MATCH
  )

  port map (
    Bus2IP_Clk              => Bus2IP_Clk,
    Bus2IP_Rst              => Bus2IP_Rst,
    ------------------------------------------
    Local_Clk               => Local_Clk,
    Local_Rst               => Local_Rst,
    ------------------------------------------
    Bus2IP_BE               => Bus2IP_BE,
    ------------------------------------------
    Dev_id                  => dev_id,
    Dev_fifo_access         => dev_fifo_access,
    Dev_in_access           => dev_sync_in_access,
    Dev_rnw                 => dev_rnw,
    Dev_bus_multiplex       => dev_bus_multiplex,
    Dev_dwidth_match        => dev_dwidth_match,
    Dev_dbus_width          => dev_dbus_width,
    ------------------------------------------
    IPIC_sync_req           => ipic_sync_req,
    IP_sync_req_rst         => ip_sync_req_rst,
    ------------------------------------------
    IP_sync_Wrack           => ip_sync_Wrack,
    IP_sync_Rdack           => ip_sync_Rdack,
    IPIC_sync_ack_rst       => ipic_sync_ack_rst,
    ------------------------------------------
    IP_sync_errack          => ip_sync_error,
    ------------------------------------------
    Sync_addr_cnt_ld        => sync_addr_cnt_ld,
    Sync_addr_cnt_ce        => sync_addr_cnt_ce,
    ------------------------------------------
    Sync_en                 => sync_en,
    Sync_ce                 => sync_ce,
    ------------------------------------------
    Steer_index             => steer_index,
    ------------------------------------------
    Dev_Rdy                 => dev_rdy,
    ------------------------------------------
    Sync_ADS                => sync_ads,
    Sync_CS_n               => sync_cs_n,
    Sync_RNW                => sync_rnw,
    Sync_Burst              => sync_burst,
    ------------------------------------------
    Sync_addr_ph            => sync_addr_ph,
    Sync_data_oe            => sync_data_oe
  );

ASYNC_CNTL_I : entity axi_epc_v2_0.async_cntl
  generic map (
    PRH_SYNC               =>  PRH_SYNC,
    NO_PRH_ASYNC           =>  NO_PRH_ASYNC,
    C_SPLB_NATIVE_DWIDTH   =>  C_SPLB_NATIVE_DWIDTH,
    ------------------------------------------
    C_PRH0_ADDR_TSU        => C_PRH0_ADDR_TSU,
    C_PRH0_ADDR_TH         => C_PRH0_ADDR_TH,
    C_PRH0_WRN_WIDTH       => C_PRH0_WRN_WIDTH,
    C_PRH0_DATA_TSU        => C_PRH0_DATA_TSU,
    C_PRH0_RDN_WIDTH       => C_PRH0_RDN_WIDTH,
    C_PRH0_DATA_TOUT       => C_PRH0_DATA_TOUT,
    C_PRH0_DATA_TH         => C_PRH0_DATA_TH,
    C_PRH0_DATA_TINV       => C_PRH0_DATA_TINV,
    C_PRH0_RDY_TOUT        => C_PRH0_RDY_TOUT,
    C_PRH0_RDY_WIDTH       => C_PRH0_RDY_WIDTH,
    C_PRH0_ADS_WIDTH       => C_PRH0_ADS_WIDTH,
    C_PRH0_CSN_TSU         => C_PRH0_CSN_TSU,
    C_PRH0_CSN_TH          => C_PRH0_CSN_TH,
    C_PRH0_WR_CYCLE        => C_PRH0_WR_CYCLE,
    C_PRH0_RD_CYCLE        => C_PRH0_RD_CYCLE,
    ------------------------------------------
    C_PRH1_ADDR_TSU        => C_PRH1_ADDR_TSU,
    C_PRH1_ADDR_TH         => C_PRH1_ADDR_TH,
    C_PRH1_WRN_WIDTH       => C_PRH1_WRN_WIDTH,
    C_PRH1_DATA_TSU        => C_PRH1_DATA_TSU,
    C_PRH1_RDN_WIDTH       => C_PRH1_RDN_WIDTH,
    C_PRH1_DATA_TOUT       => C_PRH1_DATA_TOUT,
    C_PRH1_DATA_TH         => C_PRH1_DATA_TH,
    C_PRH1_DATA_TINV       => C_PRH1_DATA_TINV,
    C_PRH1_RDY_TOUT        => C_PRH1_RDY_TOUT,
    C_PRH1_RDY_WIDTH       => C_PRH1_RDY_WIDTH,
    C_PRH1_ADS_WIDTH       => C_PRH1_ADS_WIDTH,
    C_PRH1_CSN_TSU         => C_PRH1_CSN_TSU,
    C_PRH1_CSN_TH          => C_PRH1_CSN_TH,
    C_PRH1_WR_CYCLE        => C_PRH1_WR_CYCLE,
    C_PRH1_RD_CYCLE        => C_PRH1_RD_CYCLE,
    ------------------------------------------
    C_PRH2_ADDR_TSU        => C_PRH2_ADDR_TSU,
    C_PRH2_ADDR_TH         => C_PRH2_ADDR_TH,
    C_PRH2_WRN_WIDTH       => C_PRH2_WRN_WIDTH,
    C_PRH2_DATA_TSU        => C_PRH2_DATA_TSU,
    C_PRH2_RDN_WIDTH       => C_PRH2_RDN_WIDTH,
    C_PRH2_DATA_TOUT       => C_PRH2_DATA_TOUT,
    C_PRH2_DATA_TH         => C_PRH2_DATA_TH,
    C_PRH2_DATA_TINV       => C_PRH2_DATA_TINV,
    C_PRH2_RDY_TOUT        => C_PRH2_RDY_TOUT,
    C_PRH2_RDY_WIDTH       => C_PRH2_RDY_WIDTH,
    C_PRH2_ADS_WIDTH       => C_PRH2_ADS_WIDTH,
    C_PRH2_CSN_TSU         => C_PRH2_CSN_TSU,
    C_PRH2_CSN_TH          => C_PRH2_CSN_TH,
    C_PRH2_WR_CYCLE        => C_PRH2_WR_CYCLE,
    C_PRH2_RD_CYCLE        => C_PRH2_RD_CYCLE,
    ------------------------------------------
    C_PRH3_ADDR_TSU        => C_PRH3_ADDR_TSU,
    C_PRH3_ADDR_TH         => C_PRH3_ADDR_TH,
    C_PRH3_WRN_WIDTH       => C_PRH3_WRN_WIDTH,
    C_PRH3_DATA_TSU        => C_PRH3_DATA_TSU,
    C_PRH3_RDN_WIDTH       => C_PRH3_RDN_WIDTH,
    C_PRH3_DATA_TOUT       => C_PRH3_DATA_TOUT,
    C_PRH3_DATA_TH         => C_PRH3_DATA_TH,
    C_PRH3_DATA_TINV       => C_PRH3_DATA_TINV,
    C_PRH3_RDY_TOUT        => C_PRH3_RDY_TOUT,
    C_PRH3_RDY_WIDTH       => C_PRH3_RDY_WIDTH,
    C_PRH3_ADS_WIDTH       => C_PRH3_ADS_WIDTH,
    C_PRH3_CSN_TSU         => C_PRH3_CSN_TSU,
    C_PRH3_CSN_TH          => C_PRH3_CSN_TH,
    C_PRH3_WR_CYCLE        => C_PRH3_WR_CYCLE,
    C_PRH3_RD_CYCLE        => C_PRH3_RD_CYCLE,
    ------------------------------------------
    C_BUS_CLOCK_PERIOD_PS  => C_SPLB_CLK_PERIOD_PS,
--    C_MAX_DWIDTH           => C_PRH_MAX_DWIDTH,
    C_NUM_PERIPHERALS      => C_NUM_PERIPHERALS,
    C_MAX_PERIPHERALS      => MAX_PERIPHERALS
    ------------------------------------------
  )

 port map(
    Bus2IP_CS              => Bus2IP_CS,
    Bus2IP_RdCE            => Bus2IP_RdCE,
    Bus2IP_WrCE            => Bus2IP_WrCE,
    Bus2IP_BE              => Bus2IP_BE,
    Bus2IP_RNW             => Bus2IP_RNW,
    ------------------------------------------
    IPIC_Asynch_req        => ipic_async_req,
    Dev_FIFO_access        => dev_fifo_access,
    Dev_in_access          => dev_async_in_access,
    ------------------------------------------
    Asynch_prh_rdy         => dev_rdy,
    Dev_dwidth_match       => dev_dwidth_match,
--    Dev_dbus_width         => dev_dbus_width,
    Dev_bus_multiplexed    => dev_bus_multiplex,
    Asynch_ce              => async_ce,
    ------------------------------------------
    Asynch_Wrack           => ip_async_Wrack,
    Asynch_Rdack           => ip_async_Rdack,
    Asynch_error           => ip_async_error,
    ------------------------------------------
    Asynch_Wr              => async_wr_n,
    Asynch_Rd              => async_rd_n,
    Asynch_en              => async_en,
    ------------------------------------------
    Asynch_addr_strobe     => async_ads,
    Asynch_addr_data_sel   => async_addr_ph,
    Asynch_data_sel        => async_data_oe,
    Asynch_chip_select     => async_cs_n,
    Asynch_addr_cnt_ld     => async_addr_cnt_ld,
    Asynch_addr_cnt_en     => async_addr_cnt_ce,
    ------------------------------------------
    Clk                    => Bus2IP_Clk,
    Rst                    => Bus2IP_Rst
);

ADDRESS_GEN_I: entity axi_epc_v2_0.address_gen

  generic map (
     C_PRH_MAX_AWIDTH       => C_PRH_MAX_AWIDTH,
     NO_PRH_DWIDTH_MATCH    => NO_PRH_DWIDTH_MATCH,
     NO_PRH_SYNC            => NO_PRH_SYNC,
     NO_PRH_ASYNC           => NO_PRH_ASYNC,
     ADDRCNT_WIDTH          => ADDRCNT_WIDTH
  )

  port map (
    Bus2IP_Clk              => Bus2IP_Clk,
    Bus2IP_Rst              => Bus2IP_Rst,
    ------------------------------------------
    Local_Clk               => Local_Clk,
    Local_Rst               => Local_Rst,
    ------------------------------------------
    Bus2IP_Addr             => bus2ip_addr,
    ------------------------------------------
    Dev_fifo_access         => dev_fifo_access,
    Dev_sync                => dev_sync,
    Dev_dwidth_match        => dev_dwidth_match,
    Dev_dbus_width          => dev_dbus_width,
    ------------------------------------------
    Async_addr_cnt_ld       => async_addr_cnt_ld,
    Async_addr_cnt_ce       => async_addr_cnt_ce,
    ------------------------------------------
    Sync_addr_cnt_ld        => sync_addr_cnt_ld,
    Sync_addr_cnt_ce        => sync_addr_cnt_ce,
    ------------------------------------------
    Addr_Int                => addr_int,
    Addr_suffix             => addr_suffix

  );

DATA_STEER_I: entity axi_epc_v2_0.data_steer

  generic map (
     C_SPLB_NATIVE_DWIDTH  => C_SPLB_NATIVE_DWIDTH,
     C_PRH_MAX_DWIDTH      => C_PRH_MAX_DWIDTH,
     ALL_PRH_DWIDTH_MATCH  => ALL_PRH_DWIDTH_MATCH,
     NO_PRH_DWIDTH_MATCH   => NO_PRH_DWIDTH_MATCH,
     NO_PRH_SYNC           => NO_PRH_SYNC,
     NO_PRH_ASYNC          => NO_PRH_ASYNC,
     ADDRCNT_WIDTH         => ADDRCNT_WIDTH
  )

  port map (

     Bus2IP_Clk            => Bus2IP_Clk,
     Bus2IP_Rst            => Bus2IP_Rst,
    ------------------------------------------
     Local_Clk             => Local_Clk,
     Local_Rst             => Local_Rst,
    ------------------------------------------
     Bus2IP_RNW            => Bus2IP_RNW,
     Bus2IP_BE             => Bus2IP_BE,
     Bus2IP_Data           => Bus2IP_Data,
    ------------------------------------------
     Dev_in_access         => dev_in_access,
     Dev_sync              => dev_sync,
     Dev_rnw               => dev_rnw,
     Dev_dwidth_match      => dev_dwidth_match,
     Dev_dbus_width        => dev_dbus_width,
    ------------------------------------------
     Addr_suffix           => addr_suffix,
     Steer_index           => steer_index,
    ------------------------------------------
     Async_en              => async_en,
     Async_ce              => async_ce,
    ------------------------------------------
     Sync_en               => sync_en,
     Sync_ce               => sync_ce,
    ------------------------------------------
     PRH_Data_In           => prh_data_in,
     PRH_BE                => PRH_BE,
    ------------------------------------------
     Data_Int              => data_int,
     IP2Bus_Data           => IP2Bus_Data,
     Dev_bus_multiplex         => Dev_bus_multiplex
  );


ACCESS_MUX_I : entity axi_epc_v2_0.access_mux

  generic map (
    C_NUM_PERIPHERALS      => C_NUM_PERIPHERALS,
    C_PRH_MAX_AWIDTH       => C_PRH_MAX_AWIDTH,
    C_PRH_MAX_DWIDTH       => C_PRH_MAX_DWIDTH,
    C_PRH_MAX_ADWIDTH      => C_PRH_MAX_ADWIDTH,
    ------------------------------------------
    C_PRH0_AWIDTH          => C_PRH0_AWIDTH,
    C_PRH1_AWIDTH          => C_PRH1_AWIDTH,
    C_PRH2_AWIDTH          => C_PRH2_AWIDTH,
    C_PRH3_AWIDTH          => C_PRH3_AWIDTH,
    ------------------------------------------
    C_PRH0_DWIDTH          => C_PRH0_DWIDTH,
    C_PRH1_DWIDTH          => C_PRH1_DWIDTH,
    C_PRH2_DWIDTH          => C_PRH2_DWIDTH,
    C_PRH3_DWIDTH          => C_PRH3_DWIDTH,
    ------------------------------------------
    C_PRH0_BUS_MULTIPLEX   => C_PRH0_BUS_MULTIPLEX,
    C_PRH1_BUS_MULTIPLEX   => C_PRH1_BUS_MULTIPLEX,
    C_PRH2_BUS_MULTIPLEX   => C_PRH2_BUS_MULTIPLEX,
    C_PRH3_BUS_MULTIPLEX   => C_PRH3_BUS_MULTIPLEX,
    ------------------------------------------
    MAX_PERIPHERALS        => MAX_PERIPHERALS,
    NO_PRH_SYNC            => NO_PRH_SYNC,
    NO_PRH_ASYNC           => NO_PRH_ASYNC,
    NO_PRH_BUS_MULTIPLEX   => NO_PRH_BUS_MULTIPLEX
  )

  port map (
    Local_Clk              => Local_Clk,
    Dev_id                 => dev_id,
    ------------------------------------------
    Sync_CS_n              => sync_cs_n,
    Sync_ADS               => sync_ads,
    Sync_RNW               => sync_rnw,
    Sync_Burst             => sync_burst,
    Sync_addr_ph           => sync_addr_ph,
    Sync_data_oe           => sync_data_oe,
    ------------------------------------------
    Async_CS_n             => async_cs_n,
    Async_ADS              => async_ads,
    Async_Rd_n             => async_rd_n,
    Async_Wr_n             => async_wr_n,
    Async_addr_ph          => async_addr_ph,
    Async_data_oe          => async_data_oe,
    ------------------------------------------
    Addr_Int               => addr_int,
    Data_Int               => data_int,
    ------------------------------------------
    PRH_CS_n               => PRH_CS_n,
    PRH_ADS                => PRH_ADS,
    PRH_RNW                => PRH_RNW,
    PRH_Rd_n               => PRH_Rd_n,
    PRH_Wr_n               => PRH_Wr_n,
    PRH_Burst              => PRH_Burst,
    ------------------------------------------
    PRH_Rdy                => PRH_Rdy,
    Dev_Rdy                => dev_rdy,
    ------------------------------------------
    PRH_Addr               => PRH_Addr,
    PRH_Data_O             => PRH_Data_O,
    PRH_Data_T             => PRH_Data_T
  );


prh_data_in <= PRH_Data_I(0 to C_PRH_MAX_DWIDTH-1);

-------------------------------------------------------------------------------
-- NAME: DEV_FIFO_ACCESS_PROCESS
-------------------------------------------------------------------------------
-- Description: Generate an indication to the internal modules that the
--              current transaction is to a FIFO like structure
-------------------------------------------------------------------------------
DEV_FIFO_ACCESS_PROCESS: process (Bus2IP_CS, Bus2IP_Addr) is
begin
   fifo_access <= '0';
   for i in 0 to C_NUM_PERIPHERALS-1 loop
     if (Bus2IP_CS(i) = '1') then
       if ( (PRH_FIFO_ACCESS_ARRAY(i) = 1) and
            (Bus2IP_Addr = PRH_FIFO_ADDRESS_ARRAY(i)
                           (C_SPLB_AWIDTH-C_PRH_MAX_AWIDTH to C_SPLB_AWIDTH-1))
          ) then
            fifo_access <= '1';
        end if;
     end if;
   end loop;
end process DEV_FIFO_ACCESS_PROCESS;

end architecture imp;
--------------------------------end of file------------------------------------
