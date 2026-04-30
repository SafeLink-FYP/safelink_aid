import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:safelink_aid/features/dashboard/controllers/aid_request_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/dashboard_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/navigation_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/notification_controller.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/assigned_cases.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/summary_item.dart';
import 'package:safelink_aid/features/profile/controllers/profile_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  void _openRequestsWithFilter(String filter) {
    final navCtrl = Get.find<NavigationController>();
    final reqCtrl = Get.find<AidRequestController>();
    reqCtrl.statusFilter.value = filter;
    navCtrl.changePage(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final dashCtrl = Get.find<DashboardController>();
    final profileCtrl = Get.find<ProfileController>();
    final notifCtrl = Get.find<NotificationController>();
    final navCtrl = Get.find<NavigationController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (dashCtrl.isLoading.value && dashCtrl.stats.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: dashCtrl.refreshDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(25.r),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.r),
                        bottomRight: Radius.circular(30.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                    'Hello, ${profileCtrl.displayName}',
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(color: AppTheme.white),
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  SizedBox(height: 5.h),
                                  Text(
                                    'Team Dashboard',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      color:
                                      AppTheme.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                // Notifications
                                Tooltip(
                                  message: 'Notifications',
                                  child: InkWell(
                                  onTap: () =>
                                      Get.toNamed(AppRoutes.notificationsView),
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.r),
                                        decoration: BoxDecoration(
                                          color: AppTheme.white
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                          BorderRadius.circular(12.r),
                                        ),
                                        child: Icon(
                                          Icons.notifications_outlined,
                                          color: AppTheme.white,
                                          size: 22.sp,
                                        ),
                                      ),
                                      Obx(() {
                                        if (notifCtrl.unreadCount.value == 0) {
                                          return const SizedBox.shrink();
                                        }
                                        return Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(5.r),
                                            decoration: const BoxDecoration(
                                              color: AppTheme.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${notifCtrl.unreadCount.value}',
                                              style: TextStyle(
                                                color: AppTheme.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                // Alerts
                                Tooltip(
                                  message: 'Active alerts',
                                  child: InkWell(
                                    onTap: () =>
                                        Get.toNamed(AppRoutes.alertsView),
                                    child: Container(
                                      padding: EdgeInsets.all(10.r),
                                      decoration: BoxDecoration(
                                        color: AppTheme.white
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                        BorderRadius.circular(12.r),
                                      ),
                                      child: Icon(
                                        Icons.warning_amber_rounded,
                                        color: AppTheme.white,
                                        size: 22.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Padding(
                    padding: EdgeInsets.all(25.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // KPI Cards
                        Obx(() => Row(
                          children: [
                            ProfileSummaryItem(
                              label: 'Active Requests',
                              count: dashCtrl.activeRequestCount,
                              icon: AppAssets.clockIcon,
                              color: theme.primaryColor,
                              iconBackgroundGradient:
                              AppTheme.primaryGradient,
                              onTap: () =>
                                  _openRequestsWithFilter('in_progress'),
                            ),
                            SizedBox(width: 15.w),
                            ProfileSummaryItem(
                              label: 'Fulfilled',
                              count: dashCtrl.fulfilledCount,
                              icon: AppAssets.checkIcon,
                              color: AppTheme.green,
                              iconBackgroundGradient:
                              AppTheme.greenGradient,
                              onTap: () =>
                                  _openRequestsWithFilter('fulfilled'),
                            ),
                          ],
                        )),
                        SizedBox(height: 15.h),
                        Obx(() => Row(
                          children: [
                            ProfileSummaryItem(
                              label: 'Teams',
                              count: dashCtrl.teamCount,
                              icon: AppAssets.teamIcon,
                              color: AppTheme.purple,
                              iconBackgroundGradient:
                              AppTheme.purpleGradient,
                              onTap: () => navCtrl.changePage(3),
                            ),
                            SizedBox(width: 15.w),
                            ProfileSummaryItem(
                              label: 'Resources',
                              count: dashCtrl.resourceCount,
                              icon: AppAssets.cubeIcon,
                              color: AppTheme.orange,
                              iconBackgroundGradient:
                              AppTheme.orangeGradient,
                              onTap: () => navCtrl.changePage(2),
                            ),
                          ],
                        )),

                        SizedBox(height: 25.h),

                        // Recent Requests
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Assigned Cases',
                                style: theme.textTheme.headlineLarge),
                            InkWell(
                              onTap: () {
                                Get.find<NavigationController>()
                                    .changePage(1);
                              },
                              child: Text(
                                'View All',
                                style: theme.textTheme.displayMedium,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        Obx(() {
                          if (dashCtrl.recentRequests.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(30.r),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                    color: theme.dividerColor, width: 1.w),
                              ),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.checkIcon,
                                    width: 40.w,
                                    height: 40.h,
                                    colorFilter: ColorFilter.mode(
                                      AppTheme.green,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    'No assigned cases',
                                    style: theme.textTheme.headlineMedium,
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    'New cases will appear here when Government assigns one to your Team.',
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: dashCtrl.recentRequests.map((req) {
                              final iconData = _getIconForType(req.aidType);
                              void open() => Get.toNamed(
                                    AppRoutes.requestDetailView,
                                    arguments: req.id,
                                  );
                              return Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: InkWell(
                                  onTap: open,
                                  child: AssignedCases(
                                    label: req.aidTypeDisplay,
                                    location: req.address ?? 'Unknown',
                                    time: req.timeAgo,
                                    alertLevel: req.urgency.capitalizeFirst ??
                                        req.urgency,
                                    icon: iconData['icon'] as String,
                                    iconColor: iconData['color'] as Color,
                                    iconBackgroundColor:
                                    iconData['bg'] as Color,
                                    onManage: open,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Map<String, dynamic> _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'medical':
        return {
          'icon': AppAssets.shieldIcon,
          'color': AppTheme.red,
          'bg': AppTheme.lightRed,
        };
      case 'food':
      case 'water':
        return {
          'icon': AppAssets.dropletIcon,
          'color': AppTheme.orange,
          'bg': AppTheme.lightOrange,
        };
      case 'rescue':
        return {
          'icon': AppAssets.waveIcon,
          'color': AppTheme.red,
          'bg': AppTheme.lightRed,
        };
      default:
        return {
          'icon': AppAssets.cubeIcon,
          'color': AppTheme.primaryColor,
          'bg': AppTheme.primaryColor.withValues(alpha: 0.08),
        };
    }
  }
}
