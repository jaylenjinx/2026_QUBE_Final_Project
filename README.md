# 41277 Control Design: Final Project (QUBE-Servo 2)

Physical testing and design for the QUBE-Servo 2 rotary inverted pendulum (UTS, Spring 2026).
Design, simulate and run two control systems on the hardware, then demonstrate them
(Assessment Task 5, see [`docs/2026 - Task5 Assessment Criteria_v2.pdf`](docs/2026%20-%20Task5%20Assessment%20Criteria_v2.pdf);
v2 changed "three" designs to "two").

This repo started as a copy of [2026_DP2_Report](https://github.com/jaylenjinx/2026_DP2_Report)
with its full history, so the Q1 model and the Q2/Q3 controller and observer from DP2 are the
starting point.

## Control requirements

| Spec | Target |
|---|---|
| Overshoot | < 15 % |
| Settling time | < 5 s |
| Steady-state accuracy | < 50 |

## The control systems

Two are required: one frequency-domain design (transfer functions) and one time-domain design
(SFC with an observer). Extra controllers are welcome if they're justified and demonstrated.

| Folder | Design | Status |
|---|---|---|
| [`Controllers/CS1A_frequency_continuous`](Controllers/CS1A_frequency_continuous) | **Required (frequency domain).** CS1.A: design `C(s)` from `G(s)`, then discretise to `C(z)` | Balances on the QUBE; the hardware model now loads the arm-PID trial (see its README) |
| [`Controllers/CS2_SFC_observer`](Controllers/CS2_SFC_observer) | **Required (time domain).** Discrete-time SFC with integral action and a Luenberger observer | Balances on the QUBE; retuned to recover from bumps |
| [`Controllers/CS1B_frequency_discrete`](Controllers/CS1B_frequency_discrete) | Optional. CS1.B: discretise the plant to `G(z)`, then design `C(z)` directly | Template only, not used |

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
  implementation, shared equally and not read from a script; a 5 min demonstration of both
  control systems in simulation and on the hardware; then questions to each student.
- **Files on MS Teams,** with one subfolder per controller. This repo's `Controllers/`
  folders mirror that layout.
- **Individually assessed.** Every team member must be able to run each simulation from
  their own computer, answer questions on modelling, design, simulation and implementation,
  and change controller settings on request. "That wasn't my part" isn't accepted.
- **Changed targets during the demo.** You may be asked for a new overshoot or settling
  time and to implement the new design on the board. For CS2, set `OS_target` and
  `ts_target` in `params_CS2.m`, run `run_CS2` to check it, then rebuild `hw_CS2.slx`.
- **Understanding is what's marked**, not only a working system. Feedback from the demo must
  go into the final report.
- **Questions cover:** how the linear and nonlinear models were obtained, and how each
  controller was chosen and designed for the target (not by trial and error or MATLAB
  autotuning). Typical questions: how the sampling time was chosen; whether the plant is
  open-loop stable; how to reduce overshoot without moving the closed-loop poles; how the
  observer poles were chosen; how continuous eigenvalues map to discrete ones.

## Demo logistics

Thursday 5 and Friday 6 November, 10am–5pm, in 2-hour blocks by your regular lab session.
Arrive at least 30 minutes early. Before the demo, upload the MATLAB files to the
"Assessment Task 5 - Final Project Demonstration" folder in MS Teams, one subfolder per
controller, and leave out the Teensy build output (`*_ert_rtw/`, `.elf`, `.hex`, `.bin`) and
large `data_test_*.mat` runs.

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
