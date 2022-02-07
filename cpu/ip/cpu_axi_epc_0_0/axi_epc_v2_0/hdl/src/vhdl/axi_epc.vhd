-------------------------------------------------------------------------------
-- axi_epc.vhd - entity/architecture pair
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
-- File          : axi_epc.vhd
-- Company       : Xilinx
-- Version       : v1.00.a
-- Description   : External Peripheral Controller for AXI bus
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
-- Author   : VB
-- History  :
--
--  VB          08-24-2010 --  v2_0 version for AXI 
-- ^^^^^^
--            The core updated for AXI based on axi_epc_v2_0
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
use axi_lite_ipif_v3_0.ipif_pkg.SLV64_ARRAY_TYPE;
use axi_lite_ipif_v3_0.ipif_pkg.calc_num_ce;

library axi_epc_v2_0;


-------------------------------------------------------------------------------
--                     Definition of Generics
-------------------------------------------------------------------------------
-- C_BASEADDR               -- User logic base address
-- C_HIGHADDR               -- User logic high address
-- C_S_AXI_DATA_WIDTH       -- AXI data bus width
-- C_S_AXI_ADDR_WIDTH       -- AXI address bus width
-- C_FAMILY                 -- Default family
-- C_INSTANCE               -- Instance name of the axi_apb_bridge in the
--                          -- system
   ------------------------------------------------------
-- C_S_AXI_CLK_PERIOD_PS      -  The clock period of AXI Clock in picoseconds
-- C_PRH_CLK_PERIOD_PS      -  The clock period of peripheral clock in
--                             picoseconds
   ------------------------------------------------------
-- C_NUM_PERIPHERALS        -  Number of external devices connected to AXI EPC
-- C_PRH_MAX_AWIDTH         -  Maximum of address bus width of all peripherals
-- C_PRH_MAX_DWIDTH         -  Maximum of data bus width of all peripherals
-- C_PRH_MAX_ADWIDTH        -  Maximum of data bus width of all peripherals
--                             and address bus width of peripherals employing
--                             multiplexed address/data bus
-- C_PRH_CLK_SUPPORT        -  Indication of whether the synchronous interface
--                             operates on peripheral clock or on AXI clock
-- C_PRH_BURST_SUPPORT      -  Indicates if the AXI EPC supports burst
-- C_PRH(0:3)_BASEADDR      -  External peripheral (0:3) base address
-- C_PRH(0:3)_HIGHADDR      -  External peripheral (0:3) high address
-- C_PRH(0:3)_FIFO_ACCESS   -  Indicates if the support for accessing FIFO
--                             like structure within external device is
--                             required
-- C_PRH(0:3)_FIFO_OFFSET   -  Byte offset of FIFO from the base address
--                             assigned to peripheral
-- C_PRH(0:3)_AWIDTH        -  External peripheral (0:3) address bus width
-- C_PRH(0:3)_DWIDTH        -  External peripheral (0:3) data bus width
-- C_PRH(0:3)_DWIDTH_MATCH  -  Indication of whether external peripheral (0:3)
--                             supports multiple access cycle on the
--                             peripheral interface for a single AXI cycle
--                             when the peripheral data bus width is less than
--                             that of AXI bus data width
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
--                             edge of read/write signal (non-multiplexed
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
-- C_PRH(0:3)_RDY_WIDTH     -  Maximum wait period for external device (0:3)
--                             ready signal assertion

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                  Definition of Ports
-------------------------------------------------------------------------------

------------------------------------------
-- S_AXI_ACLK            -- AXI Clock
-- S_AXI_ARESETN          -- AXI Reset
-- S_AXI_AWADDR          -- AXI Write address
-- S_AXI_AWVALID         -- Write address valid
-- S_AXI_AWREADY         -- Write address ready
-- S_AXI_WDATA           -- Write data
-- S_AXI_WSTRB           -- Write strobes
-- S_AXI_WVALID          -- Write valid
-- S_AXI_WREADY          -- Write ready
-- S_AXI_BRESP           -- Write response
-- S_AXI_BVALID          -- Write response valid
-- S_AXI_BREADY          -- Response ready
-- S_AXI_ARADDR          -- Read address
-- S_AXI_ARVALID         -- Read address valid
-- S_AXI_ARREADY         -- Read address ready
-- S_AXI_RDATA           -- Read data
-- S_AXI_RRESP           -- Read response
-- S_AXI_RVALID          -- Read valid
-- S_AXI_RREADY          -- Read ready
-----------------------------------------------------
-- PERIPHERAL INTERFACE
-----------------------------------------------------
-- PRH_Clk              -- Peripheral interface clock
-- PRH_Rst              -- Peripheral interface reset
-- PRH_CS_n             -- Peripheral interface chip select
-- PRH_Addr             -- Peripheral interface address bus
-- PRH_ADS              -- Peripheral interface address strobe
-- PRH_BE               -- Peripheral interface byte enables
-- PRH_RNW              -- Peripheral interface read/write control for
--                      -- synchronous interface
-- PRH_Rd_n             -- Peripheral interface read strobe for asynchronous
--                      -- interface
-- PRH_Wr_n             -- Peripheral interface write strobe for asynchronous
--                      -- interface
-- PRH_Burst            -- Peripheral interface burst indication signal
-- PRH_Rdy              -- Peripheral interface device ready signal
-- PRH_Data_I           -- Peripheral interface input data bus
-- PRH_Data_O           -- Peripehral interface output data bus
-- PRH_Data_T           -- 3-state control for peripheral interface output data
--                      -- bus
-------------------------------------------------------------------------------

entity axi_epc is
  generic
  (
      C_S_AXI_CLK_PERIOD_PS  : integer := 10000;
      C_PRH_CLK_PERIOD_PS   : integer := 20000;
      -----------------------------------------
      C_FAMILY                : string                        := "virtex7";
      C_INSTANCE              : string                        := "axi_epc_inst";
      C_S_AXI_ADDR_WIDTH      : integer range 32 to 32   := 32;
      --C_S_AXI_DATA_WIDTH      : integer range 32 to 128  := 32;
      C_S_AXI_DATA_WIDTH      : integer range 32 to 32  := 32;
-----------------------------------------
      C_NUM_PERIPHERALS     : integer range 1 to 4 := 1;
      C_PRH_MAX_AWIDTH      : integer range 3 to 32:= 32;
      C_PRH_MAX_DWIDTH      : integer range 8 to 32:= 32;
      C_PRH_MAX_ADWIDTH     : integer range 8 to 32:= 32;
      C_PRH_CLK_SUPPORT     : integer range 0 to 1 := 0;
      C_PRH_BURST_SUPPORT   : integer              := 0;
      -----------------------------------------
      C_PRH0_BASEADDR       : std_logic_vector := X"A500_0000";
      C_PRH0_HIGHADDR       : std_logic_vector := X"A500_FFFF";

      C_PRH0_FIFO_ACCESS    : integer range 0 to 1:= 0;
      C_PRH0_FIFO_OFFSET    : integer := 0;
      C_PRH0_AWIDTH         : integer range 3 to 32:= 32;
      C_PRH0_DWIDTH         : integer range 8 to 32 := 32;
      C_PRH0_DWIDTH_MATCH   : integer range 0 to 1:= 0;
      C_PRH0_SYNC           : integer range 0 to 1:= 1;
      C_PRH0_BUS_MULTIPLEX  : integer range 0 to 1:= 0;
      C_PRH0_ADDR_TSU       : integer := 0;
      C_PRH0_ADDR_TH        : integer := 0;
      C_PRH0_ADS_WIDTH      : integer := 0;
      C_PRH0_CSN_TSU        : integer := 0;
      C_PRH0_CSN_TH         : integer := 0;
      C_PRH0_WRN_WIDTH      : integer := 0;
      C_PRH0_WR_CYCLE       : integer := 0;
      C_PRH0_DATA_TSU       : integer := 0;
      C_PRH0_DATA_TH        : integer := 0;
      C_PRH0_RDN_WIDTH      : integer := 0;
      C_PRH0_RD_CYCLE       : integer := 0;
      C_PRH0_DATA_TOUT      : integer := 0;
      C_PRH0_DATA_TINV      : integer := 0;
      C_PRH0_RDY_TOUT       : integer := 0;
      C_PRH0_RDY_WIDTH      : integer := 0;

      -----------------------------------------
      C_PRH1_BASEADDR       : std_logic_vector := X"FFFF_FFFF";
      C_PRH1_HIGHADDR       : std_logic_vector := X"0000_0000";

      C_PRH1_FIFO_ACCESS    : integer range 0 to 1:= 0;
      C_PRH1_FIFO_OFFSET    : integer := 0;
      C_PRH1_AWIDTH         : integer range 3 to 32:= 32;
      C_PRH1_DWIDTH         : integer range 8 to 32 := 32;
      C_PRH1_DWIDTH_MATCH   : integer range 0 to 1:= 0;
      C_PRH1_SYNC           : integer range 0 to 1:= 1;
      C_PRH1_BUS_MULTIPLEX  : integer range 0 to 1:= 0;
      C_PRH1_ADDR_TSU       : integer := 0;
      C_PRH1_ADDR_TH        : integer := 0;
      C_PRH1_ADS_WIDTH      : integer := 0;
      C_PRH1_CSN_TSU        : integer := 0;
      C_PRH1_CSN_TH         : integer := 0;
      C_PRH1_WRN_WIDTH      : integer := 0;
      C_PRH1_WR_CYCLE       : integer := 0;
      C_PRH1_DATA_TSU       : integer := 0;
      C_PRH1_DATA_TH        : integer := 0;
      C_PRH1_RDN_WIDTH      : integer := 0;
      C_PRH1_RD_CYCLE       : integer := 0;
      C_PRH1_DATA_TOUT      : integer := 0;
      C_PRH1_DATA_TINV      : integer := 0;
      C_PRH1_RDY_TOUT       : integer := 0;
      C_PRH1_RDY_WIDTH      : integer := 0;

      -----------------------------------------
      C_PRH2_BASEADDR       : std_logic_vector := X"FFFF_FFFF";
      C_PRH2_HIGHADDR       : std_logic_vector := X"0000_0000";

      C_PRH2_FIFO_ACCESS    : integer range 0 to 1:= 0;
      C_PRH2_FIFO_OFFSET    : integer := 0;
      C_PRH2_AWIDTH         : integer range 3 to 32:= 32;
      C_PRH2_DWIDTH         : integer range 8 to 32 := 32;
      C_PRH2_DWIDTH_MATCH   : integer range 0 to 1:= 0;
      C_PRH2_SYNC           : integer range 0 to 1:= 1;
      C_PRH2_BUS_MULTIPLEX  : integer range 0 to 1:= 0;
      C_PRH2_ADDR_TSU       : integer := 0;
      C_PRH2_ADDR_TH        : integer := 0;
      C_PRH2_ADS_WIDTH      : integer := 0;
      C_PRH2_CSN_TSU        : integer := 0;
      C_PRH2_CSN_TH         : integer := 0;
      C_PRH2_WRN_WIDTH      : integer := 0;
      C_PRH2_WR_CYCLE       : integer := 0;
      C_PRH2_DATA_TSU       : integer := 0;
      C_PRH2_DATA_TH        : integer := 0;
      C_PRH2_RDN_WIDTH      : integer := 0;
      C_PRH2_RD_CYCLE       : integer := 0;
      C_PRH2_DATA_TOUT      : integer := 0;
      C_PRH2_DATA_TINV      : integer := 0;
      C_PRH2_RDY_TOUT       : integer := 0;
      C_PRH2_RDY_WIDTH      : integer := 0;

      -----------------------------------------
      C_PRH3_BASEADDR       : std_logic_vector := X"FFFF_FFFF";
      C_PRH3_HIGHADDR       : std_logic_vector := X"0000_0000";

      C_PRH3_FIFO_ACCESS    : integer range 0 to 1:= 0;
      C_PRH3_FIFO_OFFSET    : integer := 0;
      C_PRH3_AWIDTH         : integer range 3 to 32:= 32;
      C_PRH3_DWIDTH         : integer range 8 to 32 := 32;
      C_PRH3_DWIDTH_MATCH   : integer range 0 to 1:= 0;
      C_PRH3_SYNC           : integer range 0 to 1:= 1;
      C_PRH3_BUS_MULTIPLEX  : integer range 0 to 1:= 0;
      C_PRH3_ADDR_TSU       : integer := 0;
      C_PRH3_ADDR_TH        : integer := 0;
      C_PRH3_ADS_WIDTH      : integer := 0;
      C_PRH3_CSN_TSU        : integer := 0;
      C_PRH3_CSN_TH         : integer := 0;
      C_PRH3_WRN_WIDTH      : integer := 0;
      C_PRH3_WR_CYCLE       : integer := 0;
      C_PRH3_DATA_TSU       : integer := 0;
      C_PRH3_DATA_TH        : integer := 0;
      C_PRH3_RDN_WIDTH      : integer := 0;
      C_PRH3_RD_CYCLE       : integer := 0;
      C_PRH3_DATA_TOUT      : integer := 0;
      C_PRH3_DATA_TINV      : integer := 0;
      C_PRH3_RDY_TOUT       : integer := 0;
      C_PRH3_RDY_WIDTH      : integer := 0
      -----------------------------------------
  );
  port
  (
    -- system interface
    s_axi_aclk      : in  std_logic;
    s_axi_aresetn   : in  std_logic;
    -- axi write address channel signals
    s_axi_awaddr    : in  std_logic_vector(31 downto 0);  --((c_s_axi_addr_width-1) downto 0);
    s_axi_awvalid   : in  std_logic;
    s_axi_awready   : out std_logic;
    -- axi write data channel signals
    s_axi_wdata     : in  std_logic_vector(31 downto 0);    --((c_s_axi_data_width-1) downto 0);
    s_axi_wstrb     : in  std_logic_vector(3 downto 0);    --(((c_s_axi_data_width/8)-1) downto 0);
    s_axi_wvalid    : in  std_logic;
    s_axi_wready    : out std_logic;
    -- axi write response channel signals
    s_axi_bresp     : out std_logic_vector(1 downto 0);
    s_axi_bvalid    : out std_logic;
    s_axi_bready    : in  std_logic;
    -- axi read address channel signals
    s_axi_araddr    : in  std_logic_vector(31 downto 0);     --((c_s_axi_addr_width-1) downto 0);
    s_axi_arvalid   : in  std_logic;
    s_axi_arready   : out std_logic;
    -- axi read address channel signals
    s_axi_rdata     : out std_logic_vector(31 downto 0);    --((c_s_axi_data_width-1) downto 0);
    s_axi_rresp     : out std_logic_vector(1 downto 0);
    s_axi_rvalid    : out std_logic;
    s_axi_rready    : in  std_logic;

      -- peripheral interface
    prh_clk                 : in std_logic;
    prh_rst                 : in std_logic;

    prh_cs_n                : out std_logic_vector(0 to C_NUM_PERIPHERALS-1);
    prh_addr                : out std_logic_vector(0 to C_PRH_MAX_AWIDTH-1);
    prh_ads                 : out std_logic;
    prh_be                  : out std_logic_vector(0 to C_PRH_MAX_DWIDTH/8-1);
    prh_rnw                 : out std_logic;
    prh_rd_n                : out std_logic;
    prh_wr_n                : out std_logic;
    prh_burst               : out std_logic;

    prh_rdy                 : in std_logic_vector(0 to C_NUM_PERIPHERALS-1);

    prh_data_i              : in std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1);
    prh_data_o              : out std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1);
    prh_data_t              : out std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1)
  );

-------------------------------------------------------------------------------
-- Attributes
-------------------------------------------------------------------------------

  -- Fan-Out attributes for XST

  ATTRIBUTE MAX_FANOUT                           : string;
  ATTRIBUTE MAX_FANOUT   of s_axi_aclk             : signal is "10000";
  ATTRIBUTE MAX_FANOUT   of s_axi_aresetn             : signal is "10000";
  ATTRIBUTE MAX_FANOUT   of prh_clk              : signal is "10000";
  ATTRIBUTE MAX_FANOUT   of prh_rst              : signal is "10000";

  -----------------------------------------------------------------
  -- Start of PSFUtil MPD attributes
  -----------------------------------------------------------------

  ATTRIBUTE SIGIS                                : string;
  ATTRIBUTE SIGIS of s_axi_aclk                    : signal is "Clk";
  ATTRIBUTE SIGIS of s_axi_aresetn                    : signal is "Rst";
  ATTRIBUTE SIGIS of prh_clk                     : signal is "Clk";
  ATTRIBUTE SIGIS of prh_rst                     : signal is "Rst";

  ATTRIBUTE XRANGE                               : string;
  ATTRIBUTE XRANGE of C_NUM_PERIPHERALS          : constant is "(1:4)";
  ATTRIBUTE XRANGE of C_PRH_BURST_SUPPORT        : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH_CLK_SUPPORT          : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH0_DWIDTH_MATCH        : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH1_DWIDTH_MATCH        : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH2_DWIDTH_MATCH        : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH3_DWIDTH_MATCH        : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH0_BUS_MULTIPLEX       : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH1_BUS_MULTIPLEX       : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH2_BUS_MULTIPLEX       : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH3_BUS_MULTIPLEX       : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH0_SYNC                : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH1_SYNC                : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH2_SYNC                : constant is "(0,1)";
  ATTRIBUTE XRANGE of C_PRH3_SYNC                : constant is "(0,1)";

  ATTRIBUTE XRANGE of C_PRH0_DWIDTH              : constant is "(8,16,32)";
  ATTRIBUTE XRANGE of C_PRH1_DWIDTH              : constant is "(8,16,32)";
  ATTRIBUTE XRANGE of C_PRH2_DWIDTH              : constant is "(8,16,32)";
  ATTRIBUTE XRANGE of C_PRH3_DWIDTH              : constant is "(8,16,32)";
  ATTRIBUTE XRANGE of C_PRH_MAX_AWIDTH           : constant is "(3:32)";
  ATTRIBUTE XRANGE of C_PRH_MAX_DWIDTH           : constant is "(8,16,32)";
  ATTRIBUTE XRANGE of C_PRH_MAX_ADWIDTH          : constant is "(8:32)";

  -----------------------------------------------------------------
  -- end of PSFUtil MPD attributes
  -----------------------------------------------------------------
end entity axi_epc;

-------------------------------------------------------------------------------
-- Architecture Section
-------------------------------------------------------------------------------

architecture imp of axi_epc is

-------------------------------------------------------------------------------
-- Function Declarations
-------------------------------------------------------------------------------
-- NAME: get_effective_val
-------------------------------------------------------------------------------
-- Description: Given two possible values that can be taken by an item and a
--              generic setting that affects the actual value taken by the
--              item, this function  returns the effective value taken by the
--              item depending on the value of the generic. This function
--              is used to calculate the effective data bus width based on
--              data bus width matching generic (C_PRHx_DWIDTH_MATCH) and
--              effective clock period of peripheral clock based on peripheral
--              clock support generic (C_PRH_CLK_SUPPORT)
-------------------------------------------------------------------------------
function get_effective_val(generic_val : integer;
                           value_1     : integer;
                           value_2     : integer)
                           return integer is
    variable effective_val : integer;
begin
    if generic_val = 0 then
        effective_val := value_1;
    else
        effective_val := value_2;
    end if;

return effective_val;
end function get_effective_val;
-------------------------------------------------------------------------------
-- NAME: get_ard_integer_array
-------------------------------------------------------------------------------
-- Description: Given an integer N, and an unconstrained INTEGER_ARRAY return
--              a constrained array of size N with the first N elements of the
--              input array. This function is used to construct IPIF generic
--              ARD_ID_ARRAY, ARD_DWIDTH_ARRAY, ARD_NUM_CE_ARRAY etc.
-------------------------------------------------------------------------------
function get_ard_integer_array( num_peripherals : integer;
                                prh_parameter   : INTEGER_ARRAY_TYPE )
                                return INTEGER_ARRAY_TYPE is

variable integer_array : INTEGER_ARRAY_TYPE(0 to num_peripherals-1);

begin
       for i in 0 to (num_peripherals - 1) loop
         integer_array(i) := prh_parameter(i);
       end loop;

return integer_array;
end function get_ard_integer_array;

-------------------------------------------------------------------------------
-- NAME: get_ard_address_range_array
-------------------------------------------------------------------------------
-- Description: Given an integer N, and an unconstrained INTEGER_ARRAY return
--              a constrained array of size N*2 with the first N*2 elements of
--              the input array. This function is used to construct IPIF
--              generic ARD_ADDR_RANGE_ARRAY
-------------------------------------------------------------------------------
function get_ard_addr_range_array ( num_peripherals      : integer;
                                    prh_addr_range_array : SLV64_ARRAY_TYPE)
                                    return SLV64_ARRAY_TYPE is

variable addr_range_array : SLV64_ARRAY_TYPE(0 to ((num_peripherals * 2) -1));

begin

    for i in 0 to (num_peripherals - 1) loop
       addr_range_array(i*2) := prh_addr_range_array(i*2);
       addr_range_array((i*2)+1) := prh_addr_range_array((i*2)+1);
    end loop;

return addr_range_array;

end function get_ard_addr_range_array;
-------------------------------------------------------------------------------
-- Type Declarations
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
constant MAX_PERIPHERALS : integer := 4;
constant ZERO_ADDR_PAD   : std_logic_vector(0 to 64-C_S_AXI_ADDR_WIDTH-1)
                         := (others => '0');

constant PRH_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE :=
         (
          ZERO_ADDR_PAD & C_PRH0_BASEADDR,
          ZERO_ADDR_PAD & C_PRH0_HIGHADDR,
          ZERO_ADDR_PAD & C_PRH1_BASEADDR,
          ZERO_ADDR_PAD & C_PRH1_HIGHADDR,
          ZERO_ADDR_PAD & C_PRH2_BASEADDR,
          ZERO_ADDR_PAD & C_PRH2_HIGHADDR,
          ZERO_ADDR_PAD & C_PRH3_BASEADDR,
          ZERO_ADDR_PAD & C_PRH3_HIGHADDR
          );

constant ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE :=
                                get_ard_addr_range_array(
                                                         C_NUM_PERIPHERALS,
                                                         PRH_ADDR_RANGE_ARRAY
                                                         );

constant PRH_NUM_CE_ARRAY : INTEGER_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
                            (others => 1);

constant ARD_NUM_CE_ARRAY : INTEGER_ARRAY_TYPE :=
                            get_ard_integer_array(
                                                  C_NUM_PERIPHERALS,
                                                  PRH_NUM_CE_ARRAY
                                                  );

constant PRH_DWIDTH_ARRAY : INTEGER_ARRAY_TYPE :=
    (
    C_PRH0_DWIDTH,
    C_PRH1_DWIDTH,
    C_PRH2_DWIDTH,
    C_PRH3_DWIDTH
    );

constant NUM_ARD : integer := (ARD_ADDR_RANGE_ARRAY'LENGTH/2);
constant NUM_CE : integer := calc_num_ce(ARD_NUM_CE_ARRAY);

constant PRH0_FIFO_OFFSET : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH-1) :=
         conv_std_logic_vector(C_PRH0_FIFO_OFFSET,C_S_AXI_ADDR_WIDTH);
constant PRH1_FIFO_OFFSET : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH-1) :=
         conv_std_logic_vector(C_PRH1_FIFO_OFFSET,C_S_AXI_ADDR_WIDTH);
constant PRH2_FIFO_OFFSET : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH-1) :=
         conv_std_logic_vector(C_PRH2_FIFO_OFFSET,C_S_AXI_ADDR_WIDTH);
constant PRH3_FIFO_OFFSET : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH-1) :=
         conv_std_logic_vector(C_PRH3_FIFO_OFFSET,C_S_AXI_ADDR_WIDTH);


constant PRH0_FIFO_ADDRESS : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH-1) :=
         C_PRH0_BASEADDR or PRH0_FIFO_OFFSET;
constant PRH1_FIFO_ADDRESS : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH-1) :=
         C_PRH1_BASEADDR or PRH1_FIFO_OFFSET;
constant PRH2_FIFO_ADDRESS : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH-1) :=
         C_PRH2_BASEADDR or PRH2_FIFO_OFFSET;
constant PRH3_FIFO_ADDRESS : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH-1) :=
         C_PRH3_BASEADDR or PRH3_FIFO_OFFSET;

constant LOCAL_CLK_PERIOD_PS : integer :=
  get_effective_val(C_PRH_CLK_SUPPORT,C_S_AXI_CLK_PERIOD_PS,C_PRH_CLK_PERIOD_PS);
 -- AXI lite parameters
constant C_S_AXI_EPC_MIN_SIZE  : std_logic_vector(31 downto 0):= X"FFFFFFFF";
constant C_USE_WSTRB              : integer := 1;
constant C_DPHASE_TIMEOUT         : integer := 0;


-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------
--bus2ip signals
signal bus2ip_clk       : std_logic;
signal bus2ip_reset_active_high     : std_logic;
signal bus2ip_reset_active_low     : std_logic;

signal bus2ip_cs        : std_logic_vector(0 to (ARD_ADDR_RANGE_ARRAY'LENGTH/2)-1);
signal bus2ip_rdce      : std_logic_vector(0 to NUM_CE-1);
signal bus2ip_wrce      : std_logic_vector(0 to NUM_CE-1);
signal bus2ip_addr      : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH - 1);
signal bus2ip_rnw       : std_logic;
signal bus2ip_be        : std_logic_vector(0 to (C_S_AXI_DATA_WIDTH / 8) - 1);
signal bus2ip_be_int        : std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
signal bus2ip_data      : std_logic_vector(0 to C_S_AXI_DATA_WIDTH - 1);
signal bus2ip_data_int      : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);

-- ip2bus signals
signal ip2bus_data      : std_logic_vector(0 to C_S_AXI_DATA_WIDTH - 1);
signal ip2bus_data_int      : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
signal ip2bus_wrack     : std_logic;
signal ip2bus_rdack     : std_logic;
signal ip2bus_error     : std_logic;
-- local clock and reset signals
signal local_clk        : std_logic;
signal local_rst        : std_logic;
-- local signals
signal dev_bus2ip_cs    : std_logic_vector(0 to C_NUM_PERIPHERALS-1);
signal dev_bus2ip_rdce  : std_logic_vector(0 to C_NUM_PERIPHERALS-1);
signal dev_bus2ip_wrce  : std_logic_vector(0 to C_NUM_PERIPHERALS-1);
signal dev_bus2ip_addr  : std_logic_vector(0 to C_PRH_MAX_AWIDTH-1);

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- NAME: NO_LCLK_LRST_GEN
-------------------------------------------------------------------------------
-- Description: When the C_PRH_CLK_SUPPORT is disabled use AXI clock and
--              AXI reset as the local clock and local reset respectively.
--              The syncrhonous control logic operates on local clock.
-------------------------------------------------------------------------------
NO_LCLK_LRST_GEN: if  C_PRH_CLK_SUPPORT = 0 generate
  local_clk <= bus2ip_clk;
  local_rst <= bus2ip_reset_active_high;
end generate NO_LCLK_LRST_GEN;
-------------------------------------------------------------------------------
-- NAME: LCLK_LRST_GEN
-------------------------------------------------------------------------------
-- Description: When the C_PRH_CLK_SUPPORT is enabled use external peripheral
--              clock and peripheral reset as the local clock and local reset
--              respectively. The syncrhonous control logic operates on local
--              clock.
-------------------------------------------------------------------------------
LCLK_LRST_GEN: if  C_PRH_CLK_SUPPORT /= 0 generate
  local_clk <= PRH_Clk;
  local_rst <= PRH_Rst;
end generate LCLK_LRST_GEN;
-------------------------------------------------------------------------------
----------------------
--REG_RESET_FROM_IPIF: convert active low to active hig reset to rest of
--                     the core.
----------------------
REG_RESET_FROM_IPIF: process (S_AXI_ACLK) is
begin
     if(S_AXI_ACLK'event and S_AXI_ACLK = '1') then
         bus2ip_reset_active_high <= not(bus2ip_reset_active_low);
     end if;
end process REG_RESET_FROM_IPIF;
----------------------

----------------------------------
-- INSTANTIATE AXI Lite IPIF
----------------------------------
   AXI_LITE_IPIF_I : entity axi_lite_ipif_v3_0.axi_lite_ipif
     generic map
      (
       C_S_AXI_ADDR_WIDTH        => C_S_AXI_ADDR_WIDTH,
       C_S_AXI_DATA_WIDTH        => C_S_AXI_DATA_WIDTH,

       C_S_AXI_MIN_SIZE          => C_S_AXI_EPC_MIN_SIZE,
       C_USE_WSTRB               => C_USE_WSTRB,
       C_DPHASE_TIMEOUT          => C_DPHASE_TIMEOUT,

       C_ARD_ADDR_RANGE_ARRAY    => ARD_ADDR_RANGE_ARRAY,
       C_ARD_NUM_CE_ARRAY        => ARD_NUM_CE_ARRAY,
       C_FAMILY                  => C_FAMILY
      )
     port map
      (
       S_AXI_ACLK                => s_axi_aclk,           -- in
       S_AXI_ARESETN             => s_axi_aresetn,        -- in

       S_AXI_AWADDR              => s_axi_awaddr,         -- in
       S_AXI_AWVALID             => s_axi_awvalid,        -- in
       S_AXI_AWREADY             => s_axi_awready,        -- out
       S_AXI_WDATA               => s_axi_wdata,          -- in
       S_AXI_WSTRB               => s_axi_wstrb,          -- in
       S_AXI_WVALID              => s_axi_wvalid,         -- in
       S_AXI_WREADY              => s_axi_wready,         -- out
       S_AXI_BRESP               => s_axi_bresp,          -- out
       S_AXI_BVALID              => s_axi_bvalid,         -- out
       S_AXI_BREADY              => s_axi_bready,         -- in

       S_AXI_ARADDR              => s_axi_araddr,         -- in
       S_AXI_ARVALID             => s_axi_arvalid,        -- in
       S_AXI_ARREADY             => s_axi_arready,        -- out
       S_AXI_RDATA               => s_axi_rdata,          -- out
       S_AXI_RRESP               => s_axi_rresp,          -- out
       S_AXI_RVALID              => s_axi_rvalid,         -- out
       S_AXI_RREADY              => s_axi_rready,         -- in

 -- IP Interconnect (IPIC) port signals
       Bus2IP_Clk                => bus2ip_clk,           -- out
       Bus2IP_Resetn             => bus2ip_reset_active_low,     -- out

       Bus2IP_Addr               => bus2ip_addr,          -- out
       Bus2IP_RNW                => bus2ip_rnw,                 -- out
       Bus2IP_BE                 => bus2ip_be_int,            -- out
       Bus2IP_CS                 => bus2IP_CS,                -- out
       Bus2IP_RdCE               => bus2ip_rdce,          -- out
       Bus2IP_WrCE               => bus2ip_wrce,          -- out
       Bus2IP_Data               => bus2ip_data_int,          -- out
--       Bus2IP_Data               => bus2ip_data,          -- out

       IP2Bus_Data               => ip2bus_data_int,          -- in
       IP2Bus_WrAck              => ip2bus_wrack,         -- in
       IP2Bus_RdAck              => ip2bus_rdack,         -- in
       IP2Bus_Error              => ip2bus_error          -- in

      );

EPC_CORE_I : entity axi_epc_v2_0.epc_core
  generic map
  (
      C_SPLB_CLK_PERIOD_PS        =>  C_S_AXI_CLK_PERIOD_PS,
      LOCAL_CLK_PERIOD_PS          =>  LOCAL_CLK_PERIOD_PS,
            ----------------       -------------------------
      C_SPLB_AWIDTH           =>  C_S_AXI_ADDR_WIDTH,
      C_SPLB_DWIDTH           =>  C_S_AXI_DATA_WIDTH ,
      C_SPLB_NATIVE_DWIDTH           =>  C_S_AXI_DATA_WIDTH ,
      C_FAMILY                     =>  C_FAMILY,
            ----------------       -------------------------
      C_NUM_PERIPHERALS            =>  C_NUM_PERIPHERALS,
      C_PRH_MAX_AWIDTH             =>  C_PRH_MAX_AWIDTH,
      C_PRH_MAX_DWIDTH             =>  C_PRH_MAX_DWIDTH,
      C_PRH_MAX_ADWIDTH            =>  C_PRH_MAX_ADWIDTH,
      C_PRH_CLK_SUPPORT            =>  C_PRH_CLK_SUPPORT,
      C_PRH_BURST_SUPPORT          =>  C_PRH_BURST_SUPPORT,
            ----------------       -------------------------
      C_PRH0_FIFO_ACCESS           =>  C_PRH0_FIFO_ACCESS,
      C_PRH0_AWIDTH                =>  C_PRH0_AWIDTH,
      C_PRH0_DWIDTH                =>  C_PRH0_DWIDTH,
      C_PRH0_DWIDTH_MATCH          =>  C_PRH0_DWIDTH_MATCH,
      C_PRH0_SYNC                  =>  C_PRH0_SYNC,
      C_PRH0_BUS_MULTIPLEX         =>  C_PRH0_BUS_MULTIPLEX,
      C_PRH0_ADDR_TSU              =>  C_PRH0_ADDR_TSU,
      C_PRH0_ADDR_TH               =>  C_PRH0_ADDR_TH,
      C_PRH0_ADS_WIDTH             =>  C_PRH0_ADS_WIDTH,
      C_PRH0_CSN_TSU               =>  C_PRH0_CSN_TSU,
      C_PRH0_CSN_TH                =>  C_PRH0_CSN_TH,
      C_PRH0_WRN_WIDTH             =>  C_PRH0_WRN_WIDTH,
      C_PRH0_WR_CYCLE              =>  C_PRH0_WR_CYCLE,
      C_PRH0_DATA_TSU              =>  C_PRH0_DATA_TSU,
      C_PRH0_DATA_TH               =>  C_PRH0_DATA_TH,
      C_PRH0_RDN_WIDTH             =>  C_PRH0_RDN_WIDTH,
      C_PRH0_RD_CYCLE              =>  C_PRH0_RD_CYCLE,
      C_PRH0_DATA_TOUT             =>  C_PRH0_DATA_TOUT,
      C_PRH0_DATA_TINV             =>  C_PRH0_DATA_TINV,
      C_PRH0_RDY_TOUT              =>  C_PRH0_RDY_TOUT,
      C_PRH0_RDY_WIDTH             =>  C_PRH0_RDY_WIDTH,
            ----------------       -------------------------
      C_PRH1_FIFO_ACCESS           =>  C_PRH1_FIFO_ACCESS,
      C_PRH1_AWIDTH                =>  C_PRH1_AWIDTH,
      C_PRH1_DWIDTH                =>  C_PRH1_DWIDTH,
      C_PRH1_DWIDTH_MATCH          =>  C_PRH1_DWIDTH_MATCH,
      C_PRH1_SYNC                  =>  C_PRH1_SYNC,
      C_PRH1_BUS_MULTIPLEX         =>  C_PRH1_BUS_MULTIPLEX,
      C_PRH1_ADDR_TSU              =>  C_PRH1_ADDR_TSU,
      C_PRH1_ADDR_TH               =>  C_PRH1_ADDR_TH,
      C_PRH1_ADS_WIDTH             =>  C_PRH1_ADS_WIDTH,
      C_PRH1_CSN_TSU               =>  C_PRH1_CSN_TSU,
      C_PRH1_CSN_TH                =>  C_PRH1_CSN_TH,
      C_PRH1_WRN_WIDTH             =>  C_PRH1_WRN_WIDTH,
      C_PRH1_WR_CYCLE              =>  C_PRH1_WR_CYCLE,
      C_PRH1_DATA_TSU              =>  C_PRH1_DATA_TSU,
      C_PRH1_DATA_TH               =>  C_PRH1_DATA_TH,
      C_PRH1_RDN_WIDTH             =>  C_PRH1_RDN_WIDTH,
      C_PRH1_RD_CYCLE              =>  C_PRH1_RD_CYCLE,
      C_PRH1_DATA_TOUT             =>  C_PRH1_DATA_TOUT,
      C_PRH1_DATA_TINV             =>  C_PRH1_DATA_TINV,
      C_PRH1_RDY_TOUT              =>  C_PRH1_RDY_TOUT,
      C_PRH1_RDY_WIDTH             =>  C_PRH1_RDY_WIDTH,
            ----------------       -------------------------
      C_PRH2_FIFO_ACCESS           =>  C_PRH2_FIFO_ACCESS,
      C_PRH2_AWIDTH                =>  C_PRH2_AWIDTH,
      C_PRH2_DWIDTH                =>  C_PRH2_DWIDTH,
      C_PRH2_DWIDTH_MATCH          =>  C_PRH2_DWIDTH_MATCH,
      C_PRH2_SYNC                  =>  C_PRH2_SYNC,
      C_PRH2_BUS_MULTIPLEX         =>  C_PRH2_BUS_MULTIPLEX,
      C_PRH2_ADDR_TSU              =>  C_PRH2_ADDR_TSU,
      C_PRH2_ADDR_TH               =>  C_PRH2_ADDR_TH,
      C_PRH2_ADS_WIDTH             =>  C_PRH2_ADS_WIDTH,
      C_PRH2_CSN_TSU               =>  C_PRH2_CSN_TSU,
      C_PRH2_CSN_TH                =>  C_PRH2_CSN_TH,
      C_PRH2_WRN_WIDTH             =>  C_PRH2_WRN_WIDTH,
      C_PRH2_WR_CYCLE              =>  C_PRH2_WR_CYCLE,
      C_PRH2_DATA_TSU              =>  C_PRH2_DATA_TSU,
      C_PRH2_DATA_TH               =>  C_PRH2_DATA_TH,
      C_PRH2_RDN_WIDTH             =>  C_PRH2_RDN_WIDTH,
      C_PRH2_RD_CYCLE              =>  C_PRH2_RD_CYCLE,
      C_PRH2_DATA_TOUT             =>  C_PRH2_DATA_TOUT,
      C_PRH2_DATA_TINV             =>  C_PRH2_DATA_TINV,
      C_PRH2_RDY_TOUT              =>  C_PRH2_RDY_TOUT,
      C_PRH2_RDY_WIDTH             =>  C_PRH2_RDY_WIDTH,
            ----------------       -------------------------
      C_PRH3_FIFO_ACCESS           =>  C_PRH3_FIFO_ACCESS,
      C_PRH3_AWIDTH                =>  C_PRH3_AWIDTH,
      C_PRH3_DWIDTH                =>  C_PRH3_DWIDTH,
      C_PRH3_DWIDTH_MATCH          =>  C_PRH3_DWIDTH_MATCH,
      C_PRH3_SYNC                  =>  C_PRH3_SYNC,
      C_PRH3_BUS_MULTIPLEX         =>  C_PRH3_BUS_MULTIPLEX,
      C_PRH3_ADDR_TSU              =>  C_PRH3_ADDR_TSU,
      C_PRH3_ADDR_TH               =>  C_PRH3_ADDR_TH,
      C_PRH3_ADS_WIDTH             =>  C_PRH3_ADS_WIDTH,
      C_PRH3_CSN_TSU               =>  C_PRH3_CSN_TSU,
      C_PRH3_CSN_TH                =>  C_PRH3_CSN_TH,
      C_PRH3_WRN_WIDTH             =>  C_PRH3_WRN_WIDTH,
      C_PRH3_WR_CYCLE              =>  C_PRH3_WR_CYCLE,
      C_PRH3_DATA_TSU              =>  C_PRH3_DATA_TSU,
      C_PRH3_DATA_TH               =>  C_PRH3_DATA_TH,
      C_PRH3_RDN_WIDTH             =>  C_PRH3_RDN_WIDTH,
      C_PRH3_RD_CYCLE              =>  C_PRH3_RD_CYCLE,
      C_PRH3_DATA_TOUT             =>  C_PRH3_DATA_TOUT,
      C_PRH3_DATA_TINV             =>  C_PRH3_DATA_TINV,
      C_PRH3_RDY_TOUT              =>  C_PRH3_RDY_TOUT,
      C_PRH3_RDY_WIDTH             =>  C_PRH3_RDY_WIDTH,
            ----------------       -------------------------
      MAX_PERIPHERALS              =>  MAX_PERIPHERALS,
      PRH0_FIFO_ADDRESS            =>  PRH0_FIFO_ADDRESS,
      PRH1_FIFO_ADDRESS            =>  PRH1_FIFO_ADDRESS,
      PRH2_FIFO_ADDRESS            =>  PRH2_FIFO_ADDRESS,
      PRH3_FIFO_ADDRESS            =>  PRH3_FIFO_ADDRESS
            ----------------       -------------------------
  )

  port map (
      -- IP Interconnect (IPIC) port signals ----------
      Bus2IP_Clk                  => bus2ip_clk,
      Bus2IP_Rst                  => bus2ip_reset_active_high,
      Bus2IP_CS                   => dev_bus2ip_cs,
      Bus2IP_RdCE                 => dev_bus2ip_rdce,
      Bus2IP_WrCE                 => dev_bus2ip_wrce,
      Bus2IP_Addr                 => dev_bus2ip_addr,
      Bus2IP_RNW                  => bus2ip_rnw,
      Bus2IP_BE                   => bus2ip_be,
      Bus2IP_Data                 => bus2ip_data,
      -- ip2bus signals ---------------------------------------------------
      IP2Bus_Data                 => ip2bus_data,
      IP2Bus_WrAck                => ip2bus_wrack,
      IP2Bus_RdAck                => ip2bus_rdack,
      IP2Bus_Error                => ip2bus_error,
            ----------------       -------------------------
      Local_Clk                   => local_clk,
      Local_Rst                   => local_rst,
      PRH_CS_n                    => prh_cs_n,
      PRH_Addr                    => prh_addr,
      PRH_ADS                     => prh_ads,
      PRH_BE                      => prh_be,
      PRH_RNW                     => prh_rnw,
      PRH_Rd_n                    => prh_rd_n,
      PRH_Wr_n                    => prh_wr_n,
      PRH_Burst                   => prh_burst,
      PRH_Rdy                     => prh_rdy,
      PRH_Data_I                  => prh_data_i,
      PRH_Data_O                  => prh_data_o,
      PRH_Data_T                  => prh_data_t
);


dev_bus2ip_cs <= bus2ip_cs((NUM_ARD - C_NUM_PERIPHERALS) to (NUM_ARD -1));

-- Fix the number of CEs per device as one
dev_bus2ip_rdce <= bus2ip_rdce((NUM_CE - C_NUM_PERIPHERALS) to (NUM_CE -1));
dev_bus2ip_wrce <= bus2ip_wrce((NUM_CE - C_NUM_PERIPHERALS) to (NUM_CE -1));

dev_bus2ip_addr <= bus2ip_addr(C_S_AXI_ADDR_WIDTH-C_PRH_MAX_AWIDTH to C_S_AXI_ADDR_WIDTH-1);



-- Little endian to bigendian conversion because the EPC core is in bigendian
PRH_DWIDTH_PROCESS: process (dev_bus2ip_cs, ip2bus_data, bus2ip_data_int, bus2ip_be_int) is
begin
  bus2ip_data <= (others => '0');
  ip2bus_data_int <= (others => '0');
  bus2ip_be <= (others => '0');
  for i in 0 to C_NUM_PERIPHERALS-1 loop
    if (dev_bus2ip_cs(i) = '1') then
         case PRH_DWIDTH_ARRAY(i) is
           when 8  =>
              bus2ip_data(0 to 7) <= bus2ip_data_int(7 downto 0);
              bus2ip_data(8 to 15) <= bus2ip_data_int(15 downto 8);
              bus2ip_data(16 to 23) <= bus2ip_data_int(23 downto 16);
              bus2ip_data(24 to 31) <= bus2ip_data_int(31 downto 24);
             
              ip2bus_data_int(7 downto 0) <= ip2bus_data(0 to 7);
              ip2bus_data_int(15 downto 8) <= ip2bus_data(8 to 15);
              ip2bus_data_int(23 downto 16) <= ip2bus_data(16 to 23);
              ip2bus_data_int(31 downto 24) <= ip2bus_data(24 to 31);

              bus2ip_be(0) <= bus2ip_be_int(0);
              bus2ip_be(1) <= bus2ip_be_int(1);
              bus2ip_be(2) <= bus2ip_be_int(2);
              bus2ip_be(3) <= bus2ip_be_int(3);
           when 16 =>
              bus2ip_data(0 to 15) <= bus2ip_data_int(15 downto 0);
              bus2ip_data(16 to 31) <= bus2ip_data_int(31 downto 16);

              ip2bus_data_int(31 downto 16) <= ip2bus_data(16 to 31);
              ip2bus_data_int(15 downto 0) <= ip2bus_data(0 to 15);
              
              bus2ip_be(0 to 1) <= bus2ip_be_int(1 downto 0);
              bus2ip_be(2 to 3) <= bus2ip_be_int(3 downto 2);
           when 32 =>
              bus2ip_data <= bus2ip_data_int;
 
              ip2bus_data_int <= ip2bus_data;
              bus2ip_be <= bus2ip_be_int;
         -- coverage off
           when others =>
              bus2ip_data <= bus2ip_data_int;
               
              ip2bus_data_int <= ip2bus_data;
              bus2ip_be <= bus2ip_be_int;
        -- coverage on
        end case;

    end if;
  end loop;
end process PRH_DWIDTH_PROCESS;



end architecture imp;
--------------------------------end of file------------------------------------
