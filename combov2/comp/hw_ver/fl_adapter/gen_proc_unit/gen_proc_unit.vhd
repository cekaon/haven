--------------------------------------------------------------------------
-- Project Name: Hardware - Software Framework for Functional Verification
-- File Name:    FrameLink Adapter
-- Description:  Processing of generated data and content of registers.
-- Author:       Marcela Simkova <isimkova@fit.vutbr.cz> 
-- Date:         12.6.2012 
-- --------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.math_pack.all;

-- ==========================================================================
--                              ENTITY DECLARATION
-- ==========================================================================
entity GEN_PROC_UNIT is

   generic
   (
      -- data width
      DATA_WIDTH : integer := 32
   );

   port
   (
      CLK        : in std_logic;
      RESET      : in std_logic;
      
      -- input interface
      GEN_DATA   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      MASK       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      BASE       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      MAX        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      
      -- output interface
      OUTPUT     : out std_logic_vector(DATA_WIDTH-1 downto 0);
      OUTPUT_VLD : out std_logic
   );
   
end entity;

-- ==========================================================================
--                           ARCHITECTURE DESCRIPTION
-- ==========================================================================
architecture arch of GEN_PROC_UNIT is

-- ==========================================================================
--                                    CONSTANTS
-- ==========================================================================

-- ==========================================================================
--                                     SIGNALS
-- ==========================================================================
signal sig_mask           : std_logic_vector(DATA_WIDTH-1 downto 0);
signal sig_add            : std_logic_vector(DATA_WIDTH-1 downto 0);
signal sig_output_reg_we  : std_logic;
signal sig_output_reg     : std_logic_vector(DATA_WIDTH-1 downto 0);
signal sig_output_vld     : std_logic;

begin

-- masking of generated data -> random value
   sig_mask <= GEN_DATA and MASK;
   
-- base + random value
   sig_add <= sig_mask + BASE; 
   
-- camparison of generated value with maximum value
   comparator_p: process (CLK)
   begin
     if (sig_add <= MAX) then sig_output_reg_we <= '1';
     else sig_output_reg_we <= '0';
     end if;
   end process;  
   
-- register for output values
   output_reg_p: process (CLK)
   begin
      if (rising_edge(CLK)) then
         if (RESET = '1') then
            sig_output_reg <= (others => '0');
            sig_output_vld <= '0';
         elsif (sig_output_reg_we = '1') then
            sig_output_reg <= sig_add; 
            sig_output_vld <= sig_output_reg_we;
         end if;
      end if;
   end process;
   
-- generated output
   OUTPUT     <= sig_output_reg;
   OUTPUT_vld <= sig_output_vld; 
end architecture;
