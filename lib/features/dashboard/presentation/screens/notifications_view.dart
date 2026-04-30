import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:safelink_aid/features/dashboard/controllers/navigation_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/notification_controller.dart';
import 'package:safelink_aid/features/dashboard/models/notification_model.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  void _handleTap(NotificationController ctrl, NotificationModel notif) {
    if (!notif.isRead) ctrl.markAsRead(notif.id);
    final ref = notif.referenceId;
    switch (notif.referenceType) {
      case 'aid_request':
        if (ref != null) {
          Get.toNamed(AppRoutes.requestDetailView, arguments: ref);
        }
        return;
      case 'team':
        // Close the notifications screen FIRST so we don't briefly flash
        // the dashboard underneath after the page change.
        Get.back();
        Get.find<NavigationController>().changePage(3);
        return;
      case 'alert':
        Get.toNamed(AppRoutes.alertsView);
        return;
      case 'sos_request':
        // TODO: route when SOS detail screen lands.
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final ctrl = Get.find<NotificationController>();

    return Scaffold(
      body: SafeArea(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.arrow_back_ios_new,
                              color: AppTheme.white,
                              size: 18.sp,
                              semanticLabel: 'Back'),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Text(
                        'Notifications',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                      const Spacer(),
                      Obx(() {
                        if (ctrl.unreadCount.value == 0) {
                          return const SizedBox.shrink();
                        }
                        return InkWell(
                          onTap: () => ctrl.markAllAsRead(),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppTheme.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Mark all read',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            // Notification list
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value && ctrl.notifications.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ctrl.notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 50.sp,
                          color: theme.hintColor,
                        ),
                        SizedBox(height: 15.h),
                        Text('No notifications yet',
                            style: theme.textTheme.headlineMedium),
                        SizedBox(height: 5.h),
                        Text(
                          'You\'ll be notified about new assignments and updates here.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: ctrl.refreshNotifications,
                  child: ListView.separated(
                    padding: EdgeInsets.all(20.r),
                    itemCount: ctrl.notifications.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (_, i) {
                      final notif = ctrl.notifications[i];
                      return InkWell(
                        onTap: () => _handleTap(ctrl, notif),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.all(15.r),
                          decoration: BoxDecoration(
                            color: notif.isRead
                                ? theme.cardColor
                                : theme.primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: notif.isRead
                                  ? theme.dividerColor
                                  : theme.primaryColor
                                  .withValues(alpha: 0.20),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: _typeColor(notif.notificationType)
                                      .withValues(alpha: 0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _typeIcon(notif.notificationType),
                                  color: _typeColor(notif.notificationType),
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif.title,
                                      style: notif.isRead
                                          ? theme.textTheme.headlineMedium
                                          : theme.textTheme.headlineMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      notif.body,
                                      style: theme.textTheme.bodyMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      notif.timeAgo,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              if (!notif.isRead)
                                Container(
                                  width: 8.w,
                                  height: 8.h,
                                  margin: EdgeInsets.only(top: 6.h),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Must match the public.notification_type enum
  // (alert, sos, aid_request, team_assignment, system).
  IconData _typeIcon(String type) {
    switch (type) {
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'sos':
        return Icons.emergency_outlined;
      case 'aid_request':
        return Icons.assignment_outlined;
      case 'team_assignment':
        return Icons.group_outlined;
      case 'system':
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'alert':
        return AppTheme.orange;
      case 'sos':
        return AppTheme.red;
      case 'aid_request':
        return AppTheme.primaryColor;
      case 'team_assignment':
        return AppTheme.purple;
      case 'system':
      default:
        return AppTheme.green;
    }
  }
}
