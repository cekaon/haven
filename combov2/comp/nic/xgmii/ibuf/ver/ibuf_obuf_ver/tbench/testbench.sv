/*
 * testbench.sv: Top Entity for IB_SWITCH automatic test
 * Copyright (C) 2007 CESNET
 * Author(s): Petr Kobiersky <kobiersky@liberouter.org>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 * 3. Neither the name of the Company nor the names of its contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * This software is provided ``as is'', and any express or implied
 * warranties, including, but not limited to, the implied warranties of
 * merchantability and fitness for a particular purpose are disclaimed.
 * In no event shall the company or contributors be liable for any
 * direct, indirect, incidental, special, exemplary, or consequential
 * damages (including, but not limited to, procurement of substitute
 * goods or services; loss of use, data, or profits; or business
 * interruption) however caused and on any theory of liability, whether
 * in contract, strict liability, or tort (including negligence or
 * otherwise) arising in any way out of the use of this software, even
 * if advised of the possibility of such damage.
 *
 * $Id: testbench.sv 12199 2009-12-04 21:05:28Z xsanta06 $
 *
 * TODO:
 *
 */
 

// ----------------------------------------------------------------------------
//                                 TESTBENCH
// ----------------------------------------------------------------------------
import test_pkg::*; // Test constants

module testbench;

  // -- Testbench wires and interfaces ----------------------------------------
  // V PRIPADE VIACERYCH POUZITYCH INTERFACOV JE NUTNE DOPLNENIE ICH DEKLARACIE 
  // A TIEZ DO DESIGN UNDER TEST A TEST
  logic            CLK     = 0;
  logic            CLK_156 = 0;
  logic            RESET;
  logic            RESET_IBUF;
  iFrameLinkRx #(RX_DATA_WIDTH, RX_DREM_WIDTH) RX  (CLK, RESET);
  iFrameLinkTx #(TX_DATA_WIDTH, TX_DREM_WIDTH) TX  (CLK, RESET);
  iFrameLinkTx #(TX_DATA_WIDTH, TX_DREM_WIDTH) MONITOR  (CLK, RESET);

  
  //-- Clock generation -------------------------------------------------------
  always #(CLK_PERIOD/2) CLK = ~CLK;
  always #(CLK_PERIOD_156/2) CLK_156 = ~CLK_156;

  //-- Design Under Test ------------------------------------------------------
  DUT DUT_U   (.CLK     (CLK),
               .CLK_156 (CLK_156),
               .RESET   (RESET),
               .RESET_IBUF (RESET_IBUF),
               .RX      (RX),
               .TX      (TX),
               .MONITOR (TX)
              );


  //-- Test -------------------------------------------------------------------
  TEST TEST_U (.CLK          (CLK),
               .RESET        (RESET),
               .RESET_IBUF   (RESET_IBUF),
               .RX           (RX),
               .TX           (TX),
               .MONITOR      (TX)
              );

endmodule : testbench
