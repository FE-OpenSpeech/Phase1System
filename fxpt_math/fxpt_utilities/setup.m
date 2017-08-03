% Setup

%--------------------------------------------------------
% Set path to \fxpt_math, which is the home directory, 
% and stored as a global variable
%--------------------------------------------------------
global fxpt_math_home_dir;   
fxpt_math_home_dir = 'D:\NIH\fxpt_math';   

%--------------------------------------------------------
% Add the relevant directories to Matlab's path
% (which is good for only the current Matlab session)
%--------------------------------------------------------
dir1 = [fxpt_math_home_dir '\fxpt_utilities'];  addpath(dir1)
dir1 = [fxpt_math_home_dir '\fxpt_log\source_code\matlab'];  addpath(dir1)
dir1 = [fxpt_math_home_dir '\fxpt_exp\source_code\matlab'];  addpath(dir1)
dir1 = [fxpt_math_home_dir '\fxpt_exp_ext\source_code\matlab'];  addpath(dir1)
dir1 = [fxpt_math_home_dir '\fxpt_power\source_code\matlab'];  addpath(dir1)

