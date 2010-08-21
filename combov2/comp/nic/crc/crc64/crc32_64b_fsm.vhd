--
-- crc32_64b_fsm.vhd: FSM for crc32_64b module
-- Copyright (C) 2006 CESNET
-- Author(s): Bidlo Michal <bidlom@fit.vutbr.cz>
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
-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity crc32_64b_fsm is
   port(
      CLK: in std_logic;
      RESET: in std_logic;
      DI_DV: in std_logic;
      EOP: in std_logic;
      
      DCTL: out std_logic;
      TCTL: out std_logic;
      TVAL: out std_logic
   );
end entity crc32_64b_fsm;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture crc32_64b_fsm_arch of crc32_64b_fsm is

   type fsm_states is (SL, SC, CL);
   signal curr_state, next_state : fsm_states;
   
begin
-- -------------------------------------------------------
sync_logic : process(RESET, CLK)
begin
   if (RESET = '1') then
      curr_state <= SL;
   elsif (CLK'event AND CLK = '1') then
      curr_state <= next_state;
   end if;
end process sync_logic;

-- -------------------------------------------------------
next_state_logic : process(curr_state, DI_DV, EOP)
begin
   case (curr_state) is
      when SL =>
         if EOP = '0' AND DI_DV = '1' then
            next_state <= SC;
         elsif EOP = '1' AND DI_DV = '1' then
            next_state <= CL;
         else
            next_state <= SL;
         end if;
      when SC =>
         if EOP = '1' AND DI_DV = '1' then
		 	next_state <= CL;
         else
            next_state <= SC;
         end if;
      when CL => next_state <= SL;
      when others => next_state <= SL;
   end case;
end process next_state_logic;

-- -------------------------------------------------------
output_logic : process(curr_state, DI_DV, EOP)
begin
   case (curr_state) is
      when SL =>
         DCTL <= '0';
         TCTL <= '1';
         TVAL <= '0';
      when SC =>
         DCTL <= '0';
         TCTL <= '0';
         TVAL <= '0';
      when CL =>
         DCTL <= '1';
         TCTL <= '0';
         TVAL <= '1';
      when others =>
         DCTL <= '1';
         TCTL <= '1';
         TVAL <= '0';
   end case;
end process output_logic;

end architecture crc32_64b_fsm_arch;

