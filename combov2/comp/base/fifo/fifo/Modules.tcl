# Modules.tcl: Local include Leonardo tcl script
# Copyright (C) 2003 CESNET
# Author: Martinek Tomas <martinek@liberouter.org>
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

set MOD "$MOD $ENTITY_BASE/fifo_status_ent.vhd"
set MOD "$MOD $ENTITY_BASE/fifo_ent.vhd"
set MOD "$MOD $ENTITY_BASE/fifo_status.vhd"
set MOD "$MOD $ENTITY_BASE/fifo.vhd"
set MOD "$MOD $ENTITY_BASE/fifo_status_behav.vhd"
set MOD "$MOD $ENTITY_BASE/fifo_behav.vhd"

set PKG_BASE "$ENTITY_BASE/../../pkg"
set DP_DISTMEM_BASE "$ENTITY_BASE/../../mem/dp_distmem"

set COMPONENTS [list \
                  [list "PKG" $PKG_BASE "MATH"] \
                  [list "DP_DISTMEM" $DP_DISTMEM_BASE "FULL"] \
               ]
