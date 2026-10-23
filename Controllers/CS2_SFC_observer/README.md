# CS2: discrete-time state feedback with an observer

The DP2 controller, ready for the hardware: a discrete-time SFC with a Luenberger observer,
designed from the discrete state-space model.

**Status: working design**, using the team's DP2 poles. In simulation it gives 8.37 %
overshoot and a 2.713 s settling time on both the linear and nonlinear plants, the same as
the DP2 report. It hasn't been tested on the hardware yet.

## Control structure

All stages are in the single MATLAB Function block in `ctrl_CS2.slx`:

```
x* = [r; 0; 0; 0],  u* = 0                                (DP2 Q2.2)
u(k) = -F (x_hat(k) - x*) + u*,  limited to ±10 V         (Q2.4)
x_hat(k+1) = A x_hat(k) + B u(k) + Lo (y(k) - C x_hat(k)) (Q3.3)
```

Two changes from DP2, both for the hardware:

- **Observer start.** The observer starts from the measured angles with zero velocities
  each time the controller is switched on, as the DP2 report recommends, so there's no
  start-up kick. To show observer convergence in simulation, set `xhat0_offset` in
  `params_CS2.m`, for example `[3; -1; 0; 0]*pi/180`.
- **Voltage limit.** The ±10 V limit is applied inside the block, so the observer is always
  updated with the voltage that actually reaches the motor. The hardware template's own
  limit comes after the controller block, where the observer couldn't see it.

## Files

| File | Purpose |
|---|---|
| `params_CS2.m` | **The design.** SFC poles `ps`, the gain `F`, observer poles `po_s`, the gain `Lo`, and the simulation settings |
| `run_CS2.m` | Runs the linear and nonlinear simulations, prints the results against the requirements, and saves figures (including true vs estimated states) to `figures/` |
| `ctrl_CS2.slx` | The controller: one MATLAB Function block, referenced by all three models below |
| `sim_CS2_linear.slx`, `sim_CS2_nonlinear.slx` | Simulation with the linearised plant and with the DP2 nonlinear plant |
| `hw_CS2.slx` | The course hardware model with this controller wired into its `Controller` subsystem |
| `qube_model.m`, `step_metrics.m`, `plot_response.m` | Model and helpers |
| `Hardware_settings.m`, `Hardware_data_save.m`, `exp_data_processing.m` | Hardware callbacks. `Hardware_settings.m` also runs `params_CS2.m` |

## Workflow

1. To change the design, edit `ps` and `po_s` in `params_CS2.m`; `F` and `Lo` are
   recomputed with `place`.
2. Run `run_CS2`.
3. On the hardware, open `hw_CS2.slx` from this folder and run it in external mode. Its
   `InitFcn` runs `params_CS2.m`, so the hardware uses the same gains as the simulation.

The hardware notes in `../CS1A_frequency_continuous/README.md` apply here too: start
upright, the enable switch resets the controller and the observer, and the template's
reference is 45°. Real friction will probably leave an arm offset that this design can't
remove without integral action.
