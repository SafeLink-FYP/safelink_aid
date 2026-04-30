import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/features/dashboard/controllers/navigation_controller.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/requests_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/resources_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/my_team_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:safelink_aid/features/profile/presentation/screens/profile_view.dart';
import 'dashboard_view.dart';

class MainDashboardView extends StatelessWidget {
  const MainDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find<NavigationController>();

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navController.selectedIndex.value,
          children: const [
            DashboardView(),
            RequestsView(),
            ResourcesView(),
            MyTeamView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
