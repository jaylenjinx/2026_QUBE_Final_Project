function [u, x_hat] = controller(r, theta, alpha, reset, F, Lo, A, B, C, xhat0_offset, u_max)
%CONTROLLER Discrete-time SFC with a Luenberger observer (CS2), QUBE-Servo 2 RIP.
% Every stage of the control system is in this one block (Task 5 rule):
%   1. References (DP2 Q2.2):  x* = [r; 0; 0; 0], u* = 0
%   2. Control law (Q2.4):     u(k) = -F (x_hat(k) - x*) + u*, limited to +/-u_max
%   3. Observer (Q3.3):        x_hat(k+1) = A x_hat(k) + B u(k) + Lo (y(k) - C x_hat(k))
% The observer is updated with the limited voltage that actually reaches the
% motor. It starts from the measured angles with zero velocities whenever the
% controller is enabled; xhat0_offset adds an initial estimation error, for
% showing observer convergence in simulation (keep it zero on the hardware).
% Inputs: r, theta, alpha in rad; reset = 1 (controller disabled) restarts the
% observer and holds u at 0. Outputs: u, the motor voltage Vm in V; x_hat.
%#codegen

persistent xh
y = [theta; alpha];
if isempty(xh) || reset
    xh = [y; 0; 0] + xhat0_offset;
end
x_hat = xh;

x_ref = [r; 0; 0; 0];
u_ref = 0;
u = -F*(xh - x_ref) + u_ref;
u = min(max(u, -u_max), u_max);
if reset
    u = 0;
end

xh = A*xh + B*u + Lo*(y - C*xh);
end
