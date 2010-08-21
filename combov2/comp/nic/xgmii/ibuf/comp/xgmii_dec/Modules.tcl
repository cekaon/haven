# Modules.tcl: Local include Modules tcl script
# Copyright (C) 2007 CESNET
# Author: Libor Polcak <polcak_l@liberouter.org>
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


# Set paths
set FIRMWARE_BASE       "$ENTITY_BASE/../../../../../.."
set BASE_BASE           "$FIRMWARE_BASE/comp/base"
set XGMII_BASE          "$ENTITY_BASE/../../.."
set XGMII_PKG           "$XGMII_BASE/pkg"
set SH_REG_BASE         "$BASE_BASE/shreg/sh_reg"
set BIN_ENC_BASE        "$BASE_BASE/logic/enc"

set MOD "$MOD $ENTITY_BASE/xgmii_dec_ent.vhd"

# Full Align
if { $ARCHGRP == "FULL" } {
   set MOD "$MOD $ENTITY_BASE/xgmii_dec_fsm.vhd"
	 set MOD "$MOD $ENTITY_BASE/xgmii_dec_pdec.vhd"
   set MOD "$MOD $ENTITY_BASE/xgmii_dec.vhd"
   
   # components
   set COMPONENTS [list \
      [ list "PKG_MATH"       $BASE_BASE/pkg       "MATH"     ] \
	    [ list "XGMII_PKG"      $XGMII_PKG           "COMMANDS" ] \
      [ list "SH_REG"         $SH_REG_BASE         "FULL"     ] \
      [ list "GEN_ENC"        $BIN_ENC_BASE        "FULL"     ] \
   ]
}

