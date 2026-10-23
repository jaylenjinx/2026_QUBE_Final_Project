# 41277 Control Design: Final Project (QUBE-Servo 2)

Physical testing and design for the QUBE-Servo 2 rotary inverted pendulum (UTS, Spring 2026).
Design, simulate and run three control systems on the hardware, then demonstrate them
(Assessment Task 5, see [`docs/2026 - Task5 Assessment Criteria.pdf`](docs/2026%20-%20Task5%20Assessment%20Criteria.pdf)).

This repo started as a copy of [2026_DP2_Report](https://github.com/jaylenjinx/2026_DP2_Report)
with its full history, so the Q1 model and the Q2/Q3 controller and observer from DP2 are the
starting point.

## Control requirements

| Spec | Target |
|---|---|
| Overshoot | < 15 % |
| Settling time | < 5 s |
| Steady-state accuracy | < 50 |

## The three control systems

| Folder | Design | Status |
|---|---|---|
| [`Controllers/CS1A_frequency_continuous`](Controllers/CS1A_frequency_continuous) | CS1.A: design `C(s)` from `G(s)`, then discretise to `C(z)` | Template, design to do |
| [`Controllers/CS1B_frequency_discrete`](Controllers/CS1B_frequency_discrete) | CS1.B: discretise the plant to `G(z)`, then design `C(z)` directly; compare with CS1.A | Template, design to do |
| [`Controllers/CS2_SFC_observer`](Controllers/CS2_SFC_observer) | CS2: discrete-time SFC with a Luenberger observer, from the discrete state-space model (DP2) | Working in simulation, hardware untested |

A control system may combine several controllers. Each one must govern the whole system, not just one loop.

Each folder is self-contained, so it can be uploaded to Teams as its own subfolder and run on
any team member's computer:

- **`params_<CS>.m`:** the design.
- **`run_<CS>.m`:** linear and nonlinear simulations, with a check against the requirements.
- **`ctrl_<CS>.slx`:** the controller as one MATLAB Function block. The simulation and
  hardware models all reference this one file, so the code you simulate is the code that
  runs on the QUBE.
- **`hw_<CS>.slx`:** the course hardware template with the controller wired in. It loads
  the same `params_<CS>.m` when it builds.

See each folder's README for details.

## Assessment rules (Task 5)

- **One MATLAB Function block per control system.** Reference filters, controllers and
  observers all go inside that single block. Don't build them from Simulink blocks.
- **15 min demo per team:** a 5 min presentation on your modelling, designs, simulations and
  implementation, shared equally and not read from a script; a 5 min demonstration of all
  three designs in simulation and on the hardware; then 5 min of questions.
- **Files on MS Teams,** with one subfolder per controller. This repo's `Controllers/`
  folders mirror that layout.
- **Individually assessed.** Every team member must be able to run each simulation from
  their own computer and change controller settings on request.
- **Questions cover:** how the linear and nonlinear models were obtained, and how each
  controller was chosen and designed for the target (not by trial and error or MATLAB
  autotuning). Typical questions: how the sampling time was chosen; whether the plant is
  open-loop stable; how to reduce overshoot without moving the closed-loop poles; how the
  observer poles were chosen; how continuous eigenvalues map to discrete ones.

## Layout

```
Controllers/   one folder per control system (design, sim and hardware models, runs)
  tools/       build_templates.m, which generates the folders (it won't overwrite existing ones)
Hardware/      course lab template: CS01_RIP_QS2_SPI_T41_r2025b.slx and its scripts
  data/        saved hardware runs (data_test_NN.mat), kept in git
MATLAB/        DP2 model, SFC + observer design and simulation models (starting point)
Report/        DP2 report (LaTeX), for reference
docs/          Task 5 criteria, DP2 brief, QUBE-Servo 2 manual, data sheet, courseware
```

## Running the hardware template

`Hardware/CS01_RIP_QS2_SPI_T41_r2025b.slx` needs MATLAB R2025b.

1. `Hardware_settings.m` runs before the model compiles. It sets `ts = 1/1000` and the
   `save_data` flag.
2. With `save_data = true`, `Hardware_data_save.m` runs after you stop the model and saves
   the workspace as the next free `data_test_NN.mat` in the current folder. Move the runs
   you want to keep into `Hardware/data/`, or into the controller's own folder, and commit them.
3. `exp_data_processing.m` loads a saved run and plots `Vm`, `theta` and `alpha`.

## Pulling later DP2 changes

The DP2 repo is kept as the `upstream` remote:

```bash
git fetch upstream && git merge upstream/main
```
