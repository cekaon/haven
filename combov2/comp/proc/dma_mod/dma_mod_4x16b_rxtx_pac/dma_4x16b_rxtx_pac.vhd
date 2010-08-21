-- dma_4x16b_rxtx.vhd: DMA Module for 4x16 RX+TX interface
-- Copyright (C) 2008 CESNET
-- Author(s):  Pavol Korcek <korcek@liberouter.org>
--             Martin Kosek <kosek@liberouter.org>
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
-- $Id$
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.math_pack.all;

use work.dma_mod_4x16b_rxtx_pac_const.all;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of DMA_MOD_4x16b_RXTX_PAC is

signal ics_rx0_data     : std_logic_vector(15 downto 0);
signal ics_rx0_drem     : std_logic_vector( 0 downto 0);
signal ics_rx0_sop_n    : std_logic;
signal ics_rx0_eop_n    : std_logic;
signal ics_rx0_sof_n    : std_logic;
signal ics_rx0_eof_n    : std_logic;
signal ics_rx0_src_rdy_n: std_logic;
signal ics_rx0_dst_rdy_n: std_logic;

signal ics_rx1_data     : std_logic_vector(15 downto 0);
signal ics_rx1_drem     : std_logic_vector( 0 downto 0);
signal ics_rx1_sop_n    : std_logic;
signal ics_rx1_eop_n    : std_logic;
signal ics_rx1_sof_n    : std_logic;
signal ics_rx1_eof_n    : std_logic;
signal ics_rx1_src_rdy_n: std_logic;
signal ics_rx1_dst_rdy_n: std_logic;

signal ics_rx2_data     : std_logic_vector(15 downto 0);
signal ics_rx2_drem     : std_logic_vector( 0 downto 0);
signal ics_rx2_sop_n    : std_logic;
signal ics_rx2_eop_n    : std_logic;
signal ics_rx2_sof_n    : std_logic;
signal ics_rx2_eof_n    : std_logic;
signal ics_rx2_src_rdy_n: std_logic;
signal ics_rx2_dst_rdy_n: std_logic;

signal ics_rx3_data     : std_logic_vector(15 downto 0);
signal ics_rx3_drem     : std_logic_vector( 0 downto 0);
signal ics_rx3_sop_n    : std_logic;
signal ics_rx3_eop_n    : std_logic;
signal ics_rx3_sof_n    : std_logic;
signal ics_rx3_eof_n    : std_logic;
signal ics_rx3_src_rdy_n: std_logic;
signal ics_rx3_dst_rdy_n: std_logic;

signal ics_tx0_data     : std_logic_vector(15 downto 0);
signal ics_tx0_drem     : std_logic_vector( 0 downto 0);
signal ics_tx0_sop_n    : std_logic;
signal ics_tx0_eop_n    : std_logic;
signal ics_tx0_sof_n    : std_logic;
signal ics_tx0_eof_n    : std_logic;
signal ics_tx0_src_rdy_n: std_logic;
signal ics_tx0_dst_rdy_n: std_logic;

signal ics_tx1_data     : std_logic_vector(15 downto 0);
signal ics_tx1_drem     : std_logic_vector( 0 downto 0);
signal ics_tx1_sop_n    : std_logic;
signal ics_tx1_eop_n    : std_logic;
signal ics_tx1_sof_n    : std_logic;
signal ics_tx1_eof_n    : std_logic;
signal ics_tx1_src_rdy_n: std_logic;
signal ics_tx1_dst_rdy_n: std_logic;

signal ics_tx2_data     : std_logic_vector(15 downto 0);
signal ics_tx2_drem     : std_logic_vector( 0 downto 0);
signal ics_tx2_sop_n    : std_logic;
signal ics_tx2_eop_n    : std_logic;
signal ics_tx2_sof_n    : std_logic;
signal ics_tx2_eof_n    : std_logic;
signal ics_tx2_src_rdy_n: std_logic;
signal ics_tx2_dst_rdy_n: std_logic;

signal ics_tx3_data     : std_logic_vector(15 downto 0);
signal ics_tx3_drem     : std_logic_vector( 0 downto 0);
signal ics_tx3_sop_n    : std_logic;
signal ics_tx3_eop_n    : std_logic;
signal ics_tx3_sof_n    : std_logic;
signal ics_tx3_eof_n    : std_logic;
signal ics_tx3_src_rdy_n: std_logic;
signal ics_tx3_dst_rdy_n: std_logic;

begin
   RXTX_BUFFERS_I : entity work.RXTX_BUFFERS_PAC
      generic map(
         -- number of network interfaces
         NET_IFC_COUNT              => 4,
         -- RX/TX Buffer generics
         DATA_WIDTH                 => 16,
         BLOCK_SIZE                 => RXTX_BLOCK_SIZE,
         RXTXBUF_IFC_TOTAL_SIZE     => RXTX_IFC_TOTAL_SIZE,

         -- Internal Bus Endpoint generics
         IB_EP_CONNECTED_TO         => IB_EP_CONNECTED_TO,
         IB_EP_ENDPOINT_BASE        => IB_EP_ENDPOINT_BASE,
         IB_EP_ENDPOINT_LIMIT       => IB_EP_ENDPOINT_LIMIT,
         IB_EP_STRICT_ORDER         => IB_EP_STRICT_ORDER,
         IB_EP_DATA_REORDER         => IB_EP_DATA_REORDER,
         IB_EP_READ_IN_PROCESS      => IB_EP_READ_IN_PROCESS,
         IB_EP_INPUT_BUFFER_SIZE    => IB_EP_INPUT_BUFFER_SIZE,
         IB_EP_OUTPUT_BUFFER_SIZE   => IB_EP_OUTPUT_BUFFER_SIZE
      )
      port map(
         -- Common interface
         CLK            => CLK,
         RESET          => RESET,
         RX_INTERRUPT   => RX_INTERRUPT,
         TX_INTERRUPT   => TX_INTERRUPT,
         -- network interfaces interface
         -- input FrameLink interface
         RX_SOF_N(0)             => ics_rx0_sof_n,
         RX_SOF_N(1)             => ics_rx1_sof_n,
         RX_SOF_N(2)             => ics_rx2_sof_n,
         RX_SOF_N(3)             => ics_rx3_sof_n,
   
         RX_SOP_N(0)             => ics_rx0_sop_n,
         RX_SOP_N(1)             => ics_rx1_sop_n,
         RX_SOP_N(2)             => ics_rx2_sop_n,
         RX_SOP_N(3)             => ics_rx3_sop_n,
   
         RX_EOP_N(0)             => ics_rx0_eop_n,
         RX_EOP_N(1)             => ics_rx1_eop_n,
         RX_EOP_N(2)             => ics_rx2_eop_n,
         RX_EOP_N(3)             => ics_rx3_eop_n,
   
         RX_EOF_N(0)             => ics_rx0_eof_n,
         RX_EOF_N(1)             => ics_rx1_eof_n,
         RX_EOF_N(2)             => ics_rx2_eof_n,
         RX_EOF_N(3)             => ics_rx3_eof_n,
   
         RX_SRC_RDY_N(0)         => ics_rx0_src_rdy_n,
         RX_SRC_RDY_N(1)         => ics_rx1_src_rdy_n,
         RX_SRC_RDY_N(2)         => ics_rx2_src_rdy_n,
         RX_SRC_RDY_N(3)         => ics_rx3_src_rdy_n,
   
         RX_DST_RDY_N(0)         => ics_rx0_dst_rdy_n,
         RX_DST_RDY_N(1)         => ics_rx1_dst_rdy_n,
         RX_DST_RDY_N(2)         => ics_rx2_dst_rdy_n,
         RX_DST_RDY_N(3)         => ics_rx3_dst_rdy_n,
   
         RX_DATA(15 downto 0)    => ics_rx0_data,
         RX_DATA(31 downto 16)   => ics_rx1_data,
         RX_DATA(47 downto 32)   => ics_rx2_data,
         RX_DATA(63 downto 48)   => ics_rx3_data,
   
         RX_REM(0 downto 0)      => ics_rx0_drem,
         RX_REM(1 downto 1)      => ics_rx1_drem,
         RX_REM(2 downto 2)      => ics_rx2_drem,
         RX_REM(3 downto 3)      => ics_rx3_drem,

         -- output FrameLink interface
         TX_SOF_N(0)             => ics_tx0_sof_n,
         TX_SOF_N(1)             => ics_tx1_sof_n,
         TX_SOF_N(2)             => ics_tx2_sof_n,
         TX_SOF_N(3)             => ics_tx3_sof_n,

         TX_SOP_N(0)             => ics_tx0_sop_n,
         TX_SOP_N(1)             => ics_tx1_sop_n,
         TX_SOP_N(2)             => ics_tx2_sop_n,
         TX_SOP_N(3)             => ics_tx3_sop_n,

         TX_EOP_N(0)             => ics_tx0_eop_n,
         TX_EOP_N(1)             => ics_tx1_eop_n,
         TX_EOP_N(2)             => ics_tx2_eop_n,
         TX_EOP_N(3)             => ics_tx3_eop_n,

         TX_EOF_N(0)             => ics_tx0_eof_n,
         TX_EOF_N(1)             => ics_tx1_eof_n,
         TX_EOF_N(2)             => ics_tx2_eof_n,
         TX_EOF_N(3)             => ics_tx3_eof_n,

         TX_SRC_RDY_N(0)         => ics_tx0_src_rdy_n,
         TX_SRC_RDY_N(1)         => ics_tx1_src_rdy_n,
         TX_SRC_RDY_N(2)         => ics_tx2_src_rdy_n,
         TX_SRC_RDY_N(3)         => ics_tx3_src_rdy_n,

         TX_DST_RDY_N(0)         => ics_tx0_dst_rdy_n,
         TX_DST_RDY_N(1)         => ics_tx1_dst_rdy_n,
         TX_DST_RDY_N(2)         => ics_tx2_dst_rdy_n,
         TX_DST_RDY_N(3)         => ics_tx3_dst_rdy_n,

         TX_DATA(15 downto 0)    => ics_tx0_data,
         TX_DATA(31 downto 16)   => ics_tx1_data,
         TX_DATA(47 downto 32)   => ics_tx2_data,
         TX_DATA(63 downto 48)   => ics_tx3_data,

         TX_REM(0 downto 0)      => ics_tx0_drem,
         TX_REM(1 downto 1)      => ics_tx1_drem,
         TX_REM(2 downto 2)      => ics_tx2_drem,
         TX_REM(3 downto 3)      => ics_tx3_drem,

         -- Internal Bus interface
         IB_DOWN_DATA       => IB_DOWN_DATA,
         IB_DOWN_SOF_N      => IB_DOWN_SOF_N,
         IB_DOWN_EOF_N      => IB_DOWN_EOF_N,
         IB_DOWN_SRC_RDY_N  => IB_DOWN_SRC_RDY_N,
         IB_DOWN_DST_RDY_N  => IB_DOWN_DST_RDY_N,
         IB_UP_DATA         => IB_UP_DATA,
         IB_UP_SOF_N        => IB_UP_SOF_N,
         IB_UP_EOF_N        => IB_UP_EOF_N,
         IB_UP_SRC_RDY_N    => IB_UP_SRC_RDY_N,
         IB_UP_DST_RDY_N    => IB_UP_DST_RDY_N,
          
         -- MI32 interface
         MI32_DWR           => MI32_DWR,
         MI32_ADDR          => MI32_ADDR,
         MI32_RD            => MI32_RD,
         MI32_WR            => MI32_WR,
         MI32_BE            => MI32_BE,
         MI32_DRD           => MI32_DRD,
         MI32_ARDY          => MI32_ARDY,
         MI32_DRDY          => MI32_DRDY
      );

      -- Clock domain transfer: USER -> ICS (RX)
      FL_ASYNC_RX0 : entity work.fl_asfifo_cv2_16b
      port map(      
         RX_CLK      => USER_CLK,
         RX_RESET    => USER_RESET,
         TX_CLK      => CLK,
         TX_RESET    => RESET,

         RX_DATA     => RX0_DATA,
         RX_REM      => RX0_DREM,
         RX_EOP_N    => RX0_EOP_N,
         RX_SOP_N    => RX0_SOP_N,
         RX_EOF_N    => RX0_EOF_N,
         RX_SOF_N    => RX0_SOF_N,
         RX_SRC_RDY_N=> RX0_SRC_RDY_N,
         RX_DST_RDY_N=> RX0_DST_RDY_N,

         TX_DATA     => ics_rx0_data,
         TX_REM      => ics_rx0_drem,
         TX_EOP_N    => ics_rx0_eop_n,
         TX_SOP_N    => ics_rx0_sop_n,
         TX_EOF_N    => ics_rx0_eof_n,
         TX_SOF_N    => ics_rx0_sof_n,
         TX_SRC_RDY_N=> ics_rx0_src_rdy_n,
         TX_DST_RDY_N=> ics_rx0_dst_rdy_n
      );

      FL_ASYNC_RX1 : entity work.fl_asfifo_cv2_16b
      port map(      
         RX_CLK      => USER_CLK,
         RX_RESET    => USER_RESET,
         TX_CLK      => CLK,
         TX_RESET    => RESET,

         RX_DATA     => RX1_DATA,
         RX_REM      => RX1_DREM,
         RX_EOP_N    => RX1_EOP_N,
         RX_SOP_N    => RX1_SOP_N,
         RX_EOF_N    => RX1_EOF_N,
         RX_SOF_N    => RX1_SOF_N,
         RX_SRC_RDY_N=> RX1_SRC_RDY_N,
         RX_DST_RDY_N=> RX1_DST_RDY_N,

         TX_DATA     => ics_rx1_data,
         TX_REM      => ics_rx1_drem,
         TX_EOP_N    => ics_rx1_eop_n,
         TX_SOP_N    => ics_rx1_sop_n,
         TX_EOF_N    => ics_rx1_eof_n,
         TX_SOF_N    => ics_rx1_sof_n,
         TX_SRC_RDY_N=> ics_rx1_src_rdy_n,
         TX_DST_RDY_N=> ics_rx1_dst_rdy_n
      );

      FL_ASYNC_RX2 : entity work.fl_asfifo_cv2_16b
      port map(
         RX_CLK      => USER_CLK,
         RX_RESET    => USER_RESET,
         TX_CLK      => CLK,
         TX_RESET    => RESET,

         RX_DATA     => RX2_DATA,
         RX_REM      => RX2_DREM,
         RX_EOP_N    => RX2_EOP_N,
         RX_SOP_N    => RX2_SOP_N,
         RX_EOF_N    => RX2_EOF_N,
         RX_SOF_N    => RX2_SOF_N,
         RX_SRC_RDY_N=> RX2_SRC_RDY_N,
         RX_DST_RDY_N=> RX2_DST_RDY_N,

         TX_DATA     => ics_rx2_data,
         TX_REM      => ics_rx2_drem,
         TX_EOP_N    => ics_rx2_eop_n,
         TX_SOP_N    => ics_rx2_sop_n,
         TX_EOF_N    => ics_rx2_eof_n,
         TX_SOF_N    => ics_rx2_sof_n,
         TX_SRC_RDY_N=> ics_rx2_src_rdy_n,
         TX_DST_RDY_N=> ics_rx2_dst_rdy_n
      );

      FL_ASYNC_RX3 : entity work.fl_asfifo_cv2_16b
      port map(
         RX_CLK      => USER_CLK,
         RX_RESET    => USER_RESET,
         TX_CLK      => CLK,
         TX_RESET    => RESET,

         RX_DATA     => RX3_DATA,
         RX_REM      => RX3_DREM,
         RX_EOP_N    => RX3_EOP_N,
         RX_SOP_N    => RX3_SOP_N,
         RX_EOF_N    => RX3_EOF_N,
         RX_SOF_N    => RX3_SOF_N,
         RX_SRC_RDY_N=> RX3_SRC_RDY_N,
         RX_DST_RDY_N=> RX3_DST_RDY_N,

         TX_DATA     => ics_rx3_data,
         TX_REM      => ics_rx3_drem,
         TX_EOP_N    => ics_rx3_eop_n,
         TX_SOP_N    => ics_rx3_sop_n,
         TX_EOF_N    => ics_rx3_eof_n,
         TX_SOF_N    => ics_rx3_sof_n,
         TX_SRC_RDY_N=> ics_rx3_src_rdy_n,
         TX_DST_RDY_N=> ics_rx3_dst_rdy_n
      );

      -- Clock domain transfer ICS -> USER (TX)
      FL_ASYNC_TX0 : entity work.fl_asfifo_cv2_16b
      port map(
         RX_CLK      => CLK,
         RX_RESET    => RESET,
         TX_CLK      => USER_CLK,
         TX_RESET    => USER_RESET,

         RX_DATA     => ics_tx0_data,
         RX_REM      => ics_tx0_drem,
         RX_EOP_N    => ics_tx0_eop_n,
         RX_SOP_N    => ics_tx0_sop_n,
         RX_EOF_N    => ics_tx0_eof_n,
         RX_SOF_N    => ics_tx0_sof_n,
         RX_SRC_RDY_N=> ics_tx0_src_rdy_n,
         RX_DST_RDY_N=> ics_tx0_dst_rdy_n,

         TX_DATA     => TX0_DATA,
         TX_REM      => TX0_DREM,
         TX_EOP_N    => TX0_EOP_N,
         TX_SOP_N    => TX0_SOP_N,
         TX_EOF_N    => TX0_EOF_N,
         TX_SOF_N    => TX0_SOF_N,
         TX_SRC_RDY_N=> TX0_SRC_RDY_N,
         TX_DST_RDY_N=> TX0_DST_RDY_N
      );

      FL_ASYNC_TX1 : entity work.fl_asfifo_cv2_16b
      port map(
         RX_CLK      => CLK,
         RX_RESET    => RESET,
         TX_CLK      => USER_CLK,
         TX_RESET    => USER_RESET,

         RX_DATA     => ics_tx1_data,
         RX_REM      => ics_tx1_drem,
         RX_EOP_N    => ics_tx1_eop_n,
         RX_SOP_N    => ics_tx1_sop_n,
         RX_EOF_N    => ics_tx1_eof_n,
         RX_SOF_N    => ics_tx1_sof_n,
         RX_SRC_RDY_N=> ics_tx1_src_rdy_n,
         RX_DST_RDY_N=> ics_tx1_dst_rdy_n,

         TX_DATA     => TX1_DATA,
         TX_REM      => TX1_DREM,
         TX_EOP_N    => TX1_EOP_N,
         TX_SOP_N    => TX1_SOP_N,
         TX_EOF_N    => TX1_EOF_N,
         TX_SOF_N    => TX1_SOF_N,
         TX_SRC_RDY_N=> TX1_SRC_RDY_N,
         TX_DST_RDY_N=> TX1_DST_RDY_N
      );

      FL_ASYNC_TX2 : entity work.fl_asfifo_cv2_16b
      port map(
         RX_CLK      => CLK,
         RX_RESET    => RESET,
         TX_CLK      => USER_CLK,
         TX_RESET    => USER_RESET,

         RX_DATA     => ics_tx2_data,
         RX_REM      => ics_tx2_drem,
         RX_EOP_N    => ics_tx2_eop_n,
         RX_SOP_N    => ics_tx2_sop_n,
         RX_EOF_N    => ics_tx2_eof_n,
         RX_SOF_N    => ics_tx2_sof_n,
         RX_SRC_RDY_N=> ics_tx2_src_rdy_n,
         RX_DST_RDY_N=> ics_tx2_dst_rdy_n,

         TX_DATA     => TX2_DATA,
         TX_REM      => TX2_DREM,
         TX_EOP_N    => TX2_EOP_N,
         TX_SOP_N    => TX2_SOP_N,
         TX_EOF_N    => TX2_EOF_N,
         TX_SOF_N    => TX2_SOF_N,
         TX_SRC_RDY_N=> TX2_SRC_RDY_N,
         TX_DST_RDY_N=> TX2_DST_RDY_N
      );

      FL_ASYNC_TX3 : entity work.fl_asfifo_cv2_16b
      port map(
         RX_CLK      => CLK,
         RX_RESET    => RESET,
         TX_CLK      => USER_CLK,
         TX_RESET    => USER_RESET,

         RX_DATA     => ics_tx3_data,
         RX_REM      => ics_tx3_drem,
         RX_EOP_N    => ics_tx3_eop_n,
         RX_SOP_N    => ics_tx3_sop_n,
         RX_EOF_N    => ics_tx3_eof_n,
         RX_SOF_N    => ics_tx3_sof_n,
         RX_SRC_RDY_N=> ics_tx3_src_rdy_n,
         RX_DST_RDY_N=> ics_tx3_dst_rdy_n,

         TX_DATA     => TX3_DATA,
         TX_REM      => TX3_DREM,
         TX_EOP_N    => TX3_EOP_N,
         TX_SOP_N    => TX3_SOP_N,
         TX_EOF_N    => TX3_EOF_N,
         TX_SOF_N    => TX3_SOF_N,
         TX_SRC_RDY_N=> TX3_SRC_RDY_N,
         TX_DST_RDY_N=> TX3_DST_RDY_N
      );

end architecture;
-- ----------------------------------------------------------------------------
