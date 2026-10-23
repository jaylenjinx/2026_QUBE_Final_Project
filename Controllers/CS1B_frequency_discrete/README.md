# CS1.B: frequency-domain design in the z-domain

The same control structure as CS1.A, but discretise the plant first,
`G(z) = c2d(G(s), Ts, 'zoh')`, and design `C(z)` directly in the z-domain. Compare
the result with CS1.A.

To go in this folder:

- Design script: `G(z)`, the direct z-domain design of `C(z)`, and the comparison with
  CS1.A (poles and zeros, step response, hardware results).
- Simulation model (linear and nonlinear plant) with the controller in **one MATLAB
  Function block**, including any reference filter.
- Hardware model, based on `Hardware/CS01_RIP_QS2_SPI_T41_r2025b.slx`, using the same
  MATLAB Function block code.
- Saved hardware runs (`data_test_NN.mat`).
