function plot_response(out, cs_name, plant_name, theta_step, step_time)
%PLOT_RESPONSE Closed-loop plots for one simulation run, saved to figures/.
%   Arm angle with reference, pendulum angle and motor voltage; a zoom on the
%   step; and, when the controller logs x_hat (CS2), true vs estimated states.
t = out.time;  r = out.r;  th = out.theta;  al = out.alpha;  u = out.u;

fig_dir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~isfolder(fig_dir), mkdir(fig_dir); end
tag = sprintf('%s_%s', cs_name, lower(plant_name));

c_ref = [0.25 0.25 0.25];  c_th = [0 0.4470 0.7410];
c_al = [0.8500 0.3250 0.0980];  c_u = [0.4660 0.6740 0.1880];

f1 = figure('Color', 'w', 'Position', [100 100 800 700]);
tiledlayout(3, 1, 'TileSpacing', 'compact');
nexttile
plot(t, rad2deg(r), '--', 'Color', c_ref, 'LineWidth', 1.2); hold on
plot(t, rad2deg(th), 'Color', c_th, 'LineWidth', 1.5);
grid on; ylabel('\theta(t) [deg]'); legend('\theta^*', '\theta', 'Location', 'southeast');
title(sprintf('%s, %s plant', cs_name, lower(plant_name)));
nexttile
plot(t, rad2deg(al), 'Color', c_al, 'LineWidth', 1.5);
grid on; ylabel('\alpha(t) [deg]'); legend('\alpha', 'Location', 'northeast');
nexttile
plot(t, u, 'Color', c_u, 'LineWidth', 1.5);
grid on; ylabel('V_m(t) [V]'); xlabel('Time [s]'); legend('V_m', 'Location', 'northeast');
save_png(f1, fullfile(fig_dir, [tag '_response.png']));

f2 = figure('Color', 'w', 'Position', [100 100 800 450]);
w = t >= step_time - 0.5 & t <= step_time + 6;
plot(t(w), rad2deg(r(w)), '--', 'Color', c_ref, 'LineWidth', 1.2); hold on
plot(t(w), rad2deg(th(w)), 'Color', c_th, 'LineWidth', 1.5);
yline(rad2deg(theta_step)*[0.98 1.02], ':', 'Color', [0.5 0.5 0.5]);
grid on; xlabel('Time [s]'); ylabel('\theta(t) [deg]');
legend('\theta^*', '\theta', '\pm2% band', 'Location', 'southeast');
title(sprintf('%s, %s plant: step response zoom', cs_name, lower(plant_name)));
save_png(f2, fullfile(fig_dir, [tag '_step_zoom.png']));

if isprop(out, 'x_hat') || any(strcmp(out.who, 'x_hat'))
    x = as_columns(out.x, 4);  xh = as_columns(out.x_hat, 4);
    names = {'\theta [deg]', '\alpha [deg]', '\theta dot [deg/s]', '\alpha dot [deg/s]'};
    f3 = figure('Color', 'w', 'Position', [100 100 800 800]);
    tiledlayout(4, 1, 'TileSpacing', 'compact');
    for i = 1:4
        nexttile
        plot(t, rad2deg(x(:,i)), 'Color', c_th, 'LineWidth', 1.5); hold on
        plot(t, rad2deg(xh(:,i)), '--', 'Color', c_al, 'LineWidth', 1.5);
        grid on; ylabel(names{i}); legend('true', 'estimate', 'Location', 'best');
    end
    xlabel('Time [s]');
    nexttile(1); title(sprintf('%s, %s plant: true vs estimated states', cs_name, lower(plant_name)));
    save_png(f3, fullfile(fig_dir, [tag '_estimation.png']));
end
end

function v = as_columns(v, n)
% Logged vectors come back as N-by-n or, from a MATLAB Function block, n-by-1-by-N.
v = squeeze(v);
if size(v, 1) == n && size(v, 2) ~= n, v = v.'; end
end

function save_png(f, file)
% Save without the interactive axes toolbar (avoids an export warning).
for ax = findall(f, 'Type', 'axes')'
    ax.Toolbar.Visible = 'off';
end
exportgraphics(f, file, 'Resolution', 200);
end
