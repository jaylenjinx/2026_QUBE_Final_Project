function [u, x_hat] = controller(r, theta, alpha, reset, F, Fi, Lo, A, B, C, ts, ref_tau, int_band, xhat0_offset, u_max)
%CONTROLLER Discrete-time SFC with integral action and a Luenberger observer (CS2).
% Every stage of the control system is in this one block (Task 5 rule):
%   1. Reference filter:  r_f(k+1) = r_f(k) + ts/ref_tau (r - r_f(k)),  x* = [r_f; 0; 0; 0], u* = 0
%   2. Integral action:   x_i(k+1) = x_i(k) + ts (theta(k) - r), only while |theta - r| <= int_band
%                         and the voltage isn't limited (anti-windup)
%   3. Control law:       u(k) = -F (x_hat(k) - x*) - Fi x_i(k) + u*, limited to +/-u_max
%   4. Observer:          x_hat(k+1) = A x_hat(k) + B u(k) + Lo (y(k) - C x_hat(k))
% The observer is updated with the limited voltage that actually reaches the
% motor. When the controller is enabled, the observer starts from the measured
% angles with zero velocities, the reference filter from the measured theta and
% the integral from zero; xhat0_offset adds an initial estimation error for
% showing observer convergence in simulation (keep it zero on the hardware).
% Set Fi = 0 to run without integral action, or ref_tau = 0 to skip the filter.
% Inputs: r, theta, alpha in rad; reset = 1 (controller disabled) restarts all
% states and holds u at 0. Outputs: u, the motor voltage Vm in V; x_hat.
%#codegen

persistent xh xi rf
y = [theta; alpha];
if isempty(xh) || reset
    xh = [y; 0; 0] + xhat0_offset;
    xi = 0;
    rf = theta;
end
x_hat = xh;

% 1. Reference filter
if ref_tau > 0
    rf = rf + ts/ref_tau*(r - rf);
else
    rf = r;
end
x_ref = [rf; 0; 0; 0];
u_ref = 0;

% 3. Control law, with the amplifier limit
u_unlimited = -F*(xh - x_ref) - Fi*xi + u_ref;
u = min(max(u_unlimited, -u_max), u_max);
if reset
    u = 0;
end

% 2. Integral of the arm error, conditional and with anti-windup
e = theta - r;
dxi = ts*e;
winding_up = (u_unlimited > u_max && -Fi*dxi > 0) || (u_unlimited < -u_max && -Fi*dxi < 0);
if abs(e) <= int_band && ~winding_up && ~reset
    xi = xi + dxi;
end

% 4. Observer
xh = A*xh + B*u + Lo*(y - C*xh);
end
