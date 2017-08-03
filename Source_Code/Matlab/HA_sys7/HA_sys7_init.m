clear all
close all
clc
%----------------------------------------------------------------------
% Create input test signal
%----------------------------------------------------------------------
Fs = 48000;                % sample rate
Ts = 1/Fs;                 % sample time
Ns = 20000;                % number of input samples
stopTime = (Ns-1) * Ts;
signal_in = HA_sys7_test_signal(Fs, Ns);

%----------------------------------------------------------------------
% Subsystem Setup
%----------------------------------------------------------------------
HA_sys7_left_init
HA_sys7_right_init

%----------------------------------------------------------------------
% Top Level Gain paramenters
%----------------------------------------------------------------------
Gain_B1_left  = 1;
Gain_B2_left  = 1;
Gain_B3_left  = 1;
Gain_B4_left  = 1;
Gain_B5_left  = 1;
Gain_B1_right = 1;
Gain_B2_right = 1;
Gain_B3_right = 1;
Gain_B4_right = 1;
Gain_B5_right = 1;

%----------------------------------------------------------------------
% VHDL generation control parameters
%----------------------------------------------------------------------
hdlset_param('HA_sys7', 'BalanceDelays', 'on');

