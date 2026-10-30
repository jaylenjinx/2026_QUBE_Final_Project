/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: hw_CS1A.h
 *
 * Code generated for Simulink model 'hw_CS1A'.
 *
 * Model version                  : 3.47
 * Simulink Coder version         : 25.2 (R2025b) 28-Jul-2025
 * C/C++ source code generated on : Fri Oct 30 11:39:50 2026
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: ARM Compatible->ARM Cortex
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef hw_CS1A_h_
#define hw_CS1A_h_
#ifndef hw_CS1A_COMMON_INCLUDES_
#define hw_CS1A_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "rtw_extmode.h"
#include "sysran_types.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "MW_SPIwriteRead.h"
#endif                                 /* hw_CS1A_COMMON_INCLUDES_ */

#include "hw_CS1A_types.h"
#include "rt_nonfinite.h"
#include "rt_zcfcn.h"
#include "rtGetNaN.h"
#include <math.h>
#include "zero_crossing_types.h"
#include "MW_target_hardware_resources.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetFinalTime
#define rtmGetFinalTime(rtm)           ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetRTWExtModeInfo
#define rtmGetRTWExtModeInfo(rtm)      ((rtm)->extModeInfo)
#endif

#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

#ifndef rtmStepTask
#define rtmStepTask(rtm, idx)          ((rtm)->Timing.TaskCounters.TID[(idx)] == 0)
#endif

#ifndef rtmGetStopRequested
#define rtmGetStopRequested(rtm)       ((rtm)->Timing.stopRequestedFlag)
#endif

#ifndef rtmSetStopRequested
#define rtmSetStopRequested(rtm, val)  ((rtm)->Timing.stopRequestedFlag = (val))
#endif

#ifndef rtmGetStopRequestedPtr
#define rtmGetStopRequestedPtr(rtm)    (&((rtm)->Timing.stopRequestedFlag))
#endif

#ifndef rtmGetT
#define rtmGetT(rtm)                   (rtmGetTPtr((rtm))[0])
#endif

#ifndef rtmGetTFinal
#define rtmGetTFinal(rtm)              ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetTPtr
#define rtmGetTPtr(rtm)                ((rtm)->Timing.t)
#endif

#ifndef rtmTaskCounter
#define rtmTaskCounter(rtm, idx)       ((rtm)->Timing.TaskCounters.TID[(idx)])
#endif

/* Block signals (default storage) */
typedef struct {
  uint8_T uv[17];
  uint8_T data_out[17];
  real_T Memory;                       /* '<S7>/Memory' */
  real_T TmpRTBAtToogleResetOutport1;  /* '<S7>/Toogle Reset' */
  real_T Gain;                         /* '<S3>/Gain' */
  real_T Gain_g;                       /* '<S2>/Gain' */
  real_T Clock;                        /* '<S7>/Clock' */
  real_T theta_rad;                    /* '<S7>/theta' */
  real_T alpha_rad;                    /* '<S7>/phi zero pointing downwards' */
  real_T alpha;                        /* '<S7>/alpha zero pointing upwards' */
  real_T encoder0;                     /* '<S20>/MATLAB Function' */
  real_T encoder1;                     /* '<S20>/MATLAB Function' */
  real_T u;
  real_T Product4;                     /* '<S13>/Product4' */
  real_T q;
  real_T RR_tmp;
  boolean_T RR;                        /* '<S7>/Logical Operator' */
} B_hw_CS1A_T;

/* Block states (default storage) for system '<Root>' */
typedef struct {
  codertarget_arduinobase_inter_T obj; /* '<S20>/SPI WriteRead' */
  real_T Memory_PreviousInput;         /* '<S7>/Memory' */
  real_T Memory1_PreviousInput;        /* '<S7>/Memory1' */
  real_T TmpRTBAtToogleResetOutport1_Buf;/* synthesized block */
  real_T count;                        /* '<S20>/Toogle Stop' */
  real_T count_startup;                /* '<S20>/MATLAB Function1' */
  real_T count_stop;                   /* '<S20>/MATLAB Function1' */
  real_T x_ref_Buffer;                 /* synthesized block */
  real_T TmpRTBAtControllerCS1AInport3_B;/* synthesized block */
  real_T xc_Buffer;                    /* synthesized block */
  real_T u_Buffer0;                    /* synthesized block */
  real_T wF[2];                        /* '<S11>/Controller CS1A' */
  real_T wT;                           /* '<S11>/Controller CS1A' */
  real_T wA;                           /* '<S11>/Controller CS1A' */
  int32_T clockTickCounter;            /* '<S7>/Pulse Generator1' */
  int8_T QS2_SubsysRanBC;              /* '<S7>/QS2' */
  boolean_T doneDoubleBufferReInit;    /* '<S7>/theta' */
  boolean_T doneDoubleBufferReInit_j;  /* '<S7>/phi zero pointing downwards' */
  boolean_T doneDoubleBufferReInit_d;  /* '<S7>/alpha zero pointing upwards' */
  boolean_T doneDoubleBufferReInit_dt; /* '<S7>/Toogle Reset' */
  boolean_T reset_in_prev;             /* '<S7>/Toogle Reset' */
  boolean_T doneDoubleBufferReInit_c;  /* '<S20>/Toogle Stop' */
  boolean_T reset_in_prev_m;           /* '<S20>/Toogle Stop' */
  boolean_T doneDoubleBufferReInit_jg; /* '<S20>/MATLAB Function1' */
  boolean_T stop;                      /* '<S20>/MATLAB Function1' */
  boolean_T doneDoubleBufferReInit_dt0;/* '<S20>/MATLAB Function' */
  boolean_T TmpRTBAtControllerCS1AInport4_B;/* synthesized block */
  boolean_T doneDoubleBufferReInit_g;  /* '<S11>/Controller CS1A' */
  boolean_T started_not_empty;         /* '<S11>/Controller CS1A' */
} DW_hw_CS1A_T;

/* Zero-crossing (trigger) state */
typedef struct {
  ZCSigState QS2_Trig_ZCE;             /* '<S7>/QS2' */
} PrevZCX_hw_CS1A_T;

/* Parameters (default storage) */
struct P_hw_CS1A_T_ {
  real_T aA[2];                        /* Variable: aA
                                        * Referenced by: '<S11>/Controller CS1A'
                                        */
  real_T aF[3];                        /* Variable: aF
                                        * Referenced by: '<S11>/Controller CS1A'
                                        */
  real_T aT[2];                        /* Variable: aT
                                        * Referenced by: '<S11>/Controller CS1A'
                                        */
  real_T bA[2];                        /* Variable: bA
                                        * Referenced by: '<S11>/Controller CS1A'
                                        */
  real_T bF[3];                        /* Variable: bF
                                        * Referenced by: '<S11>/Controller CS1A'
                                        */
  real_T bT[2];                        /* Variable: bT
                                        * Referenced by: '<S11>/Controller CS1A'
                                        */
  real_T ts;                           /* Variable: ts
                                        * Referenced by:
                                        *   '<S7>/Step'
                                        *   '<S7>/Step1'
                                        */
  real_T u_max;                        /* Variable: u_max
                                        * Referenced by: '<S11>/Controller CS1A'
                                        */
  real_T CompareToConstant_const;     /* Mask Parameter: CompareToConstant_const
                                       * Referenced by: '<S19>/Constant'
                                       */
  real_T Reset_manual1_Value;          /* Expression: 1
                                        * Referenced by: '<S15>/Reset_manual 1'
                                        */
  real_T Reset_manual0_Value;          /* Expression: 0
                                        * Referenced by: '<S15>/Reset_manual 0'
                                        */
  real_T Constant_Value;               /* Expression: 0
                                        * Referenced by: '<S16>/Constant'
                                        */
  real_T Constant_Value_l;             /* Expression: 0
                                        * Referenced by: '<S17>/Constant'
                                        */
  real_T Gain1_Gain;                   /* Expression: pi/180
                                        * Referenced by: '<S12>/Gain1'
                                        */
  real_T Gain_Gain;                    /* Expression: -1
                                        * Referenced by: '<S1>/Gain'
                                        */
  real_T u_InitialCondition;           /* Expression: 0
                                        * Referenced by:
                                        */
  real_T Saturation_UpperSat;          /* Expression: 10
                                        * Referenced by: '<S1>/Saturation'
                                        */
  real_T Saturation_LowerSat;          /* Expression: -10
                                        * Referenced by: '<S1>/Saturation'
                                        */
  real_T SPIWriteRead_slaveSelectPin_; /* Expression: 10
                                        * Referenced by: '<S20>/SPI WriteRead'
                                        */
  real_T encoder0_Y0;                  /* Computed Parameter: encoder0_Y0
                                        * Referenced by: '<S20>/encoder0'
                                        */
  real_T encoder1_Y0;                  /* Computed Parameter: encoder1_Y0
                                        * Referenced by: '<S20>/encoder1'
                                        */
  real_T u0V_UpperSat;                 /* Expression: 10
                                        * Referenced by: '<S20>/+- 10V'
                                        */
  real_T u0V_LowerSat;                 /* Expression: -10
                                        * Referenced by: '<S20>/+- 10V'
                                        */
  real_T Reset_manual1_Value_e;        /* Expression: 1
                                        * Referenced by: '<S6>/Reset_manual 1'
                                        */
  real_T Reset_manual0_Value_i;        /* Expression: 0
                                        * Referenced by: '<S6>/Reset_manual 0'
                                        */
  real_T Reset_manual1_Value_l;        /* Expression: 1
                                        * Referenced by: '<S5>/Reset_manual 1'
                                        */
  real_T Reset_manual0_Value_l;        /* Expression: 0
                                        * Referenced by: '<S5>/Reset_manual 0'
                                        */
  real_T Reset_manual1_Value_ly;       /* Expression: 1
                                        * Referenced by: '<S4>/Reset_manual 1'
                                        */
  real_T Reset_manual0_Value_b;        /* Expression: 0
                                        * Referenced by: '<S4>/Reset_manual 0'
                                        */
  real_T thetarefdeg_Value;            /* Expression: 0
                                        * Referenced by: '<Root>/theta ref [deg]'
                                        */
  real_T Memory_InitialCondition;      /* Expression: 0
                                        * Referenced by: '<S7>/Memory'
                                        */
  real_T Memory1_InitialCondition;     /* Expression: 0
                                        * Referenced by: '<S7>/Memory1'
                                        */
  real_T TmpRTBAtToogleResetOutport1_Ini;/* Expression: 0
                                          * Referenced by:
                                          */
  real_T Step_Y0;                      /* Expression: 0
                                        * Referenced by: '<S7>/Step'
                                        */
  real_T Step_YFinal;                  /* Expression: 1
                                        * Referenced by: '<S7>/Step'
                                        */
  real_T Step1_Y0;                     /* Expression: 0
                                        * Referenced by: '<S7>/Step1'
                                        */
  real_T Step1_YFinal;                 /* Expression: -1
                                        * Referenced by: '<S7>/Step1'
                                        */
  real_T MotorEnable_Value;            /* Expression: 1
                                        * Referenced by: '<Root>/Motor Enable'
                                        */
  real_T Protection_Value;             /* Expression: 1
                                        * Referenced by: '<Root>/Protection'
                                        */
  real_T Gain_Gain_f;                  /* Expression: 180/pi
                                        * Referenced by: '<S21>/Gain'
                                        */
  real_T Constant1_Value;              /* Expression: 1
                                        * Referenced by: '<S7>/Constant1'
                                        */
  real_T Constant2_Value;              /* Expression: 1
                                        * Referenced by: '<S7>/Constant2'
                                        */
  real_T Constant3_Value;              /* Expression: 1
                                        * Referenced by: '<S7>/Constant3'
                                        */
  real_T PulseGenerator1_Amp;          /* Expression: 1
                                        * Referenced by: '<S7>/Pulse Generator1'
                                        */
  real_T PulseGenerator1_Period;   /* Computed Parameter: PulseGenerator1_Period
                                    * Referenced by: '<S7>/Pulse Generator1'
                                    */
  real_T PulseGenerator1_Duty;       /* Computed Parameter: PulseGenerator1_Duty
                                      * Referenced by: '<S7>/Pulse Generator1'
                                      */
  real_T PulseGenerator1_PhaseDelay;   /* Expression: 0
                                        * Referenced by: '<S7>/Pulse Generator1'
                                        */
  real_T Gain_Gain_d;                  /* Expression: 180/pi
                                        * Referenced by: '<S3>/Gain'
                                        */
  real_T Gain_Gain_m;                  /* Expression: 180/pi
                                        * Referenced by: '<S2>/Gain'
                                        */
  uint8_T ControllerEnable_CurrentSetting;
                          /* Computed Parameter: ControllerEnable_CurrentSetting
                           * Referenced by: '<S1>/Controller Enable'
                           */
  uint8_T ControllerEnable_CurrentSetti_e;
                          /* Computed Parameter: ControllerEnable_CurrentSetti_e
                           * Referenced by: '<Root>/Controller Enable'
                           */
  uint8_T STOPSimulation_CurrentSetting;
                            /* Computed Parameter: STOPSimulation_CurrentSetting
                             * Referenced by: '<Root>/STOP Simulation'
                             */
  uint8_T SensorsReset_CurrentSetting;
                              /* Computed Parameter: SensorsReset_CurrentSetting
                               * Referenced by: '<Root>/Sensors Reset'
                               */
};

/* Real-time Model Data Structure */
struct tag_RTM_hw_CS1A_T {
  const char_T *errorStatus;
  RTWExtModeInfo *extModeInfo;
  RTWSolverInfo solverInfo;

  /*
   * Sizes:
   * The following substructure contains sizes information
   * for many of the model attributes such as inputs, outputs,
   * dwork, sample times, etc.
   */
  struct {
    uint32_T checksums[4];
  } Sizes;

  /*
   * SpecialInfo:
   * The following substructure contains special information
   * related to other components that are dependent on RTW.
   */
  struct {
    const void *mappingInfo;
  } SpecialInfo;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    uint32_T clockTick0;
    time_T stepSize0;
    uint32_T clockTick1;
    uint32_T clockTick2;
    struct {
      uint8_T TID[3];
    } TaskCounters;

    struct {
      boolean_T TID1_2;
    } RateInteraction;

    time_T tFinal;
    SimTimeStep simTimeStep;
    boolean_T stopRequestedFlag;
    time_T *t;
    time_T tArray[3];
  } Timing;
};

/* Block parameters (default storage) */
extern P_hw_CS1A_T hw_CS1A_P;

/* Block signals (default storage) */
extern B_hw_CS1A_T hw_CS1A_B;

/* Block states (default storage) */
extern DW_hw_CS1A_T hw_CS1A_DW;

/* Zero-crossing (trigger) state */
extern PrevZCX_hw_CS1A_T hw_CS1A_PrevZCX;

/* External function called from main */
extern void hw_CS1A_SetEventsForThisBaseStep(boolean_T *eventFlags);

/* Model entry point functions */
extern void hw_CS1A_initialize(void);
extern void hw_CS1A_step0(void);       /* Sample time: [0.0s, 0.0s] */
extern void hw_CS1A_step2(void);       /* Sample time: [0.001s, 0.0s] */
extern void hw_CS1A_terminate(void);

/* Real-time Model object */
extern RT_MODEL_hw_CS1A_T *const hw_CS1A_M;
extern volatile boolean_T stopRequested;
extern volatile boolean_T runModel;

/*-
 * These blocks were eliminated from the model due to optimizations:
 *
 * Block '<S7>/Rate Transition2' : Eliminated since input and output rates are identical
 */

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'hw_CS1A'
 * '<S1>'   : 'hw_CS1A/Controller'
 * '<S2>'   : 'hw_CS1A/Radians to Degrees1'
 * '<S3>'   : 'hw_CS1A/Radians to Degrees2'
 * '<S4>'   : 'hw_CS1A/Subsystem'
 * '<S5>'   : 'hw_CS1A/Subsystem1'
 * '<S6>'   : 'hw_CS1A/Subsystem2'
 * '<S7>'   : 'hw_CS1A/System: QS2      '
 * '<S8>'   : 'hw_CS1A/Controller/  Enable'
 * '<S9>'   : 'hw_CS1A/Controller/ Enable'
 * '<S10>'  : 'hw_CS1A/Controller/CTRL Enable '
 * '<S11>'  : 'hw_CS1A/Controller/Controller CS1A'
 * '<S12>'  : 'hw_CS1A/Controller/Degrees to Radians'
 * '<S13>'  : 'hw_CS1A/Controller/Enable'
 * '<S14>'  : 'hw_CS1A/Controller/Enable '
 * '<S15>'  : 'hw_CS1A/Controller/Subsystem1'
 * '<S16>'  : 'hw_CS1A/Controller/CTRL Enable /Compare To Zero'
 * '<S17>'  : 'hw_CS1A/Controller/CTRL Enable /Compare To Zero1'
 * '<S18>'  : 'hw_CS1A/Controller/Controller CS1A/Controller CS1A'
 * '<S19>'  : 'hw_CS1A/System: QS2      /Compare To Constant'
 * '<S20>'  : 'hw_CS1A/System: QS2      /QS2'
 * '<S21>'  : 'hw_CS1A/System: QS2      /Radians to Degrees'
 * '<S22>'  : 'hw_CS1A/System: QS2      /Toogle Reset'
 * '<S23>'  : 'hw_CS1A/System: QS2      /alpha zero pointing upwards'
 * '<S24>'  : 'hw_CS1A/System: QS2      /phi zero pointing downwards'
 * '<S25>'  : 'hw_CS1A/System: QS2      /theta'
 * '<S26>'  : 'hw_CS1A/System: QS2      /QS2/MATLAB Function'
 * '<S27>'  : 'hw_CS1A/System: QS2      /QS2/MATLAB Function1'
 * '<S28>'  : 'hw_CS1A/System: QS2      /QS2/Toogle Stop'
 */
#endif                                 /* hw_CS1A_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
