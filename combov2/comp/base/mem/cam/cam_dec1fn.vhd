--
-- dec1fn.vhd: Decoder 1 from n
-- Copyright (C) 2003 CESNET
-- Author(s): Martinek Tomas <martinek@liberouter.org>
-- 
-- Modified by: Martin Kosek <xkosek00@stud.fit.vutbr.cz>
--              (Added an ENABLE signal)
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
-- TODO:
--
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.math_pack.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity cam_dec1fn is
   generic(
      ITEMS       : integer
   );
   port(
      ADDR        : in std_logic_vector(log2(ITEMS)-1 downto 0);
      ENABLE      : in std_logic;
      DO          : out std_logic_vector(ITEMS-1 downto 0)
   );
end entity cam_dec1fn;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of cam_dec1fn is


begin

process(ADDR, ENABLE)
begin
   DO    <= (others => '0');
   if ENABLE = '1' then
      for i in 0 to (ITEMS-1) loop
         if (conv_std_logic_vector(i, log2(ITEMS)) = ADDR) then
            DO(i) <= '1';
         end if;
      end loop;
   end if;
end process;

end architecture behavioral;

