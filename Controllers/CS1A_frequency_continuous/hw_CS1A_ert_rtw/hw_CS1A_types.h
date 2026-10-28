/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: hw_CS1A_types.h
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

#ifndef hw_CS1A_types_h_
#define hw_CS1A_types_h_
#include "rtwtypes.h"
#ifndef struct_tag_Dgc2TRVrL59PoNFLix7UcE
#define struct_tag_Dgc2TRVrL59PoNFLix7UcE

struct tag_Dgc2TRVrL59PoNFLix7UcE
{
  int32_T __dummy;
};

#endif                                 /* struct_tag_Dgc2TRVrL59PoNFLix7UcE */

#ifndef typedef_c_arduinodriver_ArduinoSPI_hw_T
#define typedef_c_arduinodriver_ArduinoSPI_hw_T

typedef struct tag_Dgc2TRVrL59PoNFLix7UcE c_arduinodriver_ArduinoSPI_hw_T;

#endif                             /* typedef_c_arduinodriver_ArduinoSPI_hw_T */

#ifndef struct_tag_zHYKd6eVDXgY5o2Fkt87RC
#define struct_tag_zHYKd6eVDXgY5o2Fkt87RC

struct tag_zHYKd6eVDXgY5o2Fkt87RC
{
  boolean_T matlabCodegenIsDeleted;
  int32_T isInitialized;
  boolean_T isSetupComplete;
  real_T slaveSelectPin_;
  c_arduinodriver_ArduinoSPI_hw_T SPIDriverObj;
};

#endif                                 /* struct_tag_zHYKd6eVDXgY5o2Fkt87RC */

#ifndef typedef_codertarget_arduinobase_inter_T
#define typedef_codertarget_arduinobase_inter_T

typedef struct tag_zHYKd6eVDXgY5o2Fkt87RC codertarget_arduinobase_inter_T;

#endif                             /* typedef_codertarget_arduinobase_inter_T */

/* Parameters (default storage) */
typedef struct P_hw_CS1A_T_ P_hw_CS1A_T;

/* Forward declaration for rtModel */
typedef struct tag_RTM_hw_CS1A_T RT_MODEL_hw_CS1A_T;

#endif                                 /* hw_CS1A_types_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
