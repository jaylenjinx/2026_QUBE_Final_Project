function build_templates(which, force)
%BUILD_TEMPLATES Generate the controller template folders (CS1A, CS1B, CS2).
%   BUILD_TEMPLATES builds every template. BUILD_TEMPLATES({'CS2'}) builds one.
%   Each folder gets the design file, the run script, the helpers, the single
%   MATLAB Function controller (ctrl_<CS>.slx, a subsystem file referenced by
%   every model), linear and nonlinear simulation models, and a hardware model
%   made from Hardware/CS01_RIP_QS2_SPI_T41_r2025b.slx.
%
%   It never overwrites a folder that already has a ctrl_<CS>.slx unless you
%   pass force = true, because that would discard your controller code and design.

if nargin < 1 || isempty(which), which = {'CS1A', 'CS1B', 'CS2'}; end
if nargin < 2, force = false; end

tools = fileparts(mfilename('fullpath'));
root  = fileparts(fileparts(tools));
src   = fullfile(tools, 'src');
hw_template = fullfile(root, 'Hardware', 'CS01_RIP_QS2_SPI_T41_r2025b.slx');
nl_source   = fullfile(root, 'MATLAB', 'sim_DP2_2026_SFC_Nonlinear.slx');

folders = struct('CS1A', 'CS1A_frequency_continuous', ...
                 'CS1B', 'CS1B_frequency_discrete', ...
                 'CS2',  'CS2_SFC_observer');

for i = 1:numel(which)
    cs  = which{i};
    dst = fullfile(root, 'Controllers', folders.(cs));
    if isfile(fullfile(dst, ['ctrl_' cs '.slx'])) && ~force
        error('build_templates:exists', ['%s already has a controller. Pass force = true ' ...
            'to rebuild it (this overwrites your design and controller code).'], cs);
    end
    if ~isfolder(dst), mkdir(dst); end
    fprintf('Building %s in %s\n', cs, dst);
    copy_files(cs, src, dst, root);
    old = cd(dst);
    cleanup = onCleanup(@() cd(old));
    evalin('base', sprintf('run(''%s'');', fullfile(dst, ['params_' cs '.m'])));
    build_controller(cs, src);
    build_sim(cs, 'linear', nl_source);
    build_sim(cs, 'nonlinear', nl_source);
    build_hardware(cs, hw_template);
    clear cleanup
end
end

%% Files ------------------------------------------------------------------
function copy_files(cs, src, dst, root)
files = {'qube_model.m', 'plot_response.m', 'step_metrics.m', ['params_' cs '.m']};
if startsWith(cs, 'CS1'), files{end+1} = 'block_coeffs.m'; end
for k = 1:numel(files)
    copyfile(fullfile(src, files{k}), fullfile(dst, files{k}));
end
write_text(fullfile(dst, ['run_' cs '.m']), strrep(read_text(fullfile(src, 'run_CS.m')), '__CS__', cs));

% Hardware model callbacks run these from the controller folder
hw = fullfile(root, 'Hardware');
copyfile(fullfile(hw, 'Hardware_data_save.m'), dst);
copyfile(fullfile(hw, 'exp_data_processing.m'), dst);
settings = read_text(fullfile(hw, 'Hardware_settings.m'));
settings = strrep(settings, sprintf('\r\n'), newline);
settings = regexprep(settings, '%% Add your own fixed variable here\s*$', ...
    sprintf(['%%%% Add your own fixed variable here\n' ...
             '%% Controller parameters: the same design file as the simulation\n' ...
             'run(''params_%s.m'');\n'], cs));
write_text(fullfile(dst, 'Hardware_settings.m'), settings);
end

%% Controller subsystem file (the single MATLAB Function block) -------------
function build_controller(cs, src)
name = ['ctrl_' cs];
close_if_open(name);
if isfile([name '.slx']), delete([name '.slx']); end
new_system(name, 'Subsystem');
inputs = {'r', 'theta', 'alpha', 'reset'};
for k = 1:numel(inputs)
    add_block('simulink/Sources/In1', [name '/' inputs{k}], ...
        'Position', [40 40+60*(k-1) 70 54+60*(k-1)]);
end
fb = [name '/Controller ' cs];
add_block('simulink/User-Defined Functions/MATLAB Function', fb, 'Position', [180 30 360 250]);
ch = sfroot().find('-isa', 'Stateflow.EMChart', 'Path', fb);
ch.Script = read_text(fullfile(src, ['ctrl_' cs(1:3) '.m']));
% Discrete at ts, so it samples the plant in simulation and matches the hardware rate
ch.ChartUpdate = 'DISCRETE';
ch.SampleTime  = 'ts';
n_in = numel(inputs);
data = ch.find('-isa', 'Stateflow.Data');
args = regexp(ch.Script, 'function[^=]*=\s*\w+\(([^)]*)\)', 'tokens', 'once');
args = strtrim(strsplit(args{1}, ','));
for k = n_in+1:numel(args)
    d = data(strcmp({data.Name}, args{k}));
    d.Scope = 'Parameter';
end
outs = {'u'};
if strcmp(cs, 'CS2'), outs{end+1} = 'x_hat'; end
for k = 1:numel(outs)
    add_block('simulink/Sinks/Out1', [name '/' outs{k}], 'Position', [440 60+60*(k-1) 470 74+60*(k-1)]);
    add_line(name, sprintf('Controller %s/%d', cs, k), [outs{k} '/1'], 'autorouting', 'on');
end
for k = 1:n_in
    add_line(name, [inputs{k} '/1'], sprintf('Controller %s/%d', cs, k), 'autorouting', 'on');
end
save_system(name, [name '.slx']);
close_system(name);
end

%% Simulation models ------------------------------------------------------
function build_sim(cs, plant, nl_source)
name = sprintf('sim_%s_%s', cs, plant);
close_if_open(name);
if isfile([name '.slx']), delete([name '.slx']); end
new_system(name);
set_param(name, 'StopTime', 'Tsim', 'Solver', 'ode45', 'MaxStep', 'ts', ...
    'RelTol', '1e-6', 'ReturnWorkspaceOutputs', 'on', 'SaveTime', 'off', 'SaveOutput', 'off');

add_block('simulink/Sources/Step', [name '/Arm reference'], 'Time', 'step_time', ...
    'Before', '0', 'After', 'theta_step', 'SampleTime', 'ts', 'Position', [40 40 70 70]);
add_block('simulink/Sources/Constant', [name '/Controller enabled'], 'Value', '0', ...
    'Position', [40 200 70 230]);
set_param([name '/Controller enabled'], 'Name', 'reset = 0');
ctrl = [name '/Controller'];
add_block('simulink/Ports & Subsystems/Subsystem Reference', ctrl, ...
    'ReferencedSubsystem', ['ctrl_' cs], 'Position', [180 40 300 230]);

if strcmp(plant, 'linear')
    p = [name '/Linear plant'];
    add_block('simulink/Continuous/State-Space', p, 'A', 'Ac', 'B', 'Bc', ...
        'C', 'eye(4)', 'D', 'zeros(4,1)', 'InitialCondition', 'x0', 'Position', [420 110 520 160]);
    x_src = 'Linear plant/1';
else
    load_system(nl_source);
    p = [name '/Nonlinear plant'];
    [~, src_model] = fileparts(nl_source);
    add_block([src_model '/Nonlinear Model'], p, 'Position', [420 100 520 170]);
    close_system(src_model, 0);
    set_nonlinear_ic(p);
    % The DP2 plant couples theta_dd and alpha_dd through an algebraic loop,
    % which Simulink solves; silence only that diagnostic.
    set_param(name, 'AlgebraicLoopMsg', 'none');
    add_block('simulink/Sinks/Terminator', [name '/y unused'], 'Position', [580 105 600 125]);
    add_line(name, 'Nonlinear plant/1', 'y unused/1');
    x_src = 'Nonlinear plant/2';
end
add_block('simulink/Signal Routing/Demux', [name '/x'], 'Outputs', '4', 'Position', [600 100 605 200]);
add_line(name, x_src, 'x/1', 'autorouting', 'on');
add_line(name, 'Controller/1', [get_param(p, 'Name') '/1'], 'autorouting', 'on');
add_line(name, 'Arm reference/1', 'Controller/1', 'autorouting', 'on');
add_line(name, 'x/1', 'Controller/2', 'autorouting', 'on');
add_line(name, 'x/2', 'Controller/3', 'autorouting', 'on');
add_line(name, 'reset = 0/1', 'Controller/4', 'autorouting', 'on');
for k = 3:4
    add_block('simulink/Sinks/Terminator', sprintf('%s/x%d unused', name, k), ...
        'Position', [660 100+30*k 680 120+30*k]);
    add_line(name, sprintf('x/%d', k), sprintf('x%d unused/1', k));
end

logs = {'time', 'Clock/1'; 'r', 'Arm reference/1'; 'theta', 'x/1'; 'alpha', 'x/2'; ...
        'u', 'Controller/1'; 'x', x_src};
add_block('simulink/Sources/Clock', [name '/Clock'], 'Position', [40 300 70 330]);
if strcmp(cs, 'CS2'), logs(end+1, :) = {'x_hat', 'Controller/2'}; end
for k = 1:size(logs, 1)
    add_block('simulink/Sinks/To Workspace', [name '/log ' logs{k, 1}], ...
        'VariableName', logs{k, 1}, 'SaveFormat', 'Array', 'SampleTime', 'ts', ...
        'Position', [760 40+50*k 840 60+50*k]);
    add_line(name, logs{k, 2}, ['log ' logs{k, 1} '/1'], 'autorouting', 'on');
end
save_system(name, [name '.slx']);
close_system(name);
end

function set_nonlinear_ic(p)
% Give the DP2 nonlinear plant's integrators the initial state x0.
% Position integrators feed the q1/q2 outports, velocity ones q1_d/q2_d.
map = {'q1', 'q1', 'x0(1)'; 'q1', 'q1_d', 'x0(3)'; 'q2', 'q2', 'x0(2)'; 'q2', 'q2_d', 'x0(4)'};
for k = 1:size(map, 1)
    port = [p '/' map{k, 1} '/' map{k, 2}];
    l = get_param(get_param(port, 'PortHandles').Inport, 'Line');
    blk = get_param(l, 'SrcBlockHandle');
    assert(strcmp(get_param(blk, 'BlockType'), 'Integrator'), 'Unexpected nonlinear plant layout');
    set_param(blk, 'InitialCondition', map{k, 3});
end
end

%% Hardware model ----------------------------------------------------------
function build_hardware(cs, hw_template)
name = ['hw_' cs];
close_if_open(name);
copyfile(hw_template, [name '.slx'], 'f');
load_system(name);
c = [name '/Controller'];
ref = [c '/Controller ' cs];
add_block('simulink/Ports & Subsystems/Subsystem Reference', ref, ...
    'ReferencedSubsystem', ['ctrl_' cs], 'Position', [520 160 640 320]);
add_block('simulink/Signal Routing/From', [c '/From reset'], 'GotoTag', 'Int_reset', ...
    'Position', [430 290 470 310]);
gates = {'  Enable', 1; 'Enable ', 2; ' Enable', 3};       % theta_ref, theta, alpha
for k = 1:size(gates, 1)
    add_line(c, [gates{k, 1} '/1'], sprintf('Controller %s/%d', cs, gates{k, 2}), 'autorouting', 'on');
end
add_line(c, 'From reset/1', sprintf('Controller %s/4', cs), 'autorouting', 'on');
add_line(c, sprintf('Controller %s/1', cs), 'Saturation/1', 'autorouting', 'on');
if strcmp(cs, 'CS2')
    add_block('simulink/Sinks/Terminator', [c '/x_hat unused'], 'Position', [700 290 720 310]);
    add_line(c, 'Controller CS2/2', 'x_hat unused/1');
end
save_system(name);
close_system(name);
end

%% Utilities ---------------------------------------------------------------
function close_if_open(name)
if bdIsLoaded(name), close_system(name, 0); end
end

function s = read_text(f)
s = fileread(f);
end

function write_text(f, s)
fid = fopen(f, 'w');
fwrite(fid, s);
fclose(fid);
end
