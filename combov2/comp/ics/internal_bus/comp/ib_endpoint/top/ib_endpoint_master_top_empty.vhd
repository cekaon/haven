--
-- ib_endpoint_master_top.vhd: Internal Bus End Point Component
-- Copyright (C) 2006 CESNET
-- Author(s): Petr Kobiersky <xkobie00@stud.fit.vutbr.cz>
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
use work.ib_pkg.all; -- Internal Bus package
use work.math_pack.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity IB_ENDPOINT_MASTER_TOP is
   generic(
      LIMIT               : std_logic_vector(31 downto 0);
      INPUT_BUFFER_SIZE   : integer:=0;
      OUTPUT_BUFFER_SIZE  : integer:=0;
      READ_REORDER_BUFFER : boolean:=true;
      STRICT_EN           : boolean;       -- Eanble Strict version
   );
   port(
      -- Common Interface
      IB_CLK        : in std_logic;
      IB_RESET      : in std_logic;
      
      -- Internal Bus Interface
      INTERNAL_BUS  : inout t_internal_bus64;

      -- Write Interface
      WR_ADDR       : out std_logic_vector(31 downto 0);
      WR_DATA       : out std_logic_vector(63 downto 0);
      WR_BE         : out std_logic_vector(7 downto 0);
      WR_REQ        : out std_logic;
      WR_RDY        : in  std_logic;
      WR_LENGTH     : out std_logic_vector(11 downto 0);
      WR_SOF        : out std_logic;
      WR_EOF        : out std_logic;

      -- Read Interface
      -- Input Interface
      RD_ADDR       : out std_logic_vector(31 downto 0);
      RD_BE         : out std_logic_vector(7 downto 0);
      RD_REQ        : out std_logic;
      RD_ARDY       : in  std_logic;
      RD_SOF_IN     : out std_logic;
      RD_EOF_IN     : out std_logic;
      -- Output Interface
      RD_DATA       : in  std_logic_vector(63 downto 0);
      RD_SRC_RDY    : in  std_logic;
      RD_DST_RDY    : out std_logic;

      -- Busmaster
      -- Input
      BM_GLOBAL_ADDR   : in  std_logic_vector(63 downto 0);   -- Global Address 
      BM_LOCAL_ADDR    : in  std_logic_vector(31 downto 0);   -- Local Address
      BM_LENGTH        : in  std_logic_vector(11 downto 0);   -- Length
      BM_TAG           : in  std_logic_vector(15 downto 0);   -- Operation TAG
      BM_TRANS_TYPE    : in  std_logic_vector(1 downto 0);    -- Transaction Type
      BM_REQ           : in  std_logic;                       -- Request
      BM_ACK           : out std_logic;                       -- Ack
      -- Output
      BM_OP_TAG        : out std_logic_vector(15 downto 0);   -- Operation TAG
      BM_OP_DONE       : out std_logic                        -- Acknowledg
  );
end entity IB_ENDPOINT_MASTER_TOP;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture IB_ENDPOINT_MASTER_TOP_ARCH of IB_ENDPOINT_MASTER_TOP is
   
begin


end architecture IB_ENDPOINT_MASTER_TOP_ARCH;
