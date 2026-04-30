import 'dart:async';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/core/utilities/dialog_helpers.dart';
import 'package:safelink_aid/features/dashboard/models/aid_request_model.dart';
import 'package:safelink_aid/features/dashboard/services/aid_request_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent, AuthState;

class AidRequestController extends GetxController {
  final AidRequestService _service = Get.find<AidRequestService>();

  final isLoading = false.obs;
  final requests = <AidRequestModel>[].obs;
  final selectedRequest = Rxn<AidRequestModel>();
  final searchQuery = ''.obs;
  final statusFilter = 'all'.obs;
  final timeline = <Map<String, dynamic>>[].obs;

  String? _lastSeenUserId;
  StreamSubscription<AuthState>? _authSub;

  @override
  void onInit() {
    super.onInit();
    _lastSeenUserId = SupabaseService.instance.currentUser?.id;
    _authSub = SupabaseService.instance.auth.onAuthStateChange
        .listen(_onAuthChange);
    loadRequests();
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
        _clearLocal();
        loadRequests();
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
    requests.clear();
    selectedRequest.value = null;
    searchQuery.value = '';
    statusFilter.value = 'all';
    timeline.clear();
  }

  Future<void> loadRequests() async {
    isLoading.value = true;
    try {
      requests.value = await _service.getAssignedRequests();
    } catch (e) {
      Get.log('Error loading aid requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<AidRequestModel> get filteredRequests {
    final q = searchQuery.value.trim().toLowerCase();
    return requests.where((r) {
      final matchesQuery = q.isEmpty ||
          r.aidType.toLowerCase().contains(q) ||
          (r.userName?.toLowerCase().contains(q) ?? false) ||
          (r.address?.toLowerCase().contains(q) ?? false) ||
          r.description.toLowerCase().contains(q);
      final matchesStatus =
          statusFilter.value == 'all' || r.status == statusFilter.value;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  Future<void> selectRequest(String id) async {
    try {
      selectedRequest.value = await _service.getRequestById(id);
      if (selectedRequest.value != null) {
        await loadTimeline(id);
      }
    } catch (e) {
      Get.log('Error loading request detail: $e');
    }
  }

  Future<void> loadTimeline(String requestId) async {
    try {
      timeline.value = await _service.getRequestTimeline(requestId);
    } catch (e) {
      Get.log('Error loading timeline: $e');
    }
  }

  Future<void> markInProgress(String id) async {
    try {
      DialogHelpers.showLoadingDialog();
      await _service.markInProgress(id);
      _updateLocalStatus(id, 'in_progress');
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Updated',
        message: 'Request marked as in progress.',
      );
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t mark in progress',
        error: e,
      );
    }
  }

  Future<void> fulfillRequest(String id) async {
    try {
      DialogHelpers.showLoadingDialog();
      await _service.fulfillRequest(id);
      _updateLocalStatus(id, 'fulfilled');
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Fulfilled',
        message: 'Request has been marked as fulfilled.',
      );
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t fulfill request',
        error: e,
      );
    }
  }

  Future<void> rejectRequest(String id, {String? reason}) async {
    try {
      DialogHelpers.showLoadingDialog();
      await _service.rejectRequest(id, reason: reason);
      _updateLocalStatus(id, 'rejected');
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Rejected',
        message: 'Request has been rejected.',
      );
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t reject request',
        error: e,
      );
    }
  }

  void _updateLocalStatus(String id, String status) {
    final idx = requests.indexWhere((r) => r.id == id);
    if (idx != -1) {
      requests[idx] = requests[idx].copyWith(status: status);
    }
    if (selectedRequest.value?.id == id) {
      selectedRequest.value = selectedRequest.value?.copyWith(status: status);
    }
  }

  Future<void> refreshRequests() => loadRequests();
}
