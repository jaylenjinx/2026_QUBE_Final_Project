%% CS1A arm PID developed interactively in Control System Designer
% Hardware_settings.m loads this file before building hw_CS1A.
% Preserves the existing pendulum PD and reference filter from the N60 design.
% No simulation, deployment or hardware execution is performed by this file.
pid_folder=fileparts(mfilename('fullpath'));
run(fullfile(pid_folder,'params_CS1A_candidate.m'));
C_theta_PD_s=C_theta_s;

%% PID selected in the Compensator Editor
% Normalised editor gain -1.997; zeros at the original arm zero and -0.5;
% poles at 0 and -60. Keep the original zero's full precision.
% Approximately -107.45*(s+2.23017)*(s+0.5)/(s*(s+60)).
pid_editor_gain=-1.997;
pid_integral_zero=0.5;
s=tf('s');
C_theta_pid_s=pid_editor_gain*(1-s/arm_zero)*(1+s/pid_integral_zero) ...
    /(s*(1+s/N));
C_theta_s=C_theta_pid_s;

%% Tustin conversion at the existing 1 ms sampling period
C_theta_pid_z=c2d(C_theta_pid_s,ts,'tustin');
C_theta_z=C_theta_pid_z;
[bT,aT]=block_coeffs(C_theta_z);
% bA/aA and bF/aF remain the candidate pendulum/filter coefficients.
u_max=10;

%% Full-order digital stability check; do not cancel hidden modes
pid_plant_z=ss(A,B,C,D,ts);
pid_inner_z=feedback(pid_plant_z,ss(C_alpha_z),1,2);
pid_feedback_z=feedback(pid_inner_z*ss(C_theta_z),1,1,1);
assert(isstable(pid_feedback_z),'CS1A_PID:unstable','Digital PID feedback is unstable.');
% Existing controller clips voltage but has no dedicated PID anti-windup.
% Quantised-encoder and hardware validation of this PID remain pending.
