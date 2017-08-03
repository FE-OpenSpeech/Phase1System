
%-----------------------------------------------
% FIR Decimator Blocks
%-----------------------------------------------
FIRDecimator1.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRDecimator1'];
FIRDecimator1.decimation_factor           = 4;
FIRDecimator1.decimateNP                  = 4; % half-polyphase length;  default = 12   Controls group delay (filter order)
FIRDecimator1.attenuation                 = 80;  % in dB
FIRDecimator1.FIR_coefficients            = designMultirateFIR(1, FIRDecimator1.decimation_factor, FIRDecimator1.decimateNP, FIRDecimator1.attenuation);
FIRDecimator1.filter_object               = dsp.FIRDecimator(FIRDecimator1.decimation_factor, FIRDecimator1.FIR_coefficients);
FIRDecimator1.numeric_type                = numerictype(1,32,28);
FIRDecimator1.serial_partitions_available = hdlfilterserialinfo(FIRDecimator1.filter_object, 'InputDataType', FIRDecimator1.numeric_type);
FIRDecimator1.folding_factor              = 8;
FIRDecimator1.serial_partition_set        = hdlfilterserialinfo(FIRDecimator1.filter_object, 'Foldingfactor', FIRDecimator1.folding_factor, 'InputDataType', FIRDecimator1.numeric_type);
disp(['Serial Partitions Available for ' FIRDecimator1.simulink_block]); FIRDecimator1.serial_partitions_available
hdlset_param(FIRDecimator1.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRDecimator1.simulink_block,'SerialPartition',FIRDecimator1.serial_partition_set)


FIRDecimator2.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRDecimator2'];
FIRDecimator2.decimation_factor           = 2;
FIRDecimator2.decimateNP                  = 4; % half-polyphase length;  default = 12   Controls group delay (filter order)
FIRDecimator2.attenuation                 = 80;  % in dB
FIRDecimator2.FIR_coefficients            = designMultirateFIR(1, FIRDecimator2.decimation_factor, FIRDecimator2.decimateNP, FIRDecimator2.attenuation);
FIRDecimator2.filter_object               = dsp.FIRDecimator(FIRDecimator2.decimation_factor, FIRDecimator2.FIR_coefficients);
FIRDecimator2.numeric_type                = numerictype(1,32,28);
FIRDecimator2.serial_partitions_available = hdlfilterserialinfo(FIRDecimator2.filter_object, 'InputDataType', FIRDecimator2.numeric_type);
FIRDecimator2.folding_factor              = 4;
FIRDecimator2.serial_partition_set        = hdlfilterserialinfo(FIRDecimator2.filter_object, 'Foldingfactor', FIRDecimator2.folding_factor, 'InputDataType', FIRDecimator2.numeric_type);
disp(['Serial Partitions Available for ' FIRDecimator2.simulink_block]); FIRDecimator2.serial_partitions_available
hdlset_param(FIRDecimator2.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRDecimator2.simulink_block,'SerialPartition',FIRDecimator2.serial_partition_set)

FIRDecimator3.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRDecimator3'];
FIRDecimator3.decimation_factor           = 2;
FIRDecimator3.decimateNP                  = 3; % half-polyphase length;  default = 12   Controls group delay (filter order)
FIRDecimator3.attenuation                 = 80;  % in dB
FIRDecimator3.FIR_coefficients            = designMultirateFIR(1, FIRDecimator3.decimation_factor, FIRDecimator3.decimateNP, FIRDecimator3.attenuation);
FIRDecimator3.filter_object               = dsp.FIRDecimator(FIRDecimator3.decimation_factor, FIRDecimator3.FIR_coefficients);
FIRDecimator3.numeric_type                = numerictype(1,32,28);
FIRDecimator3.serial_partitions_available = hdlfilterserialinfo(FIRDecimator3.filter_object, 'InputDataType', FIRDecimator3.numeric_type);
FIRDecimator3.folding_factor              = 3;
FIRDecimator3.serial_partition_set        = hdlfilterserialinfo(FIRDecimator3.filter_object, 'Foldingfactor', FIRDecimator3.folding_factor, 'InputDataType', FIRDecimator3.numeric_type);
disp(['Serial Partitions Available for ' FIRDecimator3.simulink_block]); FIRDecimator3.serial_partitions_available
hdlset_param(FIRDecimator3.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRDecimator3.simulink_block,'SerialPartition',FIRDecimator3.serial_partition_set)

FIRDecimator4.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRDecimator4'];
FIRDecimator4.decimation_factor           = 2;
FIRDecimator4.decimateNP                  = 3; % half-polyphase length;  default = 12   Controls group delay (filter order)
FIRDecimator4.attenuation                 = 80;  % in dB
FIRDecimator4.FIR_coefficients            = designMultirateFIR(1, FIRDecimator4.decimation_factor, FIRDecimator4.decimateNP, FIRDecimator4.attenuation);
FIRDecimator4.filter_object               = dsp.FIRDecimator(FIRDecimator4.decimation_factor, FIRDecimator4.FIR_coefficients);
FIRDecimator4.numeric_type                = numerictype(1,32,28);
FIRDecimator4.serial_partitions_available = hdlfilterserialinfo(FIRDecimator4.filter_object, 'InputDataType', FIRDecimator4.numeric_type);
FIRDecimator4.folding_factor              = 3;
FIRDecimator4.serial_partition_set        = hdlfilterserialinfo(FIRDecimator4.filter_object, 'Foldingfactor', FIRDecimator4.folding_factor, 'InputDataType', FIRDecimator4.numeric_type);
disp(['Serial Partitions Available for ' FIRDecimator4.simulink_block]); FIRDecimator4.serial_partitions_available
hdlset_param(FIRDecimator4.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRDecimator4.simulink_block,'SerialPartition',FIRDecimator4.serial_partition_set)

FIRDecimator5.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRDecimator5'];
FIRDecimator5.decimation_factor           = 2;
FIRDecimator5.decimateNP                  = 3; % half-polyphase length;  default = 12   Controls group delay (filter order)
FIRDecimator5.attenuation                 = 80;  % in dB
FIRDecimator5.FIR_coefficients            = designMultirateFIR(1, FIRDecimator5.decimation_factor, FIRDecimator5.decimateNP, FIRDecimator5.attenuation);
FIRDecimator5.filter_object               = dsp.FIRDecimator(FIRDecimator5.decimation_factor, FIRDecimator5.FIR_coefficients);
FIRDecimator5.numeric_type                = numerictype(1,32,28);
FIRDecimator5.serial_partitions_available = hdlfilterserialinfo(FIRDecimator5.filter_object, 'InputDataType', FIRDecimator5.numeric_type);
FIRDecimator5.folding_factor              = 3;
FIRDecimator5.serial_partition_set        = hdlfilterserialinfo(FIRDecimator5.filter_object, 'Foldingfactor', FIRDecimator5.folding_factor, 'InputDataType', FIRDecimator5.numeric_type);
disp(['Serial Partitions Available for ' FIRDecimator5.simulink_block]); FIRDecimator5.serial_partitions_available
hdlset_param(FIRDecimator5.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRDecimator5.simulink_block,'SerialPartition',FIRDecimator5.serial_partition_set)


%-----------------------------------------------
% FIR Interpolator Blocks
%-----------------------------------------------
FIRInterpolator1.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRInterpolator1'];
FIRInterpolator1.interpolation_factor        = 4;
FIRInterpolator1.decimateNP                  = 4; % half-polyphase length;  default = 12   Controls group delay (filter order)
FIRInterpolator1.attenuation                 = 80;  % in dB
FIRInterpolator1.FIR_coefficients            = designMultirateFIR(FIRInterpolator1.interpolation_factor, 1, FIRInterpolator1.decimateNP, FIRInterpolator1.attenuation);
FIRInterpolator1.filter_object               = dsp.FIRInterpolator(FIRInterpolator1.interpolation_factor, FIRInterpolator1.FIR_coefficients);
FIRInterpolator1.numeric_type                = numerictype(1,32,28);
FIRInterpolator1.serial_partitions_available = hdlfilterserialinfo(FIRInterpolator1.filter_object, 'InputDataType', FIRInterpolator1.numeric_type);
FIRInterpolator1.folding_factor              = 8;
FIRInterpolator1.serial_partition_set        = hdlfilterserialinfo(FIRInterpolator1.filter_object, 'Foldingfactor', FIRInterpolator1.folding_factor, 'InputDataType', FIRInterpolator1.numeric_type);
disp(['Serial Partitions Available for ' FIRInterpolator1.simulink_block]); FIRInterpolator1.serial_partitions_available
hdlset_param(FIRInterpolator1.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRInterpolator1.simulink_block,'SerialPartition',FIRInterpolator1.serial_partition_set)
disp(['Serial Partition chosen = [' num2str(hdlget_param(FIRInterpolator1.simulink_block,'SerialPartition')) ']'])



FIRInterpolator2.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRInterpolator2'];
FIRInterpolator2.interpolation_factor        = 2;
FIRInterpolator2.decimateNP                  = 4; % half-polyphase length;  default = 12   Controls group delay (filter order)
FIRInterpolator2.attenuation                 = 80;  % in dB
FIRInterpolator2.FIR_coefficients            = designMultirateFIR(FIRInterpolator2.interpolation_factor, 1, FIRInterpolator2.decimateNP, FIRInterpolator2.attenuation);
FIRInterpolator2.filter_object               = dsp.FIRInterpolator(FIRInterpolator2.interpolation_factor, FIRInterpolator2.FIR_coefficients);
FIRInterpolator2.numeric_type                = numerictype(1,32,28);
FIRInterpolator2.serial_partitions_available = hdlfilterserialinfo(FIRInterpolator2.filter_object, 'InputDataType', FIRInterpolator2.numeric_type);
FIRInterpolator2.folding_factor              = 4;
FIRInterpolator2.serial_partition_set        = hdlfilterserialinfo(FIRInterpolator2.filter_object, 'Foldingfactor', FIRInterpolator2.folding_factor, 'InputDataType', FIRInterpolator2.numeric_type);
disp(['Serial Partitions Available for ' FIRInterpolator2.simulink_block]); FIRInterpolator2.serial_partitions_available
hdlset_param(FIRInterpolator2.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRInterpolator2.simulink_block,'SerialPartition',FIRInterpolator2.serial_partition_set)

FIRInterpolator3.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRInterpolator3'];
FIRInterpolator3.interpolation_factor        = 2;
FIRInterpolator3.decimateNP                  = 3; % half-polyphase length;  default = 12   Controls group delay (filter order)
FIRInterpolator3.attenuation                 = 80;  % in dB
FIRInterpolator3.FIR_coefficients            = designMultirateFIR(FIRInterpolator3.interpolation_factor, 1, FIRInterpolator3.decimateNP, FIRInterpolator3.attenuation);
FIRInterpolator3.filter_object               = dsp.FIRInterpolator(FIRInterpolator3.interpolation_factor, FIRInterpolator3.FIR_coefficients);
FIRInterpolator3.numeric_type                = numerictype(1,32,28);
FIRInterpolator3.serial_partitions_available = hdlfilterserialinfo(FIRInterpolator3.filter_object, 'InputDataType', FIRInterpolator3.numeric_type);
FIRInterpolator3.folding_factor              = 3;
FIRInterpolator3.serial_partition_set        = hdlfilterserialinfo(FIRInterpolator3.filter_object, 'Foldingfactor', FIRInterpolator3.folding_factor, 'InputDataType', FIRInterpolator3.numeric_type);
disp(['Serial Partitions Available for ' FIRInterpolator3.simulink_block]); FIRInterpolator3.serial_partitions_available
hdlset_param(FIRInterpolator3.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRInterpolator3.simulink_block,'SerialPartition',FIRInterpolator3.serial_partition_set)

FIRInterpolator4.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRInterpolator4'];
FIRInterpolator4.interpolation_factor        = 2;
FIRInterpolator4.decimateNP                  = 3; % half-polyphase length;  default = 12   Controls group delay (filter order)
FIRInterpolator4.attenuation                 = 80;  % in dB
FIRInterpolator4.FIR_coefficients            = designMultirateFIR(FIRInterpolator4.interpolation_factor, 1, FIRInterpolator4.decimateNP, FIRInterpolator4.attenuation);
FIRInterpolator4.filter_object               = dsp.FIRInterpolator(FIRInterpolator4.interpolation_factor, FIRInterpolator4.FIR_coefficients);
FIRInterpolator4.numeric_type                = numerictype(1,32,28);
FIRInterpolator4.serial_partitions_available = hdlfilterserialinfo(FIRInterpolator4.filter_object, 'InputDataType', FIRInterpolator4.numeric_type);
FIRInterpolator4.folding_factor              = 3;
FIRInterpolator4.serial_partition_set        = hdlfilterserialinfo(FIRInterpolator4.filter_object, 'Foldingfactor', FIRInterpolator4.folding_factor, 'InputDataType', FIRInterpolator4.numeric_type);
disp(['Serial Partitions Available for ' FIRInterpolator4.simulink_block]); FIRInterpolator4.serial_partitions_available
hdlset_param(FIRInterpolator4.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRInterpolator4.simulink_block,'SerialPartition',FIRInterpolator4.serial_partition_set)

FIRInterpolator5.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRInterpolator5'];
FIRInterpolator5.interpolation_factor        = 2;
FIRInterpolator5.decimateNP                  = 3; % half-polyphase length;  default = 12   Controls group delay (filter order)
FIRInterpolator5.attenuation                 = 80;  % in dB
FIRInterpolator5.FIR_coefficients            = designMultirateFIR(FIRInterpolator5.interpolation_factor, 1, FIRInterpolator5.decimateNP, FIRInterpolator5.attenuation);
FIRInterpolator5.filter_object               = dsp.FIRInterpolator(FIRInterpolator5.interpolation_factor, FIRInterpolator5.FIR_coefficients);
FIRInterpolator5.numeric_type                = numerictype(1,32,28);
FIRInterpolator5.serial_partitions_available = hdlfilterserialinfo(FIRInterpolator5.filter_object, 'InputDataType', FIRInterpolator5.numeric_type);
FIRInterpolator5.folding_factor              = 3;
FIRInterpolator5.serial_partition_set        = hdlfilterserialinfo(FIRInterpolator5.filter_object, 'Foldingfactor', FIRInterpolator5.folding_factor, 'InputDataType', FIRInterpolator5.numeric_type);
disp(['Serial Partitions Available for ' FIRInterpolator5.simulink_block]); FIRInterpolator5.serial_partitions_available
hdlset_param(FIRInterpolator5.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRInterpolator5.simulink_block,'SerialPartition',FIRInterpolator5.serial_partition_set)



%-----------------------------------------------
% FIR Bandpass Block
%-----------------------------------------------
FIRBandPass1.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRBandPass1'];
FIRBandPass1.filter_order                = 32;
FIRBandPass1.FIR_coefficients            = fir1(FIRBandPass1.filter_order,[1/3 2/3]);
FIRBandPass1.filter_object               = dsp.FIRFilter('Numerator', FIRBandPass1.FIR_coefficients);
FIRBandPass1.numeric_type                = numerictype(1,32,28);
FIRBandPass1.serial_partitions_available = hdlfilterserialinfo(FIRBandPass1.filter_object, 'InputDataType', FIRBandPass1.numeric_type);
FIRBandPass1.folding_factor              = 12;
FIRBandPass1.serial_partition_set        = hdlfilterserialinfo(FIRBandPass1.filter_object, 'Foldingfactor', FIRBandPass1.folding_factor, 'InputDataType', FIRBandPass1.numeric_type);
disp(['Serial Partitions Available for ' FIRBandPass1.simulink_block]); FIRBandPass1.serial_partitions_available
hdlset_param(FIRBandPass1.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRBandPass1.simulink_block,'SerialPartition',FIRBandPass1.serial_partition_set)

FIRBandPass2.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRBandPass2'];
FIRBandPass2.filter_order                = 32;
FIRBandPass2.FIR_coefficients            = fir1(FIRBandPass2.filter_order,[1/3 2/3]);
FIRBandPass2.filter_object               = dsp.FIRFilter('Numerator', FIRBandPass2.FIR_coefficients);
FIRBandPass2.numeric_type                = numerictype(1,32,28);
FIRBandPass2.serial_partitions_available = hdlfilterserialinfo(FIRBandPass2.filter_object, 'InputDataType', FIRBandPass2.numeric_type);
FIRBandPass2.folding_factor              = 12;
FIRBandPass2.serial_partition_set        = hdlfilterserialinfo(FIRBandPass2.filter_object, 'Foldingfactor', FIRBandPass2.folding_factor, 'InputDataType', FIRBandPass2.numeric_type);
disp(['Serial Partitions Available for ' FIRBandPass2.simulink_block]); FIRBandPass2.serial_partitions_available
hdlset_param(FIRBandPass2.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRBandPass2.simulink_block,'SerialPartition',FIRBandPass2.serial_partition_set)

FIRBandPass3.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRBandPass3'];
FIRBandPass3.filter_order                = 12;
FIRBandPass3.FIR_coefficients            = fir1(FIRBandPass3.filter_order,[1/3 2/3]);
FIRBandPass3.filter_object               = dsp.FIRFilter('Numerator', FIRBandPass3.FIR_coefficients);
FIRBandPass3.numeric_type                = numerictype(1,32,28);
FIRBandPass3.serial_partitions_available = hdlfilterserialinfo(FIRBandPass3.filter_object, 'InputDataType', FIRBandPass3.numeric_type);
FIRBandPass3.folding_factor              = 4;
FIRBandPass3.serial_partition_set        = hdlfilterserialinfo(FIRBandPass3.filter_object, 'Foldingfactor', FIRBandPass3.folding_factor, 'InputDataType', FIRBandPass3.numeric_type);
disp(['Serial Partitions Available for ' FIRBandPass3.simulink_block]); FIRBandPass3.serial_partitions_available
hdlset_param(FIRBandPass3.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRBandPass3.simulink_block,'SerialPartition',FIRBandPass3.serial_partition_set)

FIRBandPass4.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRBandPass4'];
FIRBandPass4.filter_order                = 8;
FIRBandPass4.FIR_coefficients            = fir1(FIRBandPass4.filter_order,[1/3 2/3]);
FIRBandPass4.filter_object               = dsp.FIRFilter('Numerator', FIRBandPass4.FIR_coefficients);
FIRBandPass4.numeric_type                = numerictype(1,32,28);
FIRBandPass4.serial_partitions_available = hdlfilterserialinfo(FIRBandPass4.filter_object, 'InputDataType', FIRBandPass4.numeric_type);
FIRBandPass4.folding_factor              = 4;
FIRBandPass4.serial_partition_set        = hdlfilterserialinfo(FIRBandPass4.filter_object, 'Foldingfactor', FIRBandPass4.folding_factor, 'InputDataType', FIRBandPass4.numeric_type);
disp(['Serial Partitions Available for ' FIRBandPass4.simulink_block]); FIRBandPass4.serial_partitions_available
hdlset_param(FIRBandPass4.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRBandPass4.simulink_block,'SerialPartition',FIRBandPass4.serial_partition_set)

FIRBandPass5.simulink_block              = ['HA_sys7/HA_LR/HA_right/FIRBandPass5'];
FIRBandPass5.filter_order                = 6;
FIRBandPass5.FIR_coefficients            = fir1(FIRBandPass5.filter_order,[1/3 2/3]);
FIRBandPass5.filter_object               = dsp.FIRFilter('Numerator', FIRBandPass5.FIR_coefficients);
FIRBandPass5.numeric_type                = numerictype(1,32,28);
FIRBandPass5.serial_partitions_available = hdlfilterserialinfo(FIRBandPass5.filter_object, 'InputDataType', FIRBandPass5.numeric_type);
FIRBandPass5.folding_factor              = 3;
FIRBandPass5.serial_partition_set        = hdlfilterserialinfo(FIRBandPass5.filter_object, 'Foldingfactor', FIRBandPass5.folding_factor, 'InputDataType', FIRBandPass5.numeric_type);
disp(['Serial Partitions Available for ' FIRBandPass5.simulink_block]); FIRBandPass5.serial_partitions_available
hdlset_param(FIRBandPass5.simulink_block,'Architecture','Partly Serial')
hdlset_param(FIRBandPass5.simulink_block,'SerialPartition',FIRBandPass5.serial_partition_set)















