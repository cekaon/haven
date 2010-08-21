-- rx_dma_ctrl_tb.vhd: Testbench File
-- Copyright (C) 2007 CESNET
-- Author(s): Petr Kastovsky <kastovsky@liberouter.org>
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in
--    the documentation and/or other materials provided with the
--    distribution.
-- 3. Neither the name of the Company nor the names of its contributors
--    may be used to endorse or promote products derived from this
--    software without specific prior written permission.
--
-- This software is provided ``as is'', and any express or implied
-- warranties, including, but not limited to, the implied warranties of
-- merchantability and fitness for a particular purpose are disclaimed.
-- In no event shall the company or contributors be liable for any
-- direct, indirect, incidental, special, exemplary, or consequential
-- damages (including, but not limited to, procurement of substitute
-- goods or services; loss of use, data, or profits; or business
-- interruption) however caused and on any theory of liability, whether
-- in contract, strict liability, or tort (including negligence or
-- otherwise) arising in any way out of the use of this software, even
-- if advised of the possibility of such damage.
--
--
--
-- TODO:
--

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

use work.ib_pkg.all; -- Internal Bus Package
use work.ib_sim_oper.all; -- Internal Bus Simulation Package
use work.ib_bfm_pkg.all; -- Internal Bus BFM Package

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity testbench is
end entity testbench;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of testbench is

   -- Constant declaration
   constant CLKPER      : time := 10 ns;
   constant gndvec      : std_logic_vector(128 downto 0) := (others => '0');
   constant MEM_PAGE_SIZE     : integer := 4096;
   constant DESC_BLOCK_SIZE   : integer := 4096;
   constant INT_TIMEOUT       : integer := 10;
   constant BUFFER_ADDR       : std_logic_vector(31 downto 0) := X"00000000";
   constant BUFFER_SIZE       : integer := 1024;
   constant DMA_DATA_WIDTH    : integer := 16;
   constant NET_IFC_COUNT     : integer := 4;

   constant TEST_BASE_ADDR       : integer := 16#02000000#;
   constant TEST_LIMIT           : std_logic_vector(31 downto 0) := X"04000000";

   signal CLK          : std_logic;
   signal RESET        : std_logic;

   -- Common interface
   signal rx_interrupt   : std_logic_vector(2*NET_IFC_COUNT - 1 downto 0);
   signal tx_interrupt   : std_logic_vector(2*NET_IFC_COUNT - 1 downto 0);

   -- Switch1 Map
   signal internal_bus        : t_internal_bus64;
   signal switch1_port1       : t_internal_bus64;
   signal switch1_port2       : t_internal_bus64;

   -- endpoint Map
   signal ib_wr               : t_ibmi_write64;
   signal ib_rd               : t_ibmi_read64s;
   signal ib_bm               : t_ibbm_64;
  
   -- IB_SIM component ctrl      
   signal ib_sim_ctrl         : t_ib_ctrl;
   signal ib_sim_strobe       : std_logic;
   signal ib_sim_busy         : std_logic;

   alias ib_clk               : std_logic is CLK; 

   signal RX_BUF_NEWLEN       : std_logic_vector(NET_IFC_COUNT*16-1 downto 0);
   signal RX_BUF_NEWLEN_DV    : std_logic_vector(NET_IFC_COUNT-1 downto 0);
   signal RX_BUF_NEWLEN_RDY   : std_logic_vector(NET_IFC_COUNT-1 downto 0);  -- always set to '1'
   signal RX_BUF_RELLEN       : std_logic_vector(NET_IFC_COUNT*16-1 downto 0);
   signal RX_BUF_RELLEN_DV    : std_logic_vector(NET_IFC_COUNT-1 downto 0);
   signal TX_BUF_NEWLEN       : std_logic_vector(NET_IFC_COUNT*16-1 downto 0);
   signal TX_BUF_NEWLEN_DV    : std_logic_vector(NET_IFC_COUNT-1 downto 0);
   signal TX_BUF_NEWLEN_RDY   : std_logic_vector(NET_IFC_COUNT-1 downto 0);  -- always set to '1'
   signal TX_BUF_RELLEN       : std_logic_vector(NET_IFC_COUNT*16-1 downto 0);
   signal TX_BUF_RELLEN_DV    : std_logic_vector(NET_IFC_COUNT-1 downto 0);

begin

-- ------------------------------------------------------------------
-- UUT Instantion
uut : entity work.DMA_CTRL_ARRAY
   generic map (
      NET_IFC_COUNT     => NET_IFC_COUNT,
      MEM_PAGE_SIZE     => MEM_PAGE_SIZE,
      DESC_BLOCK_SIZE   => DESC_BLOCK_SIZE,
      INT_TIMEOUT       => INT_TIMEOUT,
      BUFFER_ADDR       => BUFFER_ADDR,
      BUFFER_SIZE       => BUFFER_SIZE,
      DMA_DATA_WIDTH    => DMA_DATA_WIDTH
   )
   port map (
      -- Common interface
      CLK         => CLK,
      RESET       => RESET,

      RX_INTERRUPT   => rx_interrupt,
      TX_INTERRUPT   => tx_interrupt,

      -- Receive buffer interface
      RX_BUF_NEWLEN     => RX_BUF_NEWLEN,
      RX_BUF_NEWLEN_DV  => RX_BUF_NEWLEN_DV,
      RX_BUF_NEWLEN_RDY => RX_BUF_NEWLEN_RDY,
      RX_BUF_RELLEN     => RX_BUF_RELLEN,
      RX_BUF_RELLEN_DV  => RX_BUF_RELLEN_DV,

      -- Transmit buffer interface
      TX_BUF_NEWLEN     => TX_BUF_NEWLEN,
      TX_BUF_NEWLEN_DV  => TX_BUF_NEWLEN_DV,
      TX_BUF_NEWLEN_RDY => TX_BUF_NEWLEN_RDY,
      TX_BUF_RELLEN     => TX_BUF_RELLEN,
      TX_BUF_RELLEN_DV  => TX_BUF_RELLEN_DV,

      -- Memory interface
      -- Write interface
      WR_ADDR     => ib_wr.ADDR,
      WR_DATA     => ib_wr.DATA,
      WR_BE       => ib_wr.BE,
      WR_REQ      => ib_wr.REQ,
      WR_RDY      => ib_wr.RDY,
      -- Read interface
      RD_ADDR     => ib_rd.ADDR,
      RD_BE       => ib_rd.BE,
      RD_REQ      => ib_rd.REQ,
      RD_ARDY     => ib_rd.ARDY,
      RD_DATA     => ib_rd.DATA,
      RD_SRC_RDY  => ib_rd.SRC_RDY,
      RD_DST_RDY  => ib_rd.DST_RDY,

      -- Bus Master interface
      BM_GLOBAL_ADDR => ib_bm.GLOBAL_ADDR,
      BM_LOCAL_ADDR  => ib_bm.LOCAL_ADDR,
      BM_LENGTH      => ib_bm.LENGTH,
      BM_TAG         => ib_bm.TAG,
      BM_TRANS_TYPE  => ib_bm.TRANS_TYPE,
      BM_REQ         => ib_bm.REQ,
      -- Output
      BM_ACK         => ib_bm.ACK,
      BM_OP_TAG      => ib_bm.OP_TAG,
      BM_OP_DONE     => ib_bm.OP_DONE
   );

-- clk clock generator
clkgen_CLK: process
begin
   CLK <= '1';
   wait for CLKPER/2;
   CLK <= '0';
   wait for CLKPER/2;
end process;

-- Internal Bus Switch -----------------------------------------------------
IB_SWITCH1_I : entity work.IB_SWITCH
   generic map (
      -- Data Width (64/128)
      DATA_WIDTH        => 64,
      -- Port 0 Address Space
      SWITCH_BASE        => X"00000000",
      SWITCH_LIMIT       => X"01000000",
      -- Port 1 Address Space
      DOWNSTREAM0_BASE   => X"00000000",
      DOWNSTREAM0_LIMIT  => X"00400000",
      -- Port 2 Address Space
      DOWNSTREAM1_BASE   => X"00800000",
      DOWNSTREAM1_LIMIT  => X"00000100"
   )

   port map (
      -- Common Interface
      IB_CLK         => ib_clk,
      IB_RESET       => reset,
      -- Upstream Port
      PORT0          => internal_bus,
      -- Downstream Ports
      PORT1          => switch1_port1,
      PORT2          => switch1_port2
   );
   
-- Internal Bus Endpoint ---------------------------------------------------
IB_ENDPOINT_I : entity work.IB_ENDPOINT_MASTER
   generic map(
--       BASE_ADDR     => conv_std_logic_vector(TEST_BASE_ADDR, 32),
      LIMIT         => TEST_LIMIT
   )
   port map(
      -- Common Interface
      IB_CLK        => ib_clk,
      IB_RESET      => reset,
      -- Internal Bus Interface
      INTERNAL_BUS  => switch1_port1,
      -- User Component Interface
      WR            => ib_wr,
      RD            => ib_rd,

      -- Busmaster
      BM            => ib_bm
   );

-- Internal Bus Bus Functional Model ------------------------------------------
IB_BFM_U : entity work.IB_BFM
   GENERIC MAP (
       MEMORY_SIZE => 4096,
       MEMORY_BASE_ADDR => X"00000000" & X"CCCCD000"
       )
   PORT MAP (
      CLK          => ib_clk,
      -- Internal Bus Interface
      IB           => internal_bus
      );

-- ----------------------------------------------------------------------------
--                         Main testbench process
-- ----------------------------------------------------------------------------
tb : process

--  -- Support for ib_op
--    procedure ib_op(ctrl : in t_ib_ctrl) is
--    begin
--       wait until (IB_CLK'event and IB_CLK='1' and ib_sim_busy = '0');
--       ib_sim_ctrl <= ctrl;
--       ib_sim_strobe <= '1';
--       wait until (IB_CLK'event and IB_CLK='1');
--       ib_sim_strobe <= '0';
--    end ib_op;


begin
   RESET <= '1', '0' after 100 ns;

   RX_BUF_NEWLEN(63 downto 0) <= X"0000" & X"0000" & X"0000" & X"0000";
   RX_BUF_NEWLEN_DV(3 downto 0) <= "0000";
   InitMemory(256, "rx_desc_data.txt", IbCmd);
--    ShowMemory(IbCmd);

   wait for 5*CLKPER;
   
   -- initialization - Write first descriptor 
   SendLocalWrite(X"00200000", X"08000000", 8, 16#1234#, X"00000000" & X"CCCCD001", IbCmd);
   -- initialization - Write swStrPtr 
   SendLocalWrite(X"00201008", X"08000000", 4, 16#1234#, X"00000000" & X"00000000", IbCmd);
   -- initialization - Write swEndPtr 
   SendLocalWrite(X"0020100C", X"08000000", 4, 16#1234#, X"00000000" & X"00000000", IbCmd);
   -- initialization - Write start command to controlRegiter 
   SendLocalWrite(X"00201000", X"08000000", 4, 16#1234#, X"00000000" & X"00000001", IbCmd);

--    -- initialization - Write first descriptor 
--    SendLocalWrite(X"00210000", X"08000000", 8, 16#1234#, X"00000000" & X"CCCCD001", IbCmd);
--    -- initialization - Write swStrPtr 
--    SendLocalWrite(X"00211008", X"08000000", 4, 16#1234#, X"00000000" & X"00000000", IbCmd);
--    -- initialization - Write swEndPtr 
--    SendLocalWrite(X"0021100C", X"08000000", 4, 16#1234#, X"00000000" & X"00000000", IbCmd);
--    -- initialization - Write start command to controlRegiter 
--    SendLocalWrite(X"00211000", X"08000000", 8, 16#1234#, X"0000000D" & X"00000000", IbCmd);
--    
--    -- initialization - Write first descriptor 
--    SendLocalWrite(X"00220000", X"08000000", 8, 16#1234#, X"00000000" & X"CCCCD001", IbCmd);
--    -- initialization - Write swStrPtr 
--    SendLocalWrite(X"00221008", X"08000000", 4, 16#1234#, X"00000000" & X"00000000", IbCmd);
--    -- initialization - Write swEndPtr 
--    SendLocalWrite(X"0022100C", X"08000000", 4, 16#1234#, X"00000000" & X"00000000", IbCmd);
--    -- initialization - Write start command to controlRegiter 
--    SendLocalWrite(X"00221000", X"08000000", 8, 16#1234#, X"0000000D" & X"00000000", IbCmd);
-- 
--    -- initialization - Write first descriptor 
--    SendLocalWrite(X"00230000", X"08000000", 8, 16#1234#, X"00000000" & X"CCCCD001", IbCmd);
--    -- initialization - Write swStrPtr 
--    SendLocalWrite(X"00231008", X"08000000", 4, 16#1234#, X"00000000" & X"00000000", IbCmd);
--    -- initialization - Write swEndPtr 
--    SendLocalWrite(X"0023100C", X"08000000", 4, 16#1234#, X"00000000" & X"00000000", IbCmd);
--    -- initialization - Write start command to controlRegiter 
--    SendLocalWrite(X"00231000", X"08000000", 8, 16#1234#, X"0000000D" & X"00000000", IbCmd);
--    wait for 15*CLKPER;

   -- running - simulate packet arrival
   RX_BUF_NEWLEN(15 downto 0) <= X"0030";
   RX_BUF_NEWLEN_DV(0)        <= '1';
   wait for CLKPER;
   RX_BUF_NEWLEN(15 downto 0) <= X"0000";
   RX_BUF_NEWLEN_DV(0)        <= '0';

--    -- running - simulate packet arrival
--    RX_BUF_NEWLEN(31 downto 16) <= X"0040";
--    RX_BUF_NEWLEN_DV(1)        <= '1';
--    wait for CLKPER;
--    RX_BUF_NEWLEN(31 downto 16) <= X"0000";
--    RX_BUF_NEWLEN_DV(1)        <= '0';
-- 
--    -- running - simulate packet arrival
--    RX_BUF_NEWLEN(47 downto 32) <= X"0050";
--    RX_BUF_NEWLEN_DV(2)        <= '1';
--    wait for CLKPER;
--    RX_BUF_NEWLEN(47 downto 32) <= X"0000";
--    RX_BUF_NEWLEN_DV(2)        <= '0';
-- 
--    -- running - simulate packet arrival
--    RX_BUF_NEWLEN(63 downto 48) <= X"0060";
--    RX_BUF_NEWLEN_DV(3)        <= '1';
--    wait for CLKPER;
--    RX_BUF_NEWLEN(63 downto 48) <= X"0000";
--    RX_BUF_NEWLEN_DV(3)        <= '0';

   wait for 1800 ns;

   RX_BUF_NEWLEN(15 downto 0) <= X"0030";
   RX_BUF_NEWLEN_DV(0)        <= '1';
   wait for CLKPER;
   RX_BUF_NEWLEN(15 downto 0) <= X"0000";
   RX_BUF_NEWLEN_DV(0)        <= '0';


   -- DEBUG - register readback
   SendLocalRead (X"00200000", X"08000000", 8, 16#1234#, IbCmd);
   SendLocalRead (X"00201000", X"08000000", 4, 16#1234#, IbCmd);
   SendLocalRead (X"00201004", X"08000000", 4, 16#1234#, IbCmd);
   SendLocalRead (X"00201008", X"08000000", 4, 16#1234#, IbCmd);
   SendLocalRead (X"0020100C", X"08000000", 4, 16#1234#, IbCmd);
   SendLocalRead (X"00201010", X"08000000", 4, 16#1234#, IbCmd);
   SendLocalRead (X"00201014", X"08000000", 4, 16#1234#, IbCmd);
   SendLocalRead (X"00201018", X"08000000", 4, 16#1234#, IbCmd);
   SendLocalRead (X"00201020", X"08000000", 4, 16#1234#, IbCmd);
   SendLocalRead (X"00201024", X"08000000", 4, 16#1234#, IbCmd);

   wait;

end process;


end architecture behavioral;
-- ----------------------------------------------------------------------------

