import 'dart:async';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/features/dashboard/services/alert_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent, AuthState;

class AlertController extends GetxController {
  final AlertService _alertService = Get.find<AlertService>();

  final isLoading = false.obs;
  final alerts = <Map<String, dynamic>>[].obs;
  final selectedAlert = Rxn<Map<String, dynamic>>();
  final isDetailLoading = false.obs;

  String? _lastSeenUserId;
  StreamSubscription<AuthState>? _authSub;

  @override
  void onInit() {
    super.onInit();
    _lastSeenUserId = SupabaseService.instance.currentUser?.id;
    _authSub = SupabaseService.instance.auth.onAuthStateChange
        .listen(_onAuthChange);
    loadAlerts();
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
        if (newUserId == _lastSeenUserId) return;
        _lastSeenUserId = newUserId;
        alerts.clear();
        loadAlerts();
        break;
      case AuthChangeEvent.signedOut:
        _lastSeenUserId = null;
        alerts.clear();
        break;
      default:
        break;
    }
  }

  Future<void> loadAlerts() async {
    isLoading.value = true;
    try {
      alerts.value = await _alertService.getActiveAlerts();
    } catch (e) {
      Get.log('Error loading alerts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectAlert(String id) async {
    isDetailLoading.value = true;
    try {
      // Try to satisfy from the cached list first; fall back to a fetch.
      final cached = alerts.firstWhereOrNull((a) => a['id'] == id);
      if (cached != null) {
        selectedAlert.value = cached;
      } else {
        selectedAlert.value = await _alertService.getAlertById(id);
      }
    } catch (e) {
      Get.log('Error loading alert detail: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> refreshAlerts() => loadAlerts();
}
