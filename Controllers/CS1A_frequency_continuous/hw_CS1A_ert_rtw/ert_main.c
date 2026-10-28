/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: ert_main.c
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
#include "rtwtypes.h"
#include "xcp.h"
#include "ext_mode.h"
#include "MW_target_hardware_resources.h"

volatile int IsrOverrun = 0;
boolean_T isRateRunning[3] = { 0, 0, 0 };

boolean_T need2runFlags[3] = { 0, 0, 0 };

void rt_OneStep(void)
{
  extmodeSimulationTime_T currentTime = (extmodeSimulationTime_T) 0;
  boolean_T eventFlags[3];

  /* Check base rate for overrun */
  if (isRateRunning[0]++) {
    IsrOverrun = 1;
    isRateRunning[0]--;                /* allow future iterations to succeed*/
    return;
  }

  /*
   * For a bare-board target (i.e., no operating system), the rates
   * that execute this base step are buffered locally to allow for
   * overlapping preemption.
   */
  hw_CS1A_SetEventsForThisBaseStep(eventFlags);
  enable_rt_OneStep();
  currentTime = (extmodeSimulationTime_T) hw_CS1A_M->Timing.t[0];
  hw_CS1A_step0();

  /* Get model outputs here */

  /* Trigger External Mode event */
  extmodeEvent(1, currentTime);
  disable_rt_OneStep();
  isRateRunning[0]--;
  if (eventFlags[2]) {
    if (need2runFlags[2]++) {
      IsrOverrun = 1;
      need2runFlags[2]--;              /* allow future iterations to succeed*/
      return;
    }
  }

  if (need2runFlags[2]) {
    if (isRateRunning[1]) {
      /* Yield to higher priority*/
      return;
    }

    isRateRunning[2]++;
    enable_rt_OneStep();

    /* Step the model for subrate "2" */
    switch (2)
    {
     case 2 :
      currentTime = (extmodeSimulationTime_T) ((hw_CS1A_M->Timing.clockTick2) *
        0.001);
      hw_CS1A_step2();

      /* Get model outputs here */

      /* Trigger External Mode event */
      extmodeEvent(2, currentTime);
      break;

     default :
      break;
    }

    disable_rt_OneStep();
    need2runFlags[2]--;
    isRateRunning[2]--;
  }
}

extern void rtIOStreamResync();
volatile boolean_T stopRequested;
volatile boolean_T runModel;
int main(void)
{
  float modelBaseRate = 0.0005;
  float systemClock = 0;
  extmodeErrorCode_T errorCode = EXTMODE_SUCCESS;

  /* Initialize variables */
  stopRequested = false;
  runModel = false;
  MW_Arduino_Init();
  rtmSetErrorStatus(hw_CS1A_M, 0);

  /* Parse External Mode command line arguments */
  errorCode = extmodeParseArgs(0, NULL);
  if (errorCode != EXTMODE_SUCCESS) {
    return (errorCode);
  }

  hw_CS1A_initialize();
  cli();
  sei();

  /* External Mode initialization */
  errorCode = extmodeInit(hw_CS1A_M->extModeInfo, &rtmGetTFinal(hw_CS1A_M));
  if (errorCode != EXTMODE_SUCCESS) {
    /* Code to handle External Mode initialization errors
       may be added here */
  }

  if (errorCode == EXTMODE_SUCCESS) {
    /* Wait until a Start or Stop Request has been received from the Host */
    extmodeWaitForHostRequest(EXTMODE_WAIT_FOREVER);
    if (extmodeStopRequested()) {
      rtmSetStopRequested(hw_CS1A_M, true);
    }
  }

  cli();
  configureArduinoARMTimer();
  runModel =
    !extmodeSimulationComplete()&& !extmodeStopRequested()&&
    !rtmGetStopRequested(hw_CS1A_M);
  enable_rt_OneStep();
  XcpStatus lastXcpState = xcpStatusGet();
  sei();
  while (runModel) {
    /* Run External Mode background activities */
    errorCode = extmodeBackgroundRun();
    if (errorCode != EXTMODE_SUCCESS && errorCode != EXTMODE_EMPTY) {
      /* Code to handle External Mode background task errors
         may be added here */
    }

    stopRequested = !(
                      !extmodeSimulationComplete()&& !extmodeStopRequested()&&
                      !rtmGetStopRequested(hw_CS1A_M));
    runModel = !(stopRequested);
    if (stopRequested)
      disable_rt_OneStep();
    if (lastXcpState==XCP_CONNECTED && xcpStatusGet()==XCP_DISCONNECTED)
      rtIOStreamResync();
    lastXcpState = xcpStatusGet();
    MW_Arduino_Loop();
  }

  /* Terminate model */
  hw_CS1A_terminate();

  /* External Mode reset */
  extmodeReset();
  MW_Arduino_Terminate();
  cli();
  return 0;
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
