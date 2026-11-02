%% Task 5 report: every figure and number in the report comes from this script
% Run from anywhere: it changes into each controller folder, loads the same
% params file the hardware uses, runs the Simulink models and writes
%   figures/*.pdf      - plots with labelled axes, units and legends
%   results.tex        - \newcommand macros quoted in the report text
% so the report never drifts from the design files.
clear; close all; clc;
here = fileparts(mfilename('fullpath'));
root = fullfile(here, '..', '..');
figdir = fullfile(here, 'figures');
if ~exist(figdir, 'dir'), mkdir(figdir); end
R = struct();                       % results quoted in the report

col.theta = [0 0.4470 0.7410];      % arm
col.alpha = [0.8500 0.3250 0.0980]; % pendulum
col.u     = [0.4660 0.6740 0.1880]; % voltage
col.ref   = [0.2 0.2 0.2];          % reference / limits
col.est   = [0.4940 0.1840 0.5560]; % estimates

%% ---------------- CS1.A: s-domain design, then C(s) -> C(z) ----------------
cs1 = fullfile(root, 'Controllers', 'CS1A_frequency_continuous');
old = cd(cs1);
P1 = load_params('params_CS1A_candidate');
s = tf('s');

% Open-loop plant
R.olPoles = pole(P1.G_theta);
R.alphaZeros = zero(P1.G_alpha);

% Loop broken at the motor input: u = -(C_theta G_theta + C_alpha G_alpha) u
% Built in state space: tf products of these high-order factors are ill-conditioned
Gss = ss(P1.Ac, P1.Bc, P1.Cc, P1.Dc);
L = ss([P1.C_theta_s, P1.C_alpha_s])*Gss;
[Gm, Pm, Wcg, Wcp] = margin(L);
allm = allmargin(L);
R.Pm = Pm; R.Wcp = Wcp;
% Open-loop unstable plant: the loop is stable inside a band of gain factors
R.GmLow = max(allm.GainMargin(allm.GainMargin < 1)); R.GmUp = min(allm.GainMargin(allm.GainMargin > 1));
if isempty(R.GmUp), R.GmUp = Inf; end
R.Smax = norm(feedback(1, L), inf);
% Discrete loop as implemented: Tustin C(z) with the ZOH plant G(z)
Lz = ss([P1.C_theta_z, P1.C_alpha_z])*c2d(Gss, P1.ts, 'zoh');
amz = allmargin(Lz);
R.GmLowZ = max(amz.GainMargin(amz.GainMargin < 1)); R.GmUpZ = min(amz.GainMargin(amz.GainMargin > 1));
R.PmZ = min(amz.PhaseMargin(amz.PhaseMargin > 0)); R.DmZ = amz.DelayMargin(1);
R.clPolesZmax = max(abs(eig(feedback(ss(1), Lz))));
R.clPoles1 = pole(feedback(1, L));

% Closed loop r -> theta, r -> alpha, r -> u (continuous design model)
T_th = minreal(P1.F_s*P1.C_theta_s*P1.G_theta/(1 + L), 1e-6);
T_al = minreal(P1.F_s*P1.C_theta_s*P1.G_alpha/(1 + L), 1e-6);
T_u  = minreal(P1.F_s*P1.C_theta_s/(1 + L), 1e-6);
si = stepinfo(T_th, 'SettlingTimeThreshold', 0.02);
R.cs1_lin_OS = si.Overshoot; R.cs1_lin_ts = si.SettlingTime;

% Bode of the loop with margins
f = newfig([0 0 640 520]);
w = logspace(-1, 3, 2000);
[mag, ph] = bode(L, w); mag = squeeze(mag); ph = squeeze(ph);
ph = ph - 360*round((ph(end) + 180)/360);
subplot(2,1,1); semilogx(w, 20*log10(mag), 'Color', col.theta, 'LineWidth', 1.5); hold on
yline(0, '--', 'Color', col.ref); xline(Wcp, ':', 'Color', col.ref);
grid on; ylabel('|L(j\omega)| [dB]'); title('CS1.A loop transfer function at the motor input')
legend('|L(j\omega)|', '0 dB', sprintf('\\omega_c = %.1f rad/s', Wcp), 'Location', 'southwest')
subplot(2,1,2); semilogx(w, ph, 'Color', col.alpha, 'LineWidth', 1.5); hold on
yline(-180, '--', 'Color', col.ref); xline(Wcp, ':', 'Color', col.ref);
grid on; xlabel('Frequency \omega [rad/s]'); ylabel('\angle L(j\omega) [deg]')
legend('\angle L(j\omega)', '-180\circ', sprintf('PM = %.1f\\circ', Pm), 'Location', 'southwest')
save_fig(f, figdir, 'cs1a_bode');

% Root locus of a loop-gain multiplier k on L(s)
f = newfig([0 0 640 480]);
kk = [0, logspace(-3, 3, 3000)];
rl = rlocus(L, kk);
plot(real(rl.'), imag(rl.'), '.', 'Color', col.theta, 'MarkerSize', 3); hold on
po = pole(L); zo = tzero(L);
h1 = plot(real(po), imag(po), 'x', 'Color', col.alpha, 'MarkerSize', 10, 'LineWidth', 1.8);
h2 = plot(real(zo), imag(zo), 'o', 'Color', col.alpha, 'MarkerSize', 8, 'LineWidth', 1.5);
p = R.clPoles1; h3 = plot(real(p), imag(p), 'kp', 'MarkerSize', 11, 'MarkerFaceColor', 'y');
pl = rlocus(L, R.GmLow); h4 = plot(real(pl), imag(pl), 'd', 'Color', col.ref, 'MarkerSize', 7, 'MarkerFaceColor', col.ref);
xline(0, '-', 'Color', col.ref);
xlim([-90 20]); ylim([-50 50]); grid on
title('Root locus of k L(s) as the loop gain k is varied')
xlabel('Real axis \sigma [s^{-1}]'); ylabel('Imaginary axis \omega [rad/s]')
legend([h1 h2 h3 h4], 'Open-loop poles of L(s)', 'Open-loop zeros of L(s)', ...
    'Designed closed-loop poles (k = 1)', sprintf('Stability limit k = %.2f', R.GmLow), 'Location', 'northwest')
save_fig(f, figdir, 'cs1a_rlocus');

% Sensitivity
f = newfig([0 0 640 360]);
[mS] = bode(feedback(1, L), w); [mT] = bode(feedback(L, 1), w);
semilogx(w, 20*log10(squeeze(mS)), 'Color', col.theta, 'LineWidth', 1.5); hold on
semilogx(w, 20*log10(squeeze(mT)), 'Color', col.alpha, 'LineWidth', 1.5);
yline(20*log10(R.Smax), '--', 'Color', col.ref);
grid on; xlabel('Frequency \omega [rad/s]'); ylabel('Magnitude [dB]')
title('CS1.A sensitivity S(j\omega) and complementary sensitivity T(j\omega)')
legend('S = 1/(1+L)', 'T = L/(1+L)', sprintf('M_s = %.2f (%.1f dB)', R.Smax, 20*log10(R.Smax)), 'Location', 'southeast')
save_fig(f, figdir, 'cs1a_sensitivity');

% Continuous vs discrete controller (Tustin, Ts = 1 ms)
f = newfig([0 0 640 360]);
[mc] = bode(P1.C_alpha_s, w); [md] = bode(P1.C_alpha_z, w);
semilogx(w, 20*log10(squeeze(mc)), 'Color', col.theta, 'LineWidth', 2); hold on
semilogx(w, 20*log10(squeeze(md)), '--', 'Color', col.alpha, 'LineWidth', 1.5);
grid on; xlabel('Frequency \omega [rad/s]'); ylabel('|C_\alpha| [dB]')
title('Pendulum controller: C_\alpha(s) and its Tustin discretisation C_\alpha(z)')
legend('C_\alpha(s)', 'C_\alpha(z), T_s = 1 ms', 'Location', 'southeast')
save_fig(f, figdir, 'cs1a_c2d');

% Simulations (the same ctrl_CS1A block that runs on the QUBE)
S1 = struct();
for pl = {'linear', 'nonlinear'}
    assignin_all(P1);
    out = sim(['sim_CS1A_' pl{1}]);
    m = step_metrics(out.time, out.theta, out.alpha, out.u, P1.theta_step, P1.step_time);
    S1.(pl{1}) = struct('t', out.time, 'th', out.theta, 'al', out.alpha, 'u', out.u, 'm', m);
end
R.cs1 = S1;
step_figure(S1, P1, col, 'CS1.A', figdir, 'cs1a_sim', 6);
cd(old);

%% ---------------- CS2: discrete SFC + integral action + observer ----------------
cs2 = fullfile(root, 'Controllers', 'CS2_SFC_observer');
old = cd(cs2);
P2 = load_params('params_CS2');
R.F = P2.F; R.Fi = P2.Fi; R.Lo = P2.Lo; R.pz = P2.pz; R.po_z = P2.po_z;
R.ctrbRank = rank(ctrb(P2.A, P2.B)); R.obsvRank = rank(obsv(P2.A, P2.C));
R.olPolesZ = eig(P2.A);
% Gain robustness of the SFC loop (state feedback, no observer)
Ls = ss(P2.A, P2.B, P2.F, 0, P2.ts);
am = allmargin(Ls);
R.cs2GmLow = min(am.GainMargin(am.GainMargin < 1)); R.cs2GmUp = min(am.GainMargin(am.GainMargin > 1));
R.cs2Pm = min(am.PhaseMargin);
S2 = struct();
for pl = {'linear', 'nonlinear'}
    assignin_all(P2);
    out = sim(['sim_CS2_' pl{1}]);
    m = step_metrics(out.time, out.theta, out.alpha, out.u, P2.theta_step, P2.step_time);
    S2.(pl{1}) = struct('t', out.time, 'th', out.theta, 'al', out.alpha, 'u', out.u, 'm', m);
end
R.cs2 = S2;
step_figure(S2, P2, col, 'CS2', figdir, 'cs2_sim', 6);

% Pole map: SFC and observer poles inside the unit circle
f = newfig([0 0 520 480]);
th = linspace(0, 2*pi, 400); plot(cos(th), sin(th), '--', 'Color', col.ref); hold on
plot(real(R.olPolesZ), imag(R.olPolesZ), 'x', 'Color', col.ref, 'MarkerSize', 10, 'LineWidth', 1.5)
plot(real(P2.pz), imag(P2.pz), 'o', 'Color', col.theta, 'MarkerSize', 8, 'LineWidth', 1.5)
plot(real(P2.po_z), imag(P2.po_z), 's', 'Color', col.alpha, 'MarkerSize', 8, 'LineWidth', 1.5)
axis equal; grid on; xlim([0.85 1.02]); ylim([-0.08 0.08])
xlabel('Re(z)'); ylabel('Im(z)'); title('CS2 discrete-time pole locations (zoom near z = 1)')
legend('Unit circle', 'Open-loop poles of A', 'SFC poles e^{p T_s}', 'Observer poles', 'Location', 'southwest')
save_fig(f, figdir, 'cs2_zplane');
cd(old);

%% ---------------- Hardware: CS1.A run 04 (balancing with bumps) ----------------
H = load(fullfile(cs1, 'data_test_04.mat'), 'time', 'Vm', 'theta_rad', 'alpha_rad');
t = H.time(:); th = rad2deg(H.theta_rad(:)); al = rad2deg(H.alpha_rad(:)); v = H.Vm(:);
% Single-sample encoder read errors (|jump| > 90 deg in 1 ms) are replaced
% by the previous sample; they are SPI glitches, not motion.
bad = [false; abs(diff(th)) > 90]; R.hwGlitches = nnz(bad);
for k = find(bad).', th(k) = th(k-1); end
on = find(abs(al) < 20, 1);         % controller catches the pendulum
k = t >= t(on) + 2;                 % ignore the catch transient
R.hwT = t(end) - t(on); R.hwAlphaStd = std(al(k)); R.hwAlphaMax = max(abs(al(k)));
R.hwThetaStd = std(th(k)); R.hwVrms = rms(v(k));
f = newfig([0 0 720 600]);
ax(1) = subplot(3,1,1); plot(t, v, 'Color', col.u); grid on; ylabel('V_m(t) [V]'); legend('Motor voltage')
title('CS1.A on the QUBE-Servo 2 (run 04): balancing and bump rejection')
ax(2) = subplot(3,1,2); plot(t, th, 'Color', col.theta); grid on; ylabel('\theta(t) [deg]'); legend('Arm angle')
ax(3) = subplot(3,1,3); plot(t, al, 'Color', col.alpha); grid on; ylabel('\alpha(t) [deg]'); ylim([-20 20])
xlabel('Time [s]'); legend('Pendulum angle'); linkaxes(ax, 'x'); xlim([t(on) - 2, t(end)])
save_fig(f, figdir, 'hw_cs1a_run04');
% Zoom on the largest bump after the catch
[~, ib] = max(abs(al) .* k); tb = t(ib);
f = newfig([0 0 720 420]);
z = t > tb - 1 & t < tb + 4;
yyaxis left; plot(t(z), al(z), 'Color', col.alpha, 'LineWidth', 1.2); ylabel('\alpha(t) [deg]')
set(gca, 'YColor', col.alpha)
yyaxis right; plot(t(z), v(z), 'Color', col.u); ylabel('V_m(t) [V]'); set(gca, 'YColor', col.u)
grid on; xlabel('Time [s]'); title(sprintf('Zoom: recovery from a bump at t = %.1f s', tb))
legend('Pendulum angle \alpha', 'Motor voltage V_m')
after = al(t > tb & t < tb + 4);    % time until alpha stays within +/-2 deg
R.hwRecover = find(abs(after) > 2, 1, 'last')*mean(diff(t)); R.hwBumpPeak = abs(al(ib));
save_fig(f, figdir, 'hw_cs1a_bump');

%% ---------------- Write results.tex ----------------
fid = fopen(fullfile(here, 'results.tex'), 'w');
c = onCleanup(@() fclose(fid));
mac = @(n, v) fprintf(fid, '\\newcommand{\\%s}{%s}\n', n, v);
mac('KpTheta', sprintf('%.3f', P1.Kp_theta)); mac('KdTheta', sprintf('%.3f', P1.Kd_theta));
mac('KpAlpha', sprintf('%.2f', P1.Kp_alpha)); mac('KdAlpha', sprintf('%.3f', P1.Kd_alpha));
mac('PMcsA', sprintf('%.1f', R.Pm)); mac('WcpcsA', sprintf('%.1f', R.Wcp));
mac('GMlowcsA', sprintf('%.2f', R.GmLow)); mac('GMupcsA', sprintf('%.1f', R.GmUp));
mac('MscsA', sprintf('%.2f', R.Smax));
mac('GMlowcsAz', sprintf('%.2f', R.GmLowZ)); mac('GMupcsAz', sprintf('%.0f', R.GmUpZ)); mac('PMcsAz', sprintf('%.1f', R.PmZ));
mac('DMcsAz', sprintf('%.0f', R.DmZ)); mac('ZmaxcsA', sprintf('%.4f', R.clPolesZmax));
for pl = {'linear', 'nonlinear'}
    tag = upper(pl{1}(1));
    mac(['OScsA' tag], sprintf('%.1f', S1.(pl{1}).m.overshoot)); mac(['TscsA' tag], sprintf('%.2f', S1.(pl{1}).m.settling));
    mac(['UcsA' tag], sprintf('%.1f', S1.(pl{1}).m.peak_u)); mac(['AlcsA' tag], sprintf('%.1f', S1.(pl{1}).m.peak_alpha));
    mac(['OScsB' tag], sprintf('%.1f', S2.(pl{1}).m.overshoot)); mac(['TscsB' tag], sprintf('%.2f', S2.(pl{1}).m.settling));
    mac(['UcsB' tag], sprintf('%.1f', S2.(pl{1}).m.peak_u)); mac(['AlcsB' tag], sprintf('%.1f', S2.(pl{1}).m.peak_alpha));
end
mac('GMlowcsB', sprintf('%.2f', R.cs2GmLow)); mac('GMupcsB', sprintf('%.1f', R.cs2GmUp)); mac('PMcsB', sprintf('%.1f', R.cs2Pm));
mac('FcsB', mat2str(round(R.F, 3))); mac('FicsB', sprintf('%.3f', R.Fi));
mac('hwT', sprintf('%.0f', R.hwT)); mac('hwAlphaStd', sprintf('%.2f', R.hwAlphaStd));
mac('hwAlphaMax', sprintf('%.1f', R.hwAlphaMax)); mac('hwThetaStd', sprintf('%.1f', R.hwThetaStd));
mac('hwVrms', sprintf('%.2f', R.hwVrms)); mac('hwGlitches', sprintf('%d', R.hwGlitches));
mac('hwRecover', sprintf('%.1f', R.hwRecover)); mac('hwBumpPeak', sprintf('%.1f', R.hwBumpPeak));
save(fullfile(here, 'results.mat'), 'R');
disp(R)
for pl = {'linear', 'nonlinear'}
    fprintf('CS1A %-9s', pl{1}); disp(S1.(pl{1}).m)
    fprintf('CS2  %-9s', pl{1}); disp(S2.(pl{1}).m)
end
fprintf('CS1A closed-loop poles: %s\n', mat2str(R.clPoles1.', 3));
fprintf('Open-loop poles: %s\n', mat2str(R.olPoles.', 3));
fprintf('Gains: Kp_th %.3f Kd_th %.3f Kp_al %.3f Kd_al %.3f\n', P1.Kp_theta, P1.Kd_theta, P1.Kp_alpha, P1.Kd_alpha);
disp(P1.F_s); disp(R.Lo)

%% ---------------- helpers ----------------
function P = load_params(name)
% Run a params script in its own workspace and return every variable.
    run(name);
    clear name
    v = who; P = struct();
    for i = 1:numel(v), P.(v{i}) = eval(v{i}); end
end

function assignin_all(P)
% The Simulink models read their parameters from the base workspace.
    fn = fieldnames(P);
    for i = 1:numel(fn), assignin('base', fn{i}, P.(fn{i})); end
end

function f = newfig(pos)
    f = figure('Visible', 'off', 'Color', 'w', 'Position', pos);
    set(f, 'DefaultAxesFontSize', 10, 'DefaultLineLineWidth', 1.2);
end

function save_fig(f, d, name)
    exportgraphics(f, fullfile(d, [name '.pdf']), 'ContentType', 'vector');
    close(f);
end

function step_figure(S, P, col, label, figdir, name, tzoom)
% Arm, pendulum and voltage for the linear and nonlinear plants, plus a zoom
% on the arm transient with the +/-2 % settling band.
    r = rad2deg(P.theta_step);
    f = newfig([0 0 720 640]);
    subplot(3,1,1); hold on
    stairs([0 P.step_time P.Tsim], [0 r r], '--', 'Color', col.ref)
    plot(S.linear.t, rad2deg(S.linear.th), 'Color', col.theta)
    plot(S.nonlinear.t, rad2deg(S.nonlinear.th), ':', 'Color', col.alpha, 'LineWidth', 1.8)
    grid on; ylabel('\theta(t) [deg]'); title(sprintf('%s: %g\\circ arm step, simulated', label, r))
    legend('Reference r(t)', 'Linear plant', 'Nonlinear plant', 'Location', 'southeast')
    subplot(3,1,2); hold on
    plot(S.linear.t, rad2deg(S.linear.al), 'Color', col.theta)
    plot(S.nonlinear.t, rad2deg(S.nonlinear.al), ':', 'Color', col.alpha, 'LineWidth', 1.8)
    grid on; ylabel('\alpha(t) [deg]'); legend('Linear plant', 'Nonlinear plant')
    subplot(3,1,3); hold on
    plot(S.linear.t, S.linear.u, 'Color', col.theta)
    plot(S.nonlinear.t, S.nonlinear.u, ':', 'Color', col.alpha, 'LineWidth', 1.8)
    grid on; ylabel('V_m(t) [V]'); xlabel('Time [s]'); legend('Linear plant', 'Nonlinear plant')
    for a = findall(f, 'Type', 'axes')', xlim(a, [0 P.step_time + tzoom + 2]); end
    save_fig(f, figdir, name);

    f = newfig([0 0 720 380]); hold on
    t0 = P.step_time;
    patch([t0 t0+tzoom t0+tzoom t0], r*[0.98 0.98 1.02 1.02], [0.9 0.9 0.9], 'EdgeColor', 'none')
    plot(S.linear.t, rad2deg(S.linear.th), 'Color', col.theta)
    plot(S.nonlinear.t, rad2deg(S.nonlinear.th), ':', 'Color', col.alpha, 'LineWidth', 1.8)
    xline(t0 + S.linear.m.settling, '--', 'Color', col.theta);
    xline(t0 + S.nonlinear.m.settling, '--', 'Color', col.alpha);
    xlim([t0 t0 + tzoom]); ylim(r*[0.9 1.18]); grid on
    xlabel('Time [s]'); ylabel('\theta(t) [deg]'); title(sprintf('%s: zoom on the arm transient', label))
    legend('\pm2 % settling band', 'Linear plant', 'Nonlinear plant', ...
        sprintf('t_s linear = %.2f s', S.linear.m.settling), sprintf('t_s nonlinear = %.2f s', S.nonlinear.m.settling), ...
        'Location', 'southeast')
    save_fig(f, figdir, [name '_zoom']);
end
