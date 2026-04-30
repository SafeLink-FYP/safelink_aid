import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:safelink_aid/features/dashboard/controllers/alert_controller.dart';

class AlertsView extends StatelessWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final ctrl = Get.find<AlertController>();

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
              child: Row(
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
                  Icon(Icons.warning_amber_rounded,
                      color: AppTheme.white, size: 24.sp),
                  SizedBox(width: 10.w),
                  Text(
                    'Active Alerts',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
            ),

            // Alert list
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value && ctrl.alerts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ctrl.alerts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 50.sp,
                          color: AppTheme.green,
                        ),
                        SizedBox(height: 15.h),
                        Text('All Clear',
                            style: theme.textTheme.headlineMedium),
                        SizedBox(height: 5.h),
                        Text(
                          'No active alerts at this time.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: ctrl.refreshAlerts,
                  child: ListView.separated(
                    padding: EdgeInsets.all(20.r),
                    itemCount: ctrl.alerts.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (_, i) {
                      final alert = ctrl.alerts[i];
                      final severity =
                          (alert['severity'] as String?) ?? 'medium';
                      final title =
                          (alert['title'] as String?) ?? 'Alert';
                      final description =
                          (alert['description'] as String?) ?? '';
                      final alertType =
                          (alert['disaster_type'] as String?) ?? 'other';
                      final createdAt =
                      alert['created_at'] as String?;

                      return InkWell(
                        onTap: () {
                          final id = alert['id'] as String?;
                          if (id != null) {
                            Get.toNamed(
                              AppRoutes.alertDetailView,
                              arguments: id,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: _severityColor(severity)
                                .withValues(alpha: 0.30),
                            width: 1.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.black.withValues(alpha: 0.04),
                              offset: const Offset(0, 2),
                              blurRadius: 8.r,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: _severityColor(severity)
                                        .withValues(alpha: 0.10),
                                    borderRadius:
                                    BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    _alertIcon(alertType),
                                    color: _severityColor(severity),
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: theme
                                            .textTheme.headlineMedium,
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        alertType
                                            .replaceAll('_', ' ')
                                            .capitalizeFirst!,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: _severityColor(severity)
                                        .withValues(alpha: 0.10),
                                    borderRadius:
                                    BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: _severityColor(severity)
                                          .withValues(alpha: 0.30),
                                    ),
                                  ),
                                  child: Text(
                                    severity.capitalizeFirst!,
                                    style:
                                    theme.textTheme.bodySmall?.copyWith(
                                      color: _severityColor(severity),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (description.isNotEmpty) ...[
                              SizedBox(height: 12.h),
                              Text(
                                description,
                                style: theme.textTheme.bodyMedium,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (createdAt != null) ...[
                              SizedBox(height: 10.h),
                              Text(
                                _formatTime(createdAt),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
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

  // Must match the public.severity_level enum (low, medium, high, critical).
  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.red;
      case 'high':
        return AppTheme.orange;
      case 'medium':
        return AppTheme.primaryColor;
      case 'low':
      default:
        return AppTheme.green;
    }
  }

  // Must match the public.disaster_type enum (flood, earthquake, medical, other).
  IconData _alertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'flood':
        return Icons.water;
      case 'earthquake':
        return Icons.landscape;
      case 'medical':
        return Icons.medical_services_outlined;
      case 'other':
      default:
        return Icons.warning_amber_rounded;
    }
  }

  String _formatTime(String isoTime) {
    final dt = DateTime.tryParse(isoTime);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
