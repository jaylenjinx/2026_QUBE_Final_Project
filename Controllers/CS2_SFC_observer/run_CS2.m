%% CS2: simulate on the linear and nonlinear plant and check the requirements
% Edit the design in params_CS2.m, then run this script. Figures are saved
% to figures/ and the results are printed to the Command Window.
clear; close all; clc;
params_CS2;

fprintf('CS2 design: zeta = %.3f, wn = %.2f rad/s, integral %s\n', zeta, wn, mat2str(use_integral));
fprintf('  SFC poles      %s 1/s\n', mat2str(round(ps, 2)));
fprintf('  observer poles %s 1/s\n', mat2str(round(po_s, 1)));
fprintf('  F = %s, Fi = %.3f\n', mat2str(F, 4), Fi);
kr = motor_gain_range(A, B, C, F, Fi, Lo, ts);
fprintf('  stable for motor gain %.2fx-%.2fx nominal (observer included)\n\n', kr);

plants = {'sim_CS2_linear', 'Linear'; 'sim_CS2_nonlinear', 'Nonlinear'};
fprintf('CS2: %.1f deg arm step at t = %g s\n', rad2deg(theta_step), step_time);
fprintf('%-10s %9s %12s %12s %12s %10s  %s\n', 'Plant', 'OS [%]', 'ts (2%) [s]', ...
    'Final [deg]', 'max|a| [deg]', 'max|V| [V]', 'Requirements');
for k = 1:size(plants, 1)
    out = sim(plants{k, 1});
    m = step_metrics(out.time, out.theta, out.alpha, out.u, theta_step, step_time);
    verdict = 'not met';
    if m.pass, verdict = 'met (OS < 15 %, ts < 5 s)'; end
    fprintf('%-10s %9.2f %12.3f %12.2e %12.3f %10.3f  %s\n', plants{k, 2}, m.overshoot, ...
        m.settling, m.final_error, m.peak_alpha, m.peak_u, verdict);
    plot_response(out, 'CS2', plants{k, 2}, theta_step, step_time);
end

function kr = motor_gain_range(A, B, C, F, Fi, Lo, ts)
% Range of motor-gain factor k (plant input k*u) for which the whole discrete
% loop, plant + observer + integrator, stays stable.
ks = logspace(-2, 1.5, 1500);
st = false(size(ks));
for j = 1:numel(ks)
    Acl = [A, -ks(j)*B*F, -ks(j)*B*Fi; Lo*C, A - B*F - Lo*C, -B*Fi; ts*[1 0 0 0], zeros(1,4), 1];
    st(j) = max(abs(eig(Acl))) < 1;
end
d = diff([0 st 0]);
kr = [ks(find(d == 1, 1)), ks(find(d == -1, 1) - 1)];
end
