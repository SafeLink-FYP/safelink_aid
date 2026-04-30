import 'package:get/get.dart';
import 'package:safelink_aid/features/authorization/controllers/auth_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/aid_request_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/alert_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/dashboard_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/navigation_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/notification_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/resource_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/team_controller.dart';
import 'package:safelink_aid/features/dashboard/services/aid_request_service.dart';
import 'package:safelink_aid/features/dashboard/services/alert_service.dart';
import 'package:safelink_aid/features/dashboard/services/dashboard_service.dart';
import 'package:safelink_aid/features/dashboard/services/notification_service.dart';
import 'package:safelink_aid/features/dashboard/services/resource_service.dart';
import 'package:safelink_aid/features/dashboard/services/team_service.dart';
import 'package:safelink_aid/features/profile/controllers/profile_controller.dart';
import 'package:safelink_aid/features/profile/services/profile_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    /// SERVICES
    Get.put<ProfileService>(ProfileService(), permanent: true);
    Get.put<DashboardService>(DashboardService(), permanent: true);
    Get.put<AidRequestService>(AidRequestService(), permanent: true);
    Get.put<TeamService>(TeamService(), permanent: true);
    Get.put<ResourceService>(ResourceService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<AlertService>(AlertService(), permanent: true);

    /// CONTROLLERS
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);
    Get.put<DashboardController>(DashboardController(), permanent: true);
    Get.put<AidRequestController>(AidRequestController(), permanent: true);
    Get.put<TeamController>(TeamController(), permanent: true);
    Get.put<ResourceController>(ResourceController(), permanent: true);
    Get.put<NotificationController>(NotificationController(), permanent: true);
    Get.put<AlertController>(AlertController(), permanent: true);
  }
}
