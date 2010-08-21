--
-- lb_endpoint_write_fsm.vhd: Switch output controler
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

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity IB_ENDPOINT_WRITE_FSM is
   generic (
     STRICT_EN     : boolean:= false
   );
   port(
   -- Common Interface
   CLK             : in std_logic;   -- Clk
   RESET           : in std_logic;   -- Reset
   IDLE            : out std_logic;  -- FSM is Idle (For Strict Version)
   READ_FSM_IDLE   : in  std_logic;  -- Read FSM is Idle (For Strict Version)
   BM_FSM_IDLE     : in  std_logic;
   -- SHR_IN Interface
   DATA_VLD        : in  std_logic;  -- Data in Shift Reg is valid
   SOP             : in  std_logic;  -- Start of Packet
   EOP             : in  std_logic;  -- End of Packet
   SHR_RE          : out std_logic;  -- Read Data from shift reg

   -- Address Decoder Interface
   WRITE_TRANS     : in  std_logic;  -- Processing write transaction
   READ_BACK       : in  std_logic;  -- read back
   
   -- Control Interface
   DST_ADDR_WE     : out std_logic;  -- Store Addr into addr_cnt and addr_align
   DST_ADDR_CNT_CE : out std_logic;  -- Increment address
   SRC_ADDR_WE     : out std_logic;  -- Store Source Address
   LENGTH_WE       : out std_logic;  -- Store Length
   TAG_WE          : out std_logic;  -- Store TAG register
   INIT_BE         : out std_logic;  -- Init BE circuit

   -- User Component Interface
   WR_SOF          : out std_logic;  -- Start of frame (Start of transaction)
   WR_EOF          : out std_logic;  -- Ent of frame (End of Transaction)
   WR_RDY          : in  std_logic;  -- User component is ready
   WR_REQ          : out std_logic;  -- Write to user component
   RD_BACK         : out std_logic
   );
end entity IB_ENDPOINT_WRITE_FSM;


-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture IB_ENDPOINT_WRITE_FSM_ARCH of IB_ENDPOINT_WRITE_FSM is

   -- Control FSM declaration
   type   t_states is (st_idle, st_hdr, st_sof, st_write);
   signal present_state, next_state : t_states;
   signal process_en        : std_logic;
   signal read_back_reg     : std_logic;
   signal read_back_reg_we  : std_logic;

begin

process_en <= '1' when (not STRICT_EN or (STRICT_EN and READ_FSM_IDLE = '1' and BM_FSM_IDLE='1')) else '0';


-- register read_back_reg ------------------------------------------------------
read_back_regp: process(RESET, CLK)
begin
   if (CLK'event AND CLK = '1') then
      if (read_back_reg_we = '1') then
         read_back_reg <= READ_BACK;
      end if;
   end if;
end process;


-- SWITCH INPUT FSM -----------------------------------------------------------
-- next state clk logic
clk_d: process(CLK, RESET)
  begin
    if RESET = '1' then
      present_state <= st_idle;
    elsif (CLK='1' and CLK'event) then
      present_state <= next_state;
    end if;
  end process;

-- next state logic
state_trans: process(present_state, DATA_VLD, SOP, EOP, WR_RDY, WRITE_TRANS, process_en)
  begin
    case present_state is

      when st_idle =>
         -- New Write Transaction
         if (process_en = '1' and SOP = '1' and WRITE_TRANS = '1') then  
           next_state <= st_hdr; -- Start of Header
         else
           next_state <= st_idle; -- Idle
         end if;
      
      -- ST_HDR
      when st_hdr =>
         if (DATA_VLD = '1') then
            next_state <= st_sof;
         else
            next_state <= st_hdr;
         end if;
                  
      -- ST_START_OF_FRAME
      when st_sof =>
         if (EOP = '1' and WR_RDY = '1') then
           next_state <= st_idle;
         elsif (DATA_VLD = '1' and WR_RDY = '1') then
           next_state <= st_write;
         else
           next_state <= st_sof;
         end if;

      -- ST_WRITE
      when st_write =>
         -- End of transaction
         if (EOP = '1' and WR_RDY = '1') then
           next_state <= st_idle;
         else
           next_state <= st_write;
         end if;

     end case;
  end process;

-- output logic
output_logic: process(present_state, DATA_VLD, SOP, EOP, WR_RDY, WRITE_TRANS, read_back_reg, process_en)
  begin
   DST_ADDR_WE       <= '0';
   DST_ADDR_CNT_CE   <= '0';
   SRC_ADDR_WE       <= '0';
   LENGTH_WE         <= '0';
   TAG_WE            <= '0';
   INIT_BE           <= '0';
   SHR_RE            <= '0';
   WR_SOF            <= '0';
   WR_EOF            <= '0';
   WR_REQ            <= '0';
   IDLE              <= '0';
   read_back_reg_we  <= '0';
   RD_BACK           <= '0';
   
   case present_state is

      -- ST_IDLE
      when st_idle =>
        IDLE             <= '1';
        read_back_reg_we <= '1';
        if (process_en ='1' and SOP = '1' and WRITE_TRANS = '1') then
          DST_ADDR_WE       <= '1';
          LENGTH_WE         <= '1';
          TAG_WE            <= '1';
          INIT_BE           <= '1';
          SHR_RE            <= '1';
        end if;

      -- ST_HDR
      when st_hdr =>
         SRC_ADDR_WE <= '1';
         SHR_RE      <= '1'; 
         
      -- ST_START_OF_FRAME
      when st_sof =>
         RD_BACK <= read_back_reg;
         if (DATA_VLD = '1' and WR_RDY = '1') then
            SHR_RE           <= '1';
            DST_ADDR_CNT_CE  <= '1';
         end if;
         WR_EOF  <= EOP;
         WR_REQ  <= DATA_VLD;
         WR_SOF  <= DATA_VLD;

       -- ST_WRITE
      when st_write =>
        RD_BACK  <= read_back_reg;
        WR_REQ   <= DATA_VLD;
        WR_EOF   <= EOP;
        if (DATA_VLD = '1' and WR_RDY = '1') then
            SHR_RE           <= '1';
            DST_ADDR_CNT_CE  <= '1';
        end if;

     end case;
  end process;

end architecture IB_ENDPOINT_WRITE_FSM_ARCH;

