--
-- cnt_dist.vhd: Array of counters using distram
-- Copyright (C) 2005 CESNET
-- Author(s): Martin Mikusek <martin.mikusek@liberouter.org>
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
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

use work.math_pack.all;

-- auxilary functions and constant needed to evaluate generic address etc.
use WORK.distmem_func.all;

-- pragma translate_off
library unisim;
use unisim.vcomponents.all;
-- pragma translate_on


-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity cnt_dist is
   generic (
      WIDTH	   : integer := 32; -- width of counter
      DISTMEM_TYPE : integer := 32; -- type of used distram (16, 32, 64)
      COUNT	   : integer        -- count of counters
   );
   port(
      RESET     : in  std_logic;
      CLK       : in  std_logic;
      FLAG      : in  std_logic_vector(COUNT-1 downto 0);
      FLAG_DV   : in  std_logic;
      CLR       : in  std_logic;
      ADDR      : in  std_logic_vector(LOG2(COUNT)-1 downto 0);
      DO        : out std_logic_vector(WIDTH-1 downto 0);
      RDY       : out std_logic
   );
end entity cnt_dist;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture full of cnt_dist is

signal cnt_addr     : std_logic_vector(LOG2(COUNT)-1 downto 0);
signal reg_cnt_addr : std_logic_vector(LOG2(COUNT)-1 downto 0);
signal mux_addr     : std_logic_vector(LOG2(COUNT)-1 downto 0);

signal result       : std_logic_vector(WIDTH-1 downto 0);
signal mem_do       : std_logic_vector(WIDTH-1 downto 0);
signal reg_mem_do   : std_logic_vector(WIDTH-1 downto 0);
signal reg          : std_logic_vector(COUNT-1 downto 0);

signal sel          : std_logic;
signal ready        : std_logic;
signal cmp_eq0      : std_logic;
signal reg_cmp_eq0  : std_logic;
signal reg_we       : std_logic;

begin

   -- Memory connection -------------------------------------------------------
   DP_DISTMEM_U: entity work.dp_distmem
   generic map (
      distmem_type   => DISTMEM_TYPE,
      data_width     => WIDTH,
      items          => COUNT
   )
   port map (
      RESET       => RESET,
      -- Write port
      WCLK        => CLK,
      ADDRA       => mux_addr,
      DI          => result,
      WE          => reg(COUNT-1),
      DOA         => DO,

      -- Read port
      ADDRB       => cnt_addr,
      DOB         => mem_do
   );

   -- control signals ---------------------------------------------------------
   sel    <= FLAG_DV and cmp_eq0;
   reg_we <= FLAG_DV or not cmp_eq0;

   cmp_eq0 <= '1' when (reg(COUNT-1 downto 0)=
      conv_std_logic_vector(0, reg'length)) else '0';

   ready <= reg_cmp_eq0;

   -- pipe_lined distmem output -----------------------------------------------
   reg_mem_do_p: process (RESET, CLK)
   begin
      if (RESET='1') then
	 reg_mem_do <= (others=>'0');
      elsif (CLK='1' and CLK'event) then
	 reg_mem_do <= mem_do;
      end if;
   end process;

   -- pipe_lined comparator result --------------------------------------------
   reg_cmp_eq0_p: process (RESET, CLK)
   begin
      if (RESET='1') then
	 reg_cmp_eq0 <= '0';
      elsif (CLK='1' and CLK'event) then
	 reg_cmp_eq0 <= cmp_eq0;
      end if;
   end process;

   -- shift flag register -----------------------------------------------------
   reg0_p: process (RESET, CLK)
   begin
      if (RESET='1') then
	 reg(0) <= '0';
      elsif (CLK='1' and CLK'event) then
	 if (reg_we='1') then
	    if (sel='1') then
	       reg(0) <= FLAG(0);
	    else
	       reg(0) <= '0';
	    end if;
	 end if;
      end if;
   end process;

   gen_registers: for i in 1 to COUNT-1 generate
      reg_p: process (RESET, CLK)
      begin
	 if (RESET='1') then
	    reg(i) <= '0';
	 elsif (CLK='1' and CLK'event) then
	    if (reg_we='1') then
	       if (sel='1') then
		  reg(i) <= FLAG(i);
	       else
		  reg(i) <= reg(i-1);
	       end if;
	    end if;
	 end if;
      end process;
   end generate;

   -- addres counter ----------------------------------------------------------
   cnt_addr_p: process (RESET, CLK)
   begin
      if (RESET='1') then
	 cnt_addr <= (others=>'0');
      elsif (CLK='1' and CLK'event) then
	 if (FLAG_DV='1' and cmp_eq0='1') then
	    cnt_addr <= (others=>'0');
	 end if;
	 if (cmp_eq0='0') then
	    cnt_addr <= cnt_addr+1;
	 end if;
      end if;
   end process;

   -- pipelined addres counter ------------------------------------------------
   reg_cnt_addr_p: process (RESET, CLK)
   begin
      if (RESET='1') then
	 reg_cnt_addr <= (others=>'0');
      elsif (CLK='1' and CLK'event) then
	 reg_cnt_addr <= cnt_addr;
      end if;
   end process;

   -- adress multiplexor ------------------------------------------------------
   mux_addr <= ADDR when (ready='1') else reg_cnt_addr;

   -- adder -------------------------------------------------------------------
   result <= (reg_mem_do + 1) when (CLR='0')
      else conv_std_logic_vector(0, result'length);

   -- output signal mapping ---------------------------------------------------
   RDY <= ready;

end architecture full;

