--
-- dp_bmem_behav.vhd: Dual port generic BlockRAM memory (behavioral)
-- Copyright (C) 2008 CESNET
-- Author(s): Vaclav Bartos <xbarto11@stud.fit.vutbr.cz>
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


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
-- auxilarity functions and constant needed to evaluate generic address etc.
use WORK.math_pack.all;
use WORK.bmem_func.all;

-- pragma translate_off
library UNISIM;
use UNISIM.vcomponents.all;
-- pragma translate_on

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of DP_BMEM is
    
   attribute ram_style   : string; -- for XST
   attribute block_ram   : boolean; -- for precision
   
   type t_mem is array(0 to ITEMS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
   
   -- ----------------------------------------------------------------------
   -- Function to Zero out the memory
   -- This is to prevent 'U' signals in simulations
   function BRAM_INIT_MEM return t_mem is
      variable init : t_mem;
   begin
      for i in 0 to ITEMS - 1 loop
         init(i) := (others => '0');
      end loop;

      return init;
   end BRAM_INIT_MEM;
   -- ----------------------------------------------------------------------

   shared variable memory : t_mem := BRAM_INIT_MEM;
   
   signal doa_to_reg        : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal dob_to_reg        : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal reg_doa           : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal reg_dob           : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal reg_doa_dv1       : std_logic;
   signal reg_doa_dv2       : std_logic;
   signal reg_dob_dv1       : std_logic;
   signal reg_dob_dv2       : std_logic;

   attribute ram_style of memory: variable is "block"; -- auto,block,distributed
   attribute block_ram of memory: variable is true; -- true,false
   
begin
   
   -- ------------------------- memory - port A ------------------------------
   
   GEN_WRITE_FIRST_A: if (WRITE_MODE_A = "WRITE_FIRST") generate
      process(CLKA)
      begin
         if (CLKA'event and CLKA = '1') then
            if (PIPE_ENA = '1') then
               if (WEA = '1') then
                  memory(conv_integer(unsigned(ADDRA))) := DIA;
               end if;
               doa_to_reg <= memory(conv_integer(unsigned(ADDRA)));
            end if;
         end if;
      end process;
   end generate;
   
   GEN_READ_FIRST_A: if (WRITE_MODE_A = "READ_FIRST") generate
      process(CLKA)
      begin
         if (CLKA'event and CLKA = '1') then
            if (PIPE_ENA = '1') then
               doa_to_reg <= memory(conv_integer(unsigned(ADDRA)));
               if (WEA = '1') then
                  memory(conv_integer(unsigned(ADDRA))) := DIA;
               end if;
            end if;
         end if;
      end process;
   end generate;
   
   
   -- doesn't work
   GEN_NO_CHANGE_A: if (WRITE_MODE_A = "NO_CHANGE") generate
      process(CLKA)
      begin
         if (CLKA'event and CLKA = '1') then
            if (PIPE_ENA = '1') then
               if (WEA = '1' and REA = '0') then
                  memory(conv_integer(unsigned(ADDRA))) := DIA;
               end if;
               doa_to_reg <= memory(conv_integer(unsigned(ADDRA)));
            end if;
         end if;
      end process;
   end generate;
   
   
   -- ------------------------- memory - port B ------------------------------
   
   GEN_WRITE_FIRST_B: if (WRITE_MODE_B = "WRITE_FIRST") generate
      process(CLKB)
      begin
         if (CLKB'event and CLKB = '1') then
            if (PIPE_ENB = '1') then
               if (WEB = '1') then
                  memory(conv_integer(unsigned(ADDRB))) := DIB;
               end if;
               dob_to_reg <= memory(conv_integer(unsigned(ADDRB)));
            end if;
         end if;
      end process;
   end generate;
   
   GEN_READ_FIRST_B: if (WRITE_MODE_B = "READ_FIRST") generate
      process(CLKB)
      begin
         if (CLKB'event and CLKB = '1') then
            if (PIPE_ENB = '1') then
               dob_to_reg <= memory(conv_integer(unsigned(ADDRB)));
               if (WEB = '1') then
                  memory(conv_integer(unsigned(ADDRB))) := DIB;
               end if;
            end if;
         end if;
      end process;
   end generate;
   
   GEN_NO_CHANGE_B: if (WRITE_MODE_B = "NO_CHANGE") generate
      process(CLKB)
      begin
         if (CLKB'event and CLKB = '1') then
            if (PIPE_ENB = '1') then
               if (WEB = '1' and REB = '0') then
                  memory(conv_integer(unsigned(ADDRB))) := DIB;
               end if;
               dob_to_reg <= memory(conv_integer(unsigned(ADDRB)));
            end if;
         end if;
      end process;
   end generate;
   
   
   -- ------------------------ Output registers -------------------------------
   OUTPUTREG : if (OUTPUT_REG = true or OUTPUT_REG = auto) generate
      -- DOA Register
      process(RESET, CLKA)
      begin
         if (RESET = '1') then
            reg_doa     <= (others => '0');
            reg_doa_dv1 <= '0';
            reg_doa_dv2 <= '0';
         elsif (CLKA'event AND CLKA = '1') then
            if (PIPE_ENA = '1') then
               reg_doa     <= doa_to_reg;
               reg_doa_dv1 <= REA;
               reg_doa_dv2 <= reg_doa_dv1;
            end if;
         end if;
      end process;
   
      -- DOB Register
      process(RESET, CLKB)
      begin
         if (RESET = '1') then
            reg_dob     <= (others => '0');
            reg_dob_dv1 <= '0';
            reg_dob_dv2 <= '0';
         elsif (CLKB'event AND CLKB = '1') then
            if (PIPE_ENB = '1') then
              reg_dob     <= dob_to_reg;
              reg_dob_dv1 <= REB;
              reg_dob_dv2 <= reg_dob_dv1;
            end if;
         end if;
      end process;
   
      -- mapping registers to output
      DOA <= reg_doa;
      DOB <= reg_dob;
      DOA_DV <= reg_doa_dv2;
      DOB_DV <= reg_dob_dv2;
   end generate;


   -- --------------------- No Output registers -------------------------------
   NOOUTPUTREG : if (OUTPUT_REG = false) generate
      process(RESET, CLKA)
      begin
         if (RESET = '1') then
            DOA_DV <= '0';
         elsif (CLKA'event AND CLKA = '1') then
            if (PIPE_ENA = '1') then
               DOA_DV <= REA;
            end if;
         end if;
      end process;
   
      process(RESET, CLKB)
      begin
         if (RESET = '1') then
            DOB_DV <= '0';
         elsif (CLKB'event AND CLKB = '1') then
            if (PIPE_ENB = '1') then
               DOB_DV <= REB;
            end if;
         end if;
      end process;
      
      -- mapping memory to output
      DOA <= doa_to_reg;
      DOB <= dob_to_reg;
   end generate;
   
end architecture behavioral;
