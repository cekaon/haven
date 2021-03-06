# 
# XST.tcl: XST tcl script to compile specified module
# Copyright (C) 2009 CESNET
# Author(s): Pavol Korcek <korcek@liberouter.org>
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

# specify vhdl_design directory
set FIRMWARE_BASE         "../../../../../../../.."
set LOCAL_COMPL_BUF_BASE   "$FIRMWARE_BASE/comp/gics/internal_bus/comp/root/comp/local_compl_buf" 

# synthesis variables
set SYNTH_FLAGS(MODULE) "local_compl_buf"
set SYNTH_FLAGS(OUTPUT) "local_compl_buf"
set SYNTH_FLAGS(FPGA)   "xc5vlx110t"

# list of sub-components
set COMPONENTS [list  [list "LOCAL_COMPL_BUF"   $LOCAL_COMPL_BUF_BASE   "FULL"]]

set HIERARCHY(COMPONENTS)  $COMPONENTS

proc SetTopAttribConstr { } {
   set CONSTR [list \
                  "BEGIN MODEL \"local_compl_buf\"" \
                  "NET \"TRN_CLK\" PERIOD = 250MHz HIGH 50%;" \
                  "END;"\
   ]
   return $CONSTR
}

# Run global precision tcl script to include general functions
source $FIRMWARE_BASE/build/XST.inc.tcl

# In fact, XST tcl script only generates XST script named XST.xst.
SynthesizeProject SYNTH_FLAGS HIERARCHY

# Now Makefile will call 'xst -ifn XST.xst' to perform the synthesis.



