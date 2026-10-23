/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: hw_CS2_data.c
 *
 * Code generated for Simulink model 'hw_CS2'.
 *
 * Model version                  : 3.50
 * Simulink Coder version         : 25.2 (R2025b) 28-Jul-2025
 * C/C++ source code generated on : Fri Oct 23 14:57:32 2026
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: ARM Compatible->ARM Cortex
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "hw_CS2.h"

/* Block parameters (default storage) */
P_hw_CS2_T hw_CS2_P = {
  /* Variable: A
   * Referenced by: '<S11>/Controller CS2'
   */
  { 1.0, 0.0, 0.0, 0.0, 2.7012765666151475E-5, 1.0000836295802487,
    0.0539210392303818, 0.16705290504799247, 0.00099691862549093364,
    -3.0417617740373968E-6, 0.99384536883487673, -0.0060717572563429231,
    -8.8039104356570438E-7, 0.000997274362848614, -0.0017483548531475692,
    0.99458335876788906 },

  /* Variable: B
   * Referenced by: '<S11>/Controller CS2'
   */
  { 9.0098669855744051E-6, 8.8940402749631485E-6, 0.017995997558839929,
    0.0177536761881372 },

  /* Variable: C
   * Referenced by: '<S11>/Controller CS2'
   */
  { 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0 },

  /* Variable: F
   * Referenced by: '<S11>/Controller CS2'
   */
  { -0.14517718224547321, 15.382540115281666, -0.458881050592741,
    0.76529168594905406 },

  /* Variable: Lo
   * Referenced by: '<S11>/Controller CS2'
   */
  { 0.087990133783145241, -0.011086045986665016, 1.6805782147562658,
    -0.7041484771724299, -0.0058686491535795259, 0.0860207299602469,
    -0.25163680412648615, 1.8098417531259814 },

  /* Variable: ts
   * Referenced by:
   *   '<S7>/Step'
   *   '<S7>/Step1'
   */
  0.001,

  /* Variable: u_max
   * Referenced by: '<S11>/Controller CS2'
   */
  10.0,

  /* Variable: xhat0_offset
   * Referenced by: '<S11>/Controller CS2'
   */
  { 0.0, 0.0, 0.0, 0.0 },

  /* Mask Parameter: CompareToConstant_const
   * Referenced by: '<S19>/Constant'
   */
  20.0,

  /* Expression: 1
   * Referenced by: '<S15>/Reset_manual 1'
   */
  1.0,

  /* Expression: 0
   * Referenced by: '<S15>/Reset_manual 0'
   */
  0.0,

  /* Expression: 0
   * Referenced by: '<S16>/Constant'
   */
  0.0,

  /* Expression: 0
   * Referenced by: '<S17>/Constant'
   */
  0.0,

  /* Expression: pi/180
   * Referenced by: '<S12>/Gain1'
   */
  0.017453292519943295,

  /* Expression: -1.5
   * Referenced by: '<S1>/Gain'
   */
  -1.5,

  /* Expression: 0
   * Referenced by:
   */
  0.0,

  /* Expression: 10
   * Referenced by: '<S1>/Saturation'
   */
  10.0,

  /* Expression: -10
   * Referenced by: '<S1>/Saturation'
   */
  -10.0,

  /* Expression: 10
   * Referenced by: '<S20>/SPI WriteRead'
   */
  10.0,

  /* Computed Parameter: encoder0_Y0
   * Referenced by: '<S20>/encoder0'
   */
  0.0,

  /* Computed Parameter: encoder1_Y0
   * Referenced by: '<S20>/encoder1'
   */
  0.0,

  /* Expression: 10
   * Referenced by: '<S20>/+- 10V'
   */
  10.0,

  /* Expression: -10
   * Referenced by: '<S20>/+- 10V'
   */
  -10.0,

  /* Expression: 1
   * Referenced by: '<S6>/Reset_manual 1'
   */
  1.0,

  /* Expression: 0
   * Referenced by: '<S6>/Reset_manual 0'
   */
  0.0,

  /* Expression: 1
   * Referenced by: '<S5>/Reset_manual 1'
   */
  1.0,

  /* Expression: 0
   * Referenced by: '<S5>/Reset_manual 0'
   */
  0.0,

  /* Expression: 1
   * Referenced by: '<S4>/Reset_manual 1'
   */
  1.0,

  /* Expression: 0
   * Referenced by: '<S4>/Reset_manual 0'
   */
  0.0,

  /* Expression: 0
   * Referenced by: '<Root>/theta ref [deg]'
   */
  0.0,

  /* Expression: 0
   * Referenced by: '<S7>/Memory'
   */
  0.0,

  /* Expression: 0
   * Referenced by: '<S7>/Memory1'
   */
  0.0,

  /* Expression: 0
   * Referenced by:
   */
  0.0,

  /* Expression: 0
   * Referenced by: '<S7>/Step'
   */
  0.0,

  /* Expression: 1
   * Referenced by: '<S7>/Step'
   */
  1.0,

  /* Expression: 0
   * Referenced by: '<S7>/Step1'
   */
  0.0,

  /* Expression: -1
   * Referenced by: '<S7>/Step1'
   */
  -1.0,

  /* Expression: 1
   * Referenced by: '<Root>/Motor Enable'
   */
  1.0,

  /* Expression: 1
   * Referenced by: '<Root>/Protection'
   */
  1.0,

  /* Expression: 180/pi
   * Referenced by: '<S21>/Gain'
   */
  57.295779513082323,

  /* Expression: 1
   * Referenced by: '<S7>/Constant1'
   */
  1.0,

  /* Expression: 1
   * Referenced by: '<S7>/Constant2'
   */
  1.0,

  /* Expression: 1
   * Referenced by: '<S7>/Constant3'
   */
  1.0,

  /* Expression: 1
   * Referenced by: '<S7>/Pulse Generator1'
   */
  1.0,

  /* Computed Parameter: PulseGenerator1_Period
   * Referenced by: '<S7>/Pulse Generator1'
   */
  2.0,

  /* Computed Parameter: PulseGenerator1_Duty
   * Referenced by: '<S7>/Pulse Generator1'
   */
  1.0,

  /* Expression: 0
   * Referenced by: '<S7>/Pulse Generator1'
   */
  0.0,

  /* Expression: 180/pi
   * Referenced by: '<S3>/Gain'
   */
  57.295779513082323,

  /* Expression: 180/pi
   * Referenced by: '<S2>/Gain'
   */
  57.295779513082323,

  /* Computed Parameter: ControllerEnable_CurrentSetting
   * Referenced by: '<S1>/Controller Enable'
   */
  1U,

  /* Computed Parameter: ControllerEnable_CurrentSetti_e
   * Referenced by: '<Root>/Controller Enable'
   */
  1U,

  /* Computed Parameter: STOPSimulation_CurrentSetting
   * Referenced by: '<Root>/STOP Simulation'
   */
  0U,

  /* Computed Parameter: SensorsReset_CurrentSetting
   * Referenced by: '<Root>/Sensors Reset'
   */
  0U
};

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
