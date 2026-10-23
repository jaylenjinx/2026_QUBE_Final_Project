# CS1.B: frequency-domain design in the z-domain

The same control structure as CS1.A, but the plant is discretised first,
`G(z) = c2d(G(s), Ts, 'zoh')`, and `C(z)` is designed directly in the z-domain. Compare the
result with CS1.A.

**Status: template.** The design in `params_CS1B.m` is a placeholder with every stage off,
so the controller outputs 0 V. The simulation runs, but the arm doesn't move until you add
your design.

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
| `params_CS1B.m` | **Your design.** `G(z)`, and `C_alpha(z)`, `C_theta(z)`, `F(z)` built with `z = tf('z', ts)`, plus the simulation settings |
| `run_CS1B.m` | Runs the linear and nonlinear simulations, prints the results against the requirements, and saves figures to `figures/` |
| `ctrl_CS1B.slx` | The controller: one MATLAB Function block, referenced by all three models below |
| `sim_CS1B_linear.slx`, `sim_CS1B_nonlinear.slx` | Simulation with the linearised plant and with the DP2 nonlinear plant |
| `hw_CS1B.slx` | The course hardware model with this controller wired into its `Controller` subsystem |
| `qube_model.m`, `block_coeffs.m`, `step_metrics.m`, `plot_response.m` | Model and helpers |
| `Hardware_settings.m`, `Hardware_data_save.m`, `exp_data_processing.m` | Hardware callbacks. `Hardware_settings.m` also runs `params_CS1B.m` |

## Workflow

1. Write your design in the marked section of `params_CS1B.m`, using `G_theta_z` and
   `G_alpha_z`. To use the s-plane requirements, map the poles with `z = exp(s*ts)`.
2. Run `run_CS1B` and compare its results table and figures with `run_CS1A`.
3. On the hardware, open `hw_CS1B.slx` from this folder and run it in external mode. Its
   `InitFcn` runs `params_CS1B.m`, so the hardware uses the same coefficients as the
   simulation.

The hardware notes in `../CS1A_frequency_continuous/README.md` apply here too: start
upright, the enable switch resets the controller, and the template's reference is 45°.
