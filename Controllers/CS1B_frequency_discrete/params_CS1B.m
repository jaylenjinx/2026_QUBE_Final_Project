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

%% Controller design directly in the z-domain            <-- YOUR DESIGN HERE
% Placeholders: every stage is off, so the motor voltage stays at 0 V.
% Design each C(z) from G_theta_z and G_alpha_z (for example with the root locus
% in the z-plane, mapping the required s-plane poles with z = exp(s*ts)), then
% compare the result with CS1.A.
z = tf('z', ts);
C_alpha_z = tf(0, 1, ts);           % pendulum loop C_alpha(z)
C_theta_z = tf(0, 1, ts);           % arm loop C_theta(z)
F_z       = tf(1, 1, ts);           % reference prefilter F(z)

%% Coefficients for the controller block
[bA, aA] = block_coeffs(C_alpha_z);
[bT, aT] = block_coeffs(C_theta_z);
[bF, aF] = block_coeffs(F_z);
u_max = 10;                         % QUBE-Servo 2 amplifier limit [V]

%% Simulation settings (run_CS1B.m)
theta_step = 5*pi/180;              % arm reference step [rad]
step_time  = 1;                     % [s]
Tsim       = 15;                    % [s]
x0         = [0; 0; 0; 0];          % initial plant state, e.g. [0; 2*pi/180; 0; 0]
