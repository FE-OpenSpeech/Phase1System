# TCL File Generated by Component Editor 16.0
# Wed May 31 07:33:00 MDT 2017
# DO NOT MODIFY


# 
# FE_Qsys_DRC "FE_Qsys_DRC" v1.0
#  2017.05.31.07:33:00
# 
# 

# 
# request TCL package from ACDS 16.0
# 
package require -exact qsys 16.0


# 
# module FE_Qsys_DRC
# 
set_module_property DESCRIPTION ""
set_module_property NAME FE_Qsys_DRC
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME FE_Qsys_DRC
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL FE_Qsys_DRC
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file FE_Qsys_DRC.vhd VHDL PATH FE_Qsys_DRC.vhd TOP_LEVEL_FILE


# 
# parameters
# 


# 
# module assignments
# 
set_module_assignment embeddedsw.dts.compatible dev,fe-drc
set_module_assignment embeddedsw.dts.group drc
set_module_assignment embeddedsw.dts.vendor fe


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset_n reset_n Input 1


# 
# connection point s1
# 
add_interface s1 avalon end
set_interface_property s1 addressUnits WORDS
set_interface_property s1 associatedClock clock
set_interface_property s1 associatedReset reset
set_interface_property s1 bitsPerSymbol 8
set_interface_property s1 burstOnBurstBoundariesOnly false
set_interface_property s1 burstcountUnits WORDS
set_interface_property s1 explicitAddressSpan 0
set_interface_property s1 holdTime 0
set_interface_property s1 linewrapBursts false
set_interface_property s1 maximumPendingReadTransactions 0
set_interface_property s1 maximumPendingWriteTransactions 0
set_interface_property s1 readLatency 0
set_interface_property s1 readWaitTime 1
set_interface_property s1 setupTime 0
set_interface_property s1 timingUnits Cycles
set_interface_property s1 writeWaitTime 0
set_interface_property s1 ENABLED true
set_interface_property s1 EXPORT_OF ""
set_interface_property s1 PORT_NAME_MAP ""
set_interface_property s1 CMSIS_SVD_VARIABLES ""
set_interface_property s1 SVD_ADDRESS_GROUP ""

add_interface_port s1 avs_s1_address address Input 3
add_interface_port s1 avs_s1_write write Input 1
add_interface_port s1 avs_s1_writedata writedata Input 32
add_interface_port s1 avs_s1_read read Input 1
add_interface_port s1 avs_s1_readdata readdata Output 32
set_interface_assignment s1 embeddedsw.configuration.isFlash 0
set_interface_assignment s1 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s1 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s1 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point channel_sink
# 
add_interface channel_sink avalon_streaming end
set_interface_property channel_sink associatedClock clock
set_interface_property channel_sink associatedReset reset
set_interface_property channel_sink dataBitsPerSymbol 8
set_interface_property channel_sink errorDescriptor ""
set_interface_property channel_sink firstSymbolInHighOrderBits true
set_interface_property channel_sink maxChannel 0
set_interface_property channel_sink readyLatency 0
set_interface_property channel_sink ENABLED true
set_interface_property channel_sink EXPORT_OF ""
set_interface_property channel_sink PORT_NAME_MAP ""
set_interface_property channel_sink CMSIS_SVD_VARIABLES ""
set_interface_property channel_sink SVD_ADDRESS_GROUP ""

add_interface_port channel_sink ast_sink_data data Input 32
add_interface_port channel_sink ast_sink_error error Input 2
add_interface_port channel_sink ast_sink_valid valid Input 1


# 
# connection point channel_source
# 
add_interface channel_source avalon_streaming start
set_interface_property channel_source associatedClock clock
set_interface_property channel_source associatedReset reset
set_interface_property channel_source dataBitsPerSymbol 8
set_interface_property channel_source errorDescriptor ""
set_interface_property channel_source firstSymbolInHighOrderBits true
set_interface_property channel_source maxChannel 0
set_interface_property channel_source readyLatency 0
set_interface_property channel_source ENABLED true
set_interface_property channel_source EXPORT_OF ""
set_interface_property channel_source PORT_NAME_MAP ""
set_interface_property channel_source CMSIS_SVD_VARIABLES ""
set_interface_property channel_source SVD_ADDRESS_GROUP ""

add_interface_port channel_source ast_source_data data Output 32
add_interface_port channel_source ast_source_error error Output 2
add_interface_port channel_source ast_source_valid valid Output 1

