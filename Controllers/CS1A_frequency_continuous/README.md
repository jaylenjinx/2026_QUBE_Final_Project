# CS1.A: frequency-domain design in the s-domain

Design `C(s)` from the continuous-time plant `G(s)`, then discretise it to `C(z)` for
implementation at `Ts = 1 ms`.

**Status: simulation design under development.** Two designs are kept separate:

- `params_CS1A.m`: the original sequential-design baseline. It passed the ideal
  5-degree tracking test but develops persistent arm oscillation with both encoders quantised.
- `params_CS1A_candidate.m`: the experimental joint filtered-PD candidate, N = 60 rad/s.
  It passes the declared 45-degree linear/nonlinear quantised benchmarks and the tested
  linear delay/damping variations. Ripple and voltage chatter remain; precise small-command
  tracking and hardware performance are not established.

Read [CS1A_CANDIDATE_DESIGN_NOTES.md](CS1A_CANDIDATE_DESIGN_NOTES.md) for the equations,
recorded results, design-method distinction and limitations. The candidate gains use
continuous-time polynomial matching; the required frequency-domain design justification
is not complete merely because the Bode/margin checks have been performed.

**The normal runner and analysis script still load the original `params_CS1A.m`. Hardware_settings.m now loads the N60 candidate for hw_CS1A.** The model defaults are motor/controller disabled, zero arm reference, and protection enabled. Data saving is on; hardware testing is pending.

## Control structure

All stages are in the single MATLAB Function block in `ctrl_CS1A.slx`:

```
u = C_theta(z) (F(z) r - theta) + C_alpha(z) (0 - alpha),   limited to ±10 V
```

- `F(z)`: reference prefilter, for example to shape the step and avoid a derivative kick.
- `C_theta(z)`: arm-angle loop.
- `C_alpha(z)`: pendulum loop, which keeps the pendulum upright.

Each stage runs the difference equation of its `b(z⁻¹)/a(z⁻¹)`, of any order. The block was
checked against `filter()` and against the closed loop computed from the transfer functions.

## Files

| File | Purpose |
|---|---|
| `params_CS1A_candidate.m` | Separate N = 60 joint filtered-PD candidate; loading parameters only |
| `test_CS1A_quantised_candidate.m` | Original/candidate quantised comparison; specify bandwidth `60` explicitly |
| `CS1A_CANDIDATE_DESIGN_NOTES.md` | Candidate derivation, results, assumptions and open work |
| `analyse_CS1A.m` | Reproducible nominal analysis of the original saved design |
| `params_CS1A.m` | **Original baseline.** `G(s)`, `C_alpha(s)`, `C_theta(s)`, `F(s)`, the `c2d` method, and the simulation settings |
| `run_CS1A.m` | Runs the linear and nonlinear simulations, prints the results against the requirements, and saves figures to `figures/` |
| `ctrl_CS1A.slx` | The controller: one MATLAB Function block, referenced by all three models below |
| `sim_CS1A_linear.slx`, `sim_CS1A_nonlinear.slx` | Simulation with the linearised plant and with the DP2 nonlinear plant |
| `hw_CS1A.slx` | The course hardware model with this controller wired into its `Controller` subsystem |
| `qube_model.m`, `block_coeffs.m`, `step_metrics.m`, `plot_response.m` | Model and helpers |
| `Hardware_settings.m`, `Hardware_data_save.m`, `exp_data_processing.m` | Hardware callbacks. `Hardware_settings.m` loads `params_CS1A_candidate.m` |

## Candidate comparison (simulation only)

Run from this folder, with both encoders connected in the saved linear quantised model:

```matlab
test_CS1A_quantised_candidate(60, 'linear')
test_CS1A_quantised_candidate(60, 'nonlinear')
```

These comparisons use a 45-degree step, a declared +/-2% band and 60-second runs.
The function's default bandwidth is 100, so always pass `60` for the current candidate.
The nonlinear option creates its own quantised test copy. The results are placed in
`quantised_candidate_results`; each new comparison replaces that workspace variable.
These commands do not change the original parameter file or run hardware.

## Original-design workflow

1. Write your design in the marked section of `params_CS1A.m`. Each `C(s)` must be proper.
   A pure derivative isn't proper, so use a filtered one such as `N s/(s + N)`.
2. Run `run_CS1A`. It reports overshoot, 2 % settling time, final error, peak pendulum angle
   and peak voltage for both plants, and whether the requirements are met.
3. To test disturbance rejection, start from a tilted pendulum: set
   `x0 = [0; 2*pi/180; 0; 0]` in `params_CS1A.m`.
4. On the hardware, open `hw_CS1A.slx` from this folder and run it in external mode. Its
   `InitFcn` runs `Hardware_settings.m`, which runs `params_CS1A_candidate.m`. The hardware now
   uses the N60 candidate coefficients. To change a setting during the demo, edit
   `params_CS1A.m` and run the model again.

## Hardware notes

- The controller assumes `alpha = 0` upright and `theta = 0` at the start. Follow the lab
  procedure for the template's Sensors Reset, Motor Enable, Protection and Controller Enable
  switches.
- Turning the controller off clears the controller's states, through the template's
  `Int_reset` signal, so every time it's switched on it starts fresh.
- The arm reference is the `theta ref [deg]` constant at the top level of `hw_CS1A.slx`. The
  template sets it to 45°; start with a smaller step.
