-- fl_rxbuffer_ent.vhd: Frame Link protocol receiving unit entity
-- Copyright (C) 2006 CESNET
-- Author(s): Libor Polcak <xpolca03@stud.fit.vutbr.cz>
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.math_pack.all;
use work.lb_pkg.all;


-- ----------------------------------------------------------------------------
--                            Entity declaration
-- ----------------------------------------------------------------------------
entity FL_RXBUFFER is
   generic(
      -- Frame Link data width
      -- Should be multiple of 16: only 16,32,64,128 supported
      DATA_WIDTH     : integer := 16;
      -- Number of FrameLink parts
      PARTS          : integer := 3;
      -- True => use BlockBAMs in the FIFO
      -- False => use SelectRAMs in the FIFO
      USE_BRAMS      : boolean := True;
      -- number of items in the FIFO
      ITEMS          : integer := 1024
   );
   port(
      -- clock signal
      CLK : in std_logic;
      -- asynchronous reset signal, active in '1'
      RESET : in std_logic;

      -- Frame Link input
      RX_DATA      : in std_logic_vector(DATA_WIDTH-1 downto 0);
      RX_REM       : in std_logic_vector(log2(DATA_WIDTH/8) - 1 downto 0);
      RX_SOF_N     : in std_logic; -- Start of frame, active in '0'
      RX_SOP_N     : in std_logic; -- Start of packet, active in '0'
      RX_EOP_N     : in std_logic; -- End of packet, active in '0'
      RX_EOF_N     : in std_logic; -- End of frame, active in '0'
      RX_SRC_RDY_N : in std_logic; -- Source is ready, active in '0'
      RX_DST_RDY_N : out std_logic; -- RXBUFFER is ready, active in '0'

      -- MI32 in/out interface
      MI32 : inout t_mi32
   );
end entity FL_RXBUFFER;


