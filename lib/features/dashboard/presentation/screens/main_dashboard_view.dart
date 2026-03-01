import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/features/dashboard/controllers/navigation_controller.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/requests_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/resources_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/screens/team_view.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/custom_bottom_nav_bar.dart';
import 'home_view.dart';
import 'profile_view.dart';

class MainDashboardView extends StatelessWidget {
  const MainDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.put(
      NavigationController(),
      permanent: true,
    );

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navController.selectedIndex.value,
          children: const [
            HomeView(),
            RequestsView(),
            ResourcesView(),
            TeamView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
