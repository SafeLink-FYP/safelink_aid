import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/features/profile/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;

class ProfileService extends GetxService {
  final _supabase = SupabaseService.instance;

  Future<ProfileModel?> getProfile() async {
    final userId = _supabase.userId;
    if (userId == null) return null;
    final data = await _supabase.profiles
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  Future<AidWorkerProfileModel?> getAidWorkerProfile() async {
    final userId = _supabase.userId;
    if (userId == null) return null;
    final data = await _supabase.aidWorkerProfiles
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return AidWorkerProfileModel.fromJson(data);
  }

  Future<ProfileModel?> updateProfile(Map<String, dynamic> updates) async {
    final userId = _supabase.userId;
    if (userId == null) return null;
    final data = await _supabase.profiles
        .update(updates)
        .eq('id', userId)
        .select()
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  Future<AidWorkerProfileModel?> updateAidWorkerProfile(
    Map<String, dynamic> updates,
  ) async {
    final userId = _supabase.userId;
    if (userId == null) return null;
    final data = await _supabase.aidWorkerProfiles
        .update(updates)
        .eq('id', userId)
        .select()
        .maybeSingle();
    if (data == null) return null;
    return AidWorkerProfileModel.fromJson(data);
  }

  Future<ProfileModel?> uploadAvatar(Uint8List fileBytes) async {
    final userId = _supabase.userId;
    if (userId == null) return null;
    final path = '$userId/avatar.jpg';
    await _supabase.storage
        .from('avatars')
        .uploadBinary(
          path,
          fileBytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
    final publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);
    return updateProfile({'avatar_url': publicUrl});
  }

  /// Get the user's organization_id from aid_worker_profiles
  Future<String?> getOrganizationId() async {
    final aidProfile = await getAidWorkerProfile();
    return aidProfile?.organizationId;
  }
}
