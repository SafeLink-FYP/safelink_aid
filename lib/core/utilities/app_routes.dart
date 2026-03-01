import 'package:get/get.dart';
import 'package:safelink_aid/features/authorization/presentation/screens/reset_password_view.dart';
import 'package:safelink_aid/features/authorization/presentation/screens/sign_in_view.dart';
import 'package:safelink_aid/features/authorization/presentation/screens/sign_up_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/home_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/main_dashboard_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/map_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/profile_view.dart';
import 'package:safelink_aid/features/onboarding/presentation/screens/splash_view.dart';

class AppRoutes {
  static const splashView = '/splashView';
  static const signInView = '/signInView';
  static const signUpView = '/signUpView';
  static const resetPasswordView = '/resetPasswordView';
  static const homeView = '/homeView';
  static const mapView = '/mapView';
  static const casesView = '/casesView';
  static const analyticsView = '/dashboardView';
  static const profileView = '/profileView';
  static const mainDashboardView = '/mainDashboardView';

  static final routes = [
    GetPage(name: splashView, page: () => const SplashView()),
    GetPage(name: signInView, page: () => const SignInView()),
    GetPage(name: signUpView, page: () => const SignUpView()),
    GetPage(name: resetPasswordView, page: () => const ResetPasswordView()),
    GetPage(name: homeView, page: () => const HomeView()),
    GetPage(name: mapView, page: () => const MapView()),
    GetPage(name: casesView, page: () => const HomeView()),
    GetPage(name: analyticsView, page: () => const ProfileView()),
    GetPage(name: profileView, page: () => const ProfileView()),
    GetPage(name: mainDashboardView, page: () => const MainDashboardView()),
  ];
}
