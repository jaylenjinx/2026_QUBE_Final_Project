# CS1.A: frequency-domain design in the s-domain

Design the controller `C(s)` from the continuous-time plant model `G(s)`, then
discretise it to `C(z)` for implementation at `Ts = 1 ms`.

To go in this folder:

- Design script: `G(s)` from the Q1 model, the `C(s)` design and its justification,
  and the discretisation `C(z) = c2d(C(s), Ts, method)` with the chosen method.
- Simulation model (linear and nonlinear plant) with the controller in **one MATLAB
  Function block**, including any reference filter.
- Hardware model, based on `Hardware/CS01_RIP_QS2_SPI_T41_r2025b.slx`, using the same
  MATLAB Function block code.
- Saved hardware runs (`data_test_NN.mat`) for the results.
