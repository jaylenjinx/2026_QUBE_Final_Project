/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: hw_CS1A_data.c
 *
 * Code generated for Simulink model 'hw_CS1A'.
 *
 * Model version                  : 3.47
 * Simulink Coder version         : 25.2 (R2025b) 28-Jul-2025
 * C/C++ source code generated on : Wed Oct 28 19:43:03 2026
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: ARM Compatible->ARM Cortex
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "hw_CS1A.h"

/* Block parameters (default storage) */
P_hw_CS1A_T hw_CS1A_P = {
  /* Variable: aA
   * Referenced by: '<S11>/Controller CS1A'
   */
  { 1.0, -0.941747572815534 },

  /* Variable: aF
   * Referenced by: '<S11>/Controller CS1A'
   */
  { 1.0, -1.99477680912586, 0.99478348216869861 },

  /* Variable: aT
   * Referenced by: '<S11>/Controller CS1A'
   */
  { 1.0, -0.941747572815534 },

  /* Variable: bA
   * Referenced by: '<S11>/Controller CS1A'
   */
  { 181.76975061366394, -179.27069849810627 },

  /* Variable: bF
   * Referenced by: '<S11>/Controller CS1A'
   */
  { 1.6682607096228808E-6, 3.3365214192457616E-6, 1.6682607096228808E-6 },

  /* Variable: bT
   * Referenced by: '<S11>/Controller CS1A'
   */
  { -104.43796178261466, 104.20530699213815 },

  /* Variable: ts
   * Referenced by:
   *   '<S7>/Step'
   *   '<S7>/Step1'
   */
  0.001,

  /* Variable: u_max
   * Referenced by: '<S11>/Controller CS1A'
   */
  10.0,

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

  /* Expression: -1
   * Referenced by: '<S1>/Gain'
   */
  -1.0,

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
  0U,

  /* Computed Parameter: STOPSimulation_CurrentSetting
   * Referenced by: '<Root>/STOP Simulation'
   */
  0U,

  /* Computed Parameter: SensorsReset_CurrentSetting
   * Referenced by: '<Root>/Sensors Reset'
   */
  1U
};

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
