import 'package:flutter_test/flutter_test.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:safelink_aid/features/authorization/utils/route_decision.dart';

void main() {
  group('decideAidRoute', () {
    test('no session → signInView', () {
      expect(
        decideAidRoute(
          hasSession: false,
          hasActiveMembership: false,
          activeTeamApproved: null,
          latestJoinRequestStatus: null,
          hasPendingCreatedTeam: false,
        ),
        AppRoutes.signInView,
      );
    });

    test('active membership + approved team → mainDashboardView', () {
      expect(
        decideAidRoute(
          hasSession: true,
          hasActiveMembership: true,
          activeTeamApproved: true,
          latestJoinRequestStatus: null,
          hasPendingCreatedTeam: false,
        ),
        AppRoutes.mainDashboardView,
      );
    });

    test('active membership + team not approved → waitingApprovalView', () {
      expect(
        decideAidRoute(
          hasSession: true,
          hasActiveMembership: true,
          activeTeamApproved: false,
          latestJoinRequestStatus: null,
          hasPendingCreatedTeam: false,
        ),
        AppRoutes.waitingApprovalView,
      );
    });

    test('active membership + null approval state → waitingApprovalView', () {
      expect(
        decideAidRoute(
          hasSession: true,
          hasActiveMembership: true,
          activeTeamApproved: null,
          latestJoinRequestStatus: null,
          hasPendingCreatedTeam: false,
        ),
        AppRoutes.waitingApprovalView,
      );
    });

    test('no membership + pending join request → waitingApprovalView', () {
      expect(
        decideAidRoute(
          hasSession: true,
          hasActiveMembership: false,
          activeTeamApproved: null,
          latestJoinRequestStatus: 'pending',
          hasPendingCreatedTeam: false,
        ),
        AppRoutes.waitingApprovalView,
      );
    });

    test('no membership + own pending team → waitingApprovalView', () {
      expect(
        decideAidRoute(
          hasSession: true,
          hasActiveMembership: false,
          activeTeamApproved: null,
          latestJoinRequestStatus: null,
          hasPendingCreatedTeam: true,
        ),
        AppRoutes.waitingApprovalView,
      );
    });

    test('no membership + rejected join request → teamSelectionView', () {
      expect(
        decideAidRoute(
          hasSession: true,
          hasActiveMembership: false,
          activeTeamApproved: null,
          latestJoinRequestStatus: 'rejected',
          hasPendingCreatedTeam: false,
        ),
        AppRoutes.teamSelectionView,
      );
    });

    test('no membership + nothing pending → teamSelectionView', () {
      expect(
        decideAidRoute(
          hasSession: true,
          hasActiveMembership: false,
          activeTeamApproved: null,
          latestJoinRequestStatus: null,
          hasPendingCreatedTeam: false,
        ),
        AppRoutes.teamSelectionView,
      );
    });

    test(
        'active membership wins over pending join request '
        '(joining a team while still in another)',
        () {
      // If a worker is somehow listed as an active member of one team
      // while also having a pending request for another, the active
      // membership should take precedence — they should land on the
      // dashboard, not the waiting screen.
      expect(
        decideAidRoute(
          hasSession: true,
          hasActiveMembership: true,
          activeTeamApproved: true,
          latestJoinRequestStatus: 'pending',
          hasPendingCreatedTeam: false,
        ),
        AppRoutes.mainDashboardView,
      );
    });
  });
}
