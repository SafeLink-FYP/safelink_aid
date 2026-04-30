import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:safelink_aid/features/authorization/controllers/auth_controller.dart';

/// Catches deep-link / programmatic navigation to authed-only screens when
/// there is no active session. Membership-level decisions (team gate vs
/// dashboard) stay inside [AuthController.evaluateRouting].
class AuthRequiredMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final session = SupabaseService.instance.auth.currentSession;
    if (session == null) {
      return const RouteSettings(name: AppRoutes.signInView);
    }
    return null;
  }
}

/// Applied to [AppRoutes.mainDashboardView] only. Verifies that the current
/// user is allowed on the dashboard (active approved team) by kicking
/// `evaluateRouting` once per signed-in user.
///
/// We track the *user id* we have already verified for. As long as it
/// matches the current session's user, the middleware is a no-op — that
/// prevents the navigation loop that occurs when `evaluateRouting` itself
/// calls `Get.offAllNamed(mainDashboardView)` for an already-valid user.
class OnboardingGateMiddleware extends GetMiddleware {
  static String? _verifiedUserId;

  /// Call from sign-out or auth-state listeners that need to force a
  /// re-verification on the next navigation.
  static void reset() {
    _verifiedUserId = null;
  }

  @override
  RouteSettings? redirect(String? route) {
    final session = SupabaseService.instance.auth.currentSession;
    if (session == null) {
      _verifiedUserId = null;
      return const RouteSettings(name: AppRoutes.signInView);
    }
    return null;
  }

  @override
  Widget onPageBuilt(Widget page) {
    final currentUserId = SupabaseService.instance.currentUser?.id;
    if (currentUserId == null) return page;
    // Already verified routing for this user — don't re-run evaluateRouting.
    // This is the loop-breaker.
    if (_verifiedUserId == currentUserId) return page;

    _verifiedUserId = currentUserId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (Get.isRegistered<AuthController>()) {
          await AuthController.instance.evaluateRouting();
        }
      } catch (_) {
        // Allow re-attempt on the next nav if resolution failed.
        _verifiedUserId = null;
      }
    });
    return page;
  }
}
