import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:safelink_aid/features/dashboard/models/aid_request_model.dart';

class CaseCard extends StatelessWidget {
  final AidRequestModel request;

  const CaseCard({super.key, required this.request});

  Color get _urgencyColor {
    switch (request.urgency.toLowerCase()) {
      case 'critical':
        return AppTheme.red;
      case 'high':
        return AppTheme.orange;
      default:
        return AppTheme.primaryColor;
    }
  }

  Color get _urgencyBgColor {
    switch (request.urgency.toLowerCase()) {
      case 'critical':
        return AppTheme.lightRed;
      case 'high':
        return AppTheme.lightOrange;
      default:
        return AppTheme.primaryColor.withValues(alpha: 0.08);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return InkWell(
      onTap: () => Get.toNamed(
        AppRoutes.requestDetailView,
        arguments: request.id,
      ),
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: theme.dividerColor, width: 1.w),
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
                Expanded(
                  child: Text(
                    request.aidTypeDisplay,
                    style: theme.textTheme.headlineLarge,
                  ),
                ),
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: _urgencyBgColor,
                    border: Border.all(
                      color: _urgencyColor.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Text(
                    request.urgency.capitalizeFirst ?? request.urgency,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _urgencyColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              request.statusDisplay,
              style: theme.textTheme.displaySmall,
            ),
            SizedBox(height: 10.h),
            _infoRow(theme, 'Requester', request.userName ?? 'Unknown'),
            SizedBox(height: 5.h),
            _infoRow(theme, 'Location', request.address ?? 'Not specified'),
            SizedBox(height: 5.h),
            _infoRow(theme, 'People', '${request.peopleAffected}'),
            SizedBox(height: 5.h),
            _infoRow(theme, 'Time', request.timeAgo),
            SizedBox(height: 15.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                gradient: AppTheme.primaryGradient,
              ),
              child: Text(
                'View Details',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: AppTheme.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label:', style: theme.textTheme.bodyMedium),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.headlineMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
