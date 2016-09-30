/* Include files */

#include <stddef.h>
#include "blas.h"
#include "mfcStairs_sfun.h"
#include "c2_mfcStairs.h"
#include "mwmathutil.h"
#define CHARTINSTANCE_CHARTNUMBER      (chartInstance->chartNumber)
#define CHARTINSTANCE_INSTANCENUMBER   (chartInstance->instanceNumber)
#include "mfcStairs_sfun_debug_macros.h"
#define _SF_MEX_LISTEN_FOR_CTRL_C(S)   sf_mex_listen_for_ctrl_c_with_debugger(S, sfGlobalDebugInstanceStruct);

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization);
static void chart_debug_initialize_data_addresses(SimStruct *S);

/* Type Definitions */

/* Named Constants */
#define CALL_EVENT                     (-1)

/* Variable Declarations */

/* Variable Definitions */
static real_T _sfTime_;
static const char * c2_debug_family_names[57] = { "F", "R", "Y", "Ych4",
  "qmax_a", "qmax_m", "umax_a", "umax_m", "Ks_a", "Ks_m", "m", "gamma", "Mtotal",
  "Km", "Kd_a", "Kd_m", "Xmax_a", "Xmax_m", "Kx", "Rmin", "Rmax", "Emin", "Emax",
  "Kr", "i0ref", "e", "V", "Fin", "D", "S", "xa", "xm", "Mox", "Mred", "Rint",
  "Eocv", "alpha_a", "alpha_m", "qa", "qm", "ua", "um", "n_conc", "Imfc", "Sp",
  "Xap", "Xmp", "Moxp", "T", "nargin", "nargout", "x", "dummy", "S0", "Rext",
  "dx", "Pout" };

/* Function Declarations */
static void initialize_c2_mfcStairs(SFc2_mfcStairsInstanceStruct *chartInstance);
static void initialize_params_c2_mfcStairs(SFc2_mfcStairsInstanceStruct
  *chartInstance);
static void enable_c2_mfcStairs(SFc2_mfcStairsInstanceStruct *chartInstance);
static void disable_c2_mfcStairs(SFc2_mfcStairsInstanceStruct *chartInstance);
static void c2_update_debugger_state_c2_mfcStairs(SFc2_mfcStairsInstanceStruct
  *chartInstance);
static const mxArray *get_sim_state_c2_mfcStairs(SFc2_mfcStairsInstanceStruct
  *chartInstance);
static void set_sim_state_c2_mfcStairs(SFc2_mfcStairsInstanceStruct
  *chartInstance, const mxArray *c2_st);
static void finalize_c2_mfcStairs(SFc2_mfcStairsInstanceStruct *chartInstance);
static void sf_gateway_c2_mfcStairs(SFc2_mfcStairsInstanceStruct *chartInstance);
static void mdl_start_c2_mfcStairs(SFc2_mfcStairsInstanceStruct *chartInstance);
static void c2_chartstep_c2_mfcStairs(SFc2_mfcStairsInstanceStruct
  *chartInstance);
static void initSimStructsc2_mfcStairs(SFc2_mfcStairsInstanceStruct
  *chartInstance);
static void init_script_number_translation(uint32_T c2_machineNumber, uint32_T
  c2_chartNumber, uint32_T c2_instanceNumber);
static const mxArray *c2_sf_marshallOut(void *chartInstanceVoid, void *c2_inData);
static real_T c2_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_b_Pout, const char_T *c2_identifier);
static real_T c2_b_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId);
static void c2_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static const mxArray *c2_b_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static void c2_c_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_b_dx, const char_T *c2_identifier, real_T c2_y[4]);
static void c2_d_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId, real_T c2_y[4]);
static void c2_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static const mxArray *c2_c_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static real_T c2_log(SFc2_mfcStairsInstanceStruct *chartInstance, real_T c2_b_x);
static void c2_eml_error(SFc2_mfcStairsInstanceStruct *chartInstance);
static void c2_eml_scalar_eg(SFc2_mfcStairsInstanceStruct *chartInstance);
static void c2_dimagree(SFc2_mfcStairsInstanceStruct *chartInstance);
static const mxArray *c2_d_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static int32_T c2_e_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId);
static void c2_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static uint8_T c2_f_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_b_is_active_c2_mfcStairs, const char_T *c2_identifier);
static uint8_T c2_g_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId);
static void c2_b_log(SFc2_mfcStairsInstanceStruct *chartInstance, real_T *c2_b_x);
static void init_dsm_address_info(SFc2_mfcStairsInstanceStruct *chartInstance);
static void init_simulink_io_address(SFc2_mfcStairsInstanceStruct *chartInstance);

/* Function Definitions */
static void initialize_c2_mfcStairs(SFc2_mfcStairsInstanceStruct *chartInstance)
{
  if (sf_is_first_init_cond(chartInstance->S)) {
    initSimStructsc2_mfcStairs(chartInstance);
    chart_debug_initialize_data_addresses(chartInstance->S);
  }

  chartInstance->c2_sfEvent = CALL_EVENT;
  _sfTime_ = sf_get_time(chartInstance->S);
  chartInstance->c2_is_active_c2_mfcStairs = 0U;
}

static void initialize_params_c2_mfcStairs(SFc2_mfcStairsInstanceStruct
  *chartInstance)
{
  real_T c2_d0;
  sf_mex_import_named("dummy", sf_mex_get_sfun_param(chartInstance->S, 0, 0),
                      &c2_d0, 0, 0, 0U, 0, 0U, 0);
  chartInstance->c2_dummy = c2_d0;
}

static void enable_c2_mfcStairs(SFc2_mfcStairsInstanceStruct *chartInstance)
{
  _sfTime_ = sf_get_time(chartInstance->S);
}

static void disable_c2_mfcStairs(SFc2_mfcStairsInstanceStruct *chartInstance)
{
  _sfTime_ = sf_get_time(chartInstance->S);
}

static void c2_update_debugger_state_c2_mfcStairs(SFc2_mfcStairsInstanceStruct
  *chartInstance)
{
  (void)chartInstance;
}

static const mxArray *get_sim_state_c2_mfcStairs(SFc2_mfcStairsInstanceStruct
  *chartInstance)
{
  const mxArray *c2_st;
  const mxArray *c2_y = NULL;
  real_T c2_hoistedGlobal;
  real_T c2_u;
  const mxArray *c2_b_y = NULL;
  const mxArray *c2_c_y = NULL;
  uint8_T c2_b_hoistedGlobal;
  uint8_T c2_b_u;
  const mxArray *c2_d_y = NULL;
  c2_st = NULL;
  c2_st = NULL;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_createcellmatrix(3, 1), false);
  c2_hoistedGlobal = *chartInstance->c2_Pout;
  c2_u = c2_hoistedGlobal;
  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", &c2_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c2_y, 0, c2_b_y);
  c2_c_y = NULL;
  sf_mex_assign(&c2_c_y, sf_mex_create("y", *chartInstance->c2_dx, 0, 0U, 1U, 0U,
    1, 4), false);
  sf_mex_setcell(c2_y, 1, c2_c_y);
  c2_b_hoistedGlobal = chartInstance->c2_is_active_c2_mfcStairs;
  c2_b_u = c2_b_hoistedGlobal;
  c2_d_y = NULL;
  sf_mex_assign(&c2_d_y, sf_mex_create("y", &c2_b_u, 3, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c2_y, 2, c2_d_y);
  sf_mex_assign(&c2_st, c2_y, false);
  return c2_st;
}

static void set_sim_state_c2_mfcStairs(SFc2_mfcStairsInstanceStruct
  *chartInstance, const mxArray *c2_st)
{
  const mxArray *c2_u;
  real_T c2_dv0[4];
  int32_T c2_i0;
  chartInstance->c2_doneDoubleBufferReInit = true;
  c2_u = sf_mex_dup(c2_st);
  *chartInstance->c2_Pout = c2_emlrt_marshallIn(chartInstance, sf_mex_dup
    (sf_mex_getcell("Pout", c2_u, 0)), "Pout");
  c2_c_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell("dx", c2_u, 1)),
                        "dx", c2_dv0);
  for (c2_i0 = 0; c2_i0 < 4; c2_i0++) {
    (*chartInstance->c2_dx)[c2_i0] = c2_dv0[c2_i0];
  }

  chartInstance->c2_is_active_c2_mfcStairs = c2_f_emlrt_marshallIn(chartInstance,
    sf_mex_dup(sf_mex_getcell("is_active_c2_mfcStairs", c2_u, 2)),
    "is_active_c2_mfcStairs");
  sf_mex_destroy(&c2_u);
  c2_update_debugger_state_c2_mfcStairs(chartInstance);
  sf_mex_destroy(&c2_st);
}

static void finalize_c2_mfcStairs(SFc2_mfcStairsInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void sf_gateway_c2_mfcStairs(SFc2_mfcStairsInstanceStruct *chartInstance)
{
  int32_T c2_i1;
  int32_T c2_i2;
  int32_T c2_i3;
  _SFD_SYMBOL_SCOPE_PUSH(0U, 0U);
  _sfTime_ = sf_get_time(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 0U, chartInstance->c2_sfEvent);
  _SFD_DATA_RANGE_CHECK(*chartInstance->c2_Rext, 3U, 1U, 0U,
                        chartInstance->c2_sfEvent, false);
  _SFD_DATA_RANGE_CHECK(*chartInstance->c2_S0, 2U, 1U, 0U,
                        chartInstance->c2_sfEvent, false);
  _SFD_DATA_RANGE_CHECK(chartInstance->c2_dummy, 6U, 1U, 0U,
                        chartInstance->c2_sfEvent, false);
  for (c2_i1 = 0; c2_i1 < 4; c2_i1++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c2_x)[c2_i1], 1U, 1U, 0U,
                          chartInstance->c2_sfEvent, false);
  }

  for (c2_i2 = 0; c2_i2 < 2; c2_i2++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c2_T)[c2_i2], 0U, 1U, 0U,
                          chartInstance->c2_sfEvent, false);
  }

  chartInstance->c2_sfEvent = CALL_EVENT;
  c2_chartstep_c2_mfcStairs(chartInstance);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_CHECK_FOR_STATE_INCONSISTENCY(_mfcStairsMachineNumber_,
    chartInstance->chartNumber, chartInstance->instanceNumber);
  for (c2_i3 = 0; c2_i3 < 4; c2_i3++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c2_dx)[c2_i3], 4U, 1U, 0U,
                          chartInstance->c2_sfEvent, false);
  }

  _SFD_DATA_RANGE_CHECK(*chartInstance->c2_Pout, 5U, 1U, 0U,
                        chartInstance->c2_sfEvent, false);
}

static void mdl_start_c2_mfcStairs(SFc2_mfcStairsInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void c2_chartstep_c2_mfcStairs(SFc2_mfcStairsInstanceStruct
  *chartInstance)
{
  real_T c2_hoistedGlobal;
  real_T c2_b_hoistedGlobal;
  real_T c2_c_hoistedGlobal;
  int32_T c2_i4;
  real_T c2_b_T[2];
  int32_T c2_i5;
  real_T c2_b_x[4];
  real_T c2_b_dummy;
  real_T c2_b_S0;
  real_T c2_b_Rext;
  uint32_T c2_debug_family_var_map[57];
  real_T c2_F;
  real_T c2_R;
  real_T c2_Y;
  real_T c2_Ych4;
  real_T c2_qmax_a;
  real_T c2_qmax_m;
  real_T c2_umax_a;
  real_T c2_umax_m;
  real_T c2_Ks_a;
  real_T c2_Ks_m;
  real_T c2_m;
  real_T c2_gamma;
  real_T c2_Mtotal;
  real_T c2_Km;
  real_T c2_Kd_a;
  real_T c2_Kd_m;
  real_T c2_Xmax_a;
  real_T c2_Xmax_m;
  real_T c2_Kx;
  real_T c2_Rmin;
  real_T c2_Rmax;
  real_T c2_Emin;
  real_T c2_Emax;
  real_T c2_Kr;
  real_T c2_i0ref;
  real_T c2_e;
  real_T c2_V;
  real_T c2_Fin;
  real_T c2_D;
  real_T c2_S;
  real_T c2_xa;
  real_T c2_xm;
  real_T c2_Mox;
  real_T c2_Mred;
  real_T c2_Rint;
  real_T c2_Eocv;
  real_T c2_alpha_a;
  real_T c2_alpha_m;
  real_T c2_qa;
  real_T c2_qm;
  real_T c2_ua;
  real_T c2_um;
  real_T c2_n_conc;
  real_T c2_Imfc;
  real_T c2_Sp;
  real_T c2_Xap;
  real_T c2_Xmp;
  real_T c2_Moxp;
  real_T c2_c_T;
  real_T c2_nargin = 5.0;
  real_T c2_nargout = 2.0;
  real_T c2_b_dx[4];
  real_T c2_b_Pout;
  real_T c2_u;
  const mxArray *c2_y = NULL;
  real_T c2_c_x;
  real_T c2_d_x;
  real_T c2_B;
  real_T c2_b_y;
  real_T c2_c_y;
  real_T c2_d_y;
  real_T c2_e_y;
  real_T c2_e_x;
  real_T c2_f_x;
  real_T c2_g_x;
  real_T c2_h_x;
  real_T c2_i_x;
  real_T c2_j_x;
  real_T c2_A;
  real_T c2_b_B;
  real_T c2_k_x;
  real_T c2_f_y;
  real_T c2_l_x;
  real_T c2_g_y;
  real_T c2_m_x;
  real_T c2_h_y;
  real_T c2_i_y;
  real_T c2_b_A;
  real_T c2_c_B;
  real_T c2_n_x;
  real_T c2_j_y;
  real_T c2_o_x;
  real_T c2_k_y;
  real_T c2_p_x;
  real_T c2_l_y;
  real_T c2_c_A;
  real_T c2_d_B;
  real_T c2_q_x;
  real_T c2_m_y;
  real_T c2_r_x;
  real_T c2_n_y;
  real_T c2_s_x;
  real_T c2_o_y;
  real_T c2_d_A;
  real_T c2_e_B;
  real_T c2_t_x;
  real_T c2_p_y;
  real_T c2_u_x;
  real_T c2_q_y;
  real_T c2_v_x;
  real_T c2_r_y;
  real_T c2_s_y;
  real_T c2_e_A;
  real_T c2_f_B;
  real_T c2_w_x;
  real_T c2_t_y;
  real_T c2_x_x;
  real_T c2_u_y;
  real_T c2_y_x;
  real_T c2_v_y;
  real_T c2_f_A;
  real_T c2_g_B;
  real_T c2_ab_x;
  real_T c2_w_y;
  real_T c2_bb_x;
  real_T c2_x_y;
  real_T c2_cb_x;
  real_T c2_y_y;
  real_T c2_h_B;
  real_T c2_ab_y;
  real_T c2_bb_y;
  real_T c2_cb_y;
  real_T c2_db_y;
  real_T c2_d1;
  real_T c2_g_A;
  real_T c2_i_B;
  real_T c2_db_x;
  real_T c2_eb_y;
  real_T c2_eb_x;
  real_T c2_fb_y;
  real_T c2_fb_x;
  real_T c2_gb_y;
  real_T c2_hb_y;
  real_T c2_h_A;
  real_T c2_j_B;
  real_T c2_gb_x;
  real_T c2_ib_y;
  real_T c2_hb_x;
  real_T c2_jb_y;
  real_T c2_ib_x;
  real_T c2_kb_y;
  real_T c2_i_A;
  real_T c2_k_B;
  real_T c2_jb_x;
  real_T c2_lb_y;
  real_T c2_kb_x;
  real_T c2_mb_y;
  real_T c2_lb_x;
  real_T c2_nb_y;
  real_T c2_ob_y;
  real_T c2_a;
  real_T c2_b_a;
  real_T c2_c_a;
  real_T c2_ak;
  real_T c2_d_a;
  real_T c2_c;
  int32_T c2_i6;
  boolean_T guard1 = false;
  boolean_T guard2 = false;
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 0U, chartInstance->c2_sfEvent);
  c2_hoistedGlobal = chartInstance->c2_dummy;
  c2_b_hoistedGlobal = *chartInstance->c2_S0;
  c2_c_hoistedGlobal = *chartInstance->c2_Rext;
  for (c2_i4 = 0; c2_i4 < 2; c2_i4++) {
    c2_b_T[c2_i4] = (*chartInstance->c2_T)[c2_i4];
  }

  for (c2_i5 = 0; c2_i5 < 4; c2_i5++) {
    c2_b_x[c2_i5] = (*chartInstance->c2_x)[c2_i5];
  }

  c2_b_dummy = c2_hoistedGlobal;
  c2_b_S0 = c2_b_hoistedGlobal;
  c2_b_Rext = c2_c_hoistedGlobal;
  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 57U, 58U, c2_debug_family_names,
    c2_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_F, 0U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_R, 1U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Y, 2U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Ych4, 3U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_qmax_a, 4U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_qmax_m, 5U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_umax_a, 6U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_umax_m, 7U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Ks_a, 8U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Ks_m, 9U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_m, 10U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_gamma, 11U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Mtotal, 12U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Km, 13U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Kd_a, 14U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Kd_m, 15U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Xmax_a, 16U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Xmax_m, 17U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Kx, 18U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Rmin, 19U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Rmax, 20U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Emin, 21U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Emax, 22U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Kr, 23U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_i0ref, 24U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_e, 25U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_V, 26U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Fin, 27U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_D, 28U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_S, 29U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_xa, 30U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_xm, 31U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Mox, 32U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Mred, 33U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Rint, 34U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Eocv, 35U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_alpha_a, 36U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_alpha_m, 37U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_qa, 38U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_qm, 39U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_ua, 40U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_um, 41U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_n_conc, 42U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Imfc, 43U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Sp, 44U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Xap, 45U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Xmp, 46U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Moxp, 47U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_c_T, MAX_uint32_T, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_nargin, 49U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_nargout, 50U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(c2_b_T, 48U, c2_c_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(c2_b_x, 51U, c2_b_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_b_dummy, 52U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_b_S0, 53U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_b_Rext, 54U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_b_dx, 55U, c2_b_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_b_Pout, 56U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  CV_EML_FCN(0, 0);
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 2);
  c2_F = 96485.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 3);
  c2_R = 8.314472;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 4);
  c2_c_T = 298.15;
  _SFD_SYMBOL_SWITCH(48U, 48U);
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 5);
  c2_Y = 22.753;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 6);
  c2_Ych4 = 0.3;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 7);
  c2_qmax_a = 8.48;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 8);
  c2_qmax_m = 8.2;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 9);
  c2_umax_a = 1.9753;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 10);
  c2_umax_m = 0.1;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 11);
  c2_Ks_a = 20.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 12);
  c2_Ks_m = 80.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 13);
  c2_m = 2.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 14);
  c2_gamma = 663400.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 15);
  c2_Mtotal = 0.05;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 16);
  c2_Km = 0.010000000000000002;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 17);
  c2_Kd_a = 0.039506;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 18);
  c2_Kd_m = 0.002;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 19);
  c2_Xmax_a = 512.5;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 20);
  c2_Xmax_m = 537.5;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 21);
  c2_Kx = 0.04;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 22);
  c2_Rmin = 25.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 23);
  c2_Rmax = 2025.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 24);
  c2_Emin = 0.01;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 25);
  c2_Emax = 0.6744;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 26);
  c2_Kr = 0.024;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 28);
  c2_i0ref = 1.6;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 30);
  c2_e = 5.0E-6;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 32);
  c2_V = 0.05;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 33);
  c2_Fin = 0.1527;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 35);
  c2_D = 3.054;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 37);
  c2_S = c2_b_x[0];
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 38);
  c2_xa = c2_b_x[1];
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 39);
  c2_xm = c2_b_x[2];
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 40);
  c2_Mox = c2_b_x[3];
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 44);
  c2_Mred = c2_Mtotal - c2_Mox;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 45);
  if (CV_EML_IF(0, 1, 0, CV_RELATIONAL_EVAL(4U, 0U, 0, c2_Mred, 0.0, -1, 2U,
        c2_Mred < 0.0))) {
    _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 46);
    sf_mex_printf("%s =\\n", "Mred");
    c2_u = c2_Mred;
    c2_y = NULL;
    sf_mex_assign(&c2_y, sf_mex_create("y", &c2_u, 0, 0U, 0U, 0U, 0), false);
    sf_mex_call_debug(sfGlobalDebugInstanceStruct, "disp", 0U, 1U, 14, c2_y);
  }

  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 49);
  c2_c_x = -0.024 * c2_xa;
  c2_d_x = c2_c_x;
  c2_d_x = muDoubleScalarExp(c2_d_x);
  c2_Rint = c2_Rmin + 2000.0 * c2_d_x;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 50);
  c2_B = 0.024 * c2_xa;
  c2_b_y = c2_B;
  c2_c_y = c2_b_y;
  c2_d_y = c2_c_y;
  c2_e_y = -1.0 / c2_d_y;
  c2_e_x = c2_e_y;
  c2_f_x = c2_e_x;
  c2_f_x = muDoubleScalarExp(c2_f_x);
  c2_Eocv = c2_Emin + 0.6644 * c2_f_x;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 52);
  c2_g_x = 0.04 * ((c2_xa + c2_xm) - c2_Xmax_a);
  c2_h_x = c2_g_x;
  c2_h_x = muDoubleScalarTanh(c2_h_x);
  c2_alpha_a = 0.5 * (1.0 + c2_h_x);
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 53);
  c2_i_x = 0.04 * ((c2_xa + c2_xm) - c2_Xmax_m);
  c2_j_x = c2_i_x;
  c2_j_x = muDoubleScalarTanh(c2_j_x);
  c2_alpha_m = 0.5 * (1.0 + c2_j_x);
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 55);
  c2_A = 8.48 * c2_S;
  c2_b_B = c2_Ks_a + c2_S;
  c2_k_x = c2_A;
  c2_f_y = c2_b_B;
  c2_l_x = c2_k_x;
  c2_g_y = c2_f_y;
  c2_m_x = c2_l_x;
  c2_h_y = c2_g_y;
  c2_i_y = c2_m_x / c2_h_y;
  c2_b_A = c2_i_y * c2_Mox;
  c2_c_B = c2_Km + c2_Mox;
  c2_n_x = c2_b_A;
  c2_j_y = c2_c_B;
  c2_o_x = c2_n_x;
  c2_k_y = c2_j_y;
  c2_p_x = c2_o_x;
  c2_l_y = c2_k_y;
  c2_qa = c2_p_x / c2_l_y;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 56);
  c2_c_A = 8.2 * c2_S;
  c2_d_B = c2_Ks_m + c2_S;
  c2_q_x = c2_c_A;
  c2_m_y = c2_d_B;
  c2_r_x = c2_q_x;
  c2_n_y = c2_m_y;
  c2_s_x = c2_r_x;
  c2_o_y = c2_n_y;
  c2_qm = c2_s_x / c2_o_y;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 58);
  c2_d_A = 1.9753 * c2_S;
  c2_e_B = c2_Ks_a + c2_S;
  c2_t_x = c2_d_A;
  c2_p_y = c2_e_B;
  c2_u_x = c2_t_x;
  c2_q_y = c2_p_y;
  c2_v_x = c2_u_x;
  c2_r_y = c2_q_y;
  c2_s_y = c2_v_x / c2_r_y;
  c2_e_A = c2_s_y * c2_Mox;
  c2_f_B = c2_Km + c2_Mox;
  c2_w_x = c2_e_A;
  c2_t_y = c2_f_B;
  c2_x_x = c2_w_x;
  c2_u_y = c2_t_y;
  c2_y_x = c2_x_x;
  c2_v_y = c2_u_y;
  c2_ua = c2_y_x / c2_v_y;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 59);
  c2_f_A = 0.1 * c2_S;
  c2_g_B = c2_Ks_m + c2_S;
  c2_ab_x = c2_f_A;
  c2_w_y = c2_g_B;
  c2_bb_x = c2_ab_x;
  c2_x_y = c2_w_y;
  c2_cb_x = c2_bb_x;
  c2_y_y = c2_x_y;
  c2_um = c2_cb_x / c2_y_y;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 61);
  c2_h_B = c2_Mred;
  c2_ab_y = c2_h_B;
  c2_bb_y = c2_ab_y;
  c2_cb_y = c2_bb_y;
  c2_db_y = 0.05 / c2_cb_y;
  c2_d1 = c2_db_y;
  c2_b_log(chartInstance, &c2_d1);
  c2_n_conc = 0.012846348275897809 * c2_d1;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 63);
  c2_g_A = c2_Eocv - c2_n_conc;
  c2_i_B = c2_b_Rext + c2_Rint;
  c2_db_x = c2_g_A;
  c2_eb_y = c2_i_B;
  c2_eb_x = c2_db_x;
  c2_fb_y = c2_eb_y;
  c2_fb_x = c2_eb_x;
  c2_gb_y = c2_fb_y;
  c2_hb_y = c2_fb_x / c2_gb_y;
  c2_h_A = c2_hb_y * c2_Mred;
  c2_j_B = c2_e + c2_Mred;
  c2_gb_x = c2_h_A;
  c2_ib_y = c2_j_B;
  c2_hb_x = c2_gb_x;
  c2_jb_y = c2_ib_y;
  c2_ib_x = c2_hb_x;
  c2_kb_y = c2_jb_y;
  c2_Imfc = c2_ib_x / c2_kb_y;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 65);
  c2_Sp = (-c2_qa * c2_xa - c2_qm * c2_xm) + 3.054 * (c2_b_S0 - c2_S);
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 66);
  c2_Xap = (c2_ua * c2_xa - 0.039506 * c2_xa) - c2_alpha_a * 3.054 * c2_xa;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 67);
  c2_Xmp = (c2_um * c2_xm - 0.002 * c2_xm) - c2_alpha_m * 3.054 * c2_xm;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 69);
  c2_i_A = 663400.0 * c2_Imfc;
  c2_k_B = 9648.5 * c2_xa;
  c2_jb_x = c2_i_A;
  c2_lb_y = c2_k_B;
  c2_kb_x = c2_jb_x;
  c2_mb_y = c2_lb_y;
  c2_lb_x = c2_kb_x;
  c2_nb_y = c2_mb_y;
  c2_ob_y = c2_lb_x / c2_nb_y;
  c2_Moxp = -22.753 * c2_qa + c2_ob_y * 86400.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 71);
  guard2 = false;
  if (CV_EML_COND(0, 1, 0, CV_RELATIONAL_EVAL(4U, 0U, 1, c2_xa, 1.0, -1, 2U,
        c2_xa < 1.0))) {
    if (CV_EML_COND(0, 1, 1, CV_RELATIONAL_EVAL(4U, 0U, 2, c2_Xap, 0.0, -1, 2U,
          c2_Xap < 0.0))) {
      CV_EML_MCDC(0, 1, 0, true);
      CV_EML_IF(0, 1, 1, true);
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 72);
      c2_Xap = 0.0;
    } else {
      guard2 = true;
    }
  } else {
    guard2 = true;
  }

  if (guard2 == true) {
    CV_EML_MCDC(0, 1, 0, false);
    CV_EML_IF(0, 1, 1, false);
  }

  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 75);
  guard1 = false;
  if (CV_EML_COND(0, 1, 2, CV_RELATIONAL_EVAL(4U, 0U, 3, c2_xm, 0.99, -1, 2U,
        c2_xm < 0.99))) {
    if (CV_EML_COND(0, 1, 3, CV_RELATIONAL_EVAL(4U, 0U, 4, c2_Xmp, 0.0, -1, 2U,
          c2_Xmp < 0.0))) {
      CV_EML_MCDC(0, 1, 1, true);
      CV_EML_IF(0, 1, 2, true);
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 76);
      c2_Xmp = 0.0;
    } else {
      guard1 = true;
    }
  } else {
    guard1 = true;
  }

  if (guard1 == true) {
    CV_EML_MCDC(0, 1, 1, false);
    CV_EML_IF(0, 1, 2, false);
  }

  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 79);
  c2_a = c2_Imfc;
  c2_b_a = c2_a;
  c2_c_a = c2_b_a;
  c2_eml_scalar_eg(chartInstance);
  c2_dimagree(chartInstance);
  c2_ak = c2_c_a;
  c2_d_a = c2_ak;
  c2_eml_scalar_eg(chartInstance);
  c2_c = c2_d_a * c2_d_a;
  c2_b_Pout = c2_b_Rext * c2_c;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 81);
  c2_b_dx[0] = c2_Sp;
  c2_b_dx[1] = c2_Xap;
  c2_b_dx[2] = c2_Xmp;
  c2_b_dx[3] = c2_Moxp;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, -81);
  _SFD_SYMBOL_SCOPE_POP();
  for (c2_i6 = 0; c2_i6 < 4; c2_i6++) {
    (*chartInstance->c2_dx)[c2_i6] = c2_b_dx[c2_i6];
  }

  *chartInstance->c2_Pout = c2_b_Pout;
  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 0U, chartInstance->c2_sfEvent);
}

static void initSimStructsc2_mfcStairs(SFc2_mfcStairsInstanceStruct
  *chartInstance)
{
  (void)chartInstance;
}

static void init_script_number_translation(uint32_T c2_machineNumber, uint32_T
  c2_chartNumber, uint32_T c2_instanceNumber)
{
  (void)c2_machineNumber;
  (void)c2_chartNumber;
  (void)c2_instanceNumber;
}

static const mxArray *c2_sf_marshallOut(void *chartInstanceVoid, void *c2_inData)
{
  const mxArray *c2_mxArrayOutData = NULL;
  real_T c2_u;
  const mxArray *c2_y = NULL;
  SFc2_mfcStairsInstanceStruct *chartInstance;
  chartInstance = (SFc2_mfcStairsInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_u = *(real_T *)c2_inData;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", &c2_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static real_T c2_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_b_Pout, const char_T *c2_identifier)
{
  real_T c2_y;
  emlrtMsgIdentifier c2_thisId;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_b_Pout), &c2_thisId);
  sf_mex_destroy(&c2_b_Pout);
  return c2_y;
}

static real_T c2_b_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId)
{
  real_T c2_y;
  real_T c2_d2;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), &c2_d2, 1, 0, 0U, 0, 0U, 0);
  c2_y = c2_d2;
  sf_mex_destroy(&c2_u);
  return c2_y;
}

static void c2_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_b_Pout;
  const char_T *c2_identifier;
  emlrtMsgIdentifier c2_thisId;
  real_T c2_y;
  SFc2_mfcStairsInstanceStruct *chartInstance;
  chartInstance = (SFc2_mfcStairsInstanceStruct *)chartInstanceVoid;
  c2_b_Pout = sf_mex_dup(c2_mxArrayInData);
  c2_identifier = c2_varName;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_b_Pout), &c2_thisId);
  sf_mex_destroy(&c2_b_Pout);
  *(real_T *)c2_outData = c2_y;
  sf_mex_destroy(&c2_mxArrayInData);
}

static const mxArray *c2_b_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData = NULL;
  int32_T c2_i7;
  real_T c2_u[4];
  const mxArray *c2_y = NULL;
  SFc2_mfcStairsInstanceStruct *chartInstance;
  chartInstance = (SFc2_mfcStairsInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  for (c2_i7 = 0; c2_i7 < 4; c2_i7++) {
    c2_u[c2_i7] = (*(real_T (*)[4])c2_inData)[c2_i7];
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_u, 0, 0U, 1U, 0U, 1, 4), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static void c2_c_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_b_dx, const char_T *c2_identifier, real_T c2_y[4])
{
  emlrtMsgIdentifier c2_thisId;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_d_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_b_dx), &c2_thisId, c2_y);
  sf_mex_destroy(&c2_b_dx);
}

static void c2_d_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId, real_T c2_y[4])
{
  real_T c2_dv1[4];
  int32_T c2_i8;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), c2_dv1, 1, 0, 0U, 1, 0U, 1, 4);
  for (c2_i8 = 0; c2_i8 < 4; c2_i8++) {
    c2_y[c2_i8] = c2_dv1[c2_i8];
  }

  sf_mex_destroy(&c2_u);
}

static void c2_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_b_dx;
  const char_T *c2_identifier;
  emlrtMsgIdentifier c2_thisId;
  real_T c2_y[4];
  int32_T c2_i9;
  SFc2_mfcStairsInstanceStruct *chartInstance;
  chartInstance = (SFc2_mfcStairsInstanceStruct *)chartInstanceVoid;
  c2_b_dx = sf_mex_dup(c2_mxArrayInData);
  c2_identifier = c2_varName;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_d_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_b_dx), &c2_thisId, c2_y);
  sf_mex_destroy(&c2_b_dx);
  for (c2_i9 = 0; c2_i9 < 4; c2_i9++) {
    (*(real_T (*)[4])c2_outData)[c2_i9] = c2_y[c2_i9];
  }

  sf_mex_destroy(&c2_mxArrayInData);
}

static const mxArray *c2_c_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData = NULL;
  int32_T c2_i10;
  real_T c2_u[2];
  const mxArray *c2_y = NULL;
  SFc2_mfcStairsInstanceStruct *chartInstance;
  chartInstance = (SFc2_mfcStairsInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  for (c2_i10 = 0; c2_i10 < 2; c2_i10++) {
    c2_u[c2_i10] = (*(real_T (*)[2])c2_inData)[c2_i10];
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_u, 0, 0U, 1U, 0U, 1, 2), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

const mxArray *sf_c2_mfcStairs_get_eml_resolved_functions_info(void)
{
  const mxArray *c2_nameCaptureInfo = NULL;
  c2_nameCaptureInfo = NULL;
  sf_mex_assign(&c2_nameCaptureInfo, sf_mex_create("nameCaptureInfo", NULL, 0,
    0U, 1U, 0U, 2, 0, 1), false);
  return c2_nameCaptureInfo;
}

static real_T c2_log(SFc2_mfcStairsInstanceStruct *chartInstance, real_T c2_b_x)
{
  real_T c2_c_x;
  c2_c_x = c2_b_x;
  c2_b_log(chartInstance, &c2_c_x);
  return c2_c_x;
}

static void c2_eml_error(SFc2_mfcStairsInstanceStruct *chartInstance)
{
  const mxArray *c2_y = NULL;
  static char_T c2_u[30] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'E', 'l', 'F', 'u', 'n', 'D', 'o', 'm', 'a', 'i', 'n',
    'E', 'r', 'r', 'o', 'r' };

  const mxArray *c2_b_y = NULL;
  static char_T c2_b_u[3] = { 'l', 'o', 'g' };

  (void)chartInstance;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_u, 10, 0U, 1U, 0U, 2, 1, 30), false);
  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", c2_b_u, 10, 0U, 1U, 0U, 2, 1, 3),
                false);
  sf_mex_call_debug(sfGlobalDebugInstanceStruct, "error", 0U, 1U, 14,
                    sf_mex_call_debug(sfGlobalDebugInstanceStruct, "message", 1U,
    2U, 14, c2_y, 14, c2_b_y));
}

static void c2_eml_scalar_eg(SFc2_mfcStairsInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void c2_dimagree(SFc2_mfcStairsInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static const mxArray *c2_d_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData = NULL;
  int32_T c2_u;
  const mxArray *c2_y = NULL;
  SFc2_mfcStairsInstanceStruct *chartInstance;
  chartInstance = (SFc2_mfcStairsInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_u = *(int32_T *)c2_inData;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", &c2_u, 6, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static int32_T c2_e_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId)
{
  int32_T c2_y;
  int32_T c2_i11;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), &c2_i11, 1, 6, 0U, 0, 0U, 0);
  c2_y = c2_i11;
  sf_mex_destroy(&c2_u);
  return c2_y;
}

static void c2_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_b_sfEvent;
  const char_T *c2_identifier;
  emlrtMsgIdentifier c2_thisId;
  int32_T c2_y;
  SFc2_mfcStairsInstanceStruct *chartInstance;
  chartInstance = (SFc2_mfcStairsInstanceStruct *)chartInstanceVoid;
  c2_b_sfEvent = sf_mex_dup(c2_mxArrayInData);
  c2_identifier = c2_varName;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_e_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_b_sfEvent),
    &c2_thisId);
  sf_mex_destroy(&c2_b_sfEvent);
  *(int32_T *)c2_outData = c2_y;
  sf_mex_destroy(&c2_mxArrayInData);
}

static uint8_T c2_f_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_b_is_active_c2_mfcStairs, const char_T *c2_identifier)
{
  uint8_T c2_y;
  emlrtMsgIdentifier c2_thisId;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_g_emlrt_marshallIn(chartInstance, sf_mex_dup
    (c2_b_is_active_c2_mfcStairs), &c2_thisId);
  sf_mex_destroy(&c2_b_is_active_c2_mfcStairs);
  return c2_y;
}

static uint8_T c2_g_emlrt_marshallIn(SFc2_mfcStairsInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId)
{
  uint8_T c2_y;
  uint8_T c2_u0;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), &c2_u0, 1, 3, 0U, 0, 0U, 0);
  c2_y = c2_u0;
  sf_mex_destroy(&c2_u);
  return c2_y;
}

static void c2_b_log(SFc2_mfcStairsInstanceStruct *chartInstance, real_T *c2_b_x)
{
  if (*c2_b_x < 0.0) {
    c2_eml_error(chartInstance);
  }

  *c2_b_x = muDoubleScalarLog(*c2_b_x);
}

static void init_dsm_address_info(SFc2_mfcStairsInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void init_simulink_io_address(SFc2_mfcStairsInstanceStruct *chartInstance)
{
  chartInstance->c2_T = (real_T (*)[2])ssGetInputPortSignal_wrapper
    (chartInstance->S, 0);
  chartInstance->c2_dx = (real_T (*)[4])ssGetOutputPortSignal_wrapper
    (chartInstance->S, 1);
  chartInstance->c2_x = (real_T (*)[4])ssGetInputPortSignal_wrapper
    (chartInstance->S, 1);
  chartInstance->c2_S0 = (real_T *)ssGetInputPortSignal_wrapper(chartInstance->S,
    2);
  chartInstance->c2_Rext = (real_T *)ssGetInputPortSignal_wrapper
    (chartInstance->S, 3);
  chartInstance->c2_Pout = (real_T *)ssGetOutputPortSignal_wrapper
    (chartInstance->S, 2);
}

/* SFunction Glue Code */
#ifdef utFree
#undef utFree
#endif

#ifdef utMalloc
#undef utMalloc
#endif

#ifdef __cplusplus

extern "C" void *utMalloc(size_t size);
extern "C" void utFree(void*);

#else

extern void *utMalloc(size_t size);
extern void utFree(void*);

#endif

void sf_c2_mfcStairs_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(499050542U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(2938077652U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(3344119960U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(1564362524U);
}

mxArray* sf_c2_mfcStairs_get_post_codegen_info(void);
mxArray *sf_c2_mfcStairs_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs", "locals", "postCodegenInfo" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1, 1, sizeof
    (autoinheritanceFields)/sizeof(autoinheritanceFields[0]),
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateString("nBQc2ZvLoZtqbbndFKpSZB");
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,4,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(2);
      pr[1] = (double)(1);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(4);
      pr[1] = (double)(1);
      mxSetField(mxData,1,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,1,"type",mxType);
    }

    mxSetField(mxData,1,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,2,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,2,"type",mxType);
    }

    mxSetField(mxData,2,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,3,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,3,"type",mxType);
    }

    mxSetField(mxData,3,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"inputs",mxData);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,1,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"parameters",mxData);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,2,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(4);
      pr[1] = (double)(1);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,1,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,1,"type",mxType);
    }

    mxSetField(mxData,1,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"outputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"locals",mxCreateDoubleMatrix(0,0,mxREAL));
  }

  {
    mxArray* mxPostCodegenInfo = sf_c2_mfcStairs_get_post_codegen_info();
    mxSetField(mxAutoinheritanceInfo,0,"postCodegenInfo",mxPostCodegenInfo);
  }

  return(mxAutoinheritanceInfo);
}

mxArray *sf_c2_mfcStairs_third_party_uses_info(void)
{
  mxArray * mxcell3p = mxCreateCellMatrix(1,0);
  return(mxcell3p);
}

mxArray *sf_c2_mfcStairs_jit_fallback_info(void)
{
  const char *infoFields[] = { "fallbackType", "fallbackReason",
    "hiddenFallbackType", "hiddenFallbackReason", "incompatibleSymbol" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 5, infoFields);
  mxArray *fallbackType = mxCreateString("pre");
  mxArray *fallbackReason = mxCreateString("hasBreakpoints");
  mxArray *hiddenFallbackType = mxCreateString("none");
  mxArray *hiddenFallbackReason = mxCreateString("");
  mxArray *incompatibleSymbol = mxCreateString("");
  mxSetField(mxInfo, 0, infoFields[0], fallbackType);
  mxSetField(mxInfo, 0, infoFields[1], fallbackReason);
  mxSetField(mxInfo, 0, infoFields[2], hiddenFallbackType);
  mxSetField(mxInfo, 0, infoFields[3], hiddenFallbackReason);
  mxSetField(mxInfo, 0, infoFields[4], incompatibleSymbol);
  return mxInfo;
}

mxArray *sf_c2_mfcStairs_updateBuildInfo_args_info(void)
{
  mxArray *mxBIArgs = mxCreateCellMatrix(1,0);
  return mxBIArgs;
}

mxArray* sf_c2_mfcStairs_get_post_codegen_info(void)
{
  const char* fieldNames[] = { "exportedFunctionsUsedByThisChart",
    "exportedFunctionsChecksum" };

  mwSize dims[2] = { 1, 1 };

  mxArray* mxPostCodegenInfo = mxCreateStructArray(2, dims, sizeof(fieldNames)/
    sizeof(fieldNames[0]), fieldNames);

  {
    mxArray* mxExportedFunctionsChecksum = mxCreateString("");
    mwSize exp_dims[2] = { 0, 1 };

    mxArray* mxExportedFunctionsUsedByThisChart = mxCreateCellArray(2, exp_dims);
    mxSetField(mxPostCodegenInfo, 0, "exportedFunctionsUsedByThisChart",
               mxExportedFunctionsUsedByThisChart);
    mxSetField(mxPostCodegenInfo, 0, "exportedFunctionsChecksum",
               mxExportedFunctionsChecksum);
  }

  return mxPostCodegenInfo;
}

static const mxArray *sf_get_sim_state_info_c2_mfcStairs(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x3'type','srcId','name','auxInfo'{{M[1],M[10],T\"Pout\",},{M[1],M[5],T\"dx\",},{M[8],M[0],T\"is_active_c2_mfcStairs\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 3, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c2_mfcStairs_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc2_mfcStairsInstanceStruct *chartInstance;
    ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
    ChartInfoStruct * chartInfo = (ChartInfoStruct *)(crtInfo->instanceInfo);
    chartInstance = (SFc2_mfcStairsInstanceStruct *) chartInfo->chartInstance;
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (sfGlobalDebugInstanceStruct,
           _mfcStairsMachineNumber_,
           2,
           1,
           1,
           0,
           7,
           0,
           0,
           0,
           0,
           0,
           &(chartInstance->chartNumber),
           &(chartInstance->instanceNumber),
           (void *)S);

        /* Each instance must initialize its own list of scripts */
        init_script_number_translation(_mfcStairsMachineNumber_,
          chartInstance->chartNumber,chartInstance->instanceNumber);
        if (chartAlreadyPresent==0) {
          /* this is the first instance */
          sf_debug_set_chart_disable_implicit_casting
            (sfGlobalDebugInstanceStruct,_mfcStairsMachineNumber_,
             chartInstance->chartNumber,1);
          sf_debug_set_chart_event_thresholds(sfGlobalDebugInstanceStruct,
            _mfcStairsMachineNumber_,
            chartInstance->chartNumber,
            0,
            0,
            0);
          _SFD_SET_DATA_PROPS(0,1,1,0,"T");
          _SFD_SET_DATA_PROPS(1,1,1,0,"x");
          _SFD_SET_DATA_PROPS(2,1,1,0,"S0");
          _SFD_SET_DATA_PROPS(3,1,1,0,"Rext");
          _SFD_SET_DATA_PROPS(4,2,0,1,"dx");
          _SFD_SET_DATA_PROPS(5,2,0,1,"Pout");
          _SFD_SET_DATA_PROPS(6,10,0,0,"dummy");
          _SFD_STATE_INFO(0,0,2);
          _SFD_CH_SUBSTATE_COUNT(0);
          _SFD_CH_SUBSTATE_DECOMP(0);
        }

        _SFD_CV_INIT_CHART(0,0,0,0);

        {
          _SFD_CV_INIT_STATE(0,0,0,0,0,0,NULL,NULL);
        }

        _SFD_CV_INIT_TRANS(0,0,NULL,NULL,0,NULL);

        /* Initialization of MATLAB Function Model Coverage */
        _SFD_CV_INIT_EML(0,1,1,0,3,0,0,0,0,0,4,2);
        _SFD_CV_INIT_EML_FCN(0,0,"eML_blk_kernel",0,-1,1780);
        _SFD_CV_INIT_EML_IF(0,1,0,578,589,-1,600);
        _SFD_CV_INIT_EML_IF(0,1,1,1655,1675,-1,1690);
        _SFD_CV_INIT_EML_IF(0,1,2,1692,1715,-1,1730);

        {
          static int condStart[] = { 1658, 1668 };

          static int condEnd[] = { 1664, 1675 };

          static int pfixExpr[] = { 0, 1, -3 };

          _SFD_CV_INIT_EML_MCDC(0,1,0,1658,1675,2,0,&(condStart[0]),&(condEnd[0]),
                                3,&(pfixExpr[0]));
        }

        {
          static int condStart[] = { 1695, 1708 };

          static int condEnd[] = { 1704, 1715 };

          static int pfixExpr[] = { 0, 1, -3 };

          _SFD_CV_INIT_EML_MCDC(0,1,1,1695,1715,2,2,&(condStart[0]),&(condEnd[0]),
                                3,&(pfixExpr[0]));
        }

        _SFD_CV_INIT_EML_RELATIONAL(0,1,0,581,589,-1,2);
        _SFD_CV_INIT_EML_RELATIONAL(0,1,1,1658,1664,-1,2);
        _SFD_CV_INIT_EML_RELATIONAL(0,1,2,1668,1675,-1,2);
        _SFD_CV_INIT_EML_RELATIONAL(0,1,3,1695,1704,-1,2);
        _SFD_CV_INIT_EML_RELATIONAL(0,1,4,1708,1715,-1,2);

        {
          unsigned int dimVector[1];
          dimVector[0]= 2;
          _SFD_SET_DATA_COMPILED_PROPS(0,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_c_sf_marshallOut,(MexInFcnForType)NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 4;
          _SFD_SET_DATA_COMPILED_PROPS(1,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_b_sf_marshallOut,(MexInFcnForType)NULL);
        }

        _SFD_SET_DATA_COMPILED_PROPS(2,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)NULL);
        _SFD_SET_DATA_COMPILED_PROPS(3,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)NULL);

        {
          unsigned int dimVector[1];
          dimVector[0]= 4;
          _SFD_SET_DATA_COMPILED_PROPS(4,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_b_sf_marshallOut,(MexInFcnForType)
            c2_b_sf_marshallIn);
        }

        _SFD_SET_DATA_COMPILED_PROPS(5,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)c2_sf_marshallIn);
        _SFD_SET_DATA_COMPILED_PROPS(6,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)c2_sf_marshallIn);
      }
    } else {
      sf_debug_reset_current_state_configuration(sfGlobalDebugInstanceStruct,
        _mfcStairsMachineNumber_,chartInstance->chartNumber,
        chartInstance->instanceNumber);
    }
  }
}

static void chart_debug_initialize_data_addresses(SimStruct *S)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc2_mfcStairsInstanceStruct *chartInstance;
    ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
    ChartInfoStruct * chartInfo = (ChartInfoStruct *)(crtInfo->instanceInfo);
    chartInstance = (SFc2_mfcStairsInstanceStruct *) chartInfo->chartInstance;
    if (ssIsFirstInitCond(S)) {
      /* do this only if simulation is starting and after we know the addresses of all data */
      {
        _SFD_SET_DATA_VALUE_PTR(0U, *chartInstance->c2_T);
        _SFD_SET_DATA_VALUE_PTR(4U, *chartInstance->c2_dx);
        _SFD_SET_DATA_VALUE_PTR(1U, *chartInstance->c2_x);
        _SFD_SET_DATA_VALUE_PTR(6U, &chartInstance->c2_dummy);
        _SFD_SET_DATA_VALUE_PTR(2U, chartInstance->c2_S0);
        _SFD_SET_DATA_VALUE_PTR(3U, chartInstance->c2_Rext);
        _SFD_SET_DATA_VALUE_PTR(5U, chartInstance->c2_Pout);
      }
    }
  }
}

static const char* sf_get_instance_specialization(void)
{
  return "sV2J7KdZheSHFXVaprBeSrG";
}

static void sf_opaque_initialize_c2_mfcStairs(void *chartInstanceVar)
{
  chart_debug_initialization(((SFc2_mfcStairsInstanceStruct*) chartInstanceVar
    )->S,0);
  initialize_params_c2_mfcStairs((SFc2_mfcStairsInstanceStruct*)
    chartInstanceVar);
  initialize_c2_mfcStairs((SFc2_mfcStairsInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_enable_c2_mfcStairs(void *chartInstanceVar)
{
  enable_c2_mfcStairs((SFc2_mfcStairsInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_disable_c2_mfcStairs(void *chartInstanceVar)
{
  disable_c2_mfcStairs((SFc2_mfcStairsInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_gateway_c2_mfcStairs(void *chartInstanceVar)
{
  sf_gateway_c2_mfcStairs((SFc2_mfcStairsInstanceStruct*) chartInstanceVar);
}

static const mxArray* sf_opaque_get_sim_state_c2_mfcStairs(SimStruct* S)
{
  ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
  ChartInfoStruct * chartInfo = (ChartInfoStruct *)(crtInfo->instanceInfo);
  return get_sim_state_c2_mfcStairs((SFc2_mfcStairsInstanceStruct*)
    chartInfo->chartInstance);         /* raw sim ctx */
}

static void sf_opaque_set_sim_state_c2_mfcStairs(SimStruct* S, const mxArray *st)
{
  ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
  ChartInfoStruct * chartInfo = (ChartInfoStruct *)(crtInfo->instanceInfo);
  set_sim_state_c2_mfcStairs((SFc2_mfcStairsInstanceStruct*)
    chartInfo->chartInstance, st);
}

static void sf_opaque_terminate_c2_mfcStairs(void *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc2_mfcStairsInstanceStruct*) chartInstanceVar)->S;
    ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
      unload_mfcStairs_optimization_info();
    }

    finalize_c2_mfcStairs((SFc2_mfcStairsInstanceStruct*) chartInstanceVar);
    utFree(chartInstanceVar);
    if (crtInfo != NULL) {
      utFree(crtInfo);
    }

    ssSetUserData(S,NULL);
  }
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  initSimStructsc2_mfcStairs((SFc2_mfcStairsInstanceStruct*) chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c2_mfcStairs(SimStruct *S)
{
  int i;
  for (i=0;i<ssGetNumRunTimeParams(S);i++) {
    if (ssGetSFcnParamTunable(S,i)) {
      ssUpdateDlgParamAsRunTimeParam(S,i);
    }
  }

  if (sf_machine_global_initializer_called()) {
    ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
    ChartInfoStruct * chartInfo = (ChartInfoStruct *)(crtInfo->instanceInfo);
    initialize_params_c2_mfcStairs((SFc2_mfcStairsInstanceStruct*)
      (chartInfo->chartInstance));
  }
}

static void mdlSetWorkWidths_c2_mfcStairs(SimStruct *S)
{
  /* Actual parameters from chart:
     dummy
   */
  const char_T *rtParamNames[] = { "dummy" };

  ssSetNumRunTimeParams(S,ssGetSFcnParamsCount(S));

  /* registration for dummy*/
  ssRegDlgParamAsRunTimeParam(S, 0, 0, rtParamNames[0], SS_DOUBLE);
  ssMdlUpdateIsEmpty(S, 1);
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    mxArray *infoStruct = load_mfcStairs_optimization_info();
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(sf_get_instance_specialization(),infoStruct,2);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,1);
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop
      (sf_get_instance_specialization(),infoStruct,2,
       "gatewayCannotBeInlinedMultipleTimes"));
    sf_update_buildInfo(sf_get_instance_specialization(),infoStruct,2);
    if (chartIsInlinable) {
      ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 2, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 3, SS_REUSABLE_AND_LOCAL);
      sf_mark_chart_expressionable_inputs(S,sf_get_instance_specialization(),
        infoStruct,2,4);
      sf_mark_chart_reusable_outputs(S,sf_get_instance_specialization(),
        infoStruct,2,2);
    }

    {
      unsigned int outPortIdx;
      for (outPortIdx=1; outPortIdx<=2; ++outPortIdx) {
        ssSetOutputPortOptimizeInIR(S, outPortIdx, 1U);
      }
    }

    {
      unsigned int inPortIdx;
      for (inPortIdx=0; inPortIdx < 4; ++inPortIdx) {
        ssSetInputPortOptimizeInIR(S, inPortIdx, 1U);
      }
    }

    sf_set_rtw_dwork_info(S,sf_get_instance_specialization(),infoStruct,2);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(3964981500U));
  ssSetChecksum1(S,(3846438989U));
  ssSetChecksum2(S,(2194750043U));
  ssSetChecksum3(S,(2479439595U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
  ssSupportsMultipleExecInstances(S,1);
}

static void mdlRTW_c2_mfcStairs(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");
  }
}

static void mdlStart_c2_mfcStairs(SimStruct *S)
{
  SFc2_mfcStairsInstanceStruct *chartInstance;
  ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)utMalloc(sizeof
    (ChartRunTimeInfo));
  chartInstance = (SFc2_mfcStairsInstanceStruct *)utMalloc(sizeof
    (SFc2_mfcStairsInstanceStruct));
  memset(chartInstance, 0, sizeof(SFc2_mfcStairsInstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 1;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway = sf_opaque_gateway_c2_mfcStairs;
  chartInstance->chartInfo.initializeChart = sf_opaque_initialize_c2_mfcStairs;
  chartInstance->chartInfo.terminateChart = sf_opaque_terminate_c2_mfcStairs;
  chartInstance->chartInfo.enableChart = sf_opaque_enable_c2_mfcStairs;
  chartInstance->chartInfo.disableChart = sf_opaque_disable_c2_mfcStairs;
  chartInstance->chartInfo.getSimState = sf_opaque_get_sim_state_c2_mfcStairs;
  chartInstance->chartInfo.setSimState = sf_opaque_set_sim_state_c2_mfcStairs;
  chartInstance->chartInfo.getSimStateInfo = sf_get_sim_state_info_c2_mfcStairs;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c2_mfcStairs;
  chartInstance->chartInfo.mdlStart = mdlStart_c2_mfcStairs;
  chartInstance->chartInfo.mdlSetWorkWidths = mdlSetWorkWidths_c2_mfcStairs;
  chartInstance->chartInfo.extModeExec = NULL;
  chartInstance->chartInfo.restoreLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.restoreBeforeLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.storeCurrentConfiguration = NULL;
  chartInstance->chartInfo.callAtomicSubchartUserFcn = NULL;
  chartInstance->chartInfo.callAtomicSubchartAutoFcn = NULL;
  chartInstance->chartInfo.debugInstance = sfGlobalDebugInstanceStruct;
  chartInstance->S = S;
  crtInfo->isEnhancedMooreMachine = 0;
  crtInfo->checksum = SF_RUNTIME_INFO_CHECKSUM;
  crtInfo->fCheckOverflow = sf_runtime_overflow_check_is_on(S);
  crtInfo->instanceInfo = (&(chartInstance->chartInfo));
  crtInfo->isJITEnabled = false;
  crtInfo->compiledInfo = NULL;
  ssSetUserData(S,(void *)(crtInfo));  /* register the chart instance with simstruct */
  init_dsm_address_info(chartInstance);
  init_simulink_io_address(chartInstance);
  if (!sim_mode_is_rtw_gen(S)) {
  }

  chart_debug_initialization(S,1);
}

void c2_mfcStairs_method_dispatcher(SimStruct *S, int_T method, void *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c2_mfcStairs(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c2_mfcStairs(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c2_mfcStairs(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c2_mfcStairs_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}
