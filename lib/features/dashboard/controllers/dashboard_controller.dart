import 'dart:async';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/features/dashboard/models/aid_request_model.dart';
import 'package:safelink_aid/features/dashboard/models/dashboard_stats_model.dart';
import 'package:safelink_aid/features/dashboard/services/aid_request_service.dart';
import 'package:safelink_aid/features/dashboard/services/alert_service.dart';
import 'package:safelink_aid/features/dashboard/services/dashboard_service.dart';
import 'package:safelink_aid/features/profile/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent, AuthState;

class DashboardController extends GetxController {
  final DashboardService _dashService = Get.find<DashboardService>();
  final AidRequestService _aidService = Get.find<AidRequestService>();
  final AlertService _alertService = Get.find<AlertService>();
  final ProfileService _profileService = Get.find<ProfileService>();

  final isLoading = false.obs;
  final stats = Rxn<DashboardStatsModel>();
  final recentRequests = <AidRequestModel>[].obs;
  final activeAlerts = <Map<String, dynamic>>[].obs;
  final orgId = Rxn<String>();

  String? _lastSeenUserId;
  StreamSubscription<AuthState>? _authSub;

  @override
  void onInit() {
    super.onInit();
    _lastSeenUserId = SupabaseService.instance.currentUser?.id;
    _authSub = SupabaseService.instance.auth.onAuthStateChange
        .listen(_onAuthChange);
    loadDashboardData();
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  void _onAuthChange(AuthState state) {
    final newUserId = state.session?.user.id;
    switch (state.event) {
      case AuthChangeEvent.signedIn:
        // Token refreshes can re-fire signedIn with the same user — skip
        // those so we don't thrash data.
        if (newUserId == _lastSeenUserId) return;
        _lastSeenUserId = newUserId;
        _clearLocal();
        loadDashboardData();
        break;
      case AuthChangeEvent.signedOut:
        _lastSeenUserId = null;
        _clearLocal();
        break;
      default:
        break;
    }
  }

  void _clearLocal() {
    stats.value = null;
    recentRequests.clear();
    activeAlerts.clear();
    orgId.value = null;
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      // First get org id
      orgId.value = await _profileService.getOrganizationId();

      await Future.wait([
        _loadStats(),
        _loadRecentRequests(),
        _loadAlerts(),
      ]);
    } catch (e, stack) {
      Get.log('Error loading dashboard: $e\n$stack');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadStats() async {
    if (orgId.value != null) {
      stats.value = await _dashService.getOrgStats(orgId.value!);
    }
  }

  Future<void> _loadRecentRequests() async {
    final all = await _aidService.getAssignedRequests();
    recentRequests.value = all.take(5).toList();
  }

  Future<void> _loadAlerts() async {
    activeAlerts.value = await _alertService.getActiveAlerts();
  }

  int get activeRequestCount => stats.value?.activeRequests ?? 0;
  int get fulfilledCount => stats.value?.fulfilledRequests ?? 0;
  int get teamCount => stats.value?.totalTeams ?? 0;
  int get resourceCount => stats.value?.totalResources ?? 0;

  Future<void> refreshDashboard() => loadDashboardData();
}
