// Lean compiler output
// Module: ComposableFuture
// Imports: public import Init public import ComposableFuture.Core.Future public import ComposableFuture.Core.Operators public import ComposableFuture.Core.Laws public import ComposableFuture.Core.Probabilistic
#include <lean/lean.h>
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wunused-label"
#elif defined(__GNUC__) && !defined(__CLANG__)
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wunused-label"
#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
#endif
#ifdef __cplusplus
extern "C" {
#endif
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_composable_x2dfuture_ComposableFuture_Core_Future(uint8_t builtin);
lean_object* initialize_composable_x2dfuture_ComposableFuture_Core_Operators(uint8_t builtin);
lean_object* initialize_composable_x2dfuture_ComposableFuture_Core_Laws(uint8_t builtin);
lean_object* initialize_composable_x2dfuture_ComposableFuture_Core_Probabilistic(uint8_t builtin);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_composable_x2dfuture_ComposableFuture(uint8_t builtin) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_composable_x2dfuture_ComposableFuture_Core_Future(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_composable_x2dfuture_ComposableFuture_Core_Operators(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_composable_x2dfuture_ComposableFuture_Core_Laws(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_composable_x2dfuture_ComposableFuture_Core_Probabilistic(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif
