%% CS2 parameters: discrete-time SFC with a Luenberger observer (from DP2)
% Run by run_CS2.m, and by Hardware_settings.m before every hardware build,
% so the simulation and the hardware always use the same gains.

qube_model;                         % plant constants, Ac..Dc, A..D, ts

%% State feedback (DP2 Q2.3-Q2.4)
% Dominant pair from zeta = 0.6, wn = 2.5 rad/s, plus two faster real poles.
ps = [-1.5+2i, -1.5-2i, -6, -8];    % continuous-time closed-loop poles [1/s]
pz = exp(ps*ts);                    % discrete-time poles, z = e^(s Ts)
F  = place(A, B, pz);

%% Observer (DP2 Q3.2-Q3.3), about 5x faster than the fastest SFC pole
po_s = [-40, -45, -50, -55];        % continuous-time observer poles [1/s]
po_z = exp(po_s*ts);
Lo   = place(A', C', po_z)';

xhat0_offset = [0; 0; 0; 0];        % extra initial estimation error (simulation only)
u_max = 10;                         % QUBE-Servo 2 amplifier limit [V]

%% Simulation settings (run_CS2.m)
theta_step = 5*pi/180;              % arm reference step [rad]
step_time  = 1;                     % [s]
Tsim       = 15;                    % [s]
x0         = [0; 0; 0; 0];          % initial plant state, e.g. [0; 2*pi/180; 0; 0]
