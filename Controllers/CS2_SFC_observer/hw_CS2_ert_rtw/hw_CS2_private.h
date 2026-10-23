/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: hw_CS2_private.h
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

#ifndef hw_CS2_private_h_
#define hw_CS2_private_h_
#include "rtwtypes.h"
#include "multiword_types.h"
#include "zero_crossing_types.h"
#include "hw_CS2_types.h"
#include "hw_CS2.h"

/* Private macros used by the generated code to access rtModel */
#ifndef rtmIsMajorTimeStep
#define rtmIsMajorTimeStep(rtm)        (((rtm)->Timing.simTimeStep) == MAJOR_TIME_STEP)
#endif

#ifndef rtmIsMinorTimeStep
#define rtmIsMinorTimeStep(rtm)        (((rtm)->Timing.simTimeStep) == MINOR_TIME_STEP)
#endif

#ifndef rtmSetTFinal
#define rtmSetTFinal(rtm, val)         ((rtm)->Timing.tFinal = (val))
#endif

#ifndef rtmSetTPtr
#define rtmSetTPtr(rtm, val)           ((rtm)->Timing.t = (val))
#endif

extern real_T rt_roundd_snf(real_T u);
extern uint32_T MultiWord2uLong(const uint32_T u[]);
extern void uMultiWordShr(const uint32_T u1[], int32_T n1, uint32_T n2, uint32_T
  y[], int32_T n);
extern void Double2MultiWord(real_T u1, uint32_T y[], int32_T n);
extern void MultiWordAnd(const uint32_T u1[], const uint32_T u2[], uint32_T y[],
  int32_T n);

#endif                                 /* hw_CS2_private_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
