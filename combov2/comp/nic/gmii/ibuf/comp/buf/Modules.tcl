# Modules.tcl: Local include tcl script
# Copyright (C) 2005 CESNET
# Author: Martin Mikusek <martin.mikusek@liberouter.org>
#         Jiri Matousek <xmatou06@stud.fit.vutbr.cz>
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
set COMP_BASE           "$ENTITY_BASE/../../../../.."

set ASFIFO_BRAM_BASE    "$COMP_BASE/base/fifo/asfifo_bram"
set PKG_BASE            "$COMP_BASE/base/pkg"
set BUF_CORE_BASE       "$COMP_BASE/nic/common/ibuf/buf_core"

set PACKAGES "$PACKAGES $ENTITY_BASE/../../pkg/ibuf_pkg.vhd"
set PACKAGES "$PACKAGES $ENTITY_BASE/../../../../pkg/ibuf_general_pkg.vhd"

# Source files for implemented component
if { $ARCHGRP == "FULL" } {

    set PACKAGES "$PACKAGES $PKG_BASE/math_pack.vhd"
   

   # List of components
   set COMPONENTS [list \
      [list "BUF_CORE"              $BUF_CORE_BASE    "FULL"]  \
   ]

   set MOD "$MOD $ENTITY_BASE/buf.vhd"
}

# Source file for empty component - empty architecture 
if { $ARCHGRP == "EMPTY" } {
}

# debug component
if { $ARCHGRP == "DEBUG" } {
}
