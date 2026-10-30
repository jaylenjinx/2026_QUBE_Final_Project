%% CS2 parameters: discrete-time SFC with integral action and a Luenberger observer
% Run by run_CS2.m, and by Hardware_settings.m before every hardware build,
% so the simulation and the hardware always use the same gains.

qube_model;                         % plant constants, Ac..Dc, A..D, ts

%% Closed-loop poles
% The DP2 poles (zeta = 0.6, wn = 2.5 rad/s, plus -6 and -8) meet the
% requirements on the model, but the loop only stays stable while the real
% motor delivers at least 0.87x its modelled gain. The hardware has less
% (friction at the small balancing voltages), so the poles use the bandwidth
% of the CS1.A design that balances on the QUBE: a dominant pair at
% wn = 8 rad/s, zeta = 0.7, and two faster real poles.
%   DP2 poles, for reference: ps = [-1.5+2i, -1.5-2i, -6, -8];
wn   = 8;                           % dominant natural frequency [rad/s]
zeta = 0.7;                         % dominant damping
ps = [-zeta*wn + 1i*wn*sqrt(1-zeta^2), -zeta*wn - 1i*wn*sqrt(1-zeta^2), ...
      -2.4*wn, -3.2*wn];            % continuous-time SFC poles [1/s]

%% Integral action: removes the arm offset that friction leaves
% Augmented state x_i(k+1) = x_i(k) + ts*(theta(k) - r), so with
% K = [F, Fi] the control law is u = -F (x - x*) - Fi x_i.
use_integral = true;                % false: plain SFC (Fi = 0)
p_int    = -8;                      % integrator pole [1/s]
int_band = 2*pi/180;                % integrate only within +/-2 deg of the reference [rad]
ref_tau  = 0.2;                     % reference filter time constant [s] (0 = off)

if use_integral
    Aa = [A, zeros(4,1); ts*[1 0 0 0], 1];
    Ba = [B; 0];
    K  = place(Aa, Ba, exp([ps, p_int]*ts));
    F  = K(1:4);
    Fi = K(5);
else
    F  = place(A, B, exp(ps*ts));
    Fi = 0;
end
pz = exp(ps*ts);                    % discrete-time SFC poles, z = e^(s Ts)

%% Observer, about 4x faster than the fastest SFC pole
% Faster observers pass more encoder quantisation noise into the velocity
% estimates (more voltage chatter).
%   DP2 observer poles, for reference: po_s = [-40, -45, -50, -55];
po_s = [-90, -95, -100, -105];      % continuous-time observer poles [1/s]
po_z = exp(po_s*ts);
Lo   = place(A', C', po_z)';

xhat0_offset = [0; 0; 0; 0];        % extra initial estimation error (simulation only)
u_max = 10;                         % QUBE-Servo 2 amplifier limit [V]

%% Simulation settings (run_CS2.m)
% 45 deg, as for the CS1.A hardware benchmark: its +/-2 % band (0.9 deg) is
% wider than one encoder count (0.18 deg), unlike a 5 deg step's band.
theta_step = 45*pi/180;             % arm reference step [rad]
step_time  = 1;                     % [s]
Tsim       = 15;                    % [s]
x0         = [0; 0; 0; 0];          % initial plant state, e.g. [0; 2*pi/180; 0; 0]
