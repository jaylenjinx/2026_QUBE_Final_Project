# CS1.B: frequency-domain design in the z-domain

The same control structure as CS1.A, but the plant is discretised first,
`G(z) = c2d(G(s), Ts, 'zoh')`, and `C(z)` is designed directly in the z-domain. Compare the
result with CS1.A.

**Status: saved discrete PID candidate, validated in nominal linear/nonlinear
simulation.** The pendulum filtered PD, arm PID and reference filter are saved
in `params_CS1B.m`. Physical PID and quantised-encoder validation remain pending.

## Control structure

All stages are in the single MATLAB Function block in `ctrl_CS1B.slx`. It's the same block
as CS1.A:

```
u = C_theta(z) (F(z) r - theta) + C_alpha(z) (0 - alpha),   limited to ±10 V
```

Because both designs run through identical code, any difference between CS1.A and CS1.B
comes from the design method alone.

## Files

| File | Purpose |
|---|---|
| `params_CS1B.m` | Saved direct discrete PID, pendulum PD, reference filter, coefficient generation and simulation settings |
| `run_CS1B.m` | Runs the linear and nonlinear simulations, prints the results against the requirements, and saves figures to `figures/` |
| `ctrl_CS1B.slx` | The controller: one MATLAB Function block, referenced by all three models below |
| `sim_CS1B_linear.slx`, `sim_CS1B_nonlinear.slx` | Simulation with the linearised plant and with the DP2 nonlinear plant |
| `hw_CS1B.slx` | The course hardware model with this controller wired into its `Controller` subsystem |
| `qube_model.m`, `block_coeffs.m`, `step_metrics.m`, `plot_response.m` | Model and helpers |
| `Hardware_settings.m`, `Hardware_data_save.m`, `exp_data_processing.m` | Hardware callbacks. `Hardware_settings.m` also runs `params_CS1B.m` |

## Workflow

1. Edit the saved discrete design in `params_CS1B.m`, using `G_theta_z` and
   `G_alpha_z`. To use the s-plane requirements, map the poles with `z = exp(s*ts)`.
2. Run `run_CS1B` and compare its results table and figures with `run_CS1A`.
3. On the hardware, open `hw_CS1B.slx` from this folder and run it in external mode. Its
   `InitFcn` runs `params_CS1B.m`, so the hardware uses the same coefficients as the
   simulation.

The hardware notes in `../CS1A_frequency_continuous/README.md` apply here too: start
upright, the enable switch resets the controller, and the template's reference is 45°.


## Saved PID simulation and root-locus workflow

Run `design_and_simulate_CS1B.m` (or the `run_CS1B.m` shortcut).
At the top of the design script, set `open_rltool = 0` for simulations only,
or `open_rltool = 1` to also open the pendulum and effective-arm root-locus
screens. CS1A opens continuous-time controllers before their Tustin conversion;
CS1B opens the directly designed discrete-time controllers. The arm screen
includes fixed pendulum feedback and the reference filter. The pendulum-only
screen is not a complete-system stability test. Export GUI changes and save
them in the parameter file before rerunning; GUI edits are not applied automatically.

Both scripts use the saved PID parameters, run a 45-degree command at 1 s on
the linear and nonlinear Simulink plants for 30 s, and report overshoot,
2% settling, final error, pendulum excursion and total motor voltage. They also
check full-order digital stability. `run_disturbance_test = 1` adds the linear
0.2 V persistent input-disturbance test at 2 s; set it to 0 to skip it.
Results remain in `CS1B_results`; step figures are saved in this folder's
`figures/` only when `save_graphs = 1`. The default `save_graphs = 0`
displays the plots without writing image files or creating that folder.
The disturbance plot is displayed only. The printed pass flag covers overshoot and settling only.
No hardware build or execution is performed. Encoder quantisation, physical
friction, saturation recovery/anti-windup and hardware performance require
separate validation.

Saved direct discrete design (Ts=0.001 s):
- Pendulum: `180*(z-0.986)/(z-0.942)`.
- Arm: `-104*(z-0.99777)*(z-0.9995)/((z-1)*(z-0.942))`.
- Reference filter: poles 0.99777 and 0.997, no finite zeros, unity DC gain.

Previously measured interactive benchmark: linear/nonlinear overshoot 0%,
settling 3.196/3.193 s, final errors 5.1392e-6/5.1307e-6 deg, peak pendulum
2.5790/2.5799 deg and peak voltage 0.87059/0.87687 V. Linear 0.2 V persistent
disturbance peak arm deviation 2.86483 deg, final offset -6.29824e-6 deg.
Largest digital feedback pole magnitude 0.9995324685. These are recorded
prior results, not a claim that the newly saved runner has been executed.
`Hardware_settings.m` already loads `params_CS1B.m`, so subsequent hardware
builds will use these saved coefficients; no hardware model was built here.


## Final saved-file review

Both hardware models use 1 ms controller parameters, Teensy 4.1, SPI Mode 2,
1000 kHz and MSB first, with instruction-set extensions set to None. Both
hardware parameter loaders resolve their own folder. CS1B's pendulum input now
has the same -1 correction used by the working CS1A hardware model; its saved
start settings are motor/controller disabled, reference zero, protection on.
Controller gains were not changed. CS1B still requires a new hardware build
and a physical test; archive/XML checks are not a successful MATLAB build.

The current nonlinear simulations have different encoder assumptions:
CS1A has both feedback encoders quantised at 2*pi/2048 rad; CS1B does not.
The latest CS1A quantised nonlinear result settles in 6.051 s and misses the
5 s target, despite the reported smooth physical run. CS1B nominal nonlinear
settling is 3.193 s. Keep these labels when presenting results; a matched
quantised comparison remains outstanding. The linear disturbance check is
separate from these nonlinear simulations.


## Root-locus figure for the presentation

`plot_rltool_CS1B` displays the saved effective-arm root locus beside the
unit-reference step response, with both feedback loops and the reference
filter included in the response. `plot_rltool_CS1B(1)` also saves a 300 dpi PNG
under `figures/`. The default direct call displays only. It does not run
hardware or Simulink. Edits made only in the GUI are not loaded automatically.

`design_and_simulate_CS1B.m` now has `plot_rltool_figure = 1` to include this
figure; set it to 0 to skip it. The existing `save_graphs` setting also controls
saving this new figure. `open_rltool` separately controls the interactive app.
The locus varies a positive multiplier k on the complete signed saved arm PID;
the selected full-state feedback poles are highlighted at k=1. The prefilter
is outside the locus and its poles are included in the returned reference model.
CS1A uses the s-plane; CS1B uses a zoom around the z-plane poles near 1.
