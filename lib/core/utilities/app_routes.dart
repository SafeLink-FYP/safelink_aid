import 'package:get/get.dart';
import 'package:safelink_aid/core/utilities/auth_middleware.dart';
import 'package:safelink_aid/features/authorization/presentation/screens/reset_password_view.dart';
import 'package:safelink_aid/features/authorization/presentation/screens/set_new_password_view.dart';
import 'package:safelink_aid/features/authorization/presentation/screens/sign_in_view.dart';
import 'package:safelink_aid/features/authorization/presentation/screens/sign_up_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/alert_detail_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/alerts_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/create_resource_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/create_team_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/join_team_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/main_dashboard_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/notifications_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/requests_detail_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/team_selection_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/waiting_approval_view.dart';
import 'package:safelink_aid/features/onboarding/presentation/screens/onboarding_view.dart';
import 'package:safelink_aid/features/onboarding/presentation/screens/splash_view.dart';
import 'package:safelink_aid/features/profile/presentation/screens/edit_profile_view.dart';

class AppRoutes {
  static const splashView = '/splashView';
  static const onboardingView = '/onboardingView';
  static const signInView = '/signInView';
  static const signUpView = '/signUpView';
  static const resetPasswordView = '/resetPasswordView';
  static const mainDashboardView = '/mainDashboardView';
  static const requestDetailView = '/requestDetailView';
  static const createTeamView = '/createTeamView';
  static const createResourceView = '/createResourceView';
  static const notificationsView = '/notificationsView';
  static const alertsView = '/alertsView';
  static const teamSelectionView = '/teamSelectionView';
  static const joinTeamView = '/joinTeamView';
  static const waitingApprovalView = '/waitingApprovalView';
  static const editProfileView = '/editProfileView';
  static const alertDetailView = '/alertDetailView';
  static const setNewPasswordView = '/setNewPasswordView';

  static final routes = [
    // Open routes
    GetPage(name: splashView, page: () => const SplashView()),
    GetPage(name: onboardingView, page: () => const OnboardingView()),
    GetPage(name: signInView, page: () => const SignInView()),
    GetPage(name: signUpView, page: () => const SignUpView()),
    GetPage(name: resetPasswordView, page: () => const ResetPasswordView()),

    // Authed routes — session must be present.
    GetPage(
      name: mainDashboardView,
      page: () => const MainDashboardView(),
      middlewares: [OnboardingGateMiddleware()],
    ),
    GetPage(
      name: requestDetailView,
      page: () => const RequestDetailView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: createTeamView,
      page: () => const CreateTeamView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: createResourceView,
      page: () => const CreateResourceView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: joinTeamView,
      page: () => const JoinTeamView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: waitingApprovalView,
      page: () => const WaitingApprovalView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: editProfileView,
      page: () => const EditProfileView(),
      middlewares: [AuthRequiredMiddleware()],
    ),
    GetPage(
      name: setNewPasswordView,
      page: () => const SetNewPasswordView(),
    ),

    // Reachable only from inside the authed shell — no extra middleware.
    GetPage(name: notificationsView, page: () => const NotificationsView()),
    GetPage(name: alertsView, page: () => const AlertsView()),
    GetPage(name: alertDetailView, page: () => const AlertDetailView()),
    GetPage(name: teamSelectionView, page: () => const TeamSelectionView()),
  ];
}
