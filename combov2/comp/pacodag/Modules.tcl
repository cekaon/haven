# Modules.tcl: Local include tcl script
# Copyright (C) 2005 CESNET
# Author: Martin Mikusek <martin.mikusek@liberouter.org>
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

# Base directories
set COMP_BASE           "$ENTITY_BASE/.." 
set PKG_BASE            "$COMP_BASE/base/pkg"
set IBUF_PKG_BASE       "$COMP_BASE/nic/pkg"

# Source files for implemented component
set PACKAGES "$PACKAGES $PKG_BASE/math_pack.vhd \
              $IBUF_PKG_BASE/ibuf_general_pkg.vhd"

set MOD "$MOD $ENTITY_BASE/pcd_tsu_64b_ent.vhd"
set MOD "$MOD $ENTITY_BASE/pcd_tsu_128b_ent.vhd"

if { $ARCHGRP  == "FULL" | $ARCHGRP  == "IFC" } {
   set MOD "$MOD $ENTITY_BASE/pcd_tsu_64b.vhd"
   set MOD "$MOD $ENTITY_BASE/pcd_tsu_128b.vhd"
	set MOD "$MOD $ENTITY_BASE/top/pcd_tsu_t64.vhd"
	set MOD "$MOD $ENTITY_BASE/top/pcd_tsu_top2_t64.vhd"
	set MOD "$MOD $ENTITY_BASE/top/pcd_tsu_top2_128b.vhd"
	set MOD "$MOD $ENTITY_BASE/top/pcd_tsu_top2_128b_norec.vhd"
} 

