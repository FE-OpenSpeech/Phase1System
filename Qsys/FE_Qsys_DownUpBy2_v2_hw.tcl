# TCL File Generated by Component Editor 16.0
# Tue May 16 08:35:27 MDT 2017
# DO NOT MODIFY


# 
# FE_Qsys_DownUpBy2_v2 "FE_Qsys_DownUpBy2_v2" v1.0
#  2017.05.16.08:35:27
# 
# 

# 
# request TCL package from ACDS 16.0
# 
package require -exact qsys 16.0


# 
# module FE_Qsys_DownUpBy2_v2
# 
set_module_property DESCRIPTION ""
set_module_property NAME FE_Qsys_DownUpBy2_v2
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME FE_Qsys_DownUpBy2_v2
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL FE_Qsys_DownUpBy2_v2
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file FE_Qsys_DownUpBy2_v2.vhd VHDL PATH ../Source_Files/FE_Qsys_DownUpBy2_v2.vhd TOP_LEVEL_FILE


# 
# parameters
# 
add_parameter FIR_MIF_FileName_up STRING FE_MIF_FIR_UpSampleBy2.mif
set_parameter_property FIR_MIF_FileName_up DEFAULT_VALUE FE_MIF_FIR_UpSampleBy2.mif
set_parameter_property FIR_MIF_FileName_up DISPLAY_NAME FIR_MIF_FileName_up
set_parameter_property FIR_MIF_FileName_up TYPE STRING
set_parameter_property FIR_MIF_FileName_up UNITS None
set_parameter_property FIR_MIF_FileName_up HDL_PARAMETER true
add_parameter FIR_MIF_FileName_down STRING FE_MIF_FIR_DownSampleBy2.mif
set_parameter_property FIR_MIF_FileName_down DEFAULT_VALUE FE_MIF_FIR_DownSampleBy2.mif
set_parameter_property FIR_MIF_FileName_down DISPLAY_NAME FIR_MIF_FileName_down
set_parameter_property FIR_MIF_FileName_down TYPE STRING
set_parameter_property FIR_MIF_FileName_down UNITS None
set_parameter_property FIR_MIF_FileName_down HDL_PARAMETER true
add_parameter FIR_Max_Coefs INTEGER 256
set_parameter_property FIR_Max_Coefs DEFAULT_VALUE 256
set_parameter_property FIR_Max_Coefs DISPLAY_NAME FIR_Max_Coefs
set_parameter_property FIR_Max_Coefs TYPE INTEGER
set_parameter_property FIR_Max_Coefs UNITS None
set_parameter_property FIR_Max_Coefs HDL_PARAMETER true
add_parameter FIR_Addr_Width INTEGER 8
set_parameter_property FIR_Addr_Width DEFAULT_VALUE 8
set_parameter_property FIR_Addr_Width DISPLAY_NAME FIR_Addr_Width
set_parameter_property FIR_Addr_Width TYPE INTEGER
set_parameter_property FIR_Addr_Width UNITS None
set_parameter_property FIR_Addr_Width HDL_PARAMETER true


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
# connection point to_downsampler
# 
add_interface to_downsampler avalon_streaming end
set_interface_property to_downsampler associatedClock clock
set_interface_property to_downsampler associatedReset reset
set_interface_property to_downsampler dataBitsPerSymbol 8
set_interface_property to_downsampler errorDescriptor ""
set_interface_property to_downsampler firstSymbolInHighOrderBits true
set_interface_property to_downsampler maxChannel 0
set_interface_property to_downsampler readyLatency 0
set_interface_property to_downsampler ENABLED true
set_interface_property to_downsampler EXPORT_OF ""
set_interface_property to_downsampler PORT_NAME_MAP ""
set_interface_property to_downsampler CMSIS_SVD_VARIABLES ""
set_interface_property to_downsampler SVD_ADDRESS_GROUP ""

add_interface_port to_downsampler to_downsampler_data data Input 32
add_interface_port to_downsampler to_downsampler_error error Input 2
add_interface_port to_downsampler to_downsampler_valid valid Input 1


# 
# connection point to_upsampler
# 
add_interface to_upsampler avalon_streaming end
set_interface_property to_upsampler associatedClock clock
set_interface_property to_upsampler associatedReset reset
set_interface_property to_upsampler dataBitsPerSymbol 8
set_interface_property to_upsampler errorDescriptor ""
set_interface_property to_upsampler firstSymbolInHighOrderBits true
set_interface_property to_upsampler maxChannel 0
set_interface_property to_upsampler readyLatency 0
set_interface_property to_upsampler ENABLED true
set_interface_property to_upsampler EXPORT_OF ""
set_interface_property to_upsampler PORT_NAME_MAP ""
set_interface_property to_upsampler CMSIS_SVD_VARIABLES ""
set_interface_property to_upsampler SVD_ADDRESS_GROUP ""

add_interface_port to_upsampler to_Upsampler_data data Input 32
add_interface_port to_upsampler to_Upsampler_error error Input 2
add_interface_port to_upsampler to_Upsampler_valid valid Input 1


# 
# connection point downsampled
# 
add_interface downsampled avalon_streaming start
set_interface_property downsampled associatedClock clock
set_interface_property downsampled associatedReset reset
set_interface_property downsampled dataBitsPerSymbol 8
set_interface_property downsampled errorDescriptor ""
set_interface_property downsampled firstSymbolInHighOrderBits true
set_interface_property downsampled maxChannel 0
set_interface_property downsampled readyLatency 0
set_interface_property downsampled ENABLED true
set_interface_property downsampled EXPORT_OF ""
set_interface_property downsampled PORT_NAME_MAP ""
set_interface_property downsampled CMSIS_SVD_VARIABLES ""
set_interface_property downsampled SVD_ADDRESS_GROUP ""

add_interface_port downsampled downsampled_data data Output 32
add_interface_port downsampled downsampled_error error Output 2
add_interface_port downsampled downsampled_valid valid Output 1


# 
# connection point upsampled
# 
add_interface upsampled avalon_streaming start
set_interface_property upsampled associatedClock clock
set_interface_property upsampled associatedReset reset
set_interface_property upsampled dataBitsPerSymbol 8
set_interface_property upsampled errorDescriptor ""
set_interface_property upsampled firstSymbolInHighOrderBits true
set_interface_property upsampled maxChannel 0
set_interface_property upsampled readyLatency 0
set_interface_property upsampled ENABLED true
set_interface_property upsampled EXPORT_OF ""
set_interface_property upsampled PORT_NAME_MAP ""
set_interface_property upsampled CMSIS_SVD_VARIABLES ""
set_interface_property upsampled SVD_ADDRESS_GROUP ""

add_interface_port upsampled Upsampled_data data Output 32
add_interface_port upsampled Upsampled_error error Output 2
add_interface_port upsampled Upsampled_valid valid Output 1


# 
# connection point s2_FIR_up_coefficients
# 
add_interface s2_FIR_up_coefficients avalon end
set_interface_property s2_FIR_up_coefficients addressUnits WORDS
set_interface_property s2_FIR_up_coefficients associatedClock clock
set_interface_property s2_FIR_up_coefficients associatedReset reset
set_interface_property s2_FIR_up_coefficients bitsPerSymbol 8
set_interface_property s2_FIR_up_coefficients burstOnBurstBoundariesOnly false
set_interface_property s2_FIR_up_coefficients burstcountUnits WORDS
set_interface_property s2_FIR_up_coefficients explicitAddressSpan 0
set_interface_property s2_FIR_up_coefficients holdTime 0
set_interface_property s2_FIR_up_coefficients linewrapBursts false
set_interface_property s2_FIR_up_coefficients maximumPendingReadTransactions 0
set_interface_property s2_FIR_up_coefficients maximumPendingWriteTransactions 0
set_interface_property s2_FIR_up_coefficients readLatency 0
set_interface_property s2_FIR_up_coefficients readWaitTime 1
set_interface_property s2_FIR_up_coefficients setupTime 0
set_interface_property s2_FIR_up_coefficients timingUnits Cycles
set_interface_property s2_FIR_up_coefficients writeWaitTime 0
set_interface_property s2_FIR_up_coefficients ENABLED true
set_interface_property s2_FIR_up_coefficients EXPORT_OF ""
set_interface_property s2_FIR_up_coefficients PORT_NAME_MAP ""
set_interface_property s2_FIR_up_coefficients CMSIS_SVD_VARIABLES ""
set_interface_property s2_FIR_up_coefficients SVD_ADDRESS_GROUP ""

add_interface_port s2_FIR_up_coefficients avs_s2_address address Input fir_addr_width
add_interface_port s2_FIR_up_coefficients avs_s2_write write Input 1
add_interface_port s2_FIR_up_coefficients avs_s2_writedata writedata Input 32
add_interface_port s2_FIR_up_coefficients avs_s2_read read Input 1
add_interface_port s2_FIR_up_coefficients avs_s2_readdata readdata Output 32
set_interface_assignment s2_FIR_up_coefficients embeddedsw.configuration.isFlash 0
set_interface_assignment s2_FIR_up_coefficients embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s2_FIR_up_coefficients embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s2_FIR_up_coefficients embeddedsw.configuration.isPrintableDevice 0


# 
# connection point s1_FIR_down_coefficients
# 
add_interface s1_FIR_down_coefficients avalon end
set_interface_property s1_FIR_down_coefficients addressUnits WORDS
set_interface_property s1_FIR_down_coefficients associatedClock clock
set_interface_property s1_FIR_down_coefficients associatedReset reset
set_interface_property s1_FIR_down_coefficients bitsPerSymbol 8
set_interface_property s1_FIR_down_coefficients burstOnBurstBoundariesOnly false
set_interface_property s1_FIR_down_coefficients burstcountUnits WORDS
set_interface_property s1_FIR_down_coefficients explicitAddressSpan 0
set_interface_property s1_FIR_down_coefficients holdTime 0
set_interface_property s1_FIR_down_coefficients linewrapBursts false
set_interface_property s1_FIR_down_coefficients maximumPendingReadTransactions 0
set_interface_property s1_FIR_down_coefficients maximumPendingWriteTransactions 0
set_interface_property s1_FIR_down_coefficients readLatency 0
set_interface_property s1_FIR_down_coefficients readWaitTime 1
set_interface_property s1_FIR_down_coefficients setupTime 0
set_interface_property s1_FIR_down_coefficients timingUnits Cycles
set_interface_property s1_FIR_down_coefficients writeWaitTime 0
set_interface_property s1_FIR_down_coefficients ENABLED true
set_interface_property s1_FIR_down_coefficients EXPORT_OF ""
set_interface_property s1_FIR_down_coefficients PORT_NAME_MAP ""
set_interface_property s1_FIR_down_coefficients CMSIS_SVD_VARIABLES ""
set_interface_property s1_FIR_down_coefficients SVD_ADDRESS_GROUP ""

add_interface_port s1_FIR_down_coefficients avs_s1_address address Input fir_addr_width
add_interface_port s1_FIR_down_coefficients avs_s1_write write Input 1
add_interface_port s1_FIR_down_coefficients avs_s1_writedata writedata Input 32
add_interface_port s1_FIR_down_coefficients avs_s1_read read Input 1
add_interface_port s1_FIR_down_coefficients avs_s1_readdata readdata Output 32
set_interface_assignment s1_FIR_down_coefficients embeddedsw.configuration.isFlash 0
set_interface_assignment s1_FIR_down_coefficients embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s1_FIR_down_coefficients embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s1_FIR_down_coefficients embeddedsw.configuration.isPrintableDevice 0

