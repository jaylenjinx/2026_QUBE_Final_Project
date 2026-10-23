%% QUBE-Servo 2 rotary inverted pendulum model (from DP2 Q1, dp2_q1.m)
% State x = [theta; alpha; theta_dot; alpha_dot] (rad, rad/s), alpha = 0 upright.
% Input u = motor voltage Vm (V). Outputs y = [theta; alpha] (encoders).
% Defines the plant constants used by the nonlinear Simulink plant, the
% linearised continuous model (Ac, Bc, Cc, Dc) about the upright equilibrium
% and its ZOH discretisation (A, B, C, D) at ts.

%% Physical parameters (QUBE-Servo 2 user manual, damping from the workbook)
Rm = 8.4;   kt = 0.042;  km = 0.042;
mr = 0.095; Lr = 0.085;  mp = 0.024;  Lp = 0.129;
Jm = 4e-6;  Jh = 0.6e-6;
Dr = 0.0015; Dp = 0.0005; g = 9.81;

%% Derived constants
lp = Lp/2;
Jr = mr*Lr^2/3 + Jm + Jh;
Jp = mp*Lp^2/12;
a = Jr + mp*Lr^2;
b = Jp + mp*lp^2;
c = mp*Lr*lp;
h = mp*g*lp;
d = Dr + kt*km/Rm;
kv = kt/Rm;
Delta0 = a*b - c^2;

%% Linearised continuous-time model
Ac = [0, 0, 1, 0;
      0, 0, 0, 1;
      0, c*h/Delta0, -b*d/Delta0, -c*Dp/Delta0;
      0, a*h/Delta0, -c*d/Delta0, -a*Dp/Delta0];
Bc = [0; 0; b*kv/Delta0; c*kv/Delta0];
Cc = [1 0 0 0;
      0 1 0 0];
Dc = zeros(2, 1);

%% Zero-order-hold discretisation (Ts = 1 ms, as in Hardware_settings.m)
ts = 1/1000;
sys_dt = c2d(ss(Ac, Bc, Cc, Dc), ts, 'zoh');
A = sys_dt.A;  B = sys_dt.B;  C = sys_dt.C;  D = sys_dt.D;
