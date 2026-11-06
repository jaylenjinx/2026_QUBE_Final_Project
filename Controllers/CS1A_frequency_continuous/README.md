# CS1.A: frequency-domain design in the s-domain

Design `C(s)` from the continuous-time plant `G(s)`, then discretise it to `C(z)` for
implementation at `Ts = 1 ms`.

**Status: simulation design under development.** Three designs are kept separate:

- `params_CS1A.m`: the original sequential-design baseline. It passed the ideal
  5-degree tracking test but develops persistent arm oscillation with both encoders quantised.
- `params_CS1A_candidate.m`: the experimental joint filtered-PD candidate, N = 60 rad/s.
  It passes the declared 45-degree linear/nonlinear quantised benchmarks and the tested
  linear delay/damping variations. Ripple and voltage chatter remain; precise small-command
  tracking and hardware performance are not established.

- `params_CS1A_PID.m`: current arm PID with the candidate pendulum PD and reference filter.
  The simulation runner and hardware parameter loader both use this design.

Read [CS1A_CANDIDATE_DESIGN_NOTES.md](CS1A_CANDIDATE_DESIGN_NOTES.md) for the equations,
recorded results, design-method distinction and limitations. The candidate gains use
continuous-time polynomial matching; the required frequency-domain design justification
is not complete merely because the Bode/margin checks have been performed.

**The runner and Hardware_settings.m load `params_CS1A_PID.m`. The separate `analyse_CS1A.m` script still examines the original baseline.** The model defaults are motor/controller disabled, zero arm reference, and protection enabled. Data saving is on; hardware testing is pending.

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
| `Hardware_settings.m`, `Hardware_data_save.m`, `exp_data_processing.m` | Hardware callbacks. `Hardware_settings.m` loads `params_CS1A_PID.m` |

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

## Current-design workflow

1. Edit the arm PID in `params_CS1A_PID.m`. Its pendulum PD and filter are
   inherited from `params_CS1A_candidate.m`. Each continuous controller must be proper.
2. Run `design_and_simulate_CS1A` or `run_CS1A`. Use `open_rltool = 1` in the
   design script to inspect the saved continuous controllers using root locus.
3. For an initial-tilt test, change `x0` in the design script, which overrides
   the default parameter value for these simulations.
4. The hardware parameter loader uses `params_CS1A_PID.m`; changing the older
   `params_CS1A.m` does not update this hardware PID.

## Hardware notes

- The controller assumes `alpha = 0` upright and `theta = 0` at the start. Follow the lab
  procedure for the template's Sensors Reset, Motor Enable, Protection and Controller Enable
  switches.
- Turning the controller off clears the controller's states, through the template's
  `Int_reset` signal, so every time it's switched on it starts fresh.
- The arm reference is the `theta ref [deg]` constant at the top level of `hw_CS1A.slx`. The
  saved PID model starts at zero reference; follow the lab procedure for test commands.

## Current hardware PID trial

Hardware_settings.m now loads params_CS1A_PID.m. This keeps the N60 pendulum
filtered PD and existing reference filter, and replaces only the arm controller
with the filtered PID developed interactively in Control System Designer.
Its normalised editor gain is -1.997, zeros are approximately -2.23017 and -0.5,
and poles are 0 and -60. Tustin conversion uses Ts = 0.001 s.

Reported ideal digital nonlinear 45-degree test: 0% overshoot, 3.188 s settling,
2.6075 degrees peak pendulum displacement and 0.8923 V peak combined command.
The 0.2 V constant-input disturbance test removed the nominal PD arm offset.
Quantised-encoder testing, dedicated anti-windup and physical PID validation are
still pending. The generic controller currently clips its output at +/-10 V.

hw_CS1A is saved with motor/controller disabled, reference zero and protection
on. Reopen it from disk and rebuild for a lab test. `run_CS1A` now runs the
saved PID workflow described below. The original baseline parameter file and
PD comparison tools remain available separately.


## Saved PID simulation and root-locus workflow

Run `design_and_simulate_CS1A.m` (or the `run_CS1A.m` shortcut).
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
Results remain in `CS1A_results`; step figures are saved in this folder's
`figures/` only when `save_graphs = 1`. The default `save_graphs = 0`
displays the plots without writing image files or creating that folder.
The disturbance plot is displayed only. The printed pass flag covers overshoot and settling only.
No hardware build or execution is performed. Encoder quantisation, physical
friction, saturation recovery/anti-windup and hardware performance require
separate validation.

The runner now uses `params_CS1A_PID.m`, matching the PID hardware parameter
loader. `params_CS1A.m` remains available as the older baseline. The fixed
pendulum PD originated from the N60 joint polynomial design; the arm PID
was subsequently developed using Control System Designer. CS1A was not
entirely synthesised using root locus from scratch.

Previously measured interactive PID benchmark: linear settling 3.192 s,
nonlinear 3.188 s, zero overshoot, nonlinear peak pendulum 2.6075 deg and
motor voltage 0.8923 V. Linear 0.2 V disturbance final arm offset was about
-6.314e-6 deg (original PD offset -2.8692 deg). These are recorded prior
results, not a claim that the newly saved runner has been executed.


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

`plot_rltool_CS1A` displays the saved effective-arm root locus beside the
unit-reference step response, with both feedback loops and the reference
filter included in the response. `plot_rltool_CS1A(1)` also saves a 300 dpi PNG
under `figures/`. The default direct call displays only. It does not run
hardware or Simulink. Edits made only in the GUI are not loaded automatically.

`design_and_simulate_CS1A.m` now has `plot_rltool_figure = 1` to include this
figure; set it to 0 to skip it. The existing `save_graphs` setting also controls
saving this new figure. `open_rltool` separately controls the interactive app.
The locus varies a positive multiplier k on the complete signed saved arm PID;
the selected full-state feedback poles are highlighted at k=1. The prefilter
is outside the locus and its poles are included in the returned reference model.
CS1A uses the s-plane; CS1B uses a zoom around the z-plane poles near 1.
