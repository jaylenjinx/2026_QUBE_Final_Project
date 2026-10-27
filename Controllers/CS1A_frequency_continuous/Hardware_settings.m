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
% N60 candidate controller parameters for the hardware test
run(fullfile(fileparts(mfilename('fullpath')),'params_CS1A_candidate.m'));
