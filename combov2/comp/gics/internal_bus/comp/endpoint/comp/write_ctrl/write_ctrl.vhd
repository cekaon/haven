--
-- write_ctrl.vhd : Internal Bus Endpoint Write Controller Entity
-- Copyright (C) 2008 CESNET
-- Author(s): Tomas Malek <tomalek@liberouter.org>
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

use work.math_pack.all;
use work.ib_ifc_pkg.all; 
use work.ib_fmt_pkg.all; 
use work.ib_endpoint_pkg.all;

-- ----------------------------------------------------------------------------
--       ENTITY DECLARATION -- Internal Bus Endpoint Write Controller        --
-- ----------------------------------------------------------------------------
      
entity IB_ENDPOINT_WRITE_CTRL is 
   generic(
      -- Data Width (8-128)
      DATA_WIDTH : integer := 64;
      -- Address Width (1-32)
      ADDR_WIDTH : integer := 32;
      -- Strict Transaction Order
      STRICT_ORDER : boolean := false
   ); 
   port (
      -- Common interface -----------------------------------------------------
      CLK          : in std_logic;  
      RESET        : in std_logic;  

      -- IB Interface ---------------------------------------------------------
      IB_DATA      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      IB_SOF_N     : in  std_logic;
      IB_EOF_N     : in  std_logic;
      IB_SRC_RDY_N : in  std_logic;
      IB_DST_RDY_N : out std_logic;

      -- Write Interface ------------------------------------------------------
      WR_REQ       : out std_logic;                           
      WR_RDY       : in  std_logic;                                 
      WR_DATA      : out std_logic_vector(DATA_WIDTH-1 downto 0);
      WR_ADDR      : out std_logic_vector(ADDR_WIDTH-1 downto 0);       
      WR_BE        : out std_logic_vector(DATA_WIDTH/8-1 downto 0);        
      WR_LENGTH    : out std_logic_vector(11 downto 0);       
      WR_SOF       : out std_logic;                           
      WR_EOF       : out std_logic;
      
      -- Strict unit interface ------------------------------------------------
      WR_EN        : in  std_logic;
      WR_COMPLETE  : out std_logic
   );
end IB_ENDPOINT_WRITE_CTRL;



