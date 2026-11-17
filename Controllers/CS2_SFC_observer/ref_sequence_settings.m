%% Arm step sequence for hardware tests
% Used by the "Reference sequence" block in the hardware model. Flip the
% "Run step sequence" switch to 1 in external mode: the arm reference steps
% through these values, holding each for ref_hold_s seconds, then stays on
% the last one. Flip it back to 0 to return to the manual reference.
% The reference is logged as theta_ref_deg.

% Steps of 45, 90 and 135 deg. Keep each step at 135 deg or less for CS2: in
% the nonlinear simulation it needs 5.5 V and 14 deg of pendulum tilt for
% the 135 deg step, hits the 10 V limit on a 200 deg step, and drops the
% pendulum on a 220 deg step (+110 -> -110). CS1A is slower and handled
% +/-110 deg on the hardware (run 07), but the same sequence is used for
% both so the two controllers can be compared directly.

ref_seq_deg = [45 -45 90 0 -90 0];          % arm reference values [deg]
ref_hold_s  = 8;                           % time on each value [s] (72 s in total)
