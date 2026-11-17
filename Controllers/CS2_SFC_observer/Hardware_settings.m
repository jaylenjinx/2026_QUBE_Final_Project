%% Control Lab Setup Settings
%
% 41277 Control Design
% University of Technology Sydney, Australia
%
% A/Prof Ricardo Aguilera
%
% This script will run before compiling the Simulink Model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Sampling Time
ts = 1/1000;     % 1000 Hz sampling frequency

%% Save Data at the end of the experimental test
save_data = true;  % true:  save data
% false: do not save data

%% Add your own fixed variable here
% Controller parameters: the same design file as the simulation
run('params_CS2.m');
% The QUBE's pendulum encoder counts alpha opposite to the model's convention
alpha_sign = -1;
% Arm step sequence for the "Run step sequence" switch
run('ref_sequence_settings.m');
