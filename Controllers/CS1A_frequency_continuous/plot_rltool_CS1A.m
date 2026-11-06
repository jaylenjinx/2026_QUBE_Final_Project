function result = plot_rltool_CS1A(save_graphs)
%PLOT_RLTOOL_CS Saved-design root locus and filtered reference step response.
%   plot_rltool_CS1A       displays the figure without saving.
%   plot_rltool_CS1A(1)    also saves figures/CS1A_PID_rltool.png.
%   result = plot_rltool_CS1A(0) returns the models, poles and metrics as well.
%
% Equivalent architecture to the EFFECTIVE-ARM Control System Designer screen:
% pendulum feedback stays fixed; the signed saved arm PID is multiplied by a
% positive scalar k. The saved design is k=1, not an unsigned replacement for
% the arm gain. The reference filter affects the step response, not the locus.
% This function reads saved parameters; it does not run Simulink or hardware.
% MATLAB reference: https://www.mathworks.com/help/control/ref/dynamicsystem.rlocus.html

if nargin < 1, save_graphs = false; end
validateattributes(save_graphs, {'numeric','logical'}, {'scalar','real','finite'});
assert(save_graphs == 0 || save_graphs == 1, 'CS1A:saveOption', ...
    'Use 0 to display only, or 1 to save the PNG as well.');
plot_folder = fileparts(mfilename('fullpath'));
previous_path = path;
path_cleanup = onCleanup(@() path(previous_path));
addpath(plot_folder, '-begin');
run(fullfile(plot_folder, 'params_CS1A_PID.m'));

% Preserve every plant/controller state for the selected feedback check.
P_design = ss(Ac, Bc, Cc, Dc);
C_pendulum = ss(C_alpha_s);
C_arm = ss(C_theta_s);
F_reference = ss(F_s);
P_inner = feedback(P_design, C_pendulum, 1, 2);
L_arm = P_inner(1,1) * C_arm;
T_feedback = feedback(P_inner * C_arm, 1, 1, 1);
T_reference = T_feedback * F_reference;
selected_poles = pole(T_feedback);
assert(isstable(T_feedback) && isstable(T_reference), 'CS1A:unstable', ...
    'The saved complete feedback/reference model is unstable.');

% Numeric rlocus output lets us draw ordinary axes inside tiledlayout.
% MATLAB chooses the positive gain samples adaptively; include k=1 exactly.
[~, gains] = rlocus(L_arm);
gains = unique([0, reshape(gains,1,[]), 1]);
gains = gains(isfinite(gains) & gains >= 0);
roots_by_gain = rlocus(L_arm, gains);

fig = figure('Name', 'CS1A PID: root locus and reference step', ...
    'Color', 'w', 'Position', [80 100 1300 560]);
layout = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
ax_locus = nexttile(layout,1);
hold(ax_locus,'on');
branches = plot(ax_locus, real(roots_by_gain.'), imag(roots_by_gain.'), ...
    'Color', [0 0.4470 0.7410], 'LineWidth', 1.3);
open_poles = pole(L_arm);
open_zeros = zero(L_arm);
h_poles = plot(ax_locus, real(open_poles), imag(open_poles), 'x', ...
    'Color', [0.85 0.15 0.10], 'MarkerSize', 9, 'LineWidth', 1.5);
h_zeros = plot(ax_locus, real(open_zeros), imag(open_zeros), 'o', ...
    'Color', [0 0.4470 0.7410], 'MarkerSize', 8, 'LineWidth', 1.4);
h_selected = plot(ax_locus, real(selected_poles), imag(selected_poles), 's', ...
    'Color', [0.55 0.1 0.75], 'MarkerFaceColor', [0.55 0.1 0.75], ...
    'MarkerSize', 7, 'LineWidth', 1.1);
boundary = xline(ax_locus, 0, '--', 'Color', [0.35 0.35 0.35], 'LineWidth', 1);
boundary_label = 'Stability boundary: Re(s) = 0';
% Frame around the plant/controller poles, rather than remote high-gain branches.
features = [pole(L_arm); selected_poles];
span = max(real(features))-min(real(features));
pad = max(5, 0.15*span);
xlim(ax_locus, [min(real(features))-pad, max(real(features))+pad]);
yspan = max(10, 1.25*max(abs(imag(features))));
ylim(ax_locus, [-yspan yspan]);
xlabel(ax_locus, 'Real axis [1/s]');
ylabel(ax_locus, 'Imaginary axis [1/s]');
title(ax_locus, 'CS1A: arm root locus in the s-plane');

grid(ax_locus,'on');
legend(ax_locus, [branches(1), h_poles, h_zeros, h_selected, boundary], ...
    {'Root locus: k >= 0', 'Open-loop poles', 'Open-loop zeros', ...
     'Saved feedback poles: k = 1', boundary_label}, ...
    'Location', 'southoutside', 'FontSize', 10);

ax_step = nexttile(layout,2);
time = (0:ts:8)';
[response, time] = step(T_reference(1,1), time);
plot(ax_step, time, squeeze(response), 'Color', [0 0.4470 0.7410], 'LineWidth', 1.7);
hold(ax_step,'on');
yline(ax_step, 1, '--', 'Color', [0.25 0.25 0.25]);
yline(ax_step, [0.98 1.02], ':', 'Color', [0.55 0.55 0.55]);
grid(ax_step,'on');
xlabel(ax_step, 'Time after unit command [s]');
ylabel(ax_step, 'Arm angle / reference');
title(ax_step, 'Both feedback loops + saved reference filter');
info = stepinfo(T_reference(1,1), 'SettlingTimeThreshold', 0.02);
title(layout, sprintf('CS1A PID | overshoot %.2f%% | 2%% settling %.3f s', ...
    info.Overshoot, info.SettlingTime), 'FontWeight', 'bold');
set([ax_locus ax_step], 'FontSize', 12);

result.figure = fig;
result.open_loop = L_arm;
result.feedback_model = T_feedback;
result.reference_model = T_reference;
result.feedback_poles = selected_poles;
result.reference_poles = pole(T_reference);
result.stable = isstable(T_feedback) && isstable(T_reference);
result.metrics = info;
result.gains = gains;
result.root_locus = roots_by_gain;
if save_graphs
    figure_folder = fullfile(plot_folder, 'figures');
    if ~isfolder(figure_folder), mkdir(figure_folder); end
    result.png_path = fullfile(figure_folder, 'CS1A_PID_rltool.png');
    exportgraphics(fig, result.png_path, 'Resolution', 300);
end
end
