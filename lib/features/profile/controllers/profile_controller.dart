import 'dart:async';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/features/profile/models/profile_model.dart';
import 'package:safelink_aid/features/profile/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent, AuthState;

class ProfileController extends GetxController {
  final ProfileService _profileService = Get.find<ProfileService>();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isUploadingAvatar = false.obs;
  final profile = Rxn<ProfileModel>();
  final aidProfile = Rxn<AidWorkerProfileModel>();

  String? _lastSeenUserId;
  StreamSubscription<AuthState>? _authSub;

  @override
  void onInit() {
    super.onInit();
    _lastSeenUserId = SupabaseService.instance.currentUser?.id;
    _authSub = SupabaseService.instance.auth.onAuthStateChange
        .listen(_onAuthChange);
    loadProfile();
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
        profile.value = null;
        aidProfile.value = null;
        loadProfile();
        break;
      case AuthChangeEvent.signedOut:
        _lastSeenUserId = null;
        profile.value = null;
        aidProfile.value = null;
        break;
      default:
        break;
    }
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      profile.value = await _profileService.getProfile();
      aidProfile.value = await _profileService.getAidWorkerProfile();
    } catch (e) {
      Get.log('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    isSaving.value = true;
    try {
      final updated = await _profileService.updateProfile(updates);
      if (updated != null) profile.value = updated;
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.log('Error updating profile: $e');
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateAidProfile({
    String? designation,
    String? department,
  }) async {
    isSaving.value = true;
    try {
      final updates = <String, dynamic>{};
      if (designation != null) updates['designation'] = designation;
      if (department != null) updates['department'] = department;
      if (updates.isEmpty) return;

      final updated = await _profileService.updateAidWorkerProfile(updates);
      if (updated != null) aidProfile.value = updated;
      Get.snackbar('Success', 'Worker profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update worker profile');
      Get.log('Error updating aid profile: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> uploadAvatar(Uint8List fileBytes) async {
    isUploadingAvatar.value = true;
    try {
      final updated = await _profileService.uploadAvatar(fileBytes);
      if (updated != null) profile.value = updated;
    } catch (e) {
      Get.log('Error uploading avatar: $e');
      Get.snackbar('Error', 'Failed to upload profile picture');
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  String get userEmail => profile.value?.email ?? '';

  String get displayName => (profile.value?.fullName.isNotEmpty ?? false)
      ? profile.value!.fullName
      : 'Aid Worker';

  String get displayPhone => profile.value?.phone ?? '';

  String get displayCnic => profile.value?.cnic ?? '';

  String get displayDesignation =>
      (aidProfile.value?.designation.isNotEmpty ?? false)
      ? aidProfile.value!.designation
      : 'Not assigned';

  String get displayDepartment =>
      aidProfile.value?.department ?? 'Not assigned';

  String? get organizationId => aidProfile.value?.organizationId;

  String? get avatarUrl => profile.value?.avatarUrl;

  Future<void> refreshProfile() => loadProfile();
}
