-- verification_core_ent.vhd: Entity of verification core
-- Author(s): Ondrej Lengal <ilengal@fit.vutbr.cz>
--
-- $Id$
--

library ieee;
use ieee.std_logic_1164.all;
use work.math_pack.all;

-- HAVEN constants
use work.haven_const.all;

-- ==========================================================================
--                              ENTITY DECLARATION
-- ==========================================================================
entity verification_core is
   generic
   (
      -- data width 
      DATA_WIDTH         : integer := 64;
      -- the CORE_TYPE generic specifies the verified unit in the core
      CORE_TYPE          : core_type := core_fifo;
      -- should signal observers be used?
      USE_OBSERVERS      : boolean := false;
      -- should the input FrameLink coverage unit be used?
      USE_FL_COV_UNIT    : boolean := false
   );
   port
   (
      CLK                :  in std_logic;
      RESET              :  in std_logic;

      -- input interface
      RX_DATA            :  in std_logic_vector(DATA_WIDTH-1 downto 0);
      RX_REM             :  in std_logic_vector(log2(DATA_WIDTH/8)-1 downto 0);
      RX_SOF_N           :  in std_logic;
      RX_EOF_N           :  in std_logic;
      RX_SOP_N           :  in std_logic;
      RX_EOP_N           :  in std_logic;
      RX_SRC_RDY_N       :  in std_logic;
      RX_DST_RDY_N       : out std_logic;

      -- output interface
      TX_DATA            : out std_logic_vector(DATA_WIDTH-1 downto 0);
      TX_REM             : out std_logic_vector(log2(DATA_WIDTH/8)-1 downto 0);
      TX_SOF_N           : out std_logic;
      TX_EOF_N           : out std_logic;
      TX_SOP_N           : out std_logic;
      TX_EOP_N           : out std_logic;
      TX_SRC_RDY_N       : out std_logic;
      TX_DST_RDY_N       :  in std_logic;

      -- MI32 interface
      MI32_DWR           :  in std_logic_vector(31 downto 0);
      MI32_ADDR          :  in std_logic_vector(31 downto 0);
      MI32_RD            :  in std_logic;
      MI32_WR            :  in std_logic;
      MI32_BE            :  in std_logic_vector(3 downto 0);
      MI32_DRD           : out std_logic_vector(31 downto 0);
      MI32_ARDY          : out std_logic;
      MI32_DRDY          : out std_logic
   );
end entity;
