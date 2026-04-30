import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/features/dashboard/models/aid_request_model.dart';

class AidRequestService extends GetxService {
  final _supabase = SupabaseService.instance;

  /// Fetch all aid requests visible to this aid worker.
  ///
  /// Uses `get_aid_worker_assigned_requests` (SECURITY DEFINER) instead of a
  /// direct `aid_requests` select. The RPC returns the requester's profile
  /// fields too — the "profiles: aid reads own org members" policy blocks
  /// aid workers from reading citizen profiles, so a PostgREST embed silently
  /// returns null for the requester.
  Future<List<AidRequestModel>> getAssignedRequests() async {
    final data = await _supabase.rpc('get_aid_worker_assigned_requests');
    if (data == null) return const [];
    return (data as List)
        .map((e) => AidRequestModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Fetch a single request by id, scoped to the caller's org via RPC.
  Future<AidRequestModel?> getRequestById(String id) async {
    final data = await _supabase.rpc(
      'get_aid_worker_request_detail',
      params: {'p_request_id': id},
    );
    if (data == null) return null;
    return AidRequestModel.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Update status with appropriate side-effect fields
  Future<void> updateStatus(
      String id,
      String status, {
        String? rejectionReason,
      }) async {
    final updates = <String, dynamic>{'status': status};
    if (status == 'fulfilled') {
      updates['fulfilled_by'] = _supabase.userId;
      updates['fulfilled_at'] = DateTime.now().toIso8601String();
    }
    if (status == 'rejected' && rejectionReason != null) {
      updates['rejection_reason'] = rejectionReason;
    }
    await _supabase.aidRequests.update(updates).eq('id', id);
  }

  Future<void> markInProgress(String id) => updateStatus(id, 'in_progress');

  Future<void> fulfillRequest(String id) => updateStatus(id, 'fulfilled');

  Future<void> rejectRequest(String id, {String? reason}) =>
      updateStatus(id, 'rejected', rejectionReason: reason);

  /// Fetch timeline entries for a request
  Future<List<Map<String, dynamic>>> getRequestTimeline(String id) async {
    final data = await _supabase.aidRequestTimeline
        .select()
        .eq('request_id', id)
        .order('created_at', ascending: true);
    return (data as List).cast<Map<String, dynamic>>();
  }
}
