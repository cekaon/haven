# Modules.tcl: Modules.tcl script to compille all design
# Copyright (C) 2003 CESNET
# Author: Tomas Martinek    <martinek@liberouter.org>
#         Jan Korenek       <korenek@liberouter.org>
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

global VHDL_BASE 

# Modules variable
set CLKGEN  	"FULL"      
set LB      	"FULL"
set TSU      	"FULL"
set TSU_TEST  	"FULL"
set ID_COMP_LB  "LB"

# Base directories 
set UNIT_BASE     	"$VHDL_BASE/units"
set CLKGEN_BASE  	"$VHDL_BASE/tests/comp/clk_gen"
set LB_BASE       	"$UNIT_BASE/lb"
set TSU_BASE       "$VHDL_BASE/units/tsu"
set TSU_TEST_BASE  "$VHDL_BASE/units/tsu/test"
set ID_BASE         "$UNIT_BASE/common/id"

# List of packages
set PACKAGES      "$VHDL_BASE/projects/liberouter/pkg/commands.vhd \
                   $VHDL_BASE/units/common/pkg/math_pack.vhd 		\
                   $UNIT_BASE/tsu/test/pkg/ifc1_addr_space.vhd 		\
                   $UNIT_BASE/tsu/test/pkg/ifc1_consts.vhd" 		

					  
# Lists of instantces
set CLKGEN_INST     [list [list "CLK_GEN_U"             "FULL"]]
set LB_INST         [list [list "LOCAL_BUS_U"           "FULL"]]
set TSU_INST        [list [list "ibuf_gmii_top4_u"      "FULL"]]
set TSU_TEST_INST   [list [list "ibuf_test_u"           "FULL"]]
set ID_INST         [list [list "ID_COMP_LB_U"          "LB"]]


# List of components
set COMPONENTS [list \
    [list "CLKGEN"  	$CLKGEN_BASE  	$CLKGEN  	$CLKGEN_INST]  \
    [list "LB"      	$LB_BASE      	$LB      	$LB_INST]      \
    [list "ID"      	$ID_BASE      	$ID_COMP_LB	$ID_INST]      \
    [list "TSU_TEST" 	$TSU_TEST_BASE  $TSU_TEST 	$TSU_TEST_INST]      \
    [list "TSU"         $TSU_BASE       $TSU        $TSU_INST] ]
