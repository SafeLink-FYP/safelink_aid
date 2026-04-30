import 'package:safelink_aid/core/utilities/app_routes.dart';

/// Pure routing decision for an aid worker based on the current
/// session + team-status snapshot. Extracted from
/// [AuthController.evaluateRouting] so it can be unit-tested without
/// instantiating Supabase or GetX.
///
/// Inputs are expressed as already-fetched booleans / status strings —
/// the caller is responsible for hitting the database; this function is
/// just the decision tree.
///
/// Routing semantics:
///   * No session                              → signInView
///   * Active membership + team approved       → mainDashboardView
///   * Active membership + team NOT approved   → waitingApprovalView
///   * No membership + pending join request    → waitingApprovalView
///   * No membership + own pending team        → waitingApprovalView
///   * No membership + nothing pending         → teamSelectionView
String decideAidRoute({
  required bool hasSession,
  required bool hasActiveMembership,
  required bool? activeTeamApproved,
  required String? latestJoinRequestStatus,
  required bool hasPendingCreatedTeam,
}) {
  if (!hasSession) return AppRoutes.signInView;
  if (hasActiveMembership) {
    if (activeTeamApproved == true) return AppRoutes.mainDashboardView;
    return AppRoutes.waitingApprovalView;
  }
  if (latestJoinRequestStatus == 'pending') {
    return AppRoutes.waitingApprovalView;
  }
  if (hasPendingCreatedTeam) return AppRoutes.waitingApprovalView;
  return AppRoutes.teamSelectionView;
}
