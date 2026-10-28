/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: hw_CS1A.c
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
#include "rt_nonfinite.h"
#include <math.h>
#include "hw_CS1A_private.h"
#include <string.h>
#include "rtwtypes.h"
#include "multiword_types.h"
#include <stddef.h>
#include "zero_crossing_types.h"

/* Block signals (default storage) */
B_hw_CS1A_T hw_CS1A_B;

/* Block states (default storage) */
DW_hw_CS1A_T hw_CS1A_DW;

/* Previous zero-crossings (trigger) states */
PrevZCX_hw_CS1A_T hw_CS1A_PrevZCX;

/* Real-time model */
static RT_MODEL_hw_CS1A_T hw_CS1A_M_;
RT_MODEL_hw_CS1A_T *const hw_CS1A_M = &hw_CS1A_M_;
static void rate_monotonic_scheduler(void);
uint32_T MultiWord2uLong(const uint32_T u[])
{
  return u[0];
}

void uMultiWordShr(const uint32_T u1[], int32_T n1, uint32_T n2, uint32_T y[],
                   int32_T n)
{
  int32_T i;
  int32_T i1;
  int32_T nb;
  int32_T nc;
  uint32_T nr;
  uint32_T u1i;
  uint32_T yi;
  nb = (int32_T)(n2 >> 5);
  i = 0;
  if (nb < n1) {
    nc = n + nb;
    if (nc > n1) {
      nc = n1;
    }

    nr = n2 - ((uint32_T)nb << 5);
    if (nr > 0U) {
      u1i = u1[nb];
      for (i1 = nb + 1; i1 < nc; i1++) {
        yi = u1i >> nr;
        u1i = u1[i1];
        y[i] = u1i << (32U - nr) | yi;
        i++;
      }

      yi = u1i >> nr;
      if (nc < n1) {
        yi |= u1[nc] << (32U - nr);
      }

      y[i] = yi;
      i++;
    } else {
      for (i1 = nb; i1 < nc; i1++) {
        y[i] = u1[i1];
        i++;
      }
    }
  }

  while (i < n) {
    y[i] = 0U;
    i++;
  }
}

void Double2MultiWord(real_T u1, uint32_T y[], int32_T n)
{
  real_T yd;
  real_T yn;
  int32_T currExp;
  int32_T i;
  int32_T msl;
  int32_T prevExp;
  uint32_T cb;
  uint32_T u1i;
  boolean_T isNegative;
  isNegative = (u1 < 0.0);
  yn = frexp(u1, &currExp);
  msl = currExp <= 0 ? -1 : (currExp - 1) / 32;
  cb = 1U;
  for (i = msl + 1; i < n; i++) {
    y[i] = 0U;
  }

  yn = isNegative ? -yn : yn;
  prevExp = msl << 5;
  for (i = msl; i >= 0; i--) {
    yn = ldexp(yn, currExp - prevExp);
    yd = floor(yn);
    yn -= yd;
    if (i < n) {
      y[i] = (uint32_T)yd;
    }

    currExp = prevExp;
    prevExp -= 32;
  }

  if (isNegative) {
    for (i = 0; i < n; i++) {
      u1i = ~y[i];
      cb += u1i;
      y[i] = cb;
      cb = (uint32_T)(cb < u1i);
    }
  }
}

void MultiWordAnd(const uint32_T u1[], const uint32_T u2[], uint32_T y[],
                  int32_T n)
{
  int32_T i;
  for (i = 0; i < n; i++) {
    y[i] = u1[i] & u2[i];
  }
}

/*
 * Set which subrates need to run this base step (base rate always runs).
 * This function must be called prior to calling the model step function
 * in order to remember which rates need to run this base step.  The
 * buffering of events allows for overlapping preemption.
 */
void hw_CS1A_SetEventsForThisBaseStep(boolean_T *eventFlags)
{
  /* Task runs when its counter is zero, computed via rtmStepTask macro */
  eventFlags[2] = ((boolean_T)rtmStepTask(hw_CS1A_M, 2));
}

/*
 *         This function updates active task flag for each subrate
 *         and rate transition flags for tasks that exchange data.
 *         The function assumes rate-monotonic multitasking scheduler.
 *         The function must be called at model base rate so that
 *         the generated code self-manages all its subrates and rate
 *         transition flags.
 */
static void rate_monotonic_scheduler(void)
{
  /* To ensure a deterministic data transfer between two rates,
   * data is transferred at the priority of a fast task and the frequency
   * of the slow task.  The following flags indicate when the data transfer
   * happens.  That is, a rate interaction flag is set true when both rates
   * will run, and false otherwise.
   */

  /* tid 1 shares data with slower tid rate: 2 */
  if (hw_CS1A_M->Timing.TaskCounters.TID[1] == 0) {
    hw_CS1A_M->Timing.RateInteraction.TID1_2 =
      (hw_CS1A_M->Timing.TaskCounters.TID[2] == 0);
  }

  /* Compute which subrates run during the next base time step.  Subrates
   * are an integer multiple of the base rate counter.  Therefore, the subtask
   * counter is reset when it reaches its limit (zero means run).
   */
  (hw_CS1A_M->Timing.TaskCounters.TID[2])++;
  if ((hw_CS1A_M->Timing.TaskCounters.TID[2]) > 1) {/* Sample time: [0.001s, 0.0s] */
    hw_CS1A_M->Timing.TaskCounters.TID[2] = 0;
  }
}

real_T rt_roundd_snf(real_T u)
{
  real_T y;
  if (fabs(u) < 4.503599627370496E+15) {
    if (u >= 0.5) {
      y = floor(u + 0.5);
    } else if (u > -0.5) {
      y = u * 0.0;
    } else {
      y = ceil(u - 0.5);
    }
  } else {
    y = u;
  }

  return y;
}

/* Model step function for TID0 */
void hw_CS1A_step0(void)               /* Sample time: [0.0s, 0.0s] */
{
  uint64m_T tmp;
  uint64m_T tmp_0;
  uint64m_T tmp_1;
  uint64m_T tmp_2;
  uint64m_T tmp_3;
  real_T y;
  int32_T Reset_b;
  int16_T x;
  uint16_T motor;
  uint8_T tmp_4;
  boolean_T rtb_LogicalOperator;
  ZCEventType zcEvent;
  static const uint64m_T tmp_5 = { { 255U, 0U }/* chunks */
  };

  {                                    /* Sample time: [0.0s, 0.0s] */
    rate_monotonic_scheduler();
  }

  /* Reset subsysRan breadcrumbs */
  srClearBC(hw_CS1A_DW.QS2_SubsysRanBC);

  /* Memory: '<S7>/Memory' */
  hw_CS1A_B.Memory = hw_CS1A_DW.Memory_PreviousInput;

  /* MATLAB Function: '<S7>/alpha zero pointing upwards' incorporates:
   *  Memory: '<S7>/Memory1'
   */
  if (rtIsNaN(hw_CS1A_DW.Memory1_PreviousInput)) {
    hw_CS1A_B.q = (rtNaN);
  } else if (rtIsInf(hw_CS1A_DW.Memory1_PreviousInput)) {
    hw_CS1A_B.q = (rtNaN);
  } else {
    hw_CS1A_B.q = fabs(hw_CS1A_DW.Memory1_PreviousInput / 6.2831853071795862);
    if (fabs(hw_CS1A_B.q - floor(hw_CS1A_B.q + 0.5)) > 2.2204460492503131E-16 *
        hw_CS1A_B.q) {
      hw_CS1A_B.q = fmod(hw_CS1A_DW.Memory1_PreviousInput, 6.2831853071795862);
    } else {
      hw_CS1A_B.q = 0.0;
    }

    if (hw_CS1A_B.q == 0.0) {
      hw_CS1A_B.q = 0.0;
    } else if (hw_CS1A_B.q < 0.0) {
      hw_CS1A_B.q += 6.2831853071795862;
    }
  }

  if ((hw_CS1A_B.q == 0.0) && (hw_CS1A_DW.Memory1_PreviousInput > 0.0)) {
    hw_CS1A_B.q = 6.2831853071795862;
  }

  hw_CS1A_B.alpha = hw_CS1A_B.q - 3.1415926535897931;

  /* End of MATLAB Function: '<S7>/alpha zero pointing upwards' */

  /* Outputs for Atomic SubSystem: '<Root>/Controller' */
  /* ManualSwitch: '<S1>/Controller Enable' incorporates:
   *  Constant: '<S15>/Reset_manual 0'
   *  Constant: '<S15>/Reset_manual 1'
   */
  if (hw_CS1A_P.ControllerEnable_CurrentSetting == 1) {
    hw_CS1A_B.q = hw_CS1A_P.Reset_manual1_Value;
  } else {
    hw_CS1A_B.q = hw_CS1A_P.Reset_manual0_Value;
  }

  /* End of Outputs for SubSystem: '<Root>/Controller' */

  /* ManualSwitch: '<Root>/Controller Enable' incorporates:
   *  Constant: '<S6>/Reset_manual 0'
   *  Constant: '<S6>/Reset_manual 1'
   */
  if (hw_CS1A_P.ControllerEnable_CurrentSetti_e == 1) {
    hw_CS1A_B.RR_tmp = hw_CS1A_P.Reset_manual1_Value_e;
  } else {
    hw_CS1A_B.RR_tmp = hw_CS1A_P.Reset_manual0_Value_i;
  }

  /* Outputs for Atomic SubSystem: '<Root>/Controller' */
  /* Logic: '<S10>/Logical Operator' incorporates:
   *  Constant: '<S16>/Constant'
   *  Constant: '<S17>/Constant'
   *  ManualSwitch: '<Root>/Controller Enable'
   *  ManualSwitch: '<S1>/Controller Enable'
   *  RelationalOperator: '<S16>/Compare'
   *  RelationalOperator: '<S17>/Compare'
   */
  rtb_LogicalOperator = ((hw_CS1A_B.q > hw_CS1A_P.Constant_Value_l) &&
    (hw_CS1A_B.RR_tmp > hw_CS1A_P.Constant_Value));

  /* RateTransition generated from: '<S11>/Controller CS1A' incorporates:
   *  Constant: '<Root>/theta ref [deg]'
   *  Gain: '<S12>/Gain1'
   *  Gain: '<S1>/Gain'
   *  Logic: '<S10>/Logical Operator1'
   *  Product: '<S14>/Product4'
   *  Product: '<S8>/Product4'
   *  Product: '<S9>/Product4'
   *  RateTransition generated from: '<S7>/Toogle Reset'
   */
  if (hw_CS1A_M->Timing.RateInteraction.TID1_2) {
    hw_CS1A_DW.x_ref_Buffer = hw_CS1A_P.Gain1_Gain * hw_CS1A_P.thetarefdeg_Value
      * (real_T)rtb_LogicalOperator;
    hw_CS1A_DW.TmpRTBAtControllerCS1AInport3_B = hw_CS1A_B.alpha * (real_T)
      rtb_LogicalOperator * hw_CS1A_P.Gain_Gain;
    hw_CS1A_DW.TmpRTBAtControllerCS1AInport4_B = !rtb_LogicalOperator;
    hw_CS1A_DW.xc_Buffer = hw_CS1A_B.Memory * (real_T)rtb_LogicalOperator;

    /* RateTransition generated from: '<S13>/Product4' incorporates:
     *  Constant: '<Root>/theta ref [deg]'
     *  Gain: '<S12>/Gain1'
     *  Gain: '<S1>/Gain'
     *  Logic: '<S10>/Logical Operator1'
     *  Product: '<S14>/Product4'
     *  Product: '<S8>/Product4'
     *  Product: '<S9>/Product4'
     */
    hw_CS1A_B.u = hw_CS1A_DW.u_Buffer0;

    /* RateTransition generated from: '<S7>/Toogle Reset' */
    hw_CS1A_B.TmpRTBAtToogleResetOutport1 =
      hw_CS1A_DW.TmpRTBAtToogleResetOutport1_Buf;
  }

  /* End of RateTransition generated from: '<S11>/Controller CS1A' */

  /* Product: '<S13>/Product4' */
  hw_CS1A_B.Product4 = hw_CS1A_B.u * (real_T)rtb_LogicalOperator;

  /* End of Outputs for SubSystem: '<Root>/Controller' */

  /* Step: '<S7>/Step' incorporates:
   *  Step: '<S7>/Step1'
   */
  hw_CS1A_B.RR_tmp = ((hw_CS1A_M->Timing.clockTick1) * 0.0005);
  if (hw_CS1A_B.RR_tmp < hw_CS1A_P.ts) {
    hw_CS1A_B.q = hw_CS1A_P.Step_Y0;
  } else {
    hw_CS1A_B.q = hw_CS1A_P.Step_YFinal;
  }

  /* Step: '<S7>/Step1' */
  if (hw_CS1A_B.RR_tmp < 2.0 * hw_CS1A_P.ts) {
    hw_CS1A_B.RR_tmp = hw_CS1A_P.Step1_Y0;
  } else {
    hw_CS1A_B.RR_tmp = hw_CS1A_P.Step1_YFinal;
  }

  /* Logic: '<S7>/Logical Operator' incorporates:
   *  Step: '<S7>/Step'
   *  Step: '<S7>/Step1'
   *  Sum: '<S7>/Sum'
   */
  hw_CS1A_B.RR = ((hw_CS1A_B.TmpRTBAtToogleResetOutport1 != 0.0) || (hw_CS1A_B.q
    + hw_CS1A_B.RR_tmp != 0.0));

  /* DiscretePulseGenerator: '<S7>/Pulse Generator1' */
  hw_CS1A_B.q = (hw_CS1A_DW.clockTickCounter < hw_CS1A_P.PulseGenerator1_Duty) &&
    (hw_CS1A_DW.clockTickCounter >= 0) ? hw_CS1A_P.PulseGenerator1_Amp : 0.0;
  if (hw_CS1A_DW.clockTickCounter >= hw_CS1A_P.PulseGenerator1_Period - 1.0) {
    hw_CS1A_DW.clockTickCounter = 0;
  } else {
    hw_CS1A_DW.clockTickCounter++;
  }

  /* End of DiscretePulseGenerator: '<S7>/Pulse Generator1' */

  /* Outputs for Triggered SubSystem: '<S7>/QS2' incorporates:
   *  TriggerPort: '<S20>/Trigger'
   */
  zcEvent = rt_ZCFcn(RISING_ZERO_CROSSING,&hw_CS1A_PrevZCX.QS2_Trig_ZCE,
                     (hw_CS1A_B.q));
  if (zcEvent != NO_ZCEVENT) {
    /* ManualSwitch: '<Root>/STOP Simulation' incorporates:
     *  Constant: '<S5>/Reset_manual 0'
     *  Constant: '<S5>/Reset_manual 1'
     */
    if (hw_CS1A_P.STOPSimulation_CurrentSetting == 1) {
      hw_CS1A_B.q = hw_CS1A_P.Reset_manual1_Value_l;
    } else {
      hw_CS1A_B.q = hw_CS1A_P.Reset_manual0_Value_l;
    }

    /* MATLAB Function: '<S20>/Toogle Stop' incorporates:
     *  ManualSwitch: '<Root>/STOP Simulation'
     */
    rtb_LogicalOperator = (hw_CS1A_B.q > 0.5);
    Reset_b = 0;
    if ((rtb_LogicalOperator != hw_CS1A_DW.reset_in_prev_m) && (hw_CS1A_DW.count
         > 5.0)) {
      Reset_b = 1;
    }

    hw_CS1A_DW.reset_in_prev_m = rtb_LogicalOperator;
    hw_CS1A_DW.count++;
    if (hw_CS1A_DW.count > 5.0) {
      hw_CS1A_DW.count = 10.0;
    }

    /* End of MATLAB Function: '<S20>/Toogle Stop' */

    /* MATLAB Function: '<S20>/MATLAB Function1' */
    hw_CS1A_DW.stop = ((Reset_b > 0) || hw_CS1A_DW.stop);
    rtb_LogicalOperator = true;
    if (hw_CS1A_DW.count_startup >= 5.0) {
      rtb_LogicalOperator = false;
      hw_CS1A_DW.count_startup = 10.0;
    }

    for (Reset_b = 0; Reset_b < 17; Reset_b++) {
      hw_CS1A_B.data_out[Reset_b] = 0U;
    }

    hw_CS1A_B.data_out[0] = 1U;
    hw_CS1A_B.data_out[2] = 31U;

    /* Saturate: '<S20>/+- 10V' */
    if (hw_CS1A_B.Product4 > hw_CS1A_P.u0V_UpperSat) {
      hw_CS1A_B.q = hw_CS1A_P.u0V_UpperSat;
    } else if (hw_CS1A_B.Product4 < hw_CS1A_P.u0V_LowerSat) {
      hw_CS1A_B.q = hw_CS1A_P.u0V_LowerSat;
    } else {
      hw_CS1A_B.q = hw_CS1A_B.Product4;
    }

    /* MATLAB Function: '<S20>/MATLAB Function1' incorporates:
     *  Abs: '<S7>/Abs'
     *  Constant: '<Root>/Motor Enable'
     *  Constant: '<Root>/Protection'
     *  Constant: '<S19>/Constant'
     *  Constant: '<S7>/Constant1'
     *  Constant: '<S7>/Constant2'
     *  Constant: '<S7>/Constant3'
     *  Gain: '<S21>/Gain'
     *  Logic: '<S7>/Logical Operator1'
     *  Product: '<S7>/Product'
     *  RelationalOperator: '<S19>/Compare'
     *  Saturate: '<S20>/+- 10V'
     */
    hw_CS1A_B.q = rt_roundd_snf(hw_CS1A_B.q * 41.666666666666664);
    if (hw_CS1A_B.q < 32768.0) {
      if (hw_CS1A_B.q >= -32768.0) {
        x = (int16_T)hw_CS1A_B.q;
      } else {
        x = MIN_int16_T;
      }
    } else {
      x = MAX_int16_T;
    }

    x |= MIN_int16_T;
    memcpy((void *)&motor, (void *)&x, (size_t)1 * sizeof(uint16_T));
    hw_CS1A_B.data_out[15] = (uint8_T)(motor >> 8);
    hw_CS1A_B.data_out[16] = (uint8_T)(motor & 255U);
    if ((!(hw_CS1A_P.MotorEnable_Value != 0.0)) || (!(fabs(hw_CS1A_P.Gain_Gain_f
           * hw_CS1A_B.alpha * hw_CS1A_P.Protection_Value) <
          hw_CS1A_P.CompareToConstant_const))) {
      hw_CS1A_B.data_out[2] = 31U;
      hw_CS1A_B.data_out[15] = 0U;
      hw_CS1A_B.data_out[16] = 0U;
    }

    if (hw_CS1A_B.RR || rtb_LogicalOperator) {
      hw_CS1A_B.data_out[2] = 127U;
      hw_CS1A_B.data_out[15] = 0U;
      hw_CS1A_B.data_out[16] = 0U;
    }

    if (hw_CS1A_DW.stop || (hw_CS1A_DW.count_stop > 1.0)) {
      hw_CS1A_DW.count_stop++;
      hw_CS1A_B.data_out[2] = 31U;
      hw_CS1A_B.data_out[15] = 0U;
      hw_CS1A_B.data_out[16] = 0U;
    }

    hw_CS1A_DW.count_startup++;
    if ((hw_CS1A_P.Constant1_Value <= 0.0) || rtIsNaN(hw_CS1A_P.Constant1_Value))
    {
      y = 0.0;
    } else {
      y = hw_CS1A_P.Constant1_Value;
    }

    if (y >= 1.0) {
      y = 1.0;
    }

    hw_CS1A_B.q = 999.0 * y;
    if ((hw_CS1A_P.Constant2_Value <= 0.0) || rtIsNaN(hw_CS1A_P.Constant2_Value))
    {
      y = 0.0;
    } else {
      y = hw_CS1A_P.Constant2_Value;
    }

    if (y >= 1.0) {
      y = 1.0;
    }

    hw_CS1A_B.RR_tmp = 999.0 * y;
    if ((hw_CS1A_P.Constant3_Value <= 0.0) || rtIsNaN(hw_CS1A_P.Constant3_Value))
    {
      y = 0.0;
    } else {
      y = hw_CS1A_P.Constant3_Value;
    }

    if (y >= 1.0) {
      y = 1.0;
    }

    y *= 999.0;
    Double2MultiWord(hw_CS1A_B.q, &tmp_0.chunks[0U], 2);
    uMultiWordShr(&tmp_0.chunks[0U], 2, 8U, &tmp.chunks[0U], 2);
    hw_CS1A_B.data_out[3] = (uint8_T)MultiWord2uLong(&tmp.chunks[0U]);
    Double2MultiWord(hw_CS1A_B.q, &tmp_1.chunks[0U], 2);
    tmp = tmp_5;
    MultiWordAnd(&tmp_1.chunks[0U], &tmp_5.chunks[0U], &tmp_0.chunks[0U], 2);
    hw_CS1A_B.data_out[4] = (uint8_T)MultiWord2uLong(&tmp_0.chunks[0U]);
    Double2MultiWord(hw_CS1A_B.RR_tmp, &tmp.chunks[0U], 2);
    uMultiWordShr(&tmp.chunks[0U], 2, 8U, &tmp_1.chunks[0U], 2);
    hw_CS1A_B.data_out[5] = (uint8_T)MultiWord2uLong(&tmp_1.chunks[0U]);
    Double2MultiWord(hw_CS1A_B.RR_tmp, &tmp_2.chunks[0U], 2);
    tmp_0 = tmp_5;
    MultiWordAnd(&tmp_2.chunks[0U], &tmp_5.chunks[0U], &tmp.chunks[0U], 2);
    hw_CS1A_B.data_out[6] = (uint8_T)MultiWord2uLong(&tmp.chunks[0U]);
    Double2MultiWord(y, &tmp_0.chunks[0U], 2);
    uMultiWordShr(&tmp_0.chunks[0U], 2, 8U, &tmp_2.chunks[0U], 2);
    hw_CS1A_B.data_out[7] = (uint8_T)MultiWord2uLong(&tmp_2.chunks[0U]);
    Double2MultiWord(y, &tmp_3.chunks[0U], 2);
    MultiWordAnd(&tmp_3.chunks[0U], &tmp_5.chunks[0U], &tmp_0.chunks[0U], 2);
    hw_CS1A_B.data_out[8] = (uint8_T)MultiWord2uLong(&tmp_0.chunks[0U]);

    /* MATLABSystem: '<S20>/SPI WriteRead' */
    if (hw_CS1A_DW.obj.slaveSelectPin_ != hw_CS1A_P.SPIWriteRead_slaveSelectPin_)
    {
      hw_CS1A_DW.obj.slaveSelectPin_ = hw_CS1A_P.SPIWriteRead_slaveSelectPin_;
    }

    hw_CS1A_B.q = rt_roundd_snf(hw_CS1A_DW.obj.slaveSelectPin_);
    if (hw_CS1A_B.q < 256.0) {
      if (hw_CS1A_B.q >= 0.0) {
        tmp_4 = (uint8_T)hw_CS1A_B.q;
      } else {
        tmp_4 = 0U;
      }
    } else {
      tmp_4 = MAX_uint8_T;
    }

    MW_SPIwriteReadLoop(0, tmp_4, &hw_CS1A_B.data_out[0], 17.0, 1.0,
                        &hw_CS1A_B.uv[0]);

    /* MATLAB Function: '<S20>/MATLAB Function' incorporates:
     *  MATLABSystem: '<S20>/SPI WriteRead'
     */
    hw_CS1A_B.encoder0 = ((int32_T)((uint32_T)hw_CS1A_B.uv[2] << 16 | (uint32_T)
      hw_CS1A_B.uv[3] << 8 | hw_CS1A_B.uv[4]) << 8) >> 8;
    Reset_b = ((int32_T)((uint32_T)hw_CS1A_B.uv[5] << 16 | (uint32_T)
                         hw_CS1A_B.uv[6] << 8 | hw_CS1A_B.uv[7]) << 8) >> 8;
    Reset_b -= (Reset_b >> 11) << 11;
    if (Reset_b < 0) {
      Reset_b += 2048;
    }

    hw_CS1A_B.encoder1 = Reset_b;

    /* End of MATLAB Function: '<S20>/MATLAB Function' */

    /* Stop: '<S20>/Stop Simulation' incorporates:
     *  MATLAB Function: '<S20>/MATLAB Function1'
     */
    if (hw_CS1A_DW.count_stop > 1.0) {
      rtmSetStopRequested(hw_CS1A_M, 1);
    }

    /* End of Stop: '<S20>/Stop Simulation' */
    hw_CS1A_DW.QS2_SubsysRanBC = 4;
  }

  /* End of Outputs for SubSystem: '<S7>/QS2' */

  /* MATLAB Function: '<S7>/phi zero pointing downwards' */
  hw_CS1A_B.alpha_rad = hw_CS1A_B.encoder1 * 0.0030679615757712823;

  /* MATLAB Function: '<S7>/theta' */
  hw_CS1A_B.theta_rad = hw_CS1A_B.encoder0 * 0.0030679615757712823;

  /* Gain: '<S3>/Gain' */
  hw_CS1A_B.Gain = hw_CS1A_P.Gain_Gain_d * hw_CS1A_B.alpha;

  /* Gain: '<S2>/Gain' */
  hw_CS1A_B.Gain_g = hw_CS1A_P.Gain_Gain_m * hw_CS1A_B.Memory;

  /* Clock: '<S7>/Clock' */
  hw_CS1A_B.Clock = hw_CS1A_M->Timing.t[0];

  /* Update for Memory: '<S7>/Memory' */
  hw_CS1A_DW.Memory_PreviousInput = hw_CS1A_B.theta_rad;

  /* Update for Memory: '<S7>/Memory1' */
  hw_CS1A_DW.Memory1_PreviousInput = hw_CS1A_B.alpha_rad;

  /* Update absolute time */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   */
  hw_CS1A_M->Timing.t[0] =
    ((time_T)(++hw_CS1A_M->Timing.clockTick0)) * hw_CS1A_M->Timing.stepSize0;

  /* Update absolute time */
  /* The "clockTick1" counts the number of times the code of this task has
   * been executed. The resolution of this integer timer is 0.0005, which is the step size
   * of the task. Size of "clockTick1" ensures timer will not overflow during the
   * application lifespan selected.
   */
  hw_CS1A_M->Timing.clockTick1++;
}

/* Model step function for TID2 */
void hw_CS1A_step2(void)               /* Sample time: [0.001s, 0.0s] */
{
  real_T u_m;
  real_T x;
  boolean_T reset_in;

  /* ManualSwitch: '<Root>/Sensors Reset' incorporates:
   *  Constant: '<S4>/Reset_manual 0'
   *  Constant: '<S4>/Reset_manual 1'
   */
  if (hw_CS1A_P.SensorsReset_CurrentSetting == 1) {
    u_m = hw_CS1A_P.Reset_manual1_Value_ly;
  } else {
    u_m = hw_CS1A_P.Reset_manual0_Value_b;
  }

  /* MATLAB Function: '<S7>/Toogle Reset' incorporates:
   *  ManualSwitch: '<Root>/Sensors Reset'
   */
  reset_in = (u_m > 0.5);

  /* RateTransition generated from: '<S7>/Toogle Reset' incorporates:
   *  MATLAB Function: '<S7>/Toogle Reset'
   */
  hw_CS1A_DW.TmpRTBAtToogleResetOutport1_Buf = 0.0;

  /* MATLAB Function: '<S7>/Toogle Reset' */
  if (reset_in != hw_CS1A_DW.reset_in_prev) {
    /* RateTransition generated from: '<S7>/Toogle Reset' */
    hw_CS1A_DW.TmpRTBAtToogleResetOutport1_Buf = 1.0;
  }

  hw_CS1A_DW.reset_in_prev = reset_in;

  /* Outputs for Atomic SubSystem: '<Root>/Controller' */
  /* MATLAB Function: '<S11>/Controller CS1A' incorporates:
   *  RateTransition generated from: '<S11>/Controller CS1A'
   */
  if ((!hw_CS1A_DW.started_not_empty) ||
      hw_CS1A_DW.TmpRTBAtControllerCS1AInport4_B) {
    hw_CS1A_DW.wF[0] = 0.0;
    hw_CS1A_DW.wF[1] = 0.0;
    hw_CS1A_DW.wT = 0.0;
    hw_CS1A_DW.wA = 0.0;
    hw_CS1A_DW.started_not_empty = true;
  }

  u_m = hw_CS1A_P.bF[0] * hw_CS1A_DW.x_ref_Buffer + hw_CS1A_DW.wF[0];
  hw_CS1A_DW.wF[0] = (hw_CS1A_P.bF[1] * hw_CS1A_DW.x_ref_Buffer + hw_CS1A_DW.wF
                      [1]) - hw_CS1A_P.aF[1] * u_m;
  hw_CS1A_DW.wF[1] = hw_CS1A_P.bF[2] * hw_CS1A_DW.x_ref_Buffer - hw_CS1A_P.aF[2]
    * u_m;
  x = u_m - hw_CS1A_DW.xc_Buffer;
  u_m = hw_CS1A_P.bT[0] * x + hw_CS1A_DW.wT;
  hw_CS1A_DW.wT = hw_CS1A_P.bT[1] * x - hw_CS1A_P.aT[1] * u_m;
  x = (0.0 - hw_CS1A_DW.TmpRTBAtControllerCS1AInport3_B) * hw_CS1A_P.bA[0] +
    hw_CS1A_DW.wA;
  hw_CS1A_DW.wA = (0.0 - hw_CS1A_DW.TmpRTBAtControllerCS1AInport3_B) *
    hw_CS1A_P.bA[1] - hw_CS1A_P.aA[1] * x;
  u_m += x;
  if ((!(u_m >= -hw_CS1A_P.u_max)) && (!rtIsNaN(-hw_CS1A_P.u_max))) {
    u_m = -hw_CS1A_P.u_max;
  }

  if ((!(u_m <= hw_CS1A_P.u_max)) && (!rtIsNaN(hw_CS1A_P.u_max))) {
    u_m = hw_CS1A_P.u_max;
  }

  if (hw_CS1A_DW.TmpRTBAtControllerCS1AInport4_B) {
    u_m = 0.0;
  }

  /* End of MATLAB Function: '<S11>/Controller CS1A' */

  /* Saturate: '<S1>/Saturation' */
  if (u_m > hw_CS1A_P.Saturation_UpperSat) {
    u_m = hw_CS1A_P.Saturation_UpperSat;
  } else if (u_m < hw_CS1A_P.Saturation_LowerSat) {
    u_m = hw_CS1A_P.Saturation_LowerSat;
  }

  /* End of Saturate: '<S1>/Saturation' */

  /* RateTransition generated from: '<S13>/Product4' */
  hw_CS1A_DW.u_Buffer0 = u_m;

  /* End of Outputs for SubSystem: '<Root>/Controller' */

  /* Update absolute time */
  /* The "clockTick2" counts the number of times the code of this task has
   * been executed. The resolution of this integer timer is 0.001, which is the step size
   * of the task. Size of "clockTick2" ensures timer will not overflow during the
   * application lifespan selected.
   */
  hw_CS1A_M->Timing.clockTick2++;
}

/* Model initialize function */
void hw_CS1A_initialize(void)
{
  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));

  {
    /* Setup solver object */
    rtsiSetSimTimeStepPtr(&hw_CS1A_M->solverInfo, &hw_CS1A_M->Timing.simTimeStep);
    rtsiSetTPtr(&hw_CS1A_M->solverInfo, &rtmGetTPtr(hw_CS1A_M));
    rtsiSetStepSizePtr(&hw_CS1A_M->solverInfo, &hw_CS1A_M->Timing.stepSize0);
    rtsiSetErrorStatusPtr(&hw_CS1A_M->solverInfo, (&rtmGetErrorStatus(hw_CS1A_M)));
    rtsiSetRTModelPtr(&hw_CS1A_M->solverInfo, hw_CS1A_M);
  }

  rtsiSetSimTimeStep(&hw_CS1A_M->solverInfo, MAJOR_TIME_STEP);
  rtsiSetIsMinorTimeStepWithModeChange(&hw_CS1A_M->solverInfo, false);
  rtsiSetIsContModeFrozen(&hw_CS1A_M->solverInfo, false);
  rtsiSetSolverName(&hw_CS1A_M->solverInfo,"FixedStepDiscrete");
  rtmSetTPtr(hw_CS1A_M, &hw_CS1A_M->Timing.tArray[0]);
  rtmSetTFinal(hw_CS1A_M, -1);
  hw_CS1A_M->Timing.stepSize0 = 0.0005;

  /* External mode info */
  hw_CS1A_M->Sizes.checksums[0] = (3901399161U);
  hw_CS1A_M->Sizes.checksums[1] = (1385844996U);
  hw_CS1A_M->Sizes.checksums[2] = (542163385U);
  hw_CS1A_M->Sizes.checksums[3] = (649461393U);

  {
    static const sysRanDType rtAlwaysEnabled = SUBSYS_RAN_BC_ENABLE;
    static RTWExtModeInfo rt_ExtModeInfo;
    static const sysRanDType *systemRan[20];
    hw_CS1A_M->extModeInfo = (&rt_ExtModeInfo);
    rteiSetSubSystemActiveVectorAddresses(&rt_ExtModeInfo, systemRan);
    systemRan[0] = &rtAlwaysEnabled;
    systemRan[1] = &rtAlwaysEnabled;
    systemRan[2] = &rtAlwaysEnabled;
    systemRan[3] = &rtAlwaysEnabled;
    systemRan[4] = &rtAlwaysEnabled;
    systemRan[5] = (sysRanDType *)&hw_CS1A_DW.QS2_SubsysRanBC;
    systemRan[6] = (sysRanDType *)&hw_CS1A_DW.QS2_SubsysRanBC;
    systemRan[7] = (sysRanDType *)&hw_CS1A_DW.QS2_SubsysRanBC;
    systemRan[8] = (sysRanDType *)&hw_CS1A_DW.QS2_SubsysRanBC;
    systemRan[9] = (sysRanDType *)&hw_CS1A_DW.QS2_SubsysRanBC;
    systemRan[10] = &rtAlwaysEnabled;
    systemRan[11] = &rtAlwaysEnabled;
    systemRan[12] = &rtAlwaysEnabled;
    systemRan[13] = &rtAlwaysEnabled;
    systemRan[14] = &rtAlwaysEnabled;
    systemRan[15] = &rtAlwaysEnabled;
    systemRan[16] = &rtAlwaysEnabled;
    systemRan[17] = &rtAlwaysEnabled;
    systemRan[18] = &rtAlwaysEnabled;
    systemRan[19] = &rtAlwaysEnabled;
    rteiSetModelMappingInfoPtr(hw_CS1A_M->extModeInfo,
      &hw_CS1A_M->SpecialInfo.mappingInfo);
    rteiSetChecksumsPtr(hw_CS1A_M->extModeInfo, hw_CS1A_M->Sizes.checksums);
    rteiSetTPtr(hw_CS1A_M->extModeInfo, rtmGetTPtr(hw_CS1A_M));
  }

  {
    real_T tmp;
    uint8_T tmp_0;

    /* Start for RateTransition generated from: '<S7>/Toogle Reset' */
    hw_CS1A_B.TmpRTBAtToogleResetOutport1 =
      hw_CS1A_P.TmpRTBAtToogleResetOutport1_Ini;
    hw_CS1A_PrevZCX.QS2_Trig_ZCE = UNINITIALIZED_ZCSIG;

    /* InitializeConditions for Memory: '<S7>/Memory' */
    hw_CS1A_DW.Memory_PreviousInput = hw_CS1A_P.Memory_InitialCondition;

    /* InitializeConditions for Memory: '<S7>/Memory1' */
    hw_CS1A_DW.Memory1_PreviousInput = hw_CS1A_P.Memory1_InitialCondition;

    /* InitializeConditions for RateTransition generated from: '<S7>/Toogle Reset' */
    hw_CS1A_DW.TmpRTBAtToogleResetOutport1_Buf =
      hw_CS1A_P.TmpRTBAtToogleResetOutport1_Ini;

    /* SystemInitialize for Atomic SubSystem: '<Root>/Controller' */
    /* Start for RateTransition generated from: '<S13>/Product4' */
    hw_CS1A_B.u = hw_CS1A_P.u_InitialCondition;

    /* InitializeConditions for RateTransition generated from: '<S13>/Product4' */
    hw_CS1A_DW.u_Buffer0 = hw_CS1A_P.u_InitialCondition;

    /* End of SystemInitialize for SubSystem: '<Root>/Controller' */

    /* SystemInitialize for Triggered SubSystem: '<S7>/QS2' */
    /* SystemInitialize for MATLAB Function: '<S20>/MATLAB Function1' */
    hw_CS1A_DW.count_startup = 1.0;
    hw_CS1A_DW.count_stop = 1.0;

    /* SystemInitialize for MATLAB Function: '<S20>/Toogle Stop' */
    hw_CS1A_DW.count = 1.0;

    /* Start for MATLABSystem: '<S20>/SPI WriteRead' */
    hw_CS1A_DW.obj.matlabCodegenIsDeleted = false;
    hw_CS1A_DW.obj.slaveSelectPin_ = hw_CS1A_P.SPIWriteRead_slaveSelectPin_;
    hw_CS1A_DW.obj.isInitialized = 1;
    tmp = rt_roundd_snf(hw_CS1A_DW.obj.slaveSelectPin_);
    if (tmp < 256.0) {
      if (tmp >= 0.0) {
        tmp_0 = (uint8_T)tmp;
      } else {
        tmp_0 = 0U;
      }
    } else {
      tmp_0 = MAX_uint8_T;
    }

    MW_SSpinSetup(tmp_0);
    hw_CS1A_DW.obj.isSetupComplete = true;

    /* End of Start for MATLABSystem: '<S20>/SPI WriteRead' */

    /* SystemInitialize for Outport: '<S20>/encoder0' */
    hw_CS1A_B.encoder0 = hw_CS1A_P.encoder0_Y0;

    /* SystemInitialize for Outport: '<S20>/encoder1' */
    hw_CS1A_B.encoder1 = hw_CS1A_P.encoder1_Y0;

    /* End of SystemInitialize for SubSystem: '<S7>/QS2' */
  }
}

/* Model terminate function */
void hw_CS1A_terminate(void)
{
  /* Terminate for Triggered SubSystem: '<S7>/QS2' */
  /* Terminate for MATLABSystem: '<S20>/SPI WriteRead' */
  if (!hw_CS1A_DW.obj.matlabCodegenIsDeleted) {
    hw_CS1A_DW.obj.matlabCodegenIsDeleted = true;
  }

  /* End of Terminate for MATLABSystem: '<S20>/SPI WriteRead' */
  /* End of Terminate for SubSystem: '<S7>/QS2' */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
