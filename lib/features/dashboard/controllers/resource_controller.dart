import 'dart:async';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/core/utilities/dialog_helpers.dart';
import 'package:safelink_aid/features/dashboard/models/resource_model.dart';
import 'package:safelink_aid/features/dashboard/services/resource_service.dart';
import 'package:safelink_aid/features/profile/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent, AuthState;

class ResourceController extends GetxController {
  final ResourceService _service = Get.find<ResourceService>();
  final ProfileService _profileService = Get.find<ProfileService>();

  final isLoading = false.obs;
  final resources = <ResourceModel>[].obs;
  final searchQuery = ''.obs;
  final typeFilter = 'all'.obs;

  String? _lastSeenUserId;
  StreamSubscription<AuthState>? _authSub;

  @override
  void onInit() {
    super.onInit();
    _lastSeenUserId = SupabaseService.instance.currentUser?.id;
    _authSub = SupabaseService.instance.auth.onAuthStateChange
        .listen(_onAuthChange);
    loadResources();
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
        loadResources();
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
    resources.clear();
    searchQuery.value = '';
    typeFilter.value = 'all';
  }

  Future<void> loadResources() async {
    isLoading.value = true;
    try {
      resources.value = await _service.getOrgResources();
    } catch (e) {
      Get.log('Error loading resources: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<ResourceModel> get filteredResources {
    final q = searchQuery.value.trim().toLowerCase();
    return resources.where((r) {
      final matchesQuery = q.isEmpty ||
          r.name.toLowerCase().contains(q) ||
          r.resourceType.toLowerCase().contains(q);
      final matchesType =
          typeFilter.value == 'all' || r.resourceType == typeFilter.value;
      return matchesQuery && matchesType;
    }).toList();
  }

  Future<void> createResource({
    required String name,
    required String resourceType,
    String? description,
    required int quantityAvailable,
    required int quantityTotal,
    String unit = 'units',
    String? location,
  }) async {
    try {
      DialogHelpers.showLoadingDialog();
      final orgId = await _profileService.getOrganizationId();

      final resource = await _service.createResource(
        ResourceModel(
          id: '',
          name: name,
          resourceType: resourceType,
          description: description,
          quantityAvailable: quantityAvailable,
          quantityTotal: quantityTotal,
          unit: unit,
          location: location,
          managedByOrgId: orgId,
        ),
      );
      resources.insert(0, resource);
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Resource Added',
        message: '$name has been added to inventory.',
      );
      Get.back();
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t add resource',
        error: e,
      );
    }
  }

  Future<void> updateResource(String id, Map<String, dynamic> updates) async {
    try {
      DialogHelpers.showLoadingDialog();
      final updated = await _service.updateResource(id, updates);
      final idx = resources.indexWhere((r) => r.id == id);
      if (idx != -1) resources[idx] = updated;
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Updated',
        message: 'Resource has been updated.',
      );
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t update resource',
        error: e,
      );
    }
  }

  Future<void> deleteResource(String id) async {
    try {
      DialogHelpers.showLoadingDialog();
      await _service.deleteResource(id);
      resources.removeWhere((r) => r.id == id);
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Deleted',
        message: 'Resource removed from inventory.',
      );
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t delete resource',
        error: e,
      );
    }
  }

  int get totalStock =>
      resources.fold(0, (sum, r) => sum + r.quantityAvailable);
  int get totalCategories =>
      resources.map((r) => r.resourceType).toSet().length;
  int get lowStockCount => resources.where((r) => r.isLowStock).length;

  Future<void> refreshResources() => loadResources();
}
