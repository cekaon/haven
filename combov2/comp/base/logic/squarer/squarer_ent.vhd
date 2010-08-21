-- squarer_ent.vhd: Squarer entity declaration
-- Copyright (C) 2009 CESNET
-- Author(s): Ondrej Lengal <lengal@liberouter.org>
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

-- ==========================================================================
--                              ENTITY DECLARATION
-- ==========================================================================
entity SQUARER is
   generic
   (
      -- widths of operand
      OPERAND_WIDTH         : integer := 20;
      -- width of result
      RESULT_WIDTH          : integer := 40;
      -- degree of parallelism, i.e. into how many parts will the input be split
      DEGREE_OF_PARALLELISM : integer := 2;
      -- latency in clock cycles
      LATENCY               : integer := 1
   );
   port
   (
      -- common interface
      CLK      :  in std_logic;

      -- the operand
      DATA     :  in std_logic_vector(OPERAND_WIDTH-1 downto 0);

      -- result (is valid LATENCY clock cycles after operands are set)
      RESULT   : out std_logic_vector(RESULT_WIDTH-1 downto 0)
   );
end entity;
