-------------------------------------------------------------------------------
-- ipic_if_decode.vhd - entity/architecture pair
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
-- File          : ipic_if_decode.vhd
-- Company       : Xilinx
-- Version       : v1.00.a
-- Description   : External Peripheral Controller for AXI bus ipif decode logic
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
--------------------------------------------------------------------------------
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
use IEEE.std_logic_misc.or_reduce;

library unisim;
use unisim.vcomponents.FDRE;

-------------------------------------------------------------------------------
--                     Definition of Generics                                --
-------------------------------------------------------------------------------
-- C_SPLB_DWIDTH             -  Data width of PLB BUS.
-- C_NUM_PERIPHERALS        -  No of peripherals supported by external
--                             peripheral controller in the current
--                             configuration
-- C_PRH_CLK_SUPPORT        -  Indication of whether the synchronous interface
--                             operates on peripheral clock or on PLB clock
-- C_PRH(0:3)_DWIDTH_MATCH  -  Indication of whether external peripheral (0:3)
--                             supports multiple access cycle on the
--                             peripheral interface for a single PLB cycle
--                             when the peripheral data bus width is less than
--                             that of PLB bus data width
-- C_PRH(0:3)_DWIDTH        -  External peripheral (0:3) data bus width
-- MAX_PERIPHERALS          -  Maximum number of peripherals supported by the
--                             external peripheral controller
-- NO_PRH_SYNC              -  Indicates all devices are configured for
--                             asynchronous interface
-- NO_PRH_ASYNC             -  Indicates all devices are configured for
--                             synchronous interface
-- PRH_SYNC                 -  Indicates if the devices are configured for
--                             asynchronous or synchronous interface
-- NO_PRH_BUS_MULTIPLEX     -  Indicates that no device is employing
--                             multiplexed bus
-- PRH_BUS_MULTIPLEX        -  Indicates if each of the external device
--                             is configured for multiplexed bus or not
-- NO_PRH_DWIDTH_MATCH      -  Indication that no device is employing data
--                             width matching
-- PRH_DWIDTH_MATCH         -  Indicates if each of the external device
--                             is configured for data width matching or not
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--                     Definition of Ports                                   --
-------------------------------------------------------------------------------
-- Bus2IP_Clk            - IPIC clock
-- Bus2IP_Rst            - IPIC reset

-- Local_Clk             - Operational clock for peripheral interface
-- Local_Rst             - Reset for peripheral interface

-- Bus2IP_CS             - IPIC chip select signals
-- Bus2IP_RNW            - IPIC read/write control

-- IP2Bus_WrAck          - Write data acknowledgment to IPIC interface
-- IP2Bus_RdAck          - Read data acknowledgment to IPIC interface
-- IP2Bus_Error          - Error indication to IPIC interface

-- FIFO_access           - Indicates if the current access is to a FIFO
--                       - within the external peripheral device

-- Dev_id                - The decoded identification vector for the currently
--                       - selected device
-- Dev_fifo_access       - Indicates if the current access is to a FIFO
--                         within the external peripheral device. Registered
--                         output of FIFO_access
-- Dev_in_access         - Indicates if any of the peripheral device is
--                         currently being accessed
-- Dev_sync_in_access    - Indicates if any of synchronous the peripheral
--                         device is currently being accessed
-- Dev_async_in_access   - Indicates if any of asynchronous the peripheral
--                         device is currently being accessed
-- Dev_sync              - Indicates if the current device being accessed
--                         is synchronous device
-- Dev_rnw               - Read/write control indication
-- Dev_bus_multiplex     - Indicates if the currently selected device employs
--                         multiplexed bus
-- Dev_dwidth_match      - Indicates if the current device employs data
--                         width matching
-- Dev_dbus_width        - Indicates decoded value for the data bus
-- IPIC_sync_req         - Request to the synchronous control logic
-- IP_sync_req_rst       - Request reset from the synchronous control logic
-- IPIC_async_req        - Request to the asynchronous control logic
-- IP_sync_ack           - Acknowledgement from the synchronous control logic
-- IPIC_sync_ack_rst     - Acknowledgement reset to the synchronous control
-- IP_async_ack          - Acknowledgement from the asynchronous control logic

-- IP_async_addrack      - Address acknowledgement for asynchronous access from
--                         the asynchronous control logic

-- IP_sync_error        - Error indication for synchronous access from
--                         the synchronous control logic
-- IP_async_error       - Error indication for asynchronous access from
--                         the asynchronous control logic

-------------------------------------------------------------------------------


entity ipic_if_decode is
  generic (
      C_SPLB_DWIDTH            : integer;

      C_NUM_PERIPHERALS        : integer;
      C_PRH_CLK_SUPPORT        : integer;

      C_PRH0_DWIDTH_MATCH      : integer;
      C_PRH1_DWIDTH_MATCH      : integer;
      C_PRH2_DWIDTH_MATCH      : integer;
      C_PRH3_DWIDTH_MATCH      : integer;

      C_PRH0_DWIDTH            : integer;
      C_PRH1_DWIDTH            : integer;
      C_PRH2_DWIDTH            : integer;
      C_PRH3_DWIDTH            : integer;

      MAX_PERIPHERALS          : integer;
      NO_PRH_SYNC              : integer;
      NO_PRH_ASYNC             : integer;
      PRH_SYNC                 : std_logic_vector;

      NO_PRH_BUS_MULTIPLEX     : integer;
      PRH_BUS_MULTIPLEX        : std_logic_vector;
      NO_PRH_DWIDTH_MATCH      : integer;
      PRH_DWIDTH_MATCH         : std_logic_vector
    );

  port (

     Bus2IP_Clk          : in  std_logic;
     Bus2IP_Rst          : in  std_logic;

     Local_Clk           : in  std_logic;
     Local_Rst           : in  std_logic;

     -- IPIC interface
     Bus2IP_CS           : in  std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     Bus2IP_RNW          : in  std_logic;

     IP2Bus_WrAck        : out std_logic;
     IP2Bus_RdAck        : out std_logic;
     IP2Bus_Error        : out std_logic;

     FIFO_access         : in  std_logic;

     Dev_id              : out std_logic_vector(0 to C_NUM_PERIPHERALS-1);
     Dev_fifo_access     : out std_logic;
     Dev_in_access       : out std_logic;
     Dev_sync_in_access  : out std_logic;
     Dev_async_in_access : out std_logic;
     Dev_sync            : out std_logic;
     Dev_rnw             : out std_logic;
     Dev_bus_multiplex   : out std_logic;
     Dev_dwidth_match    : out std_logic;
     Dev_dbus_width      : out std_logic_vector(0 to 2);

     -- Local interface
     IPIC_sync_req       : out std_logic;
     IPIC_async_req      : out std_logic;
     IP_sync_req_rst     : in  std_logic;

     IP_sync_Wrack       : in std_logic;
     IP_sync_Rdack       : in std_logic;
     IPIC_sync_ack_rst   : out std_logic;

     IP_async_Wrack      : in  std_logic;
     IP_async_Rdack      : in  std_logic;

     IP_sync_error       : in  std_logic;
     IP_async_error      : in  std_logic
    );


end entity ipic_if_decode;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture imp of ipic_if_decode is

attribute ASYNC_REG : string;

-------------------------------------------------------------------------------
-- Function Declarations
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- NAME: get_dbus_width
-------------------------------------------------------------------------------
-- Description: Generate a decoded value of type std_logic_vector
--              corresponding to the current data bus width of the device
-------------------------------------------------------------------------------

function get_dbus_width(prh_width     : integer)
                        return std_logic_vector is

  variable decoded_dbus_width : std_logic_vector(0 to 2);

begin

  case prh_width is
    when 8  =>
      decoded_dbus_width := "001";
    when 16 =>
      decoded_dbus_width := "010";
    when 32 =>
      decoded_dbus_width := "100";
    -- coverage off
    when others =>
      decoded_dbus_width := (others => '0');
    -- coverage on
  end case;

  return decoded_dbus_width;
end function get_dbus_width;

-------------------------------------------------------------------------------
-- Type Declarations
-------------------------------------------------------------------------------

type SLV3_ARRAY_TYPE is array (natural range <>) of std_logic_vector(0 to 2);

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
constant PRH_DBUS_WIDTH : SLV3_ARRAY_TYPE(0 to MAX_PERIPHERALS-1) :=
    (get_dbus_width(C_PRH0_DWIDTH),
     get_dbus_width(C_PRH1_DWIDTH),
     get_dbus_width(C_PRH2_DWIDTH),
     get_dbus_width(C_PRH3_DWIDTH));

-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------

signal dev_in_access_int     : std_logic := '0';
signal dev_in_access_int_d1  : std_logic := '0';

signal access_start          : std_logic := '0';

signal ip_async_Wrack_d1     : std_logic := '0';
signal ip_async_Wrack_d2     : std_logic := '0';
signal ip_async_Wrack_d3     : std_logic := '0';
signal ip_async_Wrack_d4     : std_logic := '0';

signal ip_async_Rdack_d1     : std_logic := '0';
signal ip_async_Rdack_d2     : std_logic := '0';
signal ip_async_Rdack_d3     : std_logic := '0';
signal ip_async_Rdack_d4     : std_logic := '0';

signal async_access_on       : std_logic := '0';
signal async_req             : std_logic := '0';
signal local_async_req       : std_logic := '0';

signal ip_sync_Wrack_d1      : std_logic := '0';
signal ip_sync_Wrack_d2      : std_logic := '0';
signal ip_sync_Wrack_d3      : std_logic := '0';
signal ip_sync_Wrack_d4      : std_logic := '0';

signal ip_sync_Rdack_d1      : std_logic := '0';
signal ip_sync_Rdack_d2      : std_logic := '0';
signal ip_sync_Rdack_d3      : std_logic := '0';
signal ip_sync_Rdack_d4      : std_logic := '0';

signal sync_access_on        : std_logic := '0';
signal sync_req              : std_logic := '0';
signal local_sync_req        : std_logic := '0';


signal sync_req_d1           : std_logic := '0';
signal local_sync_req_rst    : std_logic := '0';
signal local_sync_req_d1     : std_logic := '0';
signal local_sync_req_d2     : std_logic := '0';
signal local_sync_req_d3     : std_logic := '0';

signal dev_sync_int          : std_logic := '0';
signal dev_sync_i            : std_logic := '0';

signal dev_burst_i           : std_logic := '0';

signal dev_bus_multiplex_int : std_logic := '0';
signal dev_bus_multiplex_i   : std_logic := '0';

signal dev_dwidth_match_int  : std_logic := '0';
signal dev_dwidth_match_i    : std_logic := '0';

signal dev_dbus_width_int    : std_logic_vector(0 to 2)
                             := (others => '0');
signal dev_dbus_width_i      : std_logic_vector(0 to 2)
                             := (others => '0');

signal ip2bus_Wrack_i        : std_logic := '0';
signal ip2bus_Rdack_i        : std_logic := '0';
signal temp_i                : std_logic;
signal local_sync_req_i      : std_logic;
-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
begin

-- DEV_IN_ACCESS_INT indicates that the PLB EPC is currently accessing an
-- external peripheral device
dev_in_access_int <= or_reduce(Bus2IP_CS(0 to C_NUM_PERIPHERALS-1));

---------------------------------------------------------------------------
-- NAME: REG_IPIC_PROCESS
---------------------------------------------------------------------------
-- Description: Register the ipic signal for the local interface.
--              These signals are not stable in case of abort. Therefore,
--              registering is required
---------------------------------------------------------------------------
REG_IPIC_PROCESS : process (Bus2IP_Clk) is
begin
  if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
     if (Bus2IP_Rst = '1') then
        Dev_id  <= (others => '0');
        Dev_fifo_access <= '0';
        Dev_rnw <= '1';
     else
        if (access_start = '1') then
          Dev_id  <= Bus2IP_CS;
          Dev_fifo_access <= FIFO_access;
          Dev_rnw <= Bus2IP_RNW;
        end if;
     end if;
   end if;
end process REG_IPIC_PROCESS;

-------------------------------------------------------------------------------
-- NAME: NO_DEV_SYNC_GEN
-------------------------------------------------------------------------------
-- Description: Tie DEV_SYNC to low if there are no synchronous external
--              peripheral device
-------------------------------------------------------------------------------
NO_DEV_SYNC_GEN: if NO_PRH_SYNC = 1 generate
   dev_sync_int <= '0';
   Dev_sync     <= '0';
end generate NO_DEV_SYNC_GEN;

-------------------------------------------------------------------------------
-- NAME: DEV_SYNC_GEN
-------------------------------------------------------------------------------
-- Description: Generate DEV_SYNC if there are external peripheral devices
--              that are configured as synchronous
-------------------------------------------------------------------------------
DEV_SYNC_GEN: if NO_PRH_SYNC = 0 generate

  --------------------------------------------------------------------------
  -- NAME: DEV_SYNC_PROCESS
  --------------------------------------------------------------------------
  -- Description: Generate DEV_SYNC_INT if the current access corresponds to
  --              synchronous external peripheral device
  --------------------------------------------------------------------------
  DEV_SYNC_PROCESS: process (Bus2IP_CS)
  begin
    dev_sync_int <= '0';
    for i in 0 to C_NUM_PERIPHERALS-1 loop
      if (Bus2IP_CS(i) = '1') then
         dev_sync_int <= PRH_SYNC(i);
      end if;
    end loop;
  end process DEV_SYNC_PROCESS;

  ---------------------------------------------------------------------------
  -- NAME: REG_DEV_SYNC_PROCESS
  ---------------------------------------------------------------------------
  -- Description: Register the device synchronous indication signal
  --              DEV_SYNC_INT
  ---------------------------------------------------------------------------
  REG_DEV_SYNC_PROCESS : process(Bus2IP_Clk) is
  begin
    if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
       if (Bus2IP_Rst = '1') then
          dev_sync_i <= '0';
       else
          if (access_start = '1') then
            dev_sync_i <= dev_sync_int;
          end if;
       end if;
     end if;
  end process REG_DEV_SYNC_PROCESS;

  Dev_sync <= dev_sync_i;

end generate DEV_SYNC_GEN;

-------------------------------------------------------------------------------
-- NAME: NO_DEV_BUS_MULTIPLEX_GEN
-------------------------------------------------------------------------------
-- Description: Tie DEV_BUS_MULTIPLEX to low when no external device is
--              employing bus multiplexing
-------------------------------------------------------------------------------
NO_DEV_BUS_MULTIPLEX_GEN: if NO_PRH_BUS_MULTIPLEX = 1 generate
  Dev_bus_multiplex <= '0';
end generate NO_DEV_BUS_MULTIPLEX_GEN;

-------------------------------------------------------------------------------
-- NAME: DEV_BUS_MULTIPLEX_GEN
-------------------------------------------------------------------------------
-- Description: Generate DEV_BUS_MULTIPLEX when any of the external device is
--              employing bus multiplexing
-------------------------------------------------------------------------------
DEV_BUS_MULTIPLEX_GEN: if NO_PRH_BUS_MULTIPLEX = 0 generate

  -----------------------------------------------------------------------------
  -- NAME: DEV_BUS_MULTIPLEX_PROCESS
  -----------------------------------------------------------------------------
  -- Description: Generate DEV_BUS_MULTIPLEX_INT if the currently selected
  --              device employs bus multiplexing
  -----------------------------------------------------------------------------
  DEV_BUS_MULTIPLEX_PROCESS: process (Bus2IP_CS) is
  begin
    dev_bus_multiplex_int <= '0';
    for i in 0 to C_NUM_PERIPHERALS-1 loop
      if (Bus2IP_CS(i) = '1') then
        dev_bus_multiplex_int <= PRH_BUS_MULTIPLEX(i);
      end if;
    end loop;
  end process DEV_BUS_MULTIPLEX_PROCESS;

  ---------------------------------------------------------------------------
  -- NAME: REG_DEV_BUS_MULTIPLEX_PROCESS
  ---------------------------------------------------------------------------
  -- Description: Register the device bus multiplex indication signal,
  --              DEV_BUS_MULTIPLEX_INT
  ---------------------------------------------------------------------------
  REG_DEV_BUS_MULTIPLEX_PROCESS : process(Bus2IP_Clk) is
  begin
    if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
       if (Bus2IP_Rst = '1') then
          dev_bus_multiplex_i <= '0';
       else
          if (access_start = '1') then
            dev_bus_multiplex_i <= dev_bus_multiplex_int;
          end if;
       end if;
     end if;
  end process REG_DEV_BUS_MULTIPLEX_PROCESS;

  Dev_bus_multiplex <= dev_bus_multiplex_i;

end generate DEV_BUS_MULTIPLEX_GEN;


-------------------------------------------------------------------------------
-- NAME: NO_DEV_DWIDTH_MATCH_GEN
-------------------------------------------------------------------------------
-- Description: Tie DEV_DWIDTH_MATCH to low if data bus width matching is
--              not enabled for any of the external peripheral device
-------------------------------------------------------------------------------
NO_DEV_DWIDTH_MATCH_GEN: if NO_PRH_DWIDTH_MATCH = 1 generate
   Dev_dwidth_match <= '0';
end generate NO_DEV_DWIDTH_MATCH_GEN;

-------------------------------------------------------------------------------
-- NAME: DEV_DWIDTH_MATCH_GEN
-------------------------------------------------------------------------------
-- Description: Generate DEV_DWIDTH_MATCH if data bus width matching is
--              enabled for any external peripheral device
-------------------------------------------------------------------------------
DEV_DWIDTH_MATCH_GEN: if NO_PRH_DWIDTH_MATCH = 0 generate

  -----------------------------------------------------------------------------
  -- NAME: DEV_DWIDTH_MATCH_PROCESS
  -----------------------------------------------------------------------------
  -- Description: Generate DEV_DWIDTH_MATCH_INT for the currently selected
  --              device. DEV_DWIDTH_MATCH_INT indicates if the current device
  --              employs datawidth matching
  -----------------------------------------------------------------------------
  DEV_DWIDTH_MATCH_PROCESS: process (Bus2IP_CS) is
  begin
    Dev_dwidth_match_int <= '0';
    for i in 0 to C_NUM_PERIPHERALS-1 loop
      if (Bus2IP_CS(i) = '1') then
        Dev_dwidth_match_int <= PRH_DWIDTH_MATCH(i);
      end if;
    end loop;
  end process DEV_DWIDTH_MATCH_PROCESS;

  ---------------------------------------------------------------------------
  -- NAME: REG_DEV_DWIDTH_MATCH_PROCESS
  ---------------------------------------------------------------------------
  -- Description: Register the device dwidth match indication signal,
  --              DEV_DWIDTH_MATCH_INT
  ---------------------------------------------------------------------------
  REG_DEV_DWIDTH_MATCH_PROCESS : process(Bus2IP_Clk) is
  begin
    if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
       if (Bus2IP_Rst = '1') then
          dev_dwidth_match_i <= '0';
       else
          if (access_start = '1') then
            dev_dwidth_match_i <= dev_dwidth_match_int;
          end if;
       end if;
     end if;
  end process REG_DEV_DWIDTH_MATCH_PROCESS;

  Dev_dwidth_match <= dev_dwidth_match_i;

end generate DEV_DWIDTH_MATCH_GEN;

-------------------------------------------------------------------------------
-- NAME: DEV_DBUS_WIDTH_PROCESS
-------------------------------------------------------------------------------
-- Description: Generate DEV_DBUS_WIDTH_INT for the currently selected device
--              DEV_DBUS_WIDTH_INT indicates the data bus width of the
--              currently selected device
-------------------------------------------------------------------------------
DEV_DBUS_WIDTH_PROCESS: process (Bus2IP_CS) is
begin
  dev_dbus_width_int <= (others => '0');
  for i in 0 to C_NUM_PERIPHERALS-1 loop
    if (Bus2IP_CS(i) = '1') then
      dev_dbus_width_int <= PRH_DBUS_WIDTH(i);
    end if;
  end loop;
end process DEV_DBUS_WIDTH_PROCESS;

---------------------------------------------------------------------------
-- NAME: REG_DEV_DBUS_WIDTH_PROCESS
---------------------------------------------------------------------------
-- Description: Register the decoded value of device data bus width,
--              DEV_DBUS_WIDTH_INT
---------------------------------------------------------------------------
REG_DEV_DBUS_WIDTH_PROCESS : process(Bus2IP_Clk)
begin
  if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
     if (Bus2IP_Rst = '1') then
        dev_dbus_width_i <= (others => '0');
     else
       if (access_start = '1') then
         dev_dbus_width_i <= dev_dbus_width_int;
       end if;
     end if;
   end if;
end process REG_DEV_DBUS_WIDTH_PROCESS;

Dev_dbus_width <= dev_dbus_width_i;

-------------------------------------------------------------------------------
-- NAME: ACCESS_START_PROCESS
-------------------------------------------------------------------------------
-- Description: Register the start of the transaction
-------------------------------------------------------------------------------
ACCESS_START_PROCESS : process(Bus2IP_Clk)
begin
  if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
    if (Bus2IP_Rst = '1')then
      dev_in_access_int_d1 <= '0';
    else
      dev_in_access_int_d1 <= dev_in_access_int;
    end if;
  end if;
end process ACCESS_START_PROCESS;

-- Generate a pulse to identify start of the transaction
access_start <= dev_in_access_int and not dev_in_access_int_d1;

-------------------------------------------------------------------------------
-- NAME: ASYNC_REQ_GEN
-------------------------------------------------------------------------------
-- Description: Generate asynchronous request signal if any of the device is
--              configured for asynchronous access
-------------------------------------------------------------------------------
ASYNC_REQ_GEN: if NO_PRH_ASYNC = 0 generate

  ---------------------------------------------------------------------------
  -- NAME: DELAY_ASYNC_WR_ACK_PROCESS
  ---------------------------------------------------------------------------
  -- Description: Delay the write acknowledgement from asynchronous control logic
  --              to generate request in case of burst access
  ---------------------------------------------------------------------------
  DELAY_ASYNC_WR_ACK_PROCESS : process(Bus2IP_Clk)
  begin
    if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
       if (Bus2IP_Rst = '1' or dev_in_access_int = '0') then
          ip_async_Wrack_d1 <= '0';
          ip_async_Wrack_d2 <= '0';
          ip_async_Wrack_d3 <= '0';
          ip_async_Wrack_d4 <= '0';
       else
          ip_async_Wrack_d1 <= IP_async_Wrack;
          ip_async_Wrack_d2 <= ip_async_Wrack_d1;
          ip_async_Wrack_d3 <= ip_async_Wrack_d2;
          ip_async_Wrack_d4 <= ip_async_Wrack_d3;
       end if;
     end if;
  end process DELAY_ASYNC_WR_ACK_PROCESS;

  ---------------------------------------------------------------------------
  -- NAME: DELAY_ASYNC_RD_ACK_PROCESS
  ---------------------------------------------------------------------------
  -- Description: Delay the Read acknowledgement from asynchronous control logic
  --              to generate request in case of burst access
  ---------------------------------------------------------------------------
  DELAY_ASYNC_RD_ACK_PROCESS : process(Bus2IP_Clk)
  begin
    if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
       if (Bus2IP_Rst = '1' or dev_in_access_int = '0') then
          ip_async_Rdack_d1 <= '0';
          ip_async_Rdack_d2 <= '0';
          ip_async_Rdack_d3 <= '0';
          ip_async_Rdack_d4 <= '0';
       else
          ip_async_Rdack_d1 <= IP_async_Rdack;
          ip_async_Rdack_d2 <= ip_async_Rdack_d1;
          ip_async_Rdack_d3 <= ip_async_Rdack_d2;
          ip_async_Rdack_d4 <= ip_async_Rdack_d3;
       end if;
     end if;
  end process DELAY_ASYNC_RD_ACK_PROCESS;

  -- If the burst indication stays during delayed acknowledgement then,
  -- generate ACCESS_ON signal. This signal will be high for only
  -- one clock pulse because ip_async_Wrack_d4 and ip_async_Rdack_d4
  -- will be only one clock.
  async_access_on <= dev_in_access_int and (ip_async_Wrack_d4 or 
                                                            ip_async_Rdack_d4);

  -- Generate a one clock ASYNC_REQ signal for every access
  async_req <= dev_in_access_int and
               not dev_sync_int and
               (access_start or async_access_on);

  ---------------------------------------------------------------------------
  -- NAME: ASYNC_REQ_PROCESS
  ---------------------------------------------------------------------------
  -- Description: Register and hold the asynchronous request signal until
  --              acknowledged by the local interface or a master abort on
  --              PLB bus occurs
  ---------------------------------------------------------------------------
  ASYNC_REQ_PROCESS : process(Bus2IP_Clk)
  begin
    if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
      if (Bus2IP_Rst = '1') then
        local_async_req <= '0';
      else
        if (dev_in_access_int = '0' or IP_async_Wrack = '1'
                                    or IP_async_Rdack = '1') then
          local_async_req <= '0';
        elsif (async_req = '1') then
          local_async_req <= '1';
        end if;
      end if;
    end if;
  end process ASYNC_REQ_PROCESS;

  IPIC_async_req <= not dev_sync_int and local_async_req;
  Dev_async_in_access <= dev_in_access_int and (not dev_sync_int);

end generate ASYNC_REQ_GEN;

-------------------------------------------------------------------------------
-- NAME: NO_ASYNC_REQ_GEN
-------------------------------------------------------------------------------
-- Description: Tie asynchronous request signal and asynchronous device
--              interface in access indication low if no device is
--              configured for asynchronous access
-------------------------------------------------------------------------------
NO_ASYNC_REQ_GEN: if NO_PRH_ASYNC = 1 generate

  Dev_async_in_access <= '0';
  IPIC_async_req <=  '0';

end generate NO_ASYNC_REQ_GEN;

-------------------------------------------------------------------------------
-- NAME: NO_SYNC_REQ_GEN
-------------------------------------------------------------------------------
-- Description: Tie synchronous request signal and synchronous device
--              interface in access indication low if no device is
--              configured for synchronous access
-------------------------------------------------------------------------------
NO_SYNC_REQ_GEN: if NO_PRH_SYNC = 1 generate

  Dev_sync_in_access <= '0';

  IPIC_sync_req <=  '0';
  IPIC_sync_ack_rst <= '1';

end generate NO_SYNC_REQ_GEN;

-------------------------------------------------------------------------------
-- NAME: SYNC_REQ_GEN
-------------------------------------------------------------------------------
-- Description: Generate synchronous request signal if any of the device is
--              configured for synchronous access
-------------------------------------------------------------------------------
SYNC_REQ_GEN: if NO_PRH_SYNC = 0 generate

  ---------------------------------------------------------------------------
  -- NAME: DELAY_ACK_PROCESS
  ---------------------------------------------------------------------------
  -- Description: Delay the acknowledgement from synchronous control logic
  --              to generate request in case of burst access
  ---------------------------------------------------------------------------
  DELAY_WR_ACK_PROCESS : process(Bus2IP_Clk)
  begin
    if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
       if (Bus2IP_Rst = '1' or dev_in_access_int = '0') then
          ip_sync_Wrack_d1 <= '0';
          ip_sync_Wrack_d2 <= '0';
          ip_sync_Wrack_d3 <= '0';
          ip_sync_Wrack_d4 <= '0';
       else
          ip_sync_Wrack_d1 <= IP_sync_Wrack;
          ip_sync_Wrack_d2 <= ip_sync_Wrack_d1;
          ip_sync_Wrack_d3 <= ip_sync_Wrack_d2;
          ip_sync_Wrack_d4 <= ip_sync_Wrack_d3;
       end if;
     end if;
  end process DELAY_WR_ACK_PROCESS;

  ---------------------------------------------------------------------------
  -- NAME: DELAY_RD_ACK_PROCESS
  ---------------------------------------------------------------------------
  -- Description: Delay the read acknowledgement from synchronous control logic
  --              to generate request in case of burst access
  ---------------------------------------------------------------------------
  DELAY_RD_ACK_PROCESS : process(Bus2IP_Clk)
  begin
    if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
       if (Bus2IP_Rst = '1' or dev_in_access_int = '0') then
          ip_sync_Rdack_d1 <= '0';
          ip_sync_Rdack_d2 <= '0';
          ip_sync_Rdack_d3 <= '0';
          ip_sync_Rdack_d4 <= '0';
       else
          ip_sync_Rdack_d1 <= IP_sync_Rdack;
          ip_sync_Rdack_d2 <= ip_sync_Rdack_d1;
          ip_sync_Rdack_d3 <= ip_sync_Rdack_d2;
          ip_sync_Rdack_d4 <= ip_sync_Rdack_d3;
       end if;
     end if;
  end process DELAY_RD_ACK_PROCESS;

  -- If the burst indication stays during delayed acknowledgement then,
  -- generate ACCESS_ON signal. This signal will be high for only
  -- one clock pulse because ip_sync_Wrack_d4 will be only one clock.
  sync_access_on <= dev_in_access_int and (ip_sync_Wrack_d4 or ip_sync_Rdack_d4);

  -- Generate a one clock SYNC_REQ signal for every access
  sync_req <= dev_in_access_int and
              dev_sync_int and
              (access_start or sync_access_on);

  -----------------------------------------------------------------------------
  -- NAME: SYNC_REQ_NO_PRH_CLK_GEN
  -----------------------------------------------------------------------------
  -- Description: Generate request when the synchronous interface operates
  --              on PLB clock
  -----------------------------------------------------------------------------
  SYNC_REQ_NO_PRH_CLK_GEN: if C_PRH_CLK_SUPPORT = 0 generate

    ---------------------------------------------------------------------------
    -- NAME: SYNC_NO_PRH_CLK_REQ_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Register the request until acknowledged by the local
    --              interface or a master abort occurs
    ---------------------------------------------------------------------------
    SYNC_NO_PRH_CLK_REQ_PROCESS : process(Bus2IP_Clk)
    begin
      if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
        if (Bus2IP_Rst = '1') then
          local_sync_req <= '0';
        else
          if (dev_in_access_int='0' or IP_sync_Wrack='1' or IP_sync_Rdack='1')
                                                                            then
            local_sync_req <= '0';
          elsif (sync_req = '1') then
            local_sync_req <= '1';
          end if;
        end if;
      end if;
    end process SYNC_NO_PRH_CLK_REQ_PROCESS;

    IPIC_sync_req <= dev_sync_int and local_sync_req;
    IPIC_sync_ack_rst <= '1';

    Dev_sync_in_access <= dev_in_access_int and dev_sync_int;

  end generate SYNC_REQ_NO_PRH_CLK_GEN;

  -----------------------------------------------------------------------------
  -- NAME: SYNC_REQ_PRH_CLK_GEN
  -----------------------------------------------------------------------------
  -- Description: The synchronous interface operates on the local clock.
  --              Generate request and double synchronize it.
  -----------------------------------------------------------------------------
  SYNC_REQ_PRH_CLK_GEN: if C_PRH_CLK_SUPPORT = 1 generate
  attribute ASYNC_REG of REG_SYNC_REQ : label is "TRUE";
  begin
    ---------------------------------------------------------------------------
    -- NAME: REQ_PULSE_GEN_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Register the SYNC_REQ signal: Needs to be an output of a
    --              flip flop because this is going to be used as clocking
    --              signal for the latch generating the request for the
    --              synchronous control logic
    ---------------------------------------------------------------------------
    REQ_PULSE_GEN_PROCESS : process(Bus2IP_Clk)
    begin
      if (Bus2IP_Clk'event and Bus2IP_Clk = '1')then
         if (Bus2IP_Rst = '1') then
           sync_req_d1 <= '0';
         else
           sync_req_d1 <= sync_req;
         end if;
      end if;
    end process REQ_PULSE_GEN_PROCESS;

   temp_i <= (Local_Rst or IP_sync_req_rst) or not(dev_in_access_int);
---------------------------------------------------------------------------
-- Description: Latch the SYNC_REQ_D1 signal. Hold it until it is reset
--              from the synchronous control state machine which indicates
--              the current request is acknowledged by the local interface
-- The condition here is as soon as the sync_req_d1 is detected active the output
-- should be active "high". The output is reseted, with the condition of "temp_i".
---------------------------------------------------------------------------
        REQ_HOLD_GEN_PROCESS: process(Bus2IP_Clk)
        begin
        if(Bus2IP_Clk'event and Bus2IP_Clk = '1') then
                if (temp_i = '1') then
                        local_sync_req_i <= '0';
                elsif(sync_req_d1 = '1') then
                        local_sync_req_i <= '1';
                end if;
         end if;
         end process REQ_HOLD_GEN_PROCESS;

    local_sync_req <= sync_req_d1 or (local_sync_req_i and (not temp_i));
--------------------------------------------------------------------------------
    local_sync_req_rst <= Local_Rst or IP_sync_req_rst;


    REG_SYNC_REQ: component FDRE
      port map (
                 Q  => local_sync_req_d1,
                 C  => Local_Clk,
                 CE => '1',
                 D  => local_sync_req,
                 R  => local_sync_req_rst
               );

    ---------------------------------------------------------------------------
    -- NAME: DOUBLE_SYNC_REQ_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Double synchronize the synchronous request signal
    ---------------------------------------------------------------------------
    DOUBLE_SYNC_REQ_PROCESS: process(Local_Clk)
    begin
      if (Local_Clk'event and Local_Clk = '1') then
        if (local_sync_req_rst = '1') then
          local_sync_req_d2 <= '0';
          local_sync_req_d3 <= '0';
        else
          local_sync_req_d2 <= local_sync_req_d1;
          local_sync_req_d3 <= local_sync_req_d2;
        end if;
      end if;
    end process DOUBLE_SYNC_REQ_PROCESS;

    -- Generate request for the syncrhonous control logic
    IPIC_sync_req <= local_sync_req_d3;

    dev_sync_in_access <= local_sync_req_d3 and dev_sync_i;

    ---------------------------------------------------------------------------
    -- NAME: SYNC_ACK_RST_PROCESS
    ---------------------------------------------------------------------------
    -- Description: Reset acknowldgement generation logic in synchronous
    --              control; This signal is inactive during an active request
    --              cycle i.e. from the time request is generated to the time
    --              it is acknowledged by the local interface
    ---------------------------------------------------------------------------
    SYNC_ACK_RST_PROCESS : process (Bus2IP_Clk)
    begin
      if (Bus2IP_Clk'event and Bus2IP_Clk = '1') then
        if (Bus2IP_Rst = '1' or dev_in_access_int = '0' ) then
          IPIC_sync_ack_rst <= '1';
        else
          if (sync_req_d1 = '1') then
            IPIC_sync_ack_rst <= '0';
          elsif (IP_sync_Wrack = '1' or IP_sync_Rdack = '1') then
            IPIC_sync_ack_rst <= '1';
          end if;
        end if;
      end if;
    end process SYNC_ACK_RST_PROCESS;

  end generate SYNC_REQ_PRH_CLK_GEN;
end generate SYNC_REQ_GEN;

Dev_in_access <= dev_in_access_int;

ip2bus_Wrack_i   <= dev_in_access_int and (IP_sync_Wrack or IP_async_Wrack);
ip2bus_Rdack_i   <= dev_in_access_int and (IP_sync_Rdack or IP_async_Rdack);

IP2Bus_WrAck  <= ip2bus_Wrack_i;
IP2Bus_RdAck  <= ip2bus_Rdack_i;

IP2Bus_Error  <= dev_in_access_int and (IP_sync_error or IP_async_error);

end architecture imp;
--------------------------------end of file------------------------------------
