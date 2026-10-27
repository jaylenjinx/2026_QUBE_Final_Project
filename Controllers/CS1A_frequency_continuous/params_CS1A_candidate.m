%% Experimental CS1A candidate: joint filtered PD, N = 60 rad/s
% Separate from params_CS1A.m: no original controller is replaced.
% Control law: u = C_theta(z)*(F(z)*r-theta) - C_alpha(z)*alpha.
% Both gains are calculated together by continuous-time polynomial matching.
% This algebraic synthesis is experimental; complete frequency-domain design
% justification and hardware validation are not established by this file.
%
% Declared benchmark: 45-degree arm step; +/-2% band = +/-0.9 degree.
% Linear/nonlinear quantised benchmark tests passed. Additional linear tests
% with 1 ms actuator delay and +/-20% arm damping passed for this benchmark.
% Do not infer a pass at smaller commands from the 45-degree results.
% The initial-tilt test retains a limit cycle and fails +/-0.1-degree recovery.
% Known trade-off: voltage chatter and tighter margins than the original.
%
% This file only loads parameters. Hardware_settings.m loads this candidate
% for hw_CS1A. The original simulation runner still loads params_CS1A.m.
% Loading these parameters alone does not operate hardware.

%% Load the same DP2 plant model
candidate_folder = fileparts(mfilename('fullpath'));
candidate_previous_path = path;
candidate_path_cleanup = onCleanup(@() path(candidate_previous_path));
addpath(candidate_folder,'-begin');
run(fullfile(candidate_folder,'qube_model.m'));
s = tf('s');
G = tf(ss(Ac,Bc,Cc,Dc));
G_theta = G(1);
G_alpha = G(2);

%% Response-pole family and derivative filter
candidate_wn = 8;         % rad/s; feedback response target
candidate_zeta = 0.7;
N = 60;                   % derivative-filter pole magnitude [rad/s]

% Plant numerators and denominator:
% G_theta = (n2*s^2+n1*s+n0)/Dplant
% G_alpha = m2*s^2/Dplant
% Dplant = s^4+d3*s^3+d2*s^2+d1*s
d3 = (a*Dp+b*d)/Delta0;
d2 = (d*Dp-a*h)/Delta0;
d1 = -d*h/Delta0;
n2 = kv*b/Delta0;
n1 = kv*Dp/Delta0;
n0 = -kv*h/Delta0;
m2 = kv*c/Delta0;

dominant = roots([1 2*candidate_zeta*candidate_wn candidate_wn^2]);
faster = -candidate_wn*[2.4 3.2];
% Dplant*(s+N) fixes the s^4 coefficient at N+d3. Hence the sum
% of all five desired feedback poles must be -(N+d3).
remaining = -(N+d3+sum(dominant)+sum(faster));
assert(real(remaining)<0,'The fifth target pole must be in the left half-plane.');
desired_feedback_poles = [dominant.' faster remaining];
desired_polynomial = real(poly(desired_feedback_poles));
open_polynomial = conv([1 d3 d2 d1 0],[1 N]);

%% Match coefficients to calculate four signed gains
% C_theta(s) = Kp_theta + Kd_theta*N*s/(s+N)
% C_alpha(s) = Kp_alpha + Kd_alpha*N*s/(s+N)
% The characteristic equation is Dplant*(s+N) plus both feedback
% numerator contributions. Rows below match s^3, s^2, s and constant.
gain_map = [n2,       n2*N, m2,   m2*N;
            n1+n2*N, n1*N, m2*N, 0;
            n0+n1*N, n0*N, 0,    0;
            n0*N,    0,    0,    0];
candidate_gains = gain_map\ ...
    (desired_polynomial(3:end).'-open_polynomial(3:end).');
Kp_theta = candidate_gains(1);
Kd_theta = candidate_gains(2);
Kp_alpha = candidate_gains(3);
Kd_alpha = candidate_gains(4);

C_theta_s = Kp_theta + Kd_theta*N*s/(s+N);
C_alpha_s = Kp_alpha + Kd_alpha*N*s/(s+N);

%% Reference shaping (not part of the feedback characteristic equation)
arm_zero = zero(C_theta_s);
assert(isscalar(arm_zero) && isreal(arm_zero) && arm_zero<0, ...
    'Reference shaping requires a stable real arm-controller zero.');
F_s = (-arm_zero)/(s-arm_zero) * 3/(s+3);

%% Discretise the continuous controllers at the original 1 ms sample time
c2d_method = 'tustin';
C_alpha_z = c2d(C_alpha_s,ts,c2d_method);
C_theta_z = c2d(C_theta_s,ts,c2d_method);
F_z = c2d(F_s,ts,c2d_method);
[bA,aA] = block_coeffs(C_alpha_z);
[bT,aT] = block_coeffs(C_theta_z);
[bF,aF] = block_coeffs(F_z);
u_max = 10;

%% Candidate benchmark settings
theta_step = 45*pi/180;
step_time = 1;
Tsim = 60;
x0 = [0;0;0;0];

clear candidate_path_cleanup
