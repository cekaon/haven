/*
 * DUT.sv: Design under test
 * Copyright (C) 2008 CESNET
 * Author(s): Martin Kosek <kosek@liberouter.org>
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
 * $Id: dut.sv 11661 2009-10-18 18:54:53Z xnovot87 $
 *
 */
 
// ----------------------------------------------------------------------------
//                        Module declaration
// ----------------------------------------------------------------------------
import test_pkg::*; // Test constants

module DUT (
   input logic CLK,
   input logic RESET,
   iFrameLinkRx.dut RX[INPUT_COUNT],
   iFrameLinkTx.dut TX
);

// Signals for DUT conection
wire [(INPUT_COUNT*INPUT_WIDTH)-1:0] rx_data;  
wire [(INPUT_COUNT*INPUT_DREM_WIDTH)-1:0] rx_drem;
wire [INPUT_COUNT-1:0] rx_sof_n;
wire [INPUT_COUNT-1:0] rx_eof_n;
wire [INPUT_COUNT-1:0] rx_sop_n;
wire [INPUT_COUNT-1:0] rx_eop_n;
wire [INPUT_COUNT-1:0] rx_src_rdy_n;
wire [INPUT_COUNT-1:0] rx_dst_rdy_n;
genvar i;

// Connecting RX to interfaces
generate
for (i=0; i<INPUT_COUNT; i++) begin
  assign rx_data[(i+1)*INPUT_WIDTH-1:INPUT_WIDTH*i] = RX[i].DATA;
  assign rx_drem[(i+1)*INPUT_DREM_WIDTH-1:INPUT_DREM_WIDTH*i] = RX[i].DREM;
  assign rx_sof_n[i] = RX[i].SOF_N;
  assign rx_eof_n[i] = RX[i].EOF_N;
  assign rx_sop_n[i] = RX[i].SOP_N;
  assign rx_eop_n[i] = RX[i].EOP_N;
  assign rx_src_rdy_n[i] = RX[i].SRC_RDY_N;
  assign RX[i].DST_RDY_N = rx_dst_rdy_n[i];
  end
endgenerate

// -------------------- Module body -------------------------------------------
FL_BINDER #(
     .INPUT_WIDTH       (INPUT_WIDTH),
     .OUTPUT_WIDTH      (OUTPUT_WIDTH),
     .INPUT_COUNT       (INPUT_COUNT),
     .FRAME_PARTS       (FRAME_PARTS),
     .LUT_MEMORY        (LUT_MEMORY),
     .LUT_BLOCK_SIZE    (LUT_BLOCK_SIZE),
     .SIMPLE_BINDER     (SIMPLE_BINDER),
     .STUPID_BINDER     (STUPID_BINDER)
      )
   VHDL_DUT_U  (
    // Common Interface
     .CLK               (CLK),
     .RESET             (RESET),
 
    // RX ports
     .RX_DATA       (rx_data),
     .RX_REM        (rx_drem),
     .RX_SOF_N      (rx_sof_n),
     .RX_EOF_N      (rx_eof_n),
     .RX_SOP_N      (rx_sop_n),
     .RX_EOP_N      (rx_eop_n),
     .RX_SRC_RDY_N  (rx_src_rdy_n),
     .RX_DST_RDY_N  (rx_dst_rdy_n),

    // TX port
     .TX_DATA       (TX.DATA),
     .TX_REM        (TX.DREM),
     .TX_SOF_N      (TX.SOF_N),
     .TX_EOF_N      (TX.EOF_N),
     .TX_SOP_N      (TX.SOP_N),
     .TX_EOP_N      (TX.EOP_N),
     .TX_SRC_RDY_N  (TX.SRC_RDY_N),
     .TX_DST_RDY_N  (TX.DST_RDY_N)
);


endmodule : DUT
