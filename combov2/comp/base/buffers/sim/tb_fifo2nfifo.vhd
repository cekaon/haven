--
-- testbench.vhd: For whole design testing
-- Copyright (C) 2008 CESNET
-- Author(s): Vozenilek Jan  <xvozen00@stud.fit.vutbr.cz>
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
-- TODO:
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.math_pack.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity testbench is
end entity;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of testbench is

   constant TEST_WIDTH : integer      := 64;
   constant TEST_FLOWS : integer      := 2;
   constant TEST_BLK_S : integer      := 8;
   constant LUT_MEM    : boolean      := false;
   constant GLOB_STATE : boolean      := true;
   constant clkper     : time         := 10 ns;

   signal clk        : std_logic;
   signal reset      : std_logic;

   signal wr         : std_logic;
   signal di         : std_logic_vector(TEST_WIDTH-1 downto 0);
   signal blk_addr   : std_logic_vector(abs(log2(TEST_FLOWS)-1) downto 0);

   signal rd         : std_logic_vector(TEST_FLOWS-1 downto 0);
   signal do         : std_logic_vector(TEST_WIDTH-1 downto 0);
   signal dv         : std_logic_vector(TEST_FLOWS-1 downto 0);

   signal empty      : std_logic_vector(TEST_FLOWS-1 downto 0);
   signal full       : std_logic_vector(TEST_FLOWS-1 downto 0);
   signal status     : std_logic_vector(log2(TEST_BLK_S+1)*TEST_FLOWS-1 downto 0);

-- ----------------------------------------------------------------------------
--                      Architecture body
-- ----------------------------------------------------------------------------
begin

uut : entity work.FIFO2NFIFO
generic map(
  DATA_WIDTH => TEST_WIDTH,
  FLOWS      => TEST_FLOWS,
  BLOCK_SIZE => TEST_BLK_S,
  LUT_MEMORY => LUT_MEM,
  GLOB_STATE => GLOB_STATE
)
port map(
  CLK        => clk,
  RESET      => reset,

  -- Write interface
  DATA_IN    => di,
  BLOCK_ADDR => blk_addr,
  WRITE      => wr,

  -- Read interface
  DATA_OUT   => do,
  DATA_VLD   => dv,
  READ       => rd,
  EMPTY      => empty,
  FULL       => full,
  STATUS     => status
);

-- ----------------------------------------------------
-- CLK clock generator
clkgen : process
begin
   clk <= '1';
   wait for clkper/2;
   clk <= '0';
   wait for clkper/2;
end process;

tb : process
begin

reset      <= '1';
wr         <= '0';
blk_addr   <= (others => '0');
rd         <= (others => '0');
di         <= (others => '0');
wait for clkper*8;
reset      <= '0';
wait for clkper*4;

blk_addr <= conv_std_logic_vector(0, blk_addr'length);
wr <= '1';
for j in 1 to 20 loop
  if (j = 4) then
    blk_addr <= blk_addr + 1;
  end if;
  for i in 0 to TEST_FLOWS-1 loop
    di((TEST_WIDTH/TEST_FLOWS)*i+(TEST_WIDTH/TEST_FLOWS)-1 downto (TEST_WIDTH/TEST_FLOWS)*i) <= conv_std_logic_vector(j, TEST_WIDTH/TEST_FLOWS);
  end loop;
  wait for clkper;
end loop;

wr <= '0';
di <= conv_std_logic_vector(0, di'length);
wait for 5*clkper;

rd <= (others => '1');
wait for clkper*20;
rd <= (others => '0');
wait for clkper*4;

end process;

-- ----------------------------------------------------------------------------
end architecture behavioral;
