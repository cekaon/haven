#
# Modules.tcl: Local include tcl script
# Copyright (C) 2008 CESNET
# Author(s): Tomas Malek <tomalek@liberouter.org>
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

# -----------------------------------------------------------------------------

if { $ARCHGRP == "FULL" } {

  set MOD "$MOD $ENTITY_BASE/../../../../pkg/ib_fmt_pkg.vhd"
  set MOD "$MOD $ENTITY_BASE/../../../../pkg/ib_ifc_pkg.vhd"  
  set MOD "$MOD $ENTITY_BASE/../../pkg/switch_pkg.vhd"

  set ADDR_DEC_BASE  "$ENTITY_BASE/../../../base/addr_dec"
  set REG_CYC_BASE   "$ENTITY_BASE/../../../base/reg_cyc"
  set MATH_BASE      "$ENTITY_BASE/../../../../../../base/pkg"  
  
  set COMPONENTS [list \
      [list "ADDR_DEC"    $ADDR_DEC_BASE     "FULL"] \
      [list "REG_CYC"     $REG_CYC_BASE      "FULL"] \
      [list "MATH_PACK"   $MATH_BASE         "MATH"] \
  ]
  
  set MOD "$MOD $ENTITY_BASE/input_routing_rules.vhd"
  set MOD "$MOD $ENTITY_BASE/input_port.vhd"  
  set MOD "$MOD $ENTITY_BASE/input.vhd"  
  set MOD "$MOD $ENTITY_BASE/input_arch.vhd"    
}

# -----------------------------------------------------------------------------

if { $ARCHGRP == "EMPTY" } {

}



