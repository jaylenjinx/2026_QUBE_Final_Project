%% CS1A: simulate on the linear and nonlinear plant and check the requirements
% Edit the design in params_CS1A.m, then run this script. Figures are saved
% to figures/ and the results are printed to the Command Window.
clear; close all; clc;
params_CS1A;

plants = {'sim_CS1A_linear', 'Linear'; 'sim_CS1A_nonlinear', 'Nonlinear'};
fprintf('CS1A: %.1f deg arm step at t = %g s\n', rad2deg(theta_step), step_time);
fprintf('%-10s %9s %12s %12s %12s %10s  %s\n', 'Plant', 'OS [%]', 'ts (2%) [s]', ...
    'Final [deg]', 'max|a| [deg]', 'max|V| [V]', 'Requirements');
for k = 1:size(plants, 1)
    out = sim(plants{k, 1});
    m = step_metrics(out.time, out.theta, out.alpha, out.u, theta_step, step_time);
    verdict = 'not met';
    if m.pass, verdict = 'met (OS < 15 %, ts < 5 s)'; end
    fprintf('%-10s %9.2f %12.3f %12.2e %12.3f %10.3f  %s\n', plants{k, 2}, m.overshoot, ...
        m.settling, m.final_error, m.peak_alpha, m.peak_u, verdict);
    plot_response(out, 'CS1A', plants{k, 2}, theta_step, step_time);
end
