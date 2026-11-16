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
% The controller blocks flip alpha for the QUBE's encoder (alpha = -alpha),
% while the simulation plants already use the model convention. The
% simulations therefore run on a temporary copy of the folder with that one
% line removed; the design files themselves are not changed.
old = cd(sim_copy(cs1, 'ctrl_CS1A'));
P1 = load_params('params_CS1A_PID');
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

%% ---------------- CS1.B: the same structure designed directly in z ----------------
cs1b = fullfile(root, 'Controllers', 'CS1B_frequency_discrete');
old = cd(sim_copy(cs1b, 'ctrl_CS1B'));
P1b = load_params('params_CS1B');
Gz = c2d(ss(P1b.Ac, P1b.Bc, P1b.Cc, P1b.Dc), P1b.ts, 'zoh');
Lbz = ss([P1b.C_theta_z, P1b.C_alpha_z])*Gz;
amb = allmargin(Lbz);
R.b_GmLow = max(amb.GainMargin(amb.GainMargin < 1)); R.b_GmUp = min(amb.GainMargin(amb.GainMargin > 1));
R.b_Pm = min(amb.PhaseMargin(amb.PhaseMargin > 0));
R.b_clPoles = log(eig(feedback(ss(1), Lbz)))/P1b.ts;   % equivalent s-plane poles
S1b = struct();
for pl = {'linear', 'nonlinear'}
    assignin_all(P1b);
    out = sim(['sim_CS1B_' pl{1}]);
    m = step_metrics(out.time, out.theta, out.alpha, out.u, P1b.theta_step, P1b.step_time);
    S1b.(pl{1}) = struct('t', out.time, 'th', out.theta, 'al', out.alpha, 'u', out.u, 'm', m);
end
step_figure(S1b, P1b, col, 'CS1.B', figdir, 'cs1b_sim', 8);
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

% Demo feedback: jitter while balancing. The real ctrl_CS2 code holds r = 0 on
% the discrete plant with encoder quantisation (2048 counts/rev); only the
% observer poles change. Every other gain is the submitted design.
% ctrl_CS2.slx shadows the .m of the same name, so run a renamed copy of the code
jd = fullfile(tempdir, 'task5_jitter'); if ~exist(jd, 'dir'), mkdir(jd); end
copyfile(fullfile(root, 'Controllers', 'tools', 'src', 'ctrl_CS2.m'), fullfile(jd, 'cs2_code.m'));
addpath(jd); rehash
q = 2*pi/2048;
obs_sets = {[-90 -95 -100 -105], [-45 -50 -55 -60], [-30 -33 -36 -39]};
R.jit = zeros(numel(obs_sets), 4);
f = newfig([0 0 720 420]); hold on
for i = 1:numel(obs_sets)
    Lo_i = place(P2.A', P2.C', exp(obs_sets{i}*P2.ts))';
    [u, th, al] = quantised_hold(P2, Lo_i, q, 6);
    k = (numel(u) - 3000 + 1):numel(u);   % last 3 s
    gm = gain_band(P2, Lo_i);
    R.jit(i, :) = [rms(u(k)), max(abs(diff(u(k)))), gm, rad2deg(std(al(k)))];
    if i < 3, plot((0:numel(u)-1)*P2.ts, u, 'LineWidth', 0.8); end
end
xlim([3 4]); grid on; xlabel('Time [s]'); ylabel('V_m [V]')
title('CS2 holding r = 0 with quantised encoders: voltage jitter')
legend(sprintf('Observer %d to %d s^{-1} (submitted)', obs_sets{1}([1 end])), ...
    sprintf('Observer %d to %d s^{-1}', obs_sets{2}([1 end])), 'Location', 'southeast')
save_fig(f, figdir, 'cs2_jitter');
rmpath(jd);
cd(old);

%% ---------------- Hardware: CS1.A (arm PID) runs 06 and 07 ----------------
% The reference was set by hand in external mode and is not logged, so each
% step's target is taken as the nearest of the commanded values below.
H = load_hw(fullfile(cs1, 'data_test_07.mat'));
targets = [-110 -90 -45 0 45 90 110];
t = H.t; th = H.th; al = H.al; v = H.v;
% Plateaus: the arm stays within 3 deg for at least 2 s
seg = []; i0 = find(abs(al) < 20 & t > 10, 1) + 1500;
while i0 < numel(t) - 2000
    j = i0; while j < numel(t) && abs(th(j) - th(i0)) < 3, j = j + 1; end
    if t(j) - t(i0) > 2, seg(end+1, :) = [i0 j-1]; end %#ok<AGROW>
    i0 = j + 1;
end
steps = [];
for n = 2:size(seg, 1)
    a = seg(n-1, :); b = seg(n, :);
    r0 = targets(abs(targets - mean(th(a(1):a(2)))) == min(abs(targets - mean(th(a(1):a(2))))));
    r1 = targets(abs(targets - mean(th(b(1):b(2)))) == min(abs(targets - mean(th(b(1):b(2))))));
    if r1 == r0 || t(b(2)) > 66, continue; end
    p0 = median(th(a(1):max(a(1), a(2)-500)));
    ks = a(1) - 1 + find(abs(th(a(1):a(2)) - p0) <= 0.5, 1, 'last');   % first motion
    kk = ks:b(2); d = r1 - r0; y = (th(kk) - r0)/d;
    os = max(0, 100*(max(y) - 1));
    out = find(abs(th(kk) - r1) > 0.02*abs(d), 1, 'last');
    ts_ = (out)*mean(diff(t));
    ess = mean(th(b(2)-1000:b(2))) - r1;
    steps(end+1, :) = [r0 r1 os ts_ ess max(abs(al(kk))) max(abs(v(kk)))]; %#ok<AGROW>
end
R.hwSteps = steps;
f = newfig([0 0 720 600]);
tl = [t(seg(1,1)) - 1, 66];
ax(1) = subplot(3,1,1); plot(t, th, 'Color', col.theta); hold on
for n = 1:size(steps,1), yline(steps(n,2), ':', 'Color', col.ref); end
grid on; ylabel('\theta(t) [deg]'); legend('Arm angle', 'Commanded angles', 'Location', 'northwest')
title('CS1.A (arm PID) on the QUBE-Servo 2, run 07: arm steps')
ax(2) = subplot(3,1,2); plot(t, al, 'Color', col.alpha); grid on; ylabel('\alpha(t) [deg]'); ylim([-12 12])
legend('Pendulum angle')
ax(3) = subplot(3,1,3); plot(t, v, 'Color', col.u); grid on; ylabel('V_m(t) [V]'); xlabel('Time [s]'); ylim([-4 4])
legend('Motor voltage'); linkaxes(ax, 'x'); xlim(tl)
save_fig(f, figdir, 'hw_cs1a_steps');
% Zoom on the -45 -> +90 step (the largest move with a settled start)
[~, n] = max(abs(steps(:,2) - steps(:,1)) .* (steps(:,1) == -45));
f = newfig([0 0 720 380]);
k = find(t > t(seg(n,2)) - 1 & t < t(seg(n,2)) + 7);
r0 = steps(n,1); r1 = steps(n,2);
patch([t(k(1)) t(k(end)) t(k(end)) t(k(1))], r1 + 0.02*abs(r1-r0)*[-1 -1 1 1], [0.9 0.9 0.9], 'EdgeColor', 'none'); hold on
plot(t(k), th(k), 'Color', col.theta, 'LineWidth', 1.3); grid on
xlabel('Time [s]'); ylabel('\theta(t) [deg]')
title(sprintf('Hardware step %+d\\circ \\rightarrow %+d\\circ: M_p = %.1f %%, t_s = %.2f s', r0, r1, steps(n,3), steps(n,4)))
legend('\pm2 % band', 'Arm angle', 'Location', 'southeast'); xlim(t(k([1 end])))
save_fig(f, figdir, 'hw_cs1a_step_zoom');
R.hwStepZoom = n;
% Bump at the end of run 07, before the final hard push
kb = t > 66 & t < 75.5;
[R.hwBumpPeak, ib] = max(abs(al) .* kb);

% Run 06: holding r = 0 for 45 s. The arm limit cycle is friction + integral.
H6 = load_hw(fullfile(cs1, 'data_test_06.mat'));
k = H6.t > 20;
th6 = H6.th(k) - mean(H6.th(k)); t6 = H6.t(k);
R.lcAmp = (max(th6) - min(th6))/2;
zc = find(th6(1:end-1) < 0 & th6(2:end) >= 0);
zc = zc([true; diff(zc) > 200]);                  % ignore quantisation chatter
R.lcPeriod = mean(diff(t6(zc)));
R.lcAlphaStd = std(H6.al(k)); R.lcVrms = rms(H6.v(k));
f = newfig([0 0 720 420]);
ax6(1) = subplot(2,1,1); plot(H6.t, H6.th, 'Color', col.theta); grid on; ylabel('\theta(t) [deg]')
title('CS1.A (arm PID) holding r = 0 on the QUBE, run 06'); legend('Arm angle')
ax6(2) = subplot(2,1,2); plot(H6.t, H6.v, 'Color', col.u); grid on; ylabel('V_m(t) [V]'); xlabel('Time [s]')
legend('Motor voltage'); linkaxes(ax6, 'x'); xlim([20 45]); ylim(ax6(1), [-6 6]); ylim(ax6(2), [-2 2])
save_fig(f, figdir, 'hw_cs1a_hold');

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
mac('hwBumpPeak', sprintf('%.1f', R.hwBumpPeak));
mac('lcAmp', sprintf('%.1f', R.lcAmp)); mac('lcPeriod', sprintf('%.1f', R.lcPeriod));
mac('lcAlphaStd', sprintf('%.2f', R.lcAlphaStd)); mac('lcVrms', sprintf('%.2f', R.lcVrms));
n = R.hwStepZoom; mac('hwZoomFrom', sprintf('%+d', R.hwSteps(n,1))); mac('hwZoomTo', sprintf('%+d', R.hwSteps(n,2)));
mac('hwZoomOS', sprintf('%.1f', R.hwSteps(n,3))); mac('hwZoomTs', sprintf('%.2f', R.hwSteps(n,4)));
% Hardware step table rows
fid2 = fopen(fullfile(here, 'hw_steps.tex'), 'w');
for n = 1:size(R.hwSteps, 1)
    fprintf(fid2, '$%+d^\\circ\\to%+d^\\circ$&%.1f&%.2f&%+.1f&%.1f&%.1f\\\\\n', R.hwSteps(n, :));
end
fclose(fid2);
for pl = {'linear', 'nonlinear'}
    tag = upper(pl{1}(1));
    mac(['OScsAb' tag], sprintf('%.1f', S1b.(pl{1}).m.overshoot)); mac(['TscsAb' tag], sprintf('%.2f', S1b.(pl{1}).m.settling));
    mac(['UcsAb' tag], sprintf('%.1f', S1b.(pl{1}).m.peak_u)); mac(['AlcsAb' tag], sprintf('%.1f', S1b.(pl{1}).m.peak_alpha));
end
mac('GMlowcsAb', sprintf('%.2f', R.b_GmLow)); mac('GMupcsAb', sprintf('%.0f', R.b_GmUp)); mac('PMcsAb', sprintf('%.1f', R.b_Pm));
names = {'Fast', 'Mid', 'Slow'};
for i = 1:3
    mac(['jitRms' names{i}], sprintf('%.2f', R.jit(i,1))); mac(['jitStep' names{i}], sprintf('%.2f', R.jit(i,2)));
    mac(['jitGm' names{i}], sprintf('%.2f', R.jit(i,3))); mac(['jitAl' names{i}], sprintf('%.2f', R.jit(i,4)));
end
save(fullfile(here, 'results.mat'), 'R');
disp(R)
for pl = {'linear', 'nonlinear'}
    fprintf('CS1A %-9s', pl{1}); disp(S1.(pl{1}).m)
    fprintf('CS2  %-9s', pl{1}); disp(S2.(pl{1}).m)
end
fprintf('CS1A closed-loop poles: %s\n', mat2str(R.clPoles1.', 3));
fprintf('Open-loop poles: %s\n', mat2str(R.olPoles.', 3));
fprintf('Gains: Kp_th %.3f Kd_th %.3f Kp_al %.3f Kd_al %.3f\n', P1.Kp_theta, P1.Kd_theta, P1.Kp_alpha, P1.Kd_alpha);
disp(zpk(P1.C_theta_s)); disp(zpk(P1.C_alpha_s)); disp(zpk(P1.F_s)); disp(R.Lo)
fprintf('bT %s aT %s\nbA %s aA %s\nbF %s aF %s\n', mat2str(P1.bT, 6), mat2str(P1.aT, 6), mat2str(P1.bA, 6), mat2str(P1.aA, 6), mat2str(P1.bF, 4), mat2str(P1.aF, 6));
fprintf('CS1B poles (s-equiv): %s\n', mat2str(R.b_clPoles.', 3));
for pl = {'linear', 'nonlinear'}, fprintf('CS1B %-9s', pl{1}); disp(S1b.(pl{1}).m), end
disp('hw steps [r0 r1 OS ts ess max|al| max|V|]'); disp(R.hwSteps)
fprintf('limit cycle amp %.2f deg period %.2f s\n', R.lcAmp, R.lcPeriod);
disp('jitter [rms u, max du, gain-low, std alpha]'); disp(R.jit)

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

function d = sim_copy(src, ctrl)
% Copy a controller folder and remove the QUBE's alpha flip from the copy, so
% the simulation plants (model sign convention) see the right sign.
    [~, name] = fileparts(src);
    d = fullfile(tempdir, ['task5_' name]);
    if exist(d, 'dir'), rmdir(d, 's'); end
    copyfile(src, d);
    bdclose('all');
    load_system(fullfile(d, [ctrl '.slx']));
    ch = find(sfroot, '-isa', 'Stateflow.EMChart', 'Path', [ctrl '/controller']);
    if isempty(ch), ch = find(sfroot, '-isa', 'Stateflow.EMChart'); end
    for c = ch'
        c.Script = regexprep(c.Script, '\n\s*alpha\s*=\s*-alpha;?[^\n]*', '');
    end
    save_system(ctrl); close_system(ctrl);
end

function H = load_hw(file)
% Hardware log in degrees, with SPI read errors removed: samples more than
% 90 deg from the local median are replaced by the previous sample.
    S = load(file, 'time', 'Vm', 'theta_rad', 'alpha_rad');
    H.t = S.time(:); H.th = rad2deg(S.theta_rad(:)); H.al = rad2deg(S.alpha_rad(:)); H.v = S.Vm(:);
    bad = abs(H.th - movmedian(H.th, 21)) > 90;
    for k = find(bad).', H.th(k) = H.th(max(k-1, 1)); end
end

function [u, th, al] = quantised_hold(P, Lo, q, T)
% Run the real ctrl_CS2 code against the discrete linear plant with r = 0,
% quantised encoder readings and a 2 deg initial pendulum tilt.
    clear cs2_code
    n = round(T/P.ts); x = [0; 2*pi/180; 0; 0];
    u = zeros(n,1); th = u; al = u;
    for k = 1:n
        y = q*round(P.C*x/q);
        u(k) = cs2_code(0, y(1), y(2), k == 1, P.F, P.Fi, Lo, P.A, P.B, P.C, P.ts, ...
            P.ref_tau, P.int_band, zeros(4,1), P.u_max, 1);
        th(k) = x(1); al(k) = x(2);
        x = P.A*x + P.B*u(k);
    end
end

function gl = gain_band(P, Lo)
% Lowest motor-gain factor k for which plant + observer-based SFC stays stable.
    ks = 0.2:0.01:1; gl = NaN;
    for k = ks
        % closed loop: plant x, integrator xi, observer xh
        Acl = [P.A, zeros(4,1), -k*P.B*P.F;
               P.ts*[1 0 0 0], 1, zeros(1,4);
               Lo*P.C, -P.B*P.Fi, P.A - P.B*P.F - Lo*P.C];
        Acl(1:4, 5) = -k*P.B*P.Fi;
        if max(abs(eig(Acl))) < 1, gl = k; return, end
    end
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
