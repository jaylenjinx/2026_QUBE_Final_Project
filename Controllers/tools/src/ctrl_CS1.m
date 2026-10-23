function u = controller(r, theta, alpha, reset, bF, aF, bT, aT, bA, aA, u_max)
%CONTROLLER Frequency-domain control system (CS1) for the QUBE-Servo 2 RIP.
% Every stage of the control system is in this one block (Task 5 rule):
%   1. Reference prefilter  F(z):       r_f     = F(z) r
%   2. Arm loop             C_theta(z): u_theta = C_theta(z) (r_f - theta)
%   3. Pendulum loop        C_alpha(z): u_alpha = C_alpha(z) (0 - alpha)
%   4. Control law and amplifier limit: u = sat(u_theta + u_alpha, +/-u_max)
% Each stage runs the difference equation of b(z^-1)/a(z^-1), with the
% coefficients from params_CS1x.m (re-run it after changing the design).
% A stage with b = 0, a = 1 is switched off; b = 1, a = 1 passes straight through.
% Inputs: r, theta, alpha in rad; reset = 1 (controller disabled) clears all
% stage states and holds u at 0. Output: u, the motor voltage Vm in V.
%#codegen

persistent wF wT wA started
if isempty(started) || reset
    % At least one slot each: code generation does not allow empty persistents
    wF = zeros(max(numel(aF) - 1, 1), 1);
    wT = zeros(max(numel(aT) - 1, 1), 1);
    wA = zeros(max(numel(aA) - 1, 1), 1);
    started = true;
end

[r_f, wF]     = lti_step(bF, aF, r, wF);
[u_theta, wT] = lti_step(bT, aT, r_f - theta, wT);
[u_alpha, wA] = lti_step(bA, aA, 0 - alpha, wA);

u = min(max(u_theta + u_alpha, -u_max), u_max);
if reset
    u = 0;
end
end

function [y, w] = lti_step(b, a, x, w)
% One sample of y = (b(z^-1)/a(z^-1)) x in direct form II transposed.
% b and a have equal length n+1 with a(1) = 1; w(1:n) holds the stage states
% (a static gain, n = 0, leaves its single slot unused).
n = numel(a) - 1;
y = b(1)*x;
if n > 0
    y = y + w(1);
    for i = 1:n-1
        w(i) = b(i+1)*x + w(i+1) - a(i+1)*y;
    end
    w(n) = b(n+1)*x - a(n+1)*y;
end
end
