-------------------------------------------------------------------------------
-- Title      : CLock
-- Project    : 
-------------------------------------------------------------------------------
-- File       : clock.vhd
-- Author     : My Account  <guest@dsun.org>
-- Company    : 
-- Created    : 2016-03-13
-- Last update: 2016-04-25
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-03-13  1.0      guest	Created
-------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

architecture STRUCTURE of clock is

  component cpu is
  port (
      DDR_cas_n         : inout std_logic;
      DDR_cke           : inout std_logic;
      DDR_ck_n          : inout std_logic;
      DDR_ck_p          : inout std_logic;
      DDR_cs_n          : inout std_logic;
      DDR_reset_n       : inout std_logic;
      DDR_odt           : inout std_logic;
      DDR_ras_n         : inout std_logic;
      DDR_we_n          : inout std_logic;
      DDR_ba            : inout std_logic_vector (2 downto 0);
      DDR_addr          : inout std_logic_vector (14 downto 0);
      DDR_dm            : inout std_logic_vector (3 downto 0);
      DDR_dq            : inout std_logic_vector (31 downto 0);
      DDR_dqs_n         : inout std_logic_vector (3 downto 0);
      DDR_dqs_p         : inout std_logic_vector (3 downto 0);
      FIXED_IO_mio      : inout std_logic_vector (53 downto 0);
      FIXED_IO_ddr_vrn  : inout std_logic;
      FIXED_IO_ddr_vrp  : inout std_logic;
      FIXED_IO_ps_srstb : inout std_logic;
      FIXED_IO_ps_clk   : inout std_logic;
      FIXED_IO_ps_porb  : inout std_logic;
      UART_0_txd        : out   std_logic;
      UART_0_rxd        : in    std_logic;
      IIC_0_sda_i       : in    std_logic;
      IIC_0_sda_o       : out   std_logic;
      IIC_0_sda_t       : out   std_logic;
      IIC_0_scl_i       : in    std_logic;
      IIC_0_scl_o       : out   std_logic;
      IIC_0_scl_t       : out   std_logic;
      IIC_1_sda_i       : in    std_logic;
      IIC_1_sda_o       : out   std_logic;
      IIC_1_sda_t       : out   std_logic;
      IIC_1_scl_i       : in    std_logic;
      IIC_1_scl_o       : out   std_logic;
      IIC_1_scl_t       : out   std_logic;
      GPIO_tri_i        : in    std_logic_vector (15 downto 0);
      GPIO_tri_o        : out   std_logic_vector (15 downto 0);
      GPIO_tri_t        : out   std_logic_vector (15 downto 0);
      IIC_scl_i         : in    std_logic;
      IIC_scl_o         : out   std_logic;
      IIC_scl_t         : out   std_logic;
      IIC_sda_i         : in    std_logic;
      IIC_sda_o         : out   std_logic;
      IIC_sda_t         : out   std_logic;
      EPC_INTF_addr     : out   std_logic_vector (0 to 31);
      EPC_INTF_ads      : out   std_logic;
      EPC_INTF_be       : out   std_logic_vector (0 to 3);
      EPC_INTF_burst    : out   std_logic;
      EPC_INTF_clk      : in    std_logic;
      EPC_INTF_cs_n     : out   std_logic_vector (0 to 0);
      EPC_INTF_data_i   : in    std_logic_vector (0 to 31);
      EPC_INTF_data_o   : out   std_logic_vector (0 to 31);
      EPC_INTF_data_t   : out   std_logic_vector (0 to 31);
      EPC_INTF_rd_n     : out   std_logic;
      EPC_INTF_rdy      : in    std_logic_vector (0 to 0);
      EPC_INTF_rnw      : out   std_logic;
      EPC_INTF_rst      : in    std_logic;
      EPC_INTF_wr_n     : out   std_logic;
      OCXO_CLK100       : in    std_logic;
      FCLK_CLK0         : out   std_logic;
      FCLK_RESET0_N     : out   std_logic;
      OCXO_RESETN       : out   std_logic_vector (0 to 0);
      Int0              : in    std_logic_vector (0 to 0);
      Int1              : in    std_logic_vector (0 to 0)
      );
  end component cpu;


  component IOBUF is
  port (
    I : in STD_LOGIC;
    O : out STD_LOGIC;
    T : in STD_LOGIC;
    IO : inout STD_LOGIC
  );
  end component IOBUF;


  component ocxo_clk_pll
      port
          (                             -- Clock in ports
              clk_in1  : in  std_logic;
              -- Clock out ports
              clk_out1 : out std_logic;
              -- Status and control signals
              resetn   : in  std_logic;
              locked   : out std_logic
              );
  end component;

  attribute SYN_BLACK_BOX                 : boolean;
  attribute SYN_BLACK_BOX of ocxo_clk_pll : component is true;

  attribute BLACK_BOX_PAD_PIN                 : string;
  attribute BLACK_BOX_PAD_PIN of ocxo_clk_pll : component is "clk_in1,clk_out1,resetn,locked";


  signal EPC_INTF_addr   : std_logic_vector (0 to 31);
  signal EPC_INTF_ads    : std_logic;
  signal EPC_INTF_be     : std_logic_vector (0 to 3);
  signal EPC_INTF_burst  : std_logic;
  signal EPC_INTF_clk    : std_logic;
  signal EPC_INTF_cs_n   : std_logic;
  signal EPC_INTF_data_i : std_logic_vector (0 to 31);
  signal EPC_INTF_data_o : std_logic_vector (0 to 31);
  signal EPC_INTF_data_t : std_logic_vector (0 to 31);
  signal EPC_INTF_rd_n   : std_logic;
  signal EPC_INTF_rdy    : std_logic;
  signal EPC_INTF_rnw    : std_logic;
  signal EPC_INTF_rst    : std_logic;
  signal EPC_INTF_wr_n   : std_logic;

  signal gpio_tri_i      : std_logic_vector (15 downto 0);
  signal gpio_tri_o      : std_logic_vector (15 downto 0);
  signal gpio_tri_t      : std_logic_vector (15 downto 0);

  signal iic_0_scl_i     : std_logic;
  signal iic_0_scl_o     : std_logic;
  signal iic_0_scl_t     : std_logic;
  signal iic_0_sda_i     : std_logic;
  signal iic_0_sda_o     : std_logic;
  signal iic_0_sda_t     : std_logic;

  signal iic_1_scl_i     : std_logic;
  signal iic_1_scl_o     : std_logic;
  signal iic_1_scl_t     : std_logic;
  signal iic_1_sda_i     : std_logic;
  signal iic_1_sda_o     : std_logic;
  signal iic_1_sda_t     : std_logic;

  signal iic_scl_i       : std_logic;
  signal iic_scl_o       : std_logic;
  signal iic_scl_t       : std_logic;
  signal iic_sda_i       : std_logic;
  signal iic_sda_o       : std_logic;
  signal iic_sda_t       : std_logic;

  SIGNAL Int0            : std_logic_vector (0 to 0);
  SIGNAL Int1            : std_logic_vector (0 to 0);

  SIGNAL fclk            : STD_LOGIC;
  SIGNAL fclk_reset_n    : STD_LOGIC;
  SIGNAL OCXO_RESETN     : std_logic_vector (0 to 0);

  SIGNAL clk             : STD_LOGIC;
  SIGNAL locked          : STD_LOGIC;

begin


    cpu_i : component cpu
        port map (
            DDR_addr(14 downto 0)     => DDR_addr(14 downto 0),
            DDR_ba(2 downto 0)        => DDR_ba(2 downto 0),
            DDR_cas_n                 => DDR_cas_n,
            DDR_ck_n                  => DDR_ck_n,
            DDR_ck_p                  => DDR_ck_p,
            DDR_cke                   => DDR_cke,
            DDR_cs_n                  => DDR_cs_n,
            DDR_dm(3 downto 0)        => DDR_dm(3 downto 0),
            DDR_dq(31 downto 0)       => DDR_dq(31 downto 0),
            DDR_dqs_n(3 downto 0)     => DDR_dqs_n(3 downto 0),
            DDR_dqs_p(3 downto 0)     => DDR_dqs_p(3 downto 0),
            DDR_odt                   => DDR_odt,
            DDR_ras_n                 => DDR_ras_n,
            DDR_reset_n               => DDR_reset_n,
            DDR_we_n                  => DDR_we_n,

            FIXED_IO_ddr_vrn          => FIXED_IO_ddr_vrn,
            FIXED_IO_ddr_vrp          => FIXED_IO_ddr_vrp,
            FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
            FIXED_IO_ps_clk           => FIXED_IO_ps_clk,
            FIXED_IO_ps_porb          => FIXED_IO_ps_porb,
            FIXED_IO_ps_srstb         => FIXED_IO_ps_srstb,

            EPC_INTF_addr     => EPC_INTF_addr,
            EPC_INTF_ads      => EPC_INTF_ads,
            EPC_INTF_be       => EPC_INTF_be,
            EPC_INTF_burst    => EPC_INTF_burst,
            EPC_INTF_clk      => clk,
            EPC_INTF_cs_n(0)  => EPC_INTF_cs_n,
            EPC_INTF_data_i   => EPC_INTF_data_i,
            EPC_INTF_data_o   => EPC_INTF_data_o,
            EPC_INTF_data_t   => EPC_INTF_data_t,
            EPC_INTF_rd_n     => EPC_INTF_rd_n,
            EPC_INTF_rdy(0)   => EPC_INTF_rdy,
            EPC_INTF_rnw      => EPC_INTF_rnw,
            EPC_INTF_rst      => OCXO_RESETN(0),
            EPC_INTF_wr_n     => EPC_INTF_wr_n,

            GPIO_tri_i        => GPIO_tri_i,
            GPIO_tri_o        => GPIO_tri_o,
            GPIO_tri_t        => GPIO_tri_t,

            IIC_0_scl_i                  => iic_0_scl_i,
            IIC_0_scl_o                  => iic_0_scl_o,
            IIC_0_scl_t                  => iic_0_scl_t,
            IIC_0_sda_i                  => iic_0_sda_i,
            IIC_0_sda_o                  => iic_0_sda_o,
            IIC_0_sda_t                  => iic_0_sda_t,

            IIC_1_scl_i                  => iic_1_scl_i,
            IIC_1_scl_o                  => iic_1_scl_o,
            IIC_1_scl_t                  => iic_1_scl_t,
            IIC_1_sda_i                  => iic_1_sda_i,
            IIC_1_sda_o                  => iic_1_sda_o,
            IIC_1_sda_t                  => iic_1_sda_t,

            IIC_scl_i                    => iic_scl_i,
            IIC_scl_o                    => iic_scl_o,
            IIC_scl_t                    => iic_scl_t,
            IIC_sda_i                    => iic_sda_i,
            IIC_sda_o                    => iic_sda_o,
            IIC_sda_t                    => iic_sda_t,

            UART_0_rxd                   => gps_rxd,
            UART_0_txd                   => gps_txd,

            OCXO_CLK100       => clk,
            FCLK_CLK0         => fclk,
            FCLK_RESET0_N     => fclk_reset_n,
            OCXO_RESETN       => OCXO_RESETN,
            Int0              => Int0,
            Int1              => Int1
            );



    -- rtc I2C interface
    rtc_scl     <= iic_0_scl_o when iic_0_scl_t = '0' else 'Z';
    iic_0_scl_i <= rtc_scl;
    rtc_sda     <= iic_0_sda_o when iic_0_sda_t = '0' else 'Z';
    iic_0_sda_i <= rtc_sda;

    -- ocxo I2C interface
    ocxo_scl    <= iic_1_scl_o when iic_1_scl_t = '0' else 'Z';
    iic_1_scl_i <= ocxo_scl;
    ocxo_sda    <= iic_1_sda_o when iic_1_sda_t = '0' else 'Z';
    iic_1_sda_i <= ocxo_sda;

    -- Temperature sensor I2C interface
    temp_scl    <= iic_scl_o when iic_scl_t = '0' else 'Z';
    iic_scl_i   <= temp_scl;
    temp_sda    <= iic_sda_o when iic_sda_t = '0' else 'Z';
    iic_sda_i   <= temp_sda;


    -- Generic gpio interface
    gpio_tri: for i in 0 to 7 generate
    begin
        --gpio_tri_iobuf: component IOBUF
        --    port map (
        --        I => GPIO_tri_o(i),
        --        IO => gpio(i),
        --        O => GPIO_tri_i(i),
        --        T => GPIO_tri_t(i)
        --        );

        gpio(i)       <= GPIO_tri_o(i) when GPIO_tri_t(i) = '0' else 'Z';
        GPIO_tri_i(i) <= gpio(i);
    end generate;

    --gpio(0)       <= gpio_tri_o(0) when gpio_tri_t(0) = '0' else 'Z';
    --gpio(1)       <= gpio_tri_o(1) when gpio_tri_t(1) = '0' else 'Z';
    --gpio(2)       <= gpio_tri_o(2) when gpio_tri_t(2) = '0' else 'Z';
    --gpio(3)       <= gpio_tri_o(3) when gpio_tri_t(3) = '0' else 'Z';
    --gpio(4)       <= gpio_tri_o(4) when gpio_tri_t(4) = '0' else 'Z';
    --gpio(5)       <= gpio_tri_o(5) when gpio_tri_t(5) = '0' else 'Z';
    --gpio(6)       <= gpio_tri_o(6) when gpio_tri_t(6) = '0' else 'Z';
    --gpio(7)       <= gpio_tri_o(7) when gpio_tri_t(7) = '0' else 'Z';
                                                   
    syspll : ocxo_clk_pll
        port map (
            -- Clock in ports
            clk_in1  => ocxo_clk,
            -- Clock out ports  
            clk_out1 => clk,
            -- Status and control signals                
            resetn   => fclk_reset_n,
            locked   => locked
            );

end STRUCTURE;
