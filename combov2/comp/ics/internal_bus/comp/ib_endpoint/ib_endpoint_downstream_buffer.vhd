--
-- ib_endpoint_downstream_buffer.vhd: Internal Bus Downstream Buffer
-- Copyright (C) 2006 CESNET
-- Author(s): Petr Kobiersky <xkobie00@stud.fit.vutbr.cz>
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
-- TODO:
--
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.ib_pkg.all;
-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity IB_ENDPOINT_DOWNSTREAM_BUFFER is
   generic(
      ITEMS            : integer
      );
   port(
      -- Common Interface
      IB_CLK           : in std_logic;
      IB_RESET         : in std_logic;

      IN_DATA          : in  std_logic_vector(63 downto 0);
      IN_SOP_N         : in  std_logic;
      IN_EOP_N         : in  std_logic;
      IN_SRC_RDY_N     : in  std_logic;
      IN_DST_RDY_N     : out std_logic;

      OUT_DATA         : out std_logic_vector(63 downto 0);
      OUT_SOP_N        : out std_logic;
      OUT_EOP_N        : out std_logic;
      OUT_SRC_RDY_N    : out std_logic;
      OUT_DST_RDY_N    : in  std_logic
      );
end entity IB_ENDPOINT_DOWNSTREAM_BUFFER;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture IB_ENDPOINT_DOWNSTREAM_BUFFER_ARCH of IB_ENDPOINT_DOWNSTREAM_BUFFER is

   signal fifo_data_in   : std_logic_vector(65 downto 0);
   signal fifo_lstblk    : std_logic;
   signal dst_rdy_n_pipe : std_logic;
   signal fifo_wr        : std_logic;
   signal fifo_data_out  : std_logic_vector(65 downto 0);
   signal fifo_rd        : std_logic;
   signal fifo_dv        : std_logic;

begin

fifo_data_in    <= IN_EOP_N & IN_SOP_N & IN_DATA;
fifo_wr         <= not IN_SRC_RDY_N and not dst_rdy_n_pipe;
IN_DST_RDY_N    <= dst_rdy_n_pipe;

OUT_DATA      <= fifo_data_out(63 downto 0);
OUT_SOP_N     <= fifo_data_out(64);
OUT_EOP_N     <= fifo_data_out(65);
OUT_SRC_RDY_N <= not fifo_dv;
fifo_rd          <= not OUT_DST_RDY_N;

-- register dst_rdy_pipe ------------------------------------------------------
dst_rdy_pipep: process(IB_RESET, IB_CLK)
  begin
    if (IB_RESET = '1') then
      dst_rdy_n_pipe <= '0';
    elsif (IB_CLK'event AND IB_CLK = '1') then
      dst_rdy_n_pipe <= fifo_lstblk;
    end if;
end process;

-- bram fifo ------------------------------------------------------------------
FIFO_BRAM_U : entity work.FIFO_BRAM
   generic map (
      ITEMS          => ITEMS,
      BLOCK_SIZE     => 2,
      BRAM_TYPE      => 36,
      DATA_WIDTH     => 66,
      AUTO_PIPELINE  => true
   )
   port map (
      CLK            => IB_CLK,
      RESET          => IB_RESET,

      -- Write interface
      WR             => fifo_wr, 
      DI             => fifo_data_in,
      FULL           => open,
      LSTBLK         => fifo_lstblk,

      -- Read interface
      RD             => fifo_rd,
      DO             => fifo_data_out,
      DV             => fifo_dv,
      EMPTY          => open
   );


end architecture IB_ENDPOINT_DOWNSTREAM_BUFFER_ARCH;

