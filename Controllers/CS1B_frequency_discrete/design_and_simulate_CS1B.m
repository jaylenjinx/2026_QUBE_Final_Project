%% CS1B PID: simulations, disturbance test and optional root-locus screens
% Run this SCRIPT in the MATLAB Editor or from the Command Window.
% Does not build, deploy or run hardware. Does not close existing figures.
% Run as a script so Simulink can read the parameters in the base workspace.

%% User settings: change 0 to 1 to open the design screens
open_rltool = 1;             % 0 = simulations only; 1 = also open both loops
save_graphs = 0;             % 0 = display only; 1 = also save step plots as PNG
plot_rltool_figure = 1;      % 0 = skip; 1 = static root-locus + step figure
run_disturbance_test = 1;    % 0 = skip; 1 = linear constant-disturbance test

%% Load this folder's saved PID design
study_folder = fileparts(mfilename('fullpath'));
study_previous_path = path;
study_path_cleanup = onCleanup(@() path(study_previous_path));
addpath(study_folder, '-begin');
run(fullfile(study_folder, 'params_CS1B.m'));

% Same benchmark for CS1A and CS1B; these overrides affect simulation only.
theta_step = deg2rad(45);
step_time = 1;
Tsim = 30;
x0 = zeros(4,1);

%% Check full-order discrete stability and ideal reference tracking
P_test_z = ss(A, B, C, D, ts);
P_inner_test_z = feedback(P_test_z, ss(C_alpha_z), 1, 2);
T_feedback_test_z = feedback(P_inner_test_z * ss(C_theta_z), 1, 1, 1);
T_reference_test_z = T_feedback_test_z * ss(F_z);
CS1B_results = struct;
CS1B_results.sample_time = ts;
CS1B_results.reference_deg = rad2deg(theta_step);
CS1B_results.feedback_poles = pole(T_feedback_test_z);
CS1B_results.reference_poles = pole(T_reference_test_z);
CS1B_results.stable = isstable(T_feedback_test_z) && isstable(T_reference_test_z);
CS1B_results.largest_pole_magnitude = max(abs(CS1B_results.reference_poles));
CS1B_results.reference_gain = dcgain(T_reference_test_z(1,1));
assert(CS1B_results.stable, 'CS1B:unstable', 'Full-order digital model is unstable.');
fprintf('\nCS1B PID: Ts = %.4g s, reference = %.1f deg\n', ts, rad2deg(theta_step));
fprintf('Stable: %d; largest pole magnitude: %.10f; reference gain: %.8f\n', ...
    CS1B_results.stable, CS1B_results.largest_pole_magnitude, CS1B_results.reference_gain);

%% Actual controller block on the linear and nonlinear Simulink plants
plants = {'sim_CS1B_linear', 'Linear'; 'sim_CS1B_nonlinear', 'Nonlinear'};
fprintf('%-10s %9s %12s %12s %12s %10s  %s\n', 'Plant', 'OS [%]', ...
    'ts (2%) [s]', 'Error [deg]', 'max|a| [deg]', 'max|V| [V]', 'OS/settling');
for study_index = 1:size(plants,1)
    out = sim(fullfile(study_folder, [plants{study_index,1} '.slx']));
    m = step_metrics(out.time, out.theta, out.alpha, out.u, theta_step, step_time);
    result_key = lower(plants{study_index,2});
    CS1B_results.(result_key) = m;
    CS1B_results.(result_key).within_voltage_limit = m.peak_u <= u_max;
    CS1B_results.([result_key '_output']) = out;
    verdict = 'not met';
    if m.pass, verdict = 'met'; end
    fprintf('%-10s %9.3f %12.3f %12.3g %12.3f %10.3f  %s\n', ...
        plants{study_index,2}, m.overshoot, m.settling, m.final_error, ...
        m.peak_alpha, m.peak_u, verdict);
    plot_response(out, 'CS1B PID', plants{study_index,2}, theta_step, step_time, save_graphs);
end
% step_metrics.pass checks overshoot <15% and settling <5 s only.
% Final error and voltage are reported separately; no accuracy unit is assumed.

%% Persistent motor-input disturbance with zero reference (linear model)
if run_disturbance_test == 1
    K_feedback_test_z = [ss(C_theta_z), ss(C_alpha_z)];
    T_disturbance_test_z = feedback(P_test_z, K_feedback_test_z);
    t_dist = (0:ts:30)';
    d_dist = 0.2 * double(t_dist >= 2);
    y_dist = lsim(T_disturbance_test_z, d_dist, t_dist);
    CS1B_results.disturbance.time = t_dist;
    CS1B_results.disturbance.angles_rad = y_dist;
    CS1B_results.disturbance.voltage = d_dist;
    CS1B_results.disturbance.final_arm_offset_deg = rad2deg(y_dist(end,1));
    CS1B_results.disturbance.peak_arm_deviation_deg = max(abs(rad2deg(y_dist(:,1))));
    fprintf('0.2 V persistent disturbance at t=2 s: peak arm %.4f deg; final offset %.6g deg\n', ...
        CS1B_results.disturbance.peak_arm_deviation_deg, ...
        CS1B_results.disturbance.final_arm_offset_deg);
    figure('Name', 'CS1B PID disturbance rejection', 'Color', 'w');
    tiledlayout(2,1);
    nexttile; plot(t_dist, rad2deg(y_dist(:,1))); grid on;
    ylabel('Arm deviation [deg]'); title('CS1B: persistent 0.2 V motor-input disturbance');
    nexttile; plot(t_dist, rad2deg(y_dist(:,2))); grid on;
    ylabel('Pendulum [deg]'); xlabel('Time [s]');
end

%% Static presentation-ready plot of the saved effective-arm design
if plot_rltool_figure == 1
    CS1B_results.rltool_plot = plot_rltool_CS1B(save_graphs);
end

%% Optional Control System Designer sessions (rltool root-locus workflow)
if open_rltool == 1
    % CS1B: design directly around the ZOH-discretised plant in z.
    P_design = P_test_z;
    P_inner_design = feedback(P_design, ss(C_alpha_z), 1, 2);
    controlSystemDesigner('rlocus', tf(P_design(2,1)), C_alpha_z);
    controlSystemDesigner('rlocus', P_inner_design(1,1), ...
        C_theta_z, tf(1,1,ts), F_z);
    fprintf(['Design screens opened: pendulum-only and arm with pendulum feedback.\n' ...
        'The pendulum-only loop is not the complete stabilised system.\n' ...
        'GUI edits do not change saved parameters: export, save and rerun to validate.\n']);
end
% Results remain in CS1B_results; step plots are saved under figures/ only when save_graphs = 1.
% Small-signal and nonlinear nominal tests do not establish hardware performance.
clear study_path_cleanup
