import 'dart:io';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:safelink_aid/core/utilities/auth_middleware.dart';
import 'package:safelink_aid/core/utilities/dialog_helpers.dart';
import 'package:safelink_aid/features/authorization/models/auth_models.dart';
import 'package:safelink_aid/features/dashboard/controllers/aid_request_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/dashboard_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find<AuthController>();

  final _supabaseService = SupabaseService.instance;
  final Rx<Session?> _session = Rx<Session?>(null);
  final RxBool isLoading = false.obs;

  Session? get session => _session.value;

  bool get isLoggedIn => _session.value != null;

  @override
  void onInit() {
    super.onInit();
    _session.value = _supabaseService.auth.currentSession;
    _supabaseService.auth.onAuthStateChange.listen((data) {
      _session.value = data.session;
      if (data.event == AuthChangeEvent.passwordRecovery) {
        Get.offAllNamed(AppRoutes.setNewPasswordView);
      }
    });
  }

  /// SIGN OUT
  Future<void> signUp(SignUpModel model) async {
    try {
      isLoading.value = true;
      DialogHelpers.showLoadingDialog();

      final AuthResponse response = await _supabaseService.auth.signUp(
        email: model.email,
        password: model.password,
        data: model.toAuthMetadata(),
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Registration failed. Please try again.');
      }

      // The handle_new_user trigger populates profiles from auth metadata.
      // We only need a follow-up update when an avatar was uploaded.
      if (model.profilePicture != null) {
        final avatarUrl = await _uploadAvatar(user.id, model.profilePicture!);
        if (avatarUrl != null) {
          await _supabaseService.profiles
              .update({'avatar_url': avatarUrl})
              .eq('id', user.id);
        }
      }

      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Success',
        message:
            'Account created successfully! Please check your email to verify your account.',
      );
      Get.offAllNamed(AppRoutes.signInView);
    } on AuthException catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(title: 'Sign Up Failed', message: e.message);
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t create account',
        error: e,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// SIGN IN
  Future<void> signIn(SignInModel model) async {
    try {
      isLoading.value = true;
      DialogHelpers.showLoadingDialog();

      await _supabaseService.auth.signInWithPassword(
        email: model.email,
        password: model.password,
      );

      DialogHelpers.hideLoadingDialog();
      await evaluateRouting();
    } on AuthException catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(title: 'Sign In Failed', message: e.message);
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t sign in',
        error: e,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// EVALUATE ROUTING BASED ON TEAM STATUS
  Future<void> evaluateRouting() async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        Get.offAllNamed(AppRoutes.signInView);
        return;
      }

      // Check if user is in an active team
      final memberResponse = await _supabaseService.teamMembers
          .select('team_id')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .maybeSingle();

      if (memberResponse == null) {
        // No active team, check join requests
        final joinReq = await _supabaseService.client
            .from('team_join_requests')
            .select('status')
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (joinReq != null && joinReq['status'] == 'pending') {
          Get.offAllNamed(AppRoutes.waitingApprovalView);
          return;
        }

        // Check if they created a pending team
        final pendingTeam = await _supabaseService.teams
            .select('is_approved')
            .eq('created_by', user.id)
            .eq('is_approved', false)
            .maybeSingle();

        if (pendingTeam != null) {
          Get.offAllNamed(AppRoutes.waitingApprovalView);
          return;
        }

        Get.offAllNamed(AppRoutes.teamSelectionView);
        return;
      }

      // Has active team mapping, check if team itself is approved
      final teamId = memberResponse['team_id'];
      final teamResponse = await _supabaseService.teams
          .select('is_approved')
          .eq('id', teamId)
          .maybeSingle();

      if (teamResponse != null && teamResponse['is_approved'] == true) {
        // Dashboard/AidRequest controllers are permanent and ran their initial
        // load at app-start, possibly before the user had an aid_worker_profile
        // or an active team. No auth event fires when those become true, so
        // refresh on entry to make sure the lists reflect the user's current
        // org scope.
        _refreshDashboardData();
        Get.offAllNamed(AppRoutes.mainDashboardView);
      } else {
        Get.offAllNamed(AppRoutes.waitingApprovalView);
      }
    } catch (e) {
      // Don't silently push to teamSelection on a transient failure — that
      // can drop a fully-onboarded user back into the team gate. Stay where
      // we are; sign the user out only if there is no session at all.
      DialogHelpers.showFailure(
        title: 'Error',
        message: 'Failed to resolve user team status. Please try again.',
      );
      if (_supabaseService.currentUser == null) {
        Get.offAllNamed(AppRoutes.signInView);
      }
    }
  }

  void _refreshDashboardData() {
    try {
      Get.find<DashboardController>().refreshDashboard();
    } catch (_) {}
    try {
      Get.find<AidRequestController>().refreshRequests();
    } catch (_) {}
  }

  /// SIGN OUT
  Future<void> signOut() async {
    try {
      await _supabaseService.auth.signOut();
      OnboardingGateMiddleware.reset();
      Get.offAllNamed(AppRoutes.signInView);
    } catch (e) {
      DialogHelpers.showFailure(
        title: 'Couldn\'t sign out',
        error: e,
      );
    }
  }

  /// RESET PASSWORD
  Future<void> resetPassword(ResetPasswordModel model) async {
    try {
      isLoading.value = true;
      DialogHelpers.showLoadingDialog();

      await _supabaseService.auth.resetPasswordForEmail(
        model.email,
        redirectTo: 'safelinkgov://reset-password',
      );

      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Email Sent',
        message: 'Check your email for reset instructions.',
      );
      Get.offAllNamed(AppRoutes.signInView);
    } on AuthException catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t send reset email',
        message: e.message,
      );
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t send reset email',
        error: e,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// UPDATE PASSWORD
  Future<void> updatePassword(String newPassword) async {
    try {
      isLoading.value = true;
      DialogHelpers.showLoadingDialog();

      await _supabaseService.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Password Updated',
        message: 'Your password has been updated successfully.',
      );

      await _supabaseService.auth.signOut();
      Get.offAllNamed(AppRoutes.signInView);
    } on AuthException catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t update password',
        message: e.message,
      );
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t update password',
        error: e,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// UPLOAD AVATAR
  Future<String?> _uploadAvatar(String userID, File file) async {
    try {
      final extension = file.path.split('.').last;
      final path = '$userID/avatar.$extension';

      await _supabaseService.storage
          .from('avatars')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _supabaseService.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  /// CHECK SESSION
  Future<bool> checkSession() async {
    try {
      final session = _supabaseService.auth.currentSession;
      if (session == null) return false;
      if (session.isExpired) {
        await _supabaseService.auth.refreshSession();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
