# Modules.tcl: Local include Leonardo tcl script
# Copyright (C) 2008 CESNET
# Author: Marek Santa <xsanta06@stud.fit.vutbr.cz>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
# 3. Neither the name of the Company nor the names of its contributors
#    may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# This software is provided ``as is'', and any express or implied
# warranties, including, but not limited to, the implied warranties of
# merchantability and fitness for a particular purpose are disclaimed.
# In no event shall the company or contributors be liable for any
# direct, indirect, incidental, special, exemplary, or consequential
# damages (including, but not limited to, procurement of substitute
# goods or services; loss of use, data, or profits; or business
# interruption) however caused and on any theory of liability, whether
# in contract, strict liability, or tort (including negligence or
# otherwise) arising in any way out of the use of this software, even
# if advised of the possibility of such damage.
#
# $Id$
#

# Source files for all components


if { $ARCHGRP == "FULL" } {
  set SV_RX_DMA_CTRL_OPT_WRAP_BASE  "$ENTITY_BASE/../../../../ver"
  set RX_DMA_CTRL_OPT_BASE          "$ENTITY_BASE/../.."
  set RX_BUFFER_BASE                "$ENTITY_BASE/../../../buffers/top"

  set SOURCE_GEN_EXEC               "$ENTITY_BASE/source_generator.sh"

  set MOD "$MOD $ENTITY_BASE/rx_dma_ctrl_opt_buf_wrapper.vhd"

#  puts "  Generating VHDL files from Handel-C ..."
#  set vhdlGenStatus [catch [exec $SOURCE_GEN_EXEC] result]
#  puts "  VHDL files generated."

  set COMPONENTS [list \
      [ list "SV_RX_DMA_CTRL_OPT_WRAP_BASE"   $SV_RX_DMA_CTRL_OPT_WRAP_BASE  "FULL"] \
      [ list "RX_DMA_CTRL_OPT_BASE"           $RX_DMA_CTRL_OPT_BASE          "FULL"] \
      [ list "RX_BUFFER_BASE"                 $RX_BUFFER_BASE                "FULL"] \
   ]

  set MOD "$MOD $ENTITY_BASE/tbench/test_pkg.sv"
  set MOD "$MOD $ENTITY_BASE/../../../../ics/local_bus/ver/mi32_ifc.sv"
  set MOD "$MOD $ENTITY_BASE/../../../../fl_tools/ver/fl_ifc.sv"
  set MOD "$MOD $ENTITY_BASE/tbench/sv_rx_dma_ctrl_pkg.sv"
  set MOD "$MOD $ENTITY_BASE/tbench/dut.sv"
  set MOD "$MOD $ENTITY_BASE/tbench/test.sv"  
}

