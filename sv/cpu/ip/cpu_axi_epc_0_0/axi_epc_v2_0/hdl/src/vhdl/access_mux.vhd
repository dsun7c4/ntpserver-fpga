
-------------------------------------------------------------------------------
-- access_mux.vhd - entity/architecture pair
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
-- File          : access_mux.vhd
-- Company       : Xilinx
-- Version       : v1.00.a
-- Description   : Multiplexes the device ready signal from external periphera.
--              -- It also multiplexes the address and data bus to be driven out
--              -- to the external peripheral devices
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

library axi_lite_ipif_v3_0;
use axi_lite_ipif_v3_0.ipif_pkg.INTEGER_ARRAY_TYPE;             

-------------------------------------------------------------------------------
--                     Definition of Generics                                --
-------------------------------------------------------------------------------
-- C_NUM_PERIPHERALS        -  No of peripherals currently configured
-- C_PRH_MAX_AWIDTH         -  Maximum of address bus width of all peripherals
-- C_PRH_MAX_DWIDTH         -  Maximum of data bus width of all peripherals
-- C_PRH_MAX_ADWIDTH        -  Maximum of data bus width of all peripherals and
--                          -  address bus width of peripherals employing bus
--                          -  multiplexing
-- C_PRH(0:3)_AWIDTH        -  Address bus width of peripherals
-- C_PRH(0:3)_DWIDTH        -  Data bus width of peripherals
-- C_PRH(0:3)_BUS_MULTIPLEX -  Indication if the peripheral employs address/data
--                          -  bus multiplexing
-- MAX_PERIPHERALS          -  Maximum no of peripherals supported by external
--                          -  peripheral controller
-- NO_PRH_SYNC              -  Indicates all devices are configured for
--                             asynchronous interface
-- NO_PRH_ASYNC             -  Indicates all devices are configured for
--                             synchronous interface
-- NO_PRH_BUS_MULTIPLEX     -  Indicates that no device is employing
--                             multiplexed bus for address and data
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                     Definition of Ports                                   --
-------------------------------------------------------------------------------
-- Dev_id                - The decoded identification vector for the currently
--                       - selected device
-- Dev_sync              - Indicates if the current device being accessed
--                         is synchronous device
-- Dev_dbus_width        - Indicates the data bus width of current device
-- Sync_CS_n             - Chip select signals for the peripherals
--                       - from synchronous control
-- Sync_ADS              - Address strobe from synchronous control
-- Sync_RNW              - Read/Write control from synchronous control
-- Sync_Burst            - Burst indication from synchronous control
-- Sync_addr_ph          - Address phase indication from synchronous control
--                         in case of multiplexed address and data bus
-- Sync_data_oe          - Data bus output enable from synchronous control
-- Async_CS_n            - Chip select signals for the peripherals from
--                       - asynchronous control
-- Async_ADS             - Address strobe from asynchronous control
-- Async_Rd_n            - Read control from asynchronous control
-- Async_Wr_n            - Write control from asynchronous control
-- Async_addr_ph         - Address phase indication from asynchronous control
--                         in case of multiplexed address and data bus
-- Async_data_oe         - Data bus output enable from asynchronous control
-- Addr_Int              - Internal peripheral address bus
-- Data_Int              - Internal peripheral data bus
-- PRH_CS_n              - Peripheral chip select signals
-- PRH_ADS               - Peripheral address strobe
-- PRH_RNW               - Peripheral read/write control
-- PRH_Rd_n              - Peripheral read strobe
-- PRH_Wr_n              - Peripheral write strobe
-- PRH_Burst             - Peripheral burst indication
-- PRH_Rdy               - Peripheral ready indication
-- Dev_Rdy               - Device ready indication from currently selected
--                       - device driven to internal logic
-- PRH_Addr              - Peripheral address bus
-- PRH_Data_O            - Peripheral output data bus
-- PRH_Data_T            - 3-state control for peripheral output data bus
-------------------------------------------------------------------------------


entity access_mux is
  generic (
      C_NUM_PERIPHERALS    : integer;
      C_PRH_MAX_AWIDTH     : integer;
      C_PRH_MAX_DWIDTH     : integer;
      C_PRH_MAX_ADWIDTH    : integer;

      C_PRH0_AWIDTH        : integer;
      C_PRH1_AWIDTH        : integer;
      C_PRH2_AWIDTH        : integer;
      C_PRH3_AWIDTH        : integer;

      C_PRH0_DWIDTH        : integer;
      C_PRH1_DWIDTH        : integer;
      C_PRH2_DWIDTH        : integer;
      C_PRH3_DWIDTH        : integer;

      C_PRH0_BUS_MULTIPLEX : integer;
      C_PRH1_BUS_MULTIPLEX : integer;
      C_PRH2_BUS_MULTIPLEX : integer;
      C_PRH3_BUS_MULTIPLEX : integer;

      MAX_PERIPHERALS      : integer;
      NO_PRH_SYNC          : integer;
      NO_PRH_ASYNC         : integer;
      NO_PRH_BUS_MULTIPLEX : integer
  );

  port (
     Local_Clk          : in  std_logic;

     Dev_id             : in  std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     --Dev_sync           : in  std_logic;
     --Dev_dbus_width     : in  std_logic_vector(0 to 2);

     Sync_CS_n          : in  std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     Sync_ADS           : in  std_logic;
     Sync_RNW           : in  std_logic;
     Sync_Burst         : in  std_logic;
     Sync_addr_ph       : in  std_logic;
     Sync_data_oe       : in  std_logic;

     Async_CS_n         : in  std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     Async_ADS          : in  std_logic;
     Async_Rd_n         : in  std_logic;
     Async_Wr_n         : in  std_logic;
     Async_addr_ph      : in  std_logic;
     Async_data_oe      : in  std_logic;

     Addr_Int           : in  std_logic_vector(0 to C_PRH_MAX_AWIDTH-1);
     Data_Int           : in  std_logic_vector(0 to C_PRH_MAX_DWIDTH-1);

     PRH_CS_n           : out std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     PRH_ADS            : out std_logic;
     PRH_RNW            : out std_logic;
     PRH_Rd_n           : out std_logic;
     PRH_Wr_n           : out std_logic;
     PRH_Burst          : out std_logic;

     PRH_Rdy            : in  std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     Dev_Rdy            : out std_logic;

     PRH_Addr           : out std_logic_vector(0 to C_PRH_MAX_AWIDTH-1);
     PRH_Data_O         : out std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1);
     PRH_Data_T         : out std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1)

    );
end entity access_mux;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture imp of access_mux is

-------------------------------------------------------------------------------
-- Function Declarations
-------------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- NAME: get_adbus_width
  -----------------------------------------------------------------------------
  -- Description: XPS EPC supports bus multiplexing. If bus is multiplexed
  --              the value of data bus width will be maximum of address bus
  --              and data bus of the device.
  -----------------------------------------------------------------------------
  function get_adbus_width (bmux        : integer;
                            awidth      : integer;
                            dwidth      : integer)
                            return integer is
    variable adwidth : integer;
    begin
      if bmux = 0 then
        adwidth := dwidth;
      else
        if dwidth > awidth then
          adwidth := dwidth;
        else
          adwidth := awidth;
        end if;
      end if;

    return adwidth;
  end function get_adbus_width;

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------

constant PRH_ADWIDTH_ARRAY : INTEGER_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
         ( get_adbus_width(C_PRH0_BUS_MULTIPLEX, C_PRH0_AWIDTH, C_PRH0_DWIDTH),
           get_adbus_width(C_PRH1_BUS_MULTIPLEX, C_PRH1_AWIDTH, C_PRH1_DWIDTH),
           get_adbus_width(C_PRH2_BUS_MULTIPLEX, C_PRH2_AWIDTH, C_PRH2_DWIDTH),
           get_adbus_width(C_PRH3_BUS_MULTIPLEX, C_PRH3_AWIDTH, C_PRH3_DWIDTH)
         );

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------

signal addr_ph         : std_logic := '0';

signal addr_out        : std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1) :=
                         (others => '0');
signal data_out        : std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1) :=
                         (others => '0');
--
signal sync_data_oe_i  : std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1) :=
                         (others => '0');
signal async_data_oe_i : std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1) :=
                         (others => '0');
signal sync_async_data_oe_i : std_logic_vector(0 to C_PRH_MAX_ADWIDTH-1) :=
                         (others => '0');
signal prh_cs_n_i      : std_logic_vector(0 to C_NUM_PERIPHERALS-1);
--
-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
begin

-------------------------------------------------------------------------------
-- NAME: ALL_DEV_SYNC_GEN
-------------------------------------------------------------------------------
-- Description: All devices are configured as synchronous devices
-------------------------------------------------------------------------------
ALL_DEV_SYNC_GEN: if NO_PRH_ASYNC = 1 generate

  REG_PRH_SIGS40 : process(Local_Clk)
  begin
  if(Local_Clk'event and Local_Clk = '1')then
      PRH_CS_n   <= Sync_CS_n;
      PRH_ADS    <= Sync_ADS;
      PRH_RNW    <= Sync_RNW;
      PRH_Rd_n   <= '1';
      PRH_Wr_n   <= '1';
      PRH_Burst  <= Sync_Burst;
   end if;
  end process REG_PRH_SIGS40;

  -----------------------------------------------------------------------------
  -- NAME: REG_PRH_SIGS41
  -----------------------------------------------------------------------------
  -- Description: register output data bus enable for each bit in sync mode
  -----------------------------------------------------------------------------
  REG_PRH_SIGS41 : process(Local_Clk)
  begin
  if (Local_Clk'event and Local_Clk = '1')then
     for i in 0 to C_PRH_MAX_ADWIDTH-1 loop
         sync_data_oe_i(i) <= not (Sync_data_oe);
     end loop;
  end if;
  end process REG_PRH_SIGS41;
  -----------------------------------------------------------------------------
  -- NAME: PRH_DATA_T_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate output data bus enable for each bit of data bus
  -----------------------------------------------------------------------------
  PRH_DATA_T_GEN: for i in 0 to C_PRH_MAX_ADWIDTH-1 generate
    PRH_Data_T(i) <= sync_data_oe_i(i);
  end generate PRH_DATA_T_GEN;

end generate ALL_DEV_SYNC_GEN;

-------------------------------------------------------------------------------
-- NAME: ALL_DEV_ASYNC_GEN
-------------------------------------------------------------------------------
-- Description: All devices are configured as asynchronous devices
-------------------------------------------------------------------------------
ALL_DEV_ASYNC_GEN: if NO_PRH_SYNC = 1 generate
  REG_PRH_SIGS42 : process(Local_Clk)
  begin
  if(Local_Clk'event and Local_Clk = '1')then
      PRH_CS_n   <= Async_CS_n;
      PRH_ADS    <= Async_ADS;
      PRH_RNW    <= '1';
      PRH_Rd_n   <= Async_Rd_n;
      PRH_Wr_n   <= Async_Wr_n;
      PRH_Burst  <= '0';
  end if;
  end process REG_PRH_SIGS42;

  -----------------------------------------------------------------------------
  -- NAME: PRH_DATA_T_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate output data bus enable for each bit of data bus
  -----------------------------------------------------------------------------
  REG_PRH_SIGS43 : process(Local_Clk)
  begin
  if (Local_Clk'event and Local_Clk = '1')then
     for i in 0 to C_PRH_MAX_ADWIDTH-1 loop
         async_data_oe_i(i) <= not (Async_data_oe);
     end loop;
  end if;
  end process REG_PRH_SIGS43;

  PRH_DATA_T_GEN: for i in 0 to C_PRH_MAX_ADWIDTH-1 generate
    PRH_Data_T(i) <= async_data_oe_i(i);
  end generate PRH_DATA_T_GEN;

end generate ALL_DEV_ASYNC_GEN;

-------------------------------------------------------------------------------
-- NAME: DEV_SYNC_AND_ASYNC_GEN
-------------------------------------------------------------------------------
-- Description: Some devices are configured as synchronous and some
--              asynchronous
-------------------------------------------------------------------------------
DEV_SYNC_AND_ASYNC_GEN: if NO_PRH_SYNC = 0 and NO_PRH_ASYNC = 0 generate
  -----------------------------------------------------------------------------
  -- NAME: PRH_CS_N_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate chip select for external peripheral device
  -----------------------------------------------------------------------------
  REG_PRH_SIGS44 : process(Local_Clk)
  begin
  if (Local_Clk'event and Local_Clk = '1')then
     for i in 0 to C_NUM_PERIPHERALS-1 loop
         prh_cs_n_i(i) <= Sync_CS_n(i) and Async_CS_n(i);
     end loop;
  end if;
  end process REG_PRH_SIGS44;

-- PRH_CS_N_GEN: Generate the PRH_CS_n signal.
  PRH_CS_N_GEN: for i in 0 to C_NUM_PERIPHERALS-1 generate
    PRH_CS_n(i)   <= prh_cs_n_i(i);
  end generate PRH_CS_N_GEN;

  -- REG_PRH_SIGS45 : Register the PRH_* signals
  REG_PRH_SIGS45 : process(Local_Clk)
  begin
  if (Local_Clk'event and Local_Clk = '1')then
      PRH_ADS    <= Sync_ADS or Async_ADS;
      PRH_RNW    <= Sync_RNW;
      PRH_Rd_n   <= Async_Rd_n;
      PRH_Wr_n   <= Async_Wr_n;
      PRH_Burst  <= Sync_Burst;
  end if;
  end process REG_PRH_SIGS45;

  -----------------------------------------------------------------------------
  -- NAME: PRH_DATA_T_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate output data bus enable for each bit of data bus
  -----------------------------------------------------------------------------

  REG_PRH_SIGS46 : process(Local_Clk)
  begin
  if (Local_Clk'event and Local_Clk = '1')then
     for i in 0 to C_PRH_MAX_ADWIDTH-1 loop
         sync_async_data_oe_i(i) <= not((Async_data_oe) xor (Sync_data_oe));
     end loop;
  end if;
  end process REG_PRH_SIGS46;

  PRH_DATA_T_GEN: for i in 0 to C_PRH_MAX_ADWIDTH-1 generate
    PRH_Data_T(i) <= sync_async_data_oe_i(i);
  end generate PRH_DATA_T_GEN;

end generate DEV_SYNC_AND_ASYNC_GEN;

-------------------------------------------------------------------------------
-- NAME: NO_PRH_BUS_MULTIPLEX_GEN
-------------------------------------------------------------------------------
-- Description: No peripheral employs bus multiplexing for address/data bus
-------------------------------------------------------------------------------
NO_PRH_BUS_MULTIPLEX_GEN: if NO_PRH_BUS_MULTIPLEX = 1 generate

  addr_ph    <= '0';

  REG_PRH_SIGS47 : process(Local_Clk)
  begin
  if (Local_Clk'event and Local_Clk = '1')then
      PRH_Data_O(0 to C_PRH_MAX_DWIDTH-1) <= Data_Int;
  end if;
  end process REG_PRH_SIGS47;

end generate NO_PRH_BUS_MULTIPLEX_GEN;


-------------------------------------------------------------------------------
-- NAME: PRH_BUS_MULTIPLEX_GEN
-------------------------------------------------------------------------------
-- Description: Atleast some peripheral employs bus multiplexing
-------------------------------------------------------------------------------
PRH_BUS_MULTIPLEX_GEN: if NO_PRH_BUS_MULTIPLEX = 0 generate

  addr_ph <= Sync_addr_ph or Async_addr_ph;

  -----------------------------------------------------------------------------
  -- NAME: ADDR_OUT_PROCESS
  -----------------------------------------------------------------------------
  -- Description: Generate adddress out for the current device
  -----------------------------------------------------------------------------
  ADDR_OUT_PROCESS: process (Dev_id, Addr_Int) is
  begin
    addr_out <= (others => '0');

    for i in 0 to C_NUM_PERIPHERALS-1 loop
      if (Dev_id(i) = '1') then

        if (PRH_ADWIDTH_ARRAY(i) > C_PRH_MAX_AWIDTH) then

          addr_out(0 to PRH_ADWIDTH_ARRAY(i)-C_PRH_MAX_AWIDTH-1)
                   <= (others => '0');
          addr_out(PRH_ADWIDTH_ARRAY(i)-C_PRH_MAX_AWIDTH
                   to PRH_ADWIDTH_ARRAY(i)-1)
                   <= Addr_Int(0 to C_PRH_MAX_AWIDTH-1);

          if (PRH_ADWIDTH_ARRAY(i) < C_PRH_MAX_ADWIDTH) then
            addr_out(PRH_ADWIDTH_ARRAY(i) to C_PRH_MAX_ADWIDTH-1)
                     <= (others => '0');
          end if;

        else

          addr_out(0 to PRH_ADWIDTH_ARRAY(i)-1) <=
            Addr_Int(C_PRH_MAX_AWIDTH-PRH_ADWIDTH_ARRAY(i)
                     to C_PRH_MAX_AWIDTH-1);

          if (PRH_ADWIDTH_ARRAY(i) < C_PRH_MAX_ADWIDTH) then
            addr_out(PRH_ADWIDTH_ARRAY(i) to C_PRH_MAX_ADWIDTH-1)
                     <= (others => '0');
          end if;

        end if;

      end if;
    end loop;

  end process ADDR_OUT_PROCESS;

  data_out(0 to C_PRH_MAX_DWIDTH-1) <= Data_Int;

  -----------------------------------------------------------------------------
  -- NAME: DWIDTH_LT_ADWIDTH_GEN
  -----------------------------------------------------------------------------
  -- Description: Tie higher bits of data bus to zero
  -----------------------------------------------------------------------------
  DWIDTH_LT_ADWIDTH_GEN: if C_PRH_MAX_DWIDTH < C_PRH_MAX_ADWIDTH generate
      data_out(C_PRH_MAX_DWIDTH to C_PRH_MAX_ADWIDTH-1) <= (others => '0');
  end generate DWIDTH_LT_ADWIDTH_GEN;

  -----------------------------------------------------------------------------
  -- NAME: AD_MUX_OUT_PROCESS
  -----------------------------------------------------------------------------
  -- Description: Multiplexes the address and data bus to be driven out to the
  --              external peripheral device if the device uses multiplexed bus
  --              for address and data
  -----------------------------------------------------------------------------
  AD_MUX_OUT_PROCESS: process (Local_Clk)
  begin
  if (Local_Clk'event and Local_Clk = '1')then
      if (addr_ph = '1') then
        PRH_Data_O <= addr_out;
      else
        PRH_Data_O <= data_out;
      end if;
  end if;
end process AD_MUX_OUT_PROCESS;

end generate PRH_BUS_MULTIPLEX_GEN;

  REG_PRH_SIGS48 : process(Local_Clk)
  begin
  if (Local_Clk'event and Local_Clk = '1')then
        PRH_Addr <= Addr_Int;
  end if;
  end process REG_PRH_SIGS48;

-------------------------------------------------------------------------------
-- NAME: DEV_RDY_PROCESS
-------------------------------------------------------------------------------
-- Description: Multiplexes the device ready signal from external peripheral
--              devices and drives to the internal logic
-------------------------------------------------------------------------------
DEV_RDY_PROCESS: process (Dev_id,PRH_Rdy) is
begin
  Dev_Rdy <= '0';
  for i in 0 to C_NUM_PERIPHERALS-1 loop
    if (Dev_id(i) = '1') then
      Dev_Rdy <= PRH_Rdy(i);
    end if;
  end loop;
end process DEV_RDY_PROCESS;

end architecture imp;
--------------------------------end of file------------------------------------
