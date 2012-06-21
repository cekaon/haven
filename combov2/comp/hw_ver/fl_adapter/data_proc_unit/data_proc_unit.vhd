--------------------------------------------------------------------------
-- Project Name: Hardware - Software Framework for Functional Verification
-- File Name:    FrameLink Adapter
-- Description:  Processes data parts from data size processing unit. 
-- Author:       Marcela Simkova <isimkova@fit.vutbr.cz> 
-- Date:         16.6.2013 
-- --------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.math_pack.all;

-- ==========================================================================
--                              ENTITY DECLARATION
-- ==========================================================================
entity DATA_PROC_UNIT is

   generic
   (
      -- data width
      SIZE_WIDTH  : integer := 32;
      DATA_WIDTH  : integer := 64
   );

   port
   (
      CLK   : in std_logic;
      RESET : in std_logic;

      -- Data Part processing interface
      DATA_SIZE     :  in std_logic_vector(SIZE_WIDTH-1 downto 0);  
      DATA_SIZE_VLD :  in std_logic; 
      
      -- Data processing interface
      DATA_REQUEST  :  in  std_logic; 
      DATA_RDY      :  out std_logic;
      DATA_REM      :  out std_logic_vector(log2(DATA_WIDTH/8)-1 downto 0);
      DATA_COMPLETE :  out std_logic
    );       
   
end entity;

-- ==========================================================================
--                           ARCHITECTURE DESCRIPTION
-- ==========================================================================
architecture arch of DATA_PROC_UNIT is

-- ==========================================================================
--                                    CONSTANTS
-- ==========================================================================
constant BLOCK_SIZE : integer := DATA_WIDTH/8;

-- ==========================================================================
--                                     SIGNALS
-- ==========================================================================
signal sig_data_size_reg : std_logic_vector(SIZE_WIDTH-1 downto 0);
signal sig_data_size     : std_logic_vector(SIZE_WIDTH-1 downto 0);
signal sig_cmp_out       : std_logic;

begin

-- register for the data size
   data_size_reg_p: process (CLK)
   begin
      if (rising_edge(CLK)) then
         if (RESET = '1') then
            sig_data_size_reg <= (others => '0');
         elsif (DATA_REQUEST = '1') then
            sig_data_size_reg <= sig_data_size;
         end if;
      end if;
   end process; 
   
-- data size mux
   data_size_mux : process (DATA_SIZE, DATA_SIZE_VLD, sig_data_size_reg, sig_cmp_out)
   begin
      sig_data_size <= (others => '0');

      if (DATA_SIZE_VLD = '1') then
        case sig_cmp_out is
           when '0'    => sig_data_size <= sig_data_size_reg - BLOCK_SIZE;
           when '1'    => sig_data_size <= DATA_SIZE;
           when others => null;   
        end case;
      else 
        sig_data_size <= sig_data_size_reg;
      end if;  
   end process;   
   
-- data size comparator
   data_size_cmp : process (sig_data_size_reg)
   begin
      sig_cmp_out <= '0';

      if (sig_data_size_reg <= BLOCK_SIZE) then 
        sig_cmp_out <= '1';
        DATA_REM    <= sig_data_size_reg(2 downto 0) - 1;
      else 
        sig_cmp_out <= '0';
        DATA_REM    <= conv_std_logic_vector(BLOCK_SIZE - 1, log2(BLOCK_SIZE));
      end if;
   end process;  
   
   DATA_COMPLETE     <= sig_cmp_out;
   
-- register for ready signal
   valid_reg_p: process (CLK)
   begin
      if (rising_edge(CLK)) then
         if (RESET = '1') then
            DATA_RDY <= '0';
         elsif (sig_cmp_out = '1') then
            DATA_RDY <= DATA_SIZE_VLD; 
         end if;
      end if;
   end process;    
        
end architecture;
