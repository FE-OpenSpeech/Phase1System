clear all
close all

% set path to home directory \fxpt_math 
global fxpt_math_home_dir
switch get_mac_address()
    case '40-8D-5C-58-3A-42'  % FE 
        fxpt_math_home_dir = 'E:\FE\ModelSim_verificaton\fxpt_math';
    case '1C-1B-0D-E0-8F-8E'  % hm
        fxpt_math_home_dir = 'E:\FE\ModelSim_verificaton\fxpt_math';
    otherwise
        error('set correct path')
end

% add paths to current Matlab session
addpath([fxpt_math_home_dir '\fxpt_log\source_code\matlab'])
addpath([fxpt_math_home_dir '\fxpt_exp\source_code\matlab'])
addpath([fxpt_math_home_dir '\fxpt_exp_ext\source_code\matlab'])
addpath([fxpt_math_home_dir '\fxpt_power\source_code\matlab'])
addpath([fxpt_math_home_dir '\fxpt_utilities'])


global fxptM

fxptM.log.W = 28;  % Word length for log data type
fxptM.log.F = 24;  % Fraction length for log data type

fxptM.exp.W = 28;  % Word length for exp data type
fxptM.exp.F = 24;  % Fraction length exp log data type

fxptM.exp_ext.W = 32;  % Word length for extended exp data type
fxptM.exp_ext.F = 8;  % Fraction length for extended exp data type

fxptM.power.W   = 32;  % Word length for power data type
fxptM.power.F   = 8;  % Fraction length for power data type


% fxpt_log_tb
% v = fxpt_log_vhdl_code_gen();

% fxpt_exp_tb
%v=fxpt_exp_vhdl_code_gen()

%fxpt_exp_ext_tb
%v=fxpt_exp_ext_vhdl_code_gen()


fxpt_power_tb
fxpt_power_vhdl_code_gen()








function mac_address = get_mac_address()
[status,result] = dos('getmac');
mac_address = result(160:176);
end


