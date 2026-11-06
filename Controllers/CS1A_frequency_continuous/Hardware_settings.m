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

%% Load this model's saved controller, independent of the current folder
hardware_folder = fileparts(mfilename('fullpath'));
hardware_previous_path = path;
hardware_path_cleanup = onCleanup(@() path(hardware_previous_path));
addpath(hardware_folder, '-begin');
run(fullfile(hardware_folder, 'params_CS1A_PID.m'));
clear hardware_path_cleanup
