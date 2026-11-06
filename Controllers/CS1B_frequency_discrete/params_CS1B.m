%% CS1.B parameters: discretise the plant first, then design C(z) in the z-domain
% Run by run_CS1B.m, and by Hardware_settings.m before every hardware build,
% so the simulation and the hardware always use the same coefficients.
%
% Control structure (see ctrl_CS1B.slx), the same as CS1.A:
%   u = C_theta(z) (F(z) r - theta) + C_alpha(z) (0 - alpha), limited to +/-u_max

qube_model;                         % plant constants, Ac..Dc, A..D, ts

%% Plant transfer functions from the motor voltage Vm, discretised with a ZOH
G   = tf(ss(Ac, Bc, Cc, Dc));
G_z = c2d(G, ts, 'zoh');
G_theta_z = G_z(1);                 % theta(z)/Vm(z)
G_alpha_z = G_z(2);                 % alpha(z)/Vm(z)

%% Controller design directly in the z-domain
% Selected directly in z using the two-loop root-locus workflow (Ts = 1 ms).
% Pendulum filtered PD; arm PID with a filtered derivative; unity-DC filter.
% These are discrete pole/zero locations, not c2d conversions of CS1A.
C_alpha_z = zpk(0.986, 0.942, 180, ts);
C_theta_z = zpk([0.99777 0.9995], [1 0.942], -104, ts);
filter_poles = [0.99777 0.997];
F_z = zpk([], filter_poles, prod(1-filter_poles), ts);

% Retain all plant/controller modes when checking the complete feedback loop.
cs1b_plant_z = ss(A, B, C, D, ts);
cs1b_inner_z = feedback(cs1b_plant_z, ss(C_alpha_z), 1, 2);
cs1b_feedback_z = feedback(cs1b_inner_z * ss(C_theta_z), 1, 1, 1);
assert(isstable(cs1b_feedback_z), 'CS1B_PID:unstable', ...
    'The complete digital feedback system is unstable.');
% Voltage clipping is implemented in ctrl_CS1B; dedicated PID anti-windup
% is not implemented. Quantised-encoder and hardware PID tests are pending.

%% Coefficients for the controller block
[bA, aA] = block_coeffs(C_alpha_z);
[bT, aT] = block_coeffs(C_theta_z);
[bF, aF] = block_coeffs(F_z);
u_max = 10;                         % QUBE-Servo 2 amplifier limit [V]

%% Simulation settings (run_CS1B.m)
theta_step = 45*pi/180;              % arm reference step [rad]
step_time  = 1;                     % [s]
Tsim       = 30;                    % [s]
x0         = [0; 0; 0; 0];          % initial plant state, e.g. [0; 2*pi/180; 0; 0]
