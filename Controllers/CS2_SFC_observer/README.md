# CS2: discrete-time state feedback with an observer

A discrete-time SFC with integral action and a Luenberger observer, designed from the
discrete state-space model.

**Status: rebuilt for the hardware, not yet tested on it.** For a 45° arm step, simulation
gives 1.5 % overshoot and 0.98 s settling on both the linear and nonlinear plants, with the
voltage peaking at 3.1 V. `hw_CS2.slx` compiles for the Teensy.

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
| Integrator | −8 |
| Observer | −90, −95, −100, −105 (about 4× the fastest SFC pole) |
| DP2, for reference | SFC −1.5 ± 2j, −6, −8; observer −40 to −55 |

**Why not the DP2 poles?** They meet the requirements on the model, but the loop only stays
stable while the real motor delivers at least 0.87× its modelled gain. Fitting the model to
the CS1.A hardware runs suggests the effective gain is lower than that, probably because of
friction at the small balancing voltages. The CS1.A design, which balances on the QUBE,
tolerates 0.53×–10×, so CS2 now uses the same bandwidth: it's stable for 0.48×–4.8×.

**Simulated with real-world effects.** A discrete simulation adds quantised encoders
(2048 counts per revolution), the ±10 V limit and stick–slip arm friction:

- **No friction:** 1.7 % overshoot, 0.99 s settling.
- **With friction:** neither plain SFC nor the integral version settles fully, because the
  arm hunts around the target. The integral version roughly halves the remaining error:
  1.2–2.3° compared with 1.8–4.5° without it.

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
2. Run `run_CS2`.
3. On the hardware, open `hw_CS2.slx` from this folder and run it in external mode. Its
   `InitFcn` runs `params_CS2.m`, so the hardware uses the same gains as the simulation.

**On the QUBE:**

1. Start with the controller disabled and the pendulum hanging. It should read α ≈ −π.
2. Lift the pendulum upright (α ≈ 0) and enable the controller.
3. Raise the arm reference gradually, before trying the 45° benchmark.
4. Keep runs short. Saved runs grow quickly: a 10-minute run was 185 MB.
