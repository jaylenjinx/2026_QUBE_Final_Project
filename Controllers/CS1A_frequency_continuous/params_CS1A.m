%% CS1.A parameters: frequency-domain design in the s-domain, then C(s) -> C(z)
% Run by run_CS1A.m, and by Hardware_settings.m before every hardware build,
% so the simulation and the hardware always use the same coefficients.
%
% Control structure (see ctrl_CS1A.slx):
%   u = C_theta(z) (F(z) r - theta) + C_alpha(z) (0 - alpha), limited to +/-u_max

qube_model;                         % plant constants, Ac..Dc, A..D, ts

%% Plant transfer functions from the motor voltage Vm
G = tf(ss(Ac, Bc, Cc, Dc));
G_theta = G(1);                     % theta(s)/Vm(s)
G_alpha = G(2);                     % alpha(s)/Vm(s)

%% Arm-position response targets (second-order approximation)
zeta = 0.6;
wn = 2.5;  % rad/s

OS_estimate = 100*exp(-pi*zeta/sqrt(1-zeta^2));
Ts_estimate = 4/(zeta*wn);

%% Controller design in the s-domain                     <-- YOUR DESIGN HERE
% Design each C(s) from G_theta and G_alpha to meet the requirements
% (overshoot < 15 %, settling time < 5 s), and keep the reasoning for the report.
% Check the signs against the model: Vm > 0 accelerates theta and alpha positively.
s = tf('s');
% Pendulum compensator with leaky integration
C_alpha_s = 181.48 * (1 + s/11.1614)^2 / ...
    ((s + 0.1)*(1 + s/50));

% Arm compensator: negative sign from the plant sign convention
C_theta_s = -41.59 * (1 + s/1.43685) / (1 + s/0.1);

% Arm-reference filter, unity DC gain
F_s = 1 / (1 + s/1.43685);

%% Discretisation C(s) -> C(z)
c2d_method = 'tustin';              % e.g. 'tustin', 'zoh', 'matched'
C_alpha_z = c2d(C_alpha_s, ts, c2d_method);
C_theta_z = c2d(C_theta_s, ts, c2d_method);
F_z       = c2d(F_s, ts, c2d_method);

%% Coefficients for the controller block
[bA, aA] = block_coeffs(C_alpha_z);
[bT, aT] = block_coeffs(C_theta_z);
[bF, aF] = block_coeffs(F_z);
u_max = 10;                         % QUBE-Servo 2 amplifier limit [V]

%% Simulation settings (run_CS1A.m)
theta_step = 5*pi/180;              % arm reference step [rad]
step_time  = 1;                     % [s]
Tsim       = 15;                    % [s]
x0         = [0; 0; 0; 0];          % initial plant state, e.g. [0; 2*pi/180; 0; 0]
