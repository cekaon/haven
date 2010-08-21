--
-- lb_endpoint_read_fsm.vhd: ib2adc Read FSM
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
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.ib_pkg.all; -- Internal Bus package
-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity IB_ENDPOINT_READ_FSM is
   generic (
     STRICT_EN     : boolean:= false
   );
   port(
   -- Common Interface
   CLK              : in std_logic;  -- Clk
   RESET            : in std_logic;  -- Reset
   IDLE             : out std_logic; -- FSM is Idle (For Strict Version)
   WRITE_FSM_IDLE   : in  std_logic; -- Write FSM is Idle (For Strict Version)

   -- SHR_IN Interface
   DATA_VLD         : in  std_logic; -- Data from Shift Reg is valid
   SOP              : in  std_logic; -- Start of Packet
   SHR_RE           : out std_logic; -- Read Data from shift reg

   -- Address Decoder Interface
   READ_TRANS       : in  std_logic; -- Processing read transaction
   
   -- Component status interface
   LAST_READ_REQ    : in std_logic;   -- Last Read Req

   -- Register control interface
   ADDR_WE          : out std_logic;  -- Store Addr into addr_cnt and addr_align
   TAG_WE           : out std_logic;  -- Store Tag into tag register
   LENGHT_WE        : out std_logic;  -- Store lenght for Align circuit
   DST_ADDR_WE      : out std_logic;  -- Store dst_addr into register

   -- Component Init interface
   INIT_BE          : out std_logic;  -- Init BE circuit
   READ_ALIGN_INIT  : out std_logic;
   RD_COMPL_REQ     : out std_logic;  -- RD Completition Req
   RD_COMPL_ACK     : in  std_logic;  -- RD Completition Ack


   -- Read Interface
   RD_SOF_IN        : out std_logic;  -- Start of frame (Start of transaction)
   RD_EOF_IN        : out std_logic;  -- Ent of frame (End of Transaction)
   RD_REQ           : out std_logic;  -- Read from User Component
   RD_ARDY          : in  std_logic   -- Adress RDY
   );
end entity IB_ENDPOINT_READ_FSM;

  
-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture IB_ENDPOINT_READ_FSM_ARCH of IB_ENDPOINT_READ_FSM is

   -- Control FSM declaration
   type   t_states is (st_init, st_idle, st_sop, st_read);
   signal present_state, next_state : t_states;
   signal process_en                : std_logic;
   signal flag                      : std_logic;
   signal flag_set                  : std_logic;
   signal flag_reset                : std_logic;

begin

process_en <= '1' when (not STRICT_EN or (STRICT_EN and WRITE_FSM_IDLE = '1')) else '0';

-- This flag is set when idle, and deasert when second header word is readed
flag_regp: process(CLK)
  begin
    if (CLK='1' and CLK'event) then
      if (flag_reset = '1') then
        flag <= '0';
      end if;
      if (flag_set = '1') then
        flag <= '1';
      end if;
   end if;
end process;


-- SWITCH INPUT FSM -----------------------------------------------------------
-- next state clk logic
clk_d: process(CLK, RESET)
  begin
    if RESET = '1' then
      present_state <= st_init;
    elsif (CLK='1' and CLK'event) then
      present_state <= next_state;
    end if;
  end process;

-- next state logic
state_trans: process(present_state, DATA_VLD, SOP, READ_TRANS, LAST_READ_REQ, RD_COMPL_ACK, RD_ARDY, flag, process_en)
  begin
    case present_state is

      when st_init =>
         next_state <= st_idle;

      when st_idle =>
         -- New Read Transaction
         if (process_en ='1' and SOP = '1' and READ_TRANS = '1' and RD_COMPL_ACK='1') then  
           next_state <= st_sop; -- Dst ADDR
         else
           next_state <= st_idle; -- Idle
         end if;

      -- ST_SOP
      when st_sop =>
         -- End of transaction
         if ( (DATA_VLD = '1' or flag='0') and LAST_READ_REQ='1' and RD_ARDY='1') then
           next_state <= st_idle;
         -- Read another word
         elsif ( (DATA_VLD = '1' or flag='0') and RD_ARDY='1') then
           next_state <= st_read;
         -- Stay
         else
           next_state <= st_sop;
         end if;

      -- ST_READ
      when st_read =>
         -- Wait for all ardy
         if (LAST_READ_REQ = '1' and RD_ARDY='1') then -- saving one cycle
           next_state <= st_idle; -- Wait for read
         else
           next_state <= st_read;
         end if;
      end case;
  end process;

-- output logic
output_logic: process(present_state, DATA_VLD, SOP, READ_TRANS, LAST_READ_REQ, RD_ARDY, RD_COMPL_ACK, flag, process_en)
  begin
   ADDR_WE          <= '0';
   LENGHT_WE        <= '0';
   TAG_WE           <= '0';
   SHR_RE           <= '0';
   RD_REQ           <= '0';
   RD_SOF_IN        <= '0';
   RD_EOF_IN        <= '0';
   INIT_BE          <= '0';
   IDLE             <= '0';
   DST_ADDR_WE      <= '0';
   READ_ALIGN_INIT  <= '0';
   RD_COMPL_REQ     <= '0';
   flag_set         <= '0';
   flag_reset       <= '0';
    
   case present_state is
     
      when st_init =>

      -- ST_IDLE
      when st_idle =>
        IDLE            <= '1';
        RD_COMPL_REQ    <= process_en and DATA_VLD and SOP and READ_TRANS;
        flag_set        <= '1';
        if (process_en ='1' and SOP = '1' and READ_TRANS = '1' and RD_COMPL_ACK = '1') then 
          ADDR_WE         <= '1';
          LENGHT_WE       <= '1';
          TAG_WE          <= '1';
          INIT_BE         <= '1';
          READ_ALIGN_INIT <= '1';
          SHR_RE          <= '1';
        end if;

      -- ST_SOP
      when st_sop =>
        DST_ADDR_WE     <= flag;
        RD_SOF_IN       <= '1';
        if (LAST_READ_REQ = '1') then
             RD_EOF_IN          <= '1';
        end if;

        if (DATA_VLD = '1') then
          RD_REQ        <= '1';
          if (RD_ARDY = '1') then
            flag_reset    <= '1';
            SHR_RE        <= flag;
          end if;
        end if;

      -- ST_READ
      when st_read =>
          if (LAST_READ_REQ = '1') then
             RD_EOF_IN          <= '1';
          end if;
          RD_REQ              <= '1';
    end case;
  end process;

end architecture IB_ENDPOINT_READ_FSM_ARCH;

