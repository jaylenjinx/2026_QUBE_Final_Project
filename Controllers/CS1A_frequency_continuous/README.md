# CS1.A: frequency-domain design in the s-domain

Design `C(s)` from the continuous-time plant `G(s)`, then discretise it to `C(z)` for
implementation at `Ts = 1 ms`.

**Status: template.** The design in `params_CS1A.m` is a placeholder with every stage off,
so the controller outputs 0 V. The simulation runs, but the arm doesn't move until you add
your design.

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
| `params_CS1A.m` | **Your design.** `G(s)`, `C_alpha(s)`, `C_theta(s)`, `F(s)`, the `c2d` method, and the simulation settings |
| `run_CS1A.m` | Runs the linear and nonlinear simulations, prints the results against the requirements, and saves figures to `figures/` |
| `ctrl_CS1A.slx` | The controller: one MATLAB Function block, referenced by all three models below |
| `sim_CS1A_linear.slx`, `sim_CS1A_nonlinear.slx` | Simulation with the linearised plant and with the DP2 nonlinear plant |
| `hw_CS1A.slx` | The course hardware model with this controller wired into its `Controller` subsystem |
| `qube_model.m`, `block_coeffs.m`, `step_metrics.m`, `plot_response.m` | Model and helpers |
| `Hardware_settings.m`, `Hardware_data_save.m`, `exp_data_processing.m` | Hardware callbacks. `Hardware_settings.m` also runs `params_CS1A.m` |

## Workflow

1. Write your design in the marked section of `params_CS1A.m`. Each `C(s)` must be proper.
   A pure derivative isn't proper, so use a filtered one such as `N s/(s + N)`.
2. Run `run_CS1A`. It reports overshoot, 2 % settling time, final error, peak pendulum angle
   and peak voltage for both plants, and whether the requirements are met.
3. To test disturbance rejection, start from a tilted pendulum: set
   `x0 = [0; 2*pi/180; 0; 0]` in `params_CS1A.m`.
4. On the hardware, open `hw_CS1A.slx` from this folder and run it in external mode. Its
   `InitFcn` runs `Hardware_settings.m`, which runs `params_CS1A.m`, so the hardware always
   uses the same coefficients as the simulation. To change a setting during the demo, edit
   `params_CS1A.m` and run the model again.

## Hardware notes

- The controller assumes `alpha = 0` upright and `theta = 0` at the start. Follow the lab
  procedure for the template's Sensors Reset, Motor Enable, Protection and Controller Enable
  switches.
- Turning the controller off clears the controller's states, through the template's
  `Int_reset` signal, so every time it's switched on it starts fresh.
- The arm reference is the `theta ref [deg]` constant at the top level of `hw_CS1A.slx`. The
  template sets it to 45°; start with a smaller step.
