-- mi_addr_subtractor_arch.vhd: MI Address Subtractor
-- Copyright (C) 2010 CESNET
-- Author(s): Vaclav Bartos <washek@liberouter.org>
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-- ----------------------------------------------------------------------------
--                          ARCHITECTURE DECLARATION                         --
-- ---------------------------------------------------------------------------- 

architecture mi_addr_subtractor_arch of MI_ADDR_SUBTRACTOR is

begin
   -- -------------------------------------------------------------------------
   --                          MI Address Subtractor                         --
   -- -------------------------------------------------------------------------
   
   OUT_ADDR  <= IN_ADDR - SUBTRACT(ADDR_WIDTH-1 downto 0);
   
   OUT_DWR   <= IN_DWR;
   OUT_BE    <= IN_BE;
   OUT_RD    <= IN_RD;
   OUT_WR    <= IN_WR;
   IN_ARDY   <= OUT_ARDY;
   IN_DRD    <= OUT_DRD;
   IN_DRDY   <= OUT_DRDY;
   
end mi_addr_subtractor_arch;