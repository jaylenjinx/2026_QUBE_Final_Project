function add_ref_sequence(model)
%ADD_REF_SEQUENCE Replace a hardware model's constant arm reference with a
% timed step sequence, and log the reference.
%
%   add_ref_sequence('path/to/hw_CS2.slx')
%
% The constant "theta ref [deg]" block is replaced by a "Reference
% sequence" subsystem:
%   - "Manual ref [deg]": the reference used while the sequence is off
%     (the old constant, still editable in external mode).
%   - "Run step sequence": a manual switch. Flip it to 1 in external mode
%     and the reference steps through ref_seq_deg, holding each value for
%     ref_hold_s seconds, then stays on the last value. Flip it back to 0
%     to return to the manual reference; flipping it to 1 again restarts
%     the sequence from the beginning.
% ref_seq_deg and ref_hold_s come from ref_sequence_settings.m, which must
% run before the build (from Hardware_settings.m or the model's InitFcn).
%
% The reference is logged as theta_ref_deg (degrees) at the same rate as
% theta_rad, alpha_rad, Vm and time, and is saved with them by
% Hardware_data_save.m.

load_system(model);
[~, n] = fileparts(model);
old = [n '/theta ref' newline '[deg]'];
pos = get_param(old, 'Position');
r_manual = get_param(old, 'Value');

ph  = get_param(old, 'PortHandles');
ln  = get_param(ph.Outport, 'Line');
dst = get_param(ln, 'DstPortHandle');
delete_line(ln);
delete_block(old);

%% Reference subsystem
sub = [n '/Reference sequence'];
add_block('built-in/Subsystem', sub, ...
    'Position', [pos(1)-95, pos(2)-20, pos(3)+20, pos(4)+20]);
add_block('simulink/Sources/Constant', [sub '/Manual ref [deg]'], ...
    'Value', r_manual, 'Position', [20 20 80 50]);
add_block('simulink/Sources/Constant', [sub '/Off'], ...
    'Value', '0', 'Position', [20 80 50 100]);
add_block('simulink/Sources/Constant', [sub '/On'], ...
    'Value', '1', 'Position', [20 120 50 140]);
add_block('simulink/Signal Routing/Manual Switch', [sub '/Run step sequence'], ...
    'Position', [100 90 135 130]);                 % starts on the upper input (Off)
add_block('simulink/Sources/Digital Clock', [sub '/Clock'], ...
    'SampleTime', 'ts', 'Position', [20 170 60 190]);
add_block('simulink/User-Defined Functions/MATLAB Function', [sub '/ref_seq'], ...
    'Position', [200 40 320 200]);
add_block('built-in/Outport', [sub '/theta_ref_deg'], 'Position', [380 110 410 130]);

rt = sfroot;
ch = rt.find('-isa', 'Stateflow.EMChart', 'Path', [sub '/ref_seq']);
ch.Script = sprintf([ ...
 'function r = ref_seq(r_manual, run, t, ref_seq_deg, ref_hold_s)\n' ...
 '%%REF_SEQ Timed arm step sequence, started by the "Run step sequence" switch.\n' ...
 'persistent t0 active\n' ...
 'if isempty(t0)\n' ...
 '    t0 = 0;\n' ...
 '    active = false;\n' ...
 'end\n' ...
 'if run > 0.5\n' ...
 '    if ~active                 %% switch just turned on: restart the sequence\n' ...
 '        t0 = t;\n' ...
 '        active = true;\n' ...
 '    end\n' ...
 '    k = floor((t - t0)/ref_hold_s) + 1;\n' ...
 '    k = min(max(k, 1), numel(ref_seq_deg));\n' ...
 '    r = ref_seq_deg(k);\n' ...
 'else\n' ...
 '    active = false;\n' ...
 '    r = r_manual;\n' ...
 'end\n']);
d = ch.find('-isa', 'Stateflow.Data', 'Name', 'ref_seq_deg'); d.Scope = 'Parameter'; d.Tunable = false;
d = ch.find('-isa', 'Stateflow.Data', 'Name', 'ref_hold_s');  d.Scope = 'Parameter'; d.Tunable = false;

add_line(sub, 'Manual ref [deg]/1', 'ref_seq/1');
add_line(sub, 'Off/1', 'Run step sequence/1');
add_line(sub, 'On/1',  'Run step sequence/2');
add_line(sub, 'Run step sequence/1', 'ref_seq/2');
add_line(sub, 'Clock/1', 'ref_seq/3');
add_line(sub, 'ref_seq/1', 'theta_ref_deg/1');

%% Wire to the controller and log it
sp = get_param(sub, 'PortHandles');
add_line(n, sp.Outport, dst, 'autorouting', 'on');
p = get_param(sub, 'Position');
tw = [n '/Log theta_ref_deg'];
add_block('simulink/Sinks/To Workspace', tw, 'VariableName', 'theta_ref_deg', ...
    'SaveFormat', 'Array', 'SampleTime', '-1', 'MaxDataPoints', 'inf', ...
    'Position', [p(1), p(4)+25, p(1)+90, p(4)+50]);
tp = get_param(tw, 'PortHandles');
add_line(n, sp.Outport, tp.Inport, 'autorouting', 'on');

save_system(n);
close_system(n);
end
