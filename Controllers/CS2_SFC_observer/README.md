# CS2: discrete-time state feedback with an observer

A discrete-time SFC with integral action and a Luenberger observer, designed from the
discrete state-space model.

**Status: balances on the QUBE; retuned to recover from bumps.** The first hardware version
worked but fell over when bumped. For a 45° arm step, simulation gives 0.6 % overshoot and
0.95 s settling on both the linear and nonlinear plants, with the voltage peaking at 1.6 V.
`hw_CS2.slx` compiles for the Teensy. The bump retune hasn't been tested on the QUBE yet.

## Control structure

All stages are in the single MATLAB Function block in `ctrl_CS2.slx`:

```
r_f(k+1)   = r_f(k) + Ts/τ (r − r_f(k))                       reference filter, τ = 0.2 s
x*         = [r_f; 0; 0; 0],  u* = 0
x_i(k+1)   = x_i(k) + Ts (θ(k) − r)                            only within ±2° of r, and not
                                                               while the voltage is limited
u(k)       = −F (x̂(k) − x*) − Fi x_i(k) + u*,  limited to ±10 V
x̂(k+1)     = A x̂(k) + B u(k) + Lo (y(k) − C x̂(k))
```

- **Integral action** removes the arm offset that friction leaves with plain state feedback.
  `F` and `Fi` are placed together on the augmented system `[x; x_i]`.
  - It only integrates near the target. Integrating during a large step makes the
    integrator wind up and overshoot: 44 % in simulation, compared with 1.5 % here.
  - It stops integrating while the voltage is at its limit (anti-windup).
  - Set `use_integral = false` in `params_CS2.m` for plain SFC.
- **The reference filter** turns a step into a smooth move. This keeps the voltage well
  below the 10 V limit; without it, the 45° step saturated.
- **On enable**, the observer starts from the measured angles with zero velocities, the
  filter starts from the measured θ, and the integral starts at zero, so switching the
  controller on causes no jump. The ±10 V limit is applied inside the block, so the observer
  is always updated with the voltage the motor actually gets.

## Design

| | Poles [1/s] |
|---|---|
| SFC | −5.6 ± 5.7j (ωn = 8 rad/s, ζ = 0.7), −19.2, −25.6 |
| Integrator | −1 |
| Observer | −90, −95, −100, −105 (about 4× the fastest SFC pole) |
| DP2, for reference | SFC −1.5 ± 2j, −6, −8; observer −40 to −55 |

**Why not the DP2 poles?** They meet the requirements on the model, but the loop only stays
stable while the real motor delivers at least 0.87× its modelled gain. Fitting the model to
the CS1.A hardware runs suggests the effective gain is lower than that, probably because of
friction at the small balancing voltages. The CS1.A design, which balances on the QUBE,
tolerates 0.53×–10×, so CS2 now uses the same bandwidth: it's stable for 0.45×–5.3×.

**Why the integrator pole is slow.** The integrator pole was first at −8. That roughly
tripled the arm gain, so a small bump drove the voltage to ±10 V and the pendulum fell. At
−1 the gains stay close to plain SFC.

A bump test simulates the nonlinear plant with the real `ctrl_CS2` code, quantised
encoders, the voltage limit, a weaker motor and friction, and kicks the balanced pendulum.
The largest pendulum kick recovered:

| Motor strength | 0.6× | 0.8× | 1× |
|---|---|---|---|
| Integrator pole −8 (before) | 91°/s | 119°/s | 137°/s |
| Integrator pole −1 (now) | 152°/s | 197°/s | 229°/s |

The trade-off is that friction offsets are removed over about a second rather than a few
hundred milliseconds. If bumps are still a problem, `wn = 7` recovers about 10 % more but
leaves less margin for a weak motor (0.50× instead of 0.45×).

**Simulated with real-world effects.** A discrete simulation adds quantised encoders
(2048 counts per revolution), the ±10 V limit and stick–slip arm friction:

- **No friction:** 1.3 % overshoot, 0.93 s settling.
- **With friction:** the arm hunts around the target rather than settling fully, with an
  average error of about 1.7°. Plain SFC under the same conditions is worse, at about 1.8–4.5°.

The friction model is a rough guess, so expect the real numbers to differ.

## Hardware model

`hw_CS2.slx` is a copy of the working `hw_CS1A.slx` with only the controller swapped to
`ctrl_CS2` (and the unused `x_hat` output terminated), so it uses the same proven hardware
settings:

- **α is negated** (`Gain = -1` in front of the controller), because the QUBE's pendulum
  encoder measures α in the opposite direction to the model.
- **θ is used as measured.** This was confirmed from the CS1.A runs.
- **The arm reference** (`theta ref [deg]`) is set to 0° for the first test.

## Files

| File | Purpose |
|---|---|
| `params_CS2.m` | **The design.** Poles, the integral settings, the gains `F`, `Fi`, `Lo`, and the simulation settings |
| `run_CS2.m` | Runs the linear and nonlinear simulations, prints the results against the requirements, and saves figures (including true vs estimated states) to `figures/` |
| `ctrl_CS2.slx` | The controller: one MATLAB Function block, referenced by all three models below |
| `sim_CS2_linear.slx`, `sim_CS2_nonlinear.slx` | Simulation with the linearised plant and with the DP2 nonlinear plant |
| `hw_CS2.slx` | The hardware model (see above) |
| `qube_model.m`, `step_metrics.m`, `plot_response.m` | Model and helpers |
| `Hardware_settings.m`, `Hardware_data_save.m`, `exp_data_processing.m` | Hardware callbacks. `Hardware_settings.m` also runs `params_CS2.m` |

## Workflow

1. To change the design, edit `params_CS2.m`: `wn`, `zeta`, `p_int`, `int_band`, `ref_tau`,
   `po_s`, or `use_integral`. The gains are recomputed with `place`.
   **For new targets asked for in the demo,** set `OS_target` [%] and `ts_target` [s]
   instead. They set `zeta` and `wn` from the second-order relations, and the faster SFC
   poles and the observer poles scale with them. `run_CS2` prints the resulting poles, gains
   and motor-gain margin.
   - A slower settling target gives a slower, less robust design. For example, 10 % and 2 s
     only stays stable for a motor gain of 0.81× or more. A settling-time limit is also met by
     any faster design, so keeping the tested one is a valid answer.
   - For a settling target under about 1 s, also shorten `ref_tau`, because the reference
     filter alone takes about 4·`ref_tau` to settle.
2. Run `run_CS2`.
3. On the hardware, open `hw_CS2.slx` from this folder and run it in external mode. Its
   `InitFcn` runs `params_CS2.m`, so the hardware uses the same gains as the simulation.

**On the QUBE:**

1. Start with the controller disabled and the pendulum hanging. It should read α ≈ −π.
2. Lift the pendulum upright (α ≈ 0) and enable the controller.
3. Raise the arm reference gradually, before trying the 45° benchmark.
4. Keep runs short. Saved runs grow quickly: a 10-minute run was 185 MB.
