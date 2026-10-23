function m = step_metrics(t, theta, alpha, u, theta_step, step_time)
%STEP_METRICS Arm-step performance against the project requirements.
%   Overshoot and 2 % settling time are measured from the step at step_time;
%   peak values are taken after the step. Angles in rad, voltage in V.
k  = t >= step_time;
tk = t(k) - step_time;
th = theta(k);

m.overshoot = 100*max(0, (max(th) - theta_step)/theta_step);
out = find(abs(th - theta_step) > 0.02*abs(theta_step), 1, 'last');
if isempty(out)
    m.settling = 0;
elseif out == numel(th)
    m.settling = NaN;                       % never settled within the run
else
    m.settling = tk(out + 1);
end
m.final_error = rad2deg(abs(th(end) - theta_step));
m.peak_alpha  = rad2deg(max(abs(alpha(k))));
m.peak_u      = max(abs(u(k)));
m.pass = m.overshoot < 15 && ~isnan(m.settling) && m.settling < 5;
end
