# TCL File Generated by Component Editor 16.0
# Tue Apr 18 08:32:27 MDT 2017
# DO NOT MODIFY


# 
# AD1939_DE0_Nano_Audio_Card_rev2 "AD1939_DE0_Nano_Audio_Card_rev2" v2.0
#  2017.04.18.08:32:27
# for daughter card revision 002
# 

# 
# request TCL package from ACDS 16.0
# 
package require -exact qsys 16.0


# 
# module AD1939_DE0_Nano_Audio_Card_rev2
# 
set_module_property DESCRIPTION "for daughter card revision 002"
set_module_property NAME AD1939_DE0_Nano_Audio_Card_rev2
set_module_property VERSION 2.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME AD1939_DE0_Nano_Audio_Card_rev2
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL AD1939_Qsys_DE0_Nano_dcr02
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file AD1939_Qsys_DE0_Nano_dcr02.vhd VHDL PATH AD1939_Qsys_DE0_Nano_dcr02.vhd TOP_LEVEL_FILE


# 
# parameters
# 


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

add_interface_port s1 avs_s1_address address Input 5
add_interface_port s1 avs_s1_write write Input 1
add_interface_port s1 avs_s1_writedata writedata Input 32
add_interface_port s1 avs_s1_read read Input 1
add_interface_port s1 avs_s1_readdata readdata Output 32
set_interface_assignment s1 embeddedsw.configuration.isFlash 0
set_interface_assignment s1 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s1 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s1 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point conduit_external
# 
add_interface conduit_external conduit end
set_interface_property conduit_external associatedClock clock
set_interface_property conduit_external associatedReset reset
set_interface_property conduit_external ENABLED true
set_interface_property conduit_external EXPORT_OF ""
set_interface_property conduit_external PORT_NAME_MAP ""
set_interface_property conduit_external CMSIS_SVD_VARIABLES ""
set_interface_property conduit_external SVD_ADDRESS_GROUP ""

add_interface_port conduit_external AD1939_SPI_CIN ad1939_spi_cin Output 1
add_interface_port conduit_external AD1939_SPI_CCLK ad1939_spi_cclk Output 1
add_interface_port conduit_external AD1939_SPI_CLATCH_n ad1939_spi_clatch_n Output 1
add_interface_port conduit_external AD1939_ADC_SDATA1 ad1939_adc_sdata1 Input 1
add_interface_port conduit_external AD1939_ADC_SDATA2 ad1939_adc_sdata2 Input 1
add_interface_port conduit_external AD1939_ADC_BCLK ad1939_adc_bclk Input 1
add_interface_port conduit_external AD1939_ADC_LRCLK ad1939_adc_lrclk Input 1
add_interface_port conduit_external AD1939_DAC_SDATA1 ad1939_dac_sdata1 Output 1
add_interface_port conduit_external AD1939_DAC_SDATA2 ad1939_dac_sdata2 Output 1
add_interface_port conduit_external AD1939_DAC_SDATA3 ad1939_dac_sdata3 Output 1
add_interface_port conduit_external AD1939_DAC_SDATA4 ad1939_dac_sdata4 Output 1
add_interface_port conduit_external AD1939_DAC_BCLK ad1939_dac_bclk Output 1
add_interface_port conduit_external AD1939_DAC_LRCLK ad1939_dac_lrclk Output 1
add_interface_port conduit_external AD1939_SPI_COUT ad1939_spi_cout Input 1


# 
# connection point Line_In_left
# 
add_interface Line_In_left avalon_streaming start
set_interface_property Line_In_left associatedClock clock
set_interface_property Line_In_left associatedReset reset
set_interface_property Line_In_left dataBitsPerSymbol 8
set_interface_property Line_In_left errorDescriptor ""
set_interface_property Line_In_left firstSymbolInHighOrderBits true
set_interface_property Line_In_left maxChannel 0
set_interface_property Line_In_left readyLatency 0
set_interface_property Line_In_left ENABLED true
set_interface_property Line_In_left EXPORT_OF ""
set_interface_property Line_In_left PORT_NAME_MAP ""
set_interface_property Line_In_left CMSIS_SVD_VARIABLES ""
set_interface_property Line_In_left SVD_ADDRESS_GROUP ""

add_interface_port Line_In_left Line_In_left_data data Output 32
add_interface_port Line_In_left Line_In_left_error error Output 2
add_interface_port Line_In_left Line_In_left_valid valid Output 1


# 
# connection point Line_In_right
# 
add_interface Line_In_right avalon_streaming start
set_interface_property Line_In_right associatedClock clock
set_interface_property Line_In_right associatedReset reset
set_interface_property Line_In_right dataBitsPerSymbol 8
set_interface_property Line_In_right errorDescriptor ""
set_interface_property Line_In_right firstSymbolInHighOrderBits true
set_interface_property Line_In_right maxChannel 0
set_interface_property Line_In_right readyLatency 0
set_interface_property Line_In_right ENABLED true
set_interface_property Line_In_right EXPORT_OF ""
set_interface_property Line_In_right PORT_NAME_MAP ""
set_interface_property Line_In_right CMSIS_SVD_VARIABLES ""
set_interface_property Line_In_right SVD_ADDRESS_GROUP ""

add_interface_port Line_In_right Line_In_right_data data Output 32
add_interface_port Line_In_right Line_In_right_error error Output 2
add_interface_port Line_In_right Line_In_right_valid valid Output 1


# 
# connection point Line_Out_left
# 
add_interface Line_Out_left avalon_streaming end
set_interface_property Line_Out_left associatedClock clock
set_interface_property Line_Out_left associatedReset reset
set_interface_property Line_Out_left dataBitsPerSymbol 8
set_interface_property Line_Out_left errorDescriptor ""
set_interface_property Line_Out_left firstSymbolInHighOrderBits true
set_interface_property Line_Out_left maxChannel 0
set_interface_property Line_Out_left readyLatency 0
set_interface_property Line_Out_left ENABLED true
set_interface_property Line_Out_left EXPORT_OF ""
set_interface_property Line_Out_left PORT_NAME_MAP ""
set_interface_property Line_Out_left CMSIS_SVD_VARIABLES ""
set_interface_property Line_Out_left SVD_ADDRESS_GROUP ""

add_interface_port Line_Out_left Line_Out_left_data data Input 32
add_interface_port Line_Out_left Line_Out_left_error error Input 2
add_interface_port Line_Out_left Line_Out_left_valid valid Input 1


# 
# connection point Line_Out_right
# 
add_interface Line_Out_right avalon_streaming end
set_interface_property Line_Out_right associatedClock clock
set_interface_property Line_Out_right associatedReset reset
set_interface_property Line_Out_right dataBitsPerSymbol 8
set_interface_property Line_Out_right errorDescriptor ""
set_interface_property Line_Out_right firstSymbolInHighOrderBits true
set_interface_property Line_Out_right maxChannel 0
set_interface_property Line_Out_right readyLatency 0
set_interface_property Line_Out_right ENABLED true
set_interface_property Line_Out_right EXPORT_OF ""
set_interface_property Line_Out_right PORT_NAME_MAP ""
set_interface_property Line_Out_right CMSIS_SVD_VARIABLES ""
set_interface_property Line_Out_right SVD_ADDRESS_GROUP ""

add_interface_port Line_Out_right Line_Out_right_data data Input 32
add_interface_port Line_Out_right Line_Out_right_error error Input 2
add_interface_port Line_Out_right Line_Out_right_valid valid Input 1


# 
# connection point Mic_In_left
# 
add_interface Mic_In_left avalon_streaming start
set_interface_property Mic_In_left associatedClock clock
set_interface_property Mic_In_left associatedReset reset
set_interface_property Mic_In_left dataBitsPerSymbol 8
set_interface_property Mic_In_left errorDescriptor ""
set_interface_property Mic_In_left firstSymbolInHighOrderBits true
set_interface_property Mic_In_left maxChannel 0
set_interface_property Mic_In_left readyLatency 0
set_interface_property Mic_In_left ENABLED true
set_interface_property Mic_In_left EXPORT_OF ""
set_interface_property Mic_In_left PORT_NAME_MAP ""
set_interface_property Mic_In_left CMSIS_SVD_VARIABLES ""
set_interface_property Mic_In_left SVD_ADDRESS_GROUP ""

add_interface_port Mic_In_left Mic_In_left_data data Output 32
add_interface_port Mic_In_left Mic_In_left_error error Output 2
add_interface_port Mic_In_left Mic_In_left_valid valid Output 1


# 
# connection point Mic_In_right
# 
add_interface Mic_In_right avalon_streaming start
set_interface_property Mic_In_right associatedClock clock
set_interface_property Mic_In_right associatedReset reset
set_interface_property Mic_In_right dataBitsPerSymbol 8
set_interface_property Mic_In_right errorDescriptor ""
set_interface_property Mic_In_right firstSymbolInHighOrderBits true
set_interface_property Mic_In_right maxChannel 0
set_interface_property Mic_In_right readyLatency 0
set_interface_property Mic_In_right ENABLED true
set_interface_property Mic_In_right EXPORT_OF ""
set_interface_property Mic_In_right PORT_NAME_MAP ""
set_interface_property Mic_In_right CMSIS_SVD_VARIABLES ""
set_interface_property Mic_In_right SVD_ADDRESS_GROUP ""

add_interface_port Mic_In_right Mic_In_right_data data Output 32
add_interface_port Mic_In_right Mic_In_right_error error Output 2
add_interface_port Mic_In_right Mic_In_right_valid valid Output 1


# 
# connection point Headphone_Out_right
# 
add_interface Headphone_Out_right avalon_streaming end
set_interface_property Headphone_Out_right associatedClock clock
set_interface_property Headphone_Out_right associatedReset reset
set_interface_property Headphone_Out_right dataBitsPerSymbol 8
set_interface_property Headphone_Out_right errorDescriptor ""
set_interface_property Headphone_Out_right firstSymbolInHighOrderBits true
set_interface_property Headphone_Out_right maxChannel 0
set_interface_property Headphone_Out_right readyLatency 0
set_interface_property Headphone_Out_right ENABLED true
set_interface_property Headphone_Out_right EXPORT_OF ""
set_interface_property Headphone_Out_right PORT_NAME_MAP ""
set_interface_property Headphone_Out_right CMSIS_SVD_VARIABLES ""
set_interface_property Headphone_Out_right SVD_ADDRESS_GROUP ""

add_interface_port Headphone_Out_right Headphone_Out_right_data data Input 32
add_interface_port Headphone_Out_right Headphone_Out_right_error error Input 2
add_interface_port Headphone_Out_right Headphone_Out_right_valid valid Input 1


# 
# connection point Headphone_Out_left
# 
add_interface Headphone_Out_left avalon_streaming end
set_interface_property Headphone_Out_left associatedClock clock
set_interface_property Headphone_Out_left associatedReset reset
set_interface_property Headphone_Out_left dataBitsPerSymbol 8
set_interface_property Headphone_Out_left errorDescriptor ""
set_interface_property Headphone_Out_left firstSymbolInHighOrderBits true
set_interface_property Headphone_Out_left maxChannel 0
set_interface_property Headphone_Out_left readyLatency 0
set_interface_property Headphone_Out_left ENABLED true
set_interface_property Headphone_Out_left EXPORT_OF ""
set_interface_property Headphone_Out_left PORT_NAME_MAP ""
set_interface_property Headphone_Out_left CMSIS_SVD_VARIABLES ""
set_interface_property Headphone_Out_left SVD_ADDRESS_GROUP ""

add_interface_port Headphone_Out_left Headphone_Out_left_data data Input 32
add_interface_port Headphone_Out_left Headphone_Out_left_error error Input 2
add_interface_port Headphone_Out_left Headphone_Out_left_valid valid Input 1

