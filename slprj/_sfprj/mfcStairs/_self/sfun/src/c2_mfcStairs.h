#ifndef __c2_mfcStairs_h__
#define __c2_mfcStairs_h__

/* Include files */
#include "sf_runtime/sfc_sf.h"
#include "sf_runtime/sfc_mex.h"
#include "rtwtypes.h"
#include "multiword_types.h"

/* Type Definitions */
#ifndef typedef_SFc2_mfcStairsInstanceStruct
#define typedef_SFc2_mfcStairsInstanceStruct

typedef struct {
  SimStruct *S;
  ChartInfoStruct chartInfo;
  uint32_T chartNumber;
  uint32_T instanceNumber;
  int32_T c2_sfEvent;
  boolean_T c2_isStable;
  boolean_T c2_doneDoubleBufferReInit;
  uint8_T c2_is_active_c2_mfcStairs;
  real_T c2_dummy;
  real_T (*c2_T)[2];
  real_T (*c2_dx)[4];
  real_T (*c2_x)[4];
  real_T *c2_S0;
  real_T *c2_Rext;
  real_T *c2_Pout;
} SFc2_mfcStairsInstanceStruct;

#endif                                 /*typedef_SFc2_mfcStairsInstanceStruct*/

/* Named Constants */

/* Variable Declarations */
extern struct SfDebugInstanceStruct *sfGlobalDebugInstanceStruct;

/* Variable Definitions */

/* Function Declarations */
extern const mxArray *sf_c2_mfcStairs_get_eml_resolved_functions_info(void);

/* Function Definitions */
extern void sf_c2_mfcStairs_get_check_sum(mxArray *plhs[]);
extern void c2_mfcStairs_method_dispatcher(SimStruct *S, int_T method, void
  *data);

#endif
