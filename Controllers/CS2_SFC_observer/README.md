# CS2: discrete-time state feedback with an observer

A discrete-time SFC with a Luenberger observer, designed from the discrete-time
state-space model. This is the controller from DP2, now to be run on the hardware.

Starting point, in `MATLAB/`:

- `dp2_q1.m`: the model; `main_SFC.m`: the SFC gain `F` and the observer gain `Lo`.
- `sim_DP2_2026_SFC_Linear.slx` and `sim_DP2_2026_SFC_Nonlinear.slx`: the SFC and
  observer are already in a single MATLAB Function block (*Digital Controller*).

To go in this folder:

- Hardware model, based on `Hardware/CS01_RIP_QS2_SPI_T41_r2025b.slx`, with the same
  controller and observer block fed by the encoder angles `[theta; alpha]`.
- Any retuning for the real plant (for example, initialising the observer from the
  first encoder readings, or adding integral action for friction), with reasons.
- Saved hardware runs (`data_test_NN.mat`).
