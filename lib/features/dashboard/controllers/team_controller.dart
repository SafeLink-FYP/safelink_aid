import 'dart:async';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/core/utilities/dialog_helpers.dart';
import 'package:safelink_aid/features/dashboard/models/team_member_model.dart';
import 'package:safelink_aid/features/dashboard/models/team_model.dart';
import 'package:safelink_aid/features/dashboard/services/team_service.dart';
import 'package:safelink_aid/features/authorization/controllers/auth_controller.dart'
    as safelink_aid_auth;
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent, AuthState;

class TeamController extends GetxController {
  final TeamService _service = Get.find<TeamService>();

  final isLoading = false.obs;

  /// The user's own approved team (shown in MyTeamView)
  final myTeam = Rxn<TeamModel>();
  final members = <TeamMemberModel>[].obs;
  final joinRequests = <Map<String, dynamic>>[].obs;

  String? _lastSeenUserId;
  StreamSubscription<AuthState>? _authSub;

  bool get isCurrentUserLeader {
    final userId = SupabaseService.instance.client.auth.currentUser?.id;
    if (userId == null) return false;
    return members.any((m) => m.userId == userId && m.role == 'leader');
  }

  @override
  void onInit() {
    super.onInit();
    _lastSeenUserId = SupabaseService.instance.currentUser?.id;
    _authSub = SupabaseService.instance.auth.onAuthStateChange
        .listen(_onAuthChange);
    loadMyTeam();
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
        loadMyTeam();
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
    myTeam.value = null;
    members.clear();
    joinRequests.clear();
  }

  Future<void> loadMyTeam() async {
    isLoading.value = true;
    try {
      final supa = SupabaseService.instance;
      final userId = supa.currentUser?.id;
      if (userId == null) return;

      // Get the user's active team membership
      final memberRow = await supa.teamMembers
          .select('team_id')
          .eq('user_id', userId)
          .eq('is_active', true)
          .maybeSingle();

      if (memberRow == null) {
        myTeam.value = null;
        return;
      }

      final teamId = memberRow['team_id'] as String;
      myTeam.value = await _service.getTeamById(teamId);

      if (myTeam.value != null) {
        await loadMembers(teamId);
        await loadJoinRequests(teamId);
      }
    } catch (e) {
      Get.log('Error loading my team: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMembers(String teamId) async {
    try {
      members.value = await _service.getTeamMembers(teamId);
    } catch (e) {
      Get.log('Error loading team members: $e');
    }
  }

  Future<void> loadJoinRequests(String teamId) async {
    try {
      // NOTE: cross-org applicants will show null for profile fields because
      // the aid_worker reads-own-org RLS policy scopes by the caller's
      // organization_id. Same-org case (the standard one) works fully.
      // Follow-up: introduce a SECURITY DEFINER RPC or filter Browse Teams
      // by org to eliminate cross-org applications at the source.
      //
      // PostgREST embed: team_join_requests.user_id → profiles.id, then
      // aid_worker_profiles.id → profiles.id. There is no direct FK between
      // team_join_requests and aid_worker_profiles, so we nest the
      // aid_worker_profiles embed inside profiles.
      final res = await SupabaseService.instance.client
          .from('team_join_requests')
          .select('''
            id, status, created_at, user_id,
            profiles (
              full_name, email, avatar_url,
              aid_worker_profiles (designation, department)
            )
          ''')
          .eq('team_id', teamId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      joinRequests.value = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      Get.log('Error loading join requests: $e');
    }
  }

  Future<void> approveJoinRequest(
      String requestId, String userId, String teamId) async {
    try {
      DialogHelpers.showLoadingDialog();
      // approve_team_join_request is SECURITY DEFINER and:
      //   - verifies caller is the active leader of the team
      //   - flips the request to 'approved'
      //   - upserts team_members with role 'member'
      //   - notifies the joiner (RLS-safe across users)
      await SupabaseService.instance.rpc(
        'approve_team_join_request',
        params: {'p_request_id': requestId},
      );
      joinRequests.removeWhere((r) => r['id'] == requestId);
      await loadMembers(teamId);
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
          title: 'Approved', message: 'User added to team.');
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t approve request',
        error: e,
      );
    }
  }

  Future<void> rejectJoinRequest(String requestId, String userId) async {
    try {
      DialogHelpers.showLoadingDialog();
      // reject_team_join_request marks the row as 'rejected' (no DELETE policy
      // exists, and the audit trail is preserved) and notifies the joiner.
      await SupabaseService.instance.rpc(
        'reject_team_join_request',
        params: {'p_request_id': requestId},
      );
      joinRequests.removeWhere((r) => r['id'] == requestId);
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
          title: 'Rejected', message: 'Request has been rejected.');
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t reject request',
        error: e,
      );
    }
  }

  Future<void> removeMember(String memberId) async {
    try {
      await _service.removeMember(memberId);
      members.removeWhere((m) => m.id == memberId);
    } catch (e) {
      DialogHelpers.showFailure(
        title: 'Couldn\'t remove member',
        error: e,
      );
    }
  }

  /// Called only from TeamSelectionView (onboarding gate), not from dashboard.
  /// Creates the user's aid_worker_profiles row (UPSERT) with the chosen
  /// organization + designation + department, then creates the team. Both
  /// share the same organization_id.
  Future<void> createTeam({
    required String name,
    required String organizationId,
    required String designation,
    String? department,
    String? description,
    List<String> specialization = const [],
    String? region,
    int capacity = 10,
    double? latitude,
    double? longitude,
  }) async {
    try {
      DialogHelpers.showLoadingDialog();
      final supa = SupabaseService.instance;
      final userId = supa.currentUser?.id;
      if (userId == null) throw Exception('No active session.');

      // UPSERT aid_worker_profiles. RLS allows the user to manage their own
      // row. Required because aid_worker_profiles.organization_id is NOT NULL,
      // so the row can't exist until the user picks an org — and we must
      // create it before the teams INSERT (RLS for teams checks org match).
      await supa.aidWorkerProfiles.upsert({
        'id': userId,
        'organization_id': organizationId,
        'designation': designation,
        'department': department,
      });

      await _service.createTeam(
        name: name,
        organizationId: organizationId,
        description: description,
        specialization: specialization,
        region: region,
        capacity: capacity,
        latitude: latitude,
        longitude: longitude,
      );
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Team Creation Requested',
        message:
            'Your team creation request has been sent to Government for approval.',
      );

      try {
        Get.find<safelink_aid_auth.AuthController>().evaluateRouting();
      } catch (e) {
        Get.back();
      }
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t create team',
        error: e,
      );
    }
  }

  /// Self-leave: a non-leader removes their own active membership and is
  /// routed back to team selection. RLS allows aid workers to UPDATE
  /// team_members rows where the team is in their own org.
  Future<void> leaveTeam() async {
    final supa = SupabaseService.instance;
    final userId = supa.currentUser?.id;
    final teamId = myTeam.value?.id;
    if (userId == null || teamId == null) return;

    try {
      DialogHelpers.showLoadingDialog();
      await supa.teamMembers
          .update({'is_active': false})
          .eq('team_id', teamId)
          .eq('user_id', userId);
      _clearLocal();
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Left team',
        message: 'You have left the team.',
      );
      // Re-evaluate routing — with no active membership, the user lands
      // on team selection.
      await Get.find<safelink_aid_auth.AuthController>().evaluateRouting();
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t leave team',
        error: e,
      );
    }
  }

  Future<void> refreshMyTeam() => loadMyTeam();
}
