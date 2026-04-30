import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';

class ResourceTile extends StatelessWidget {
  final String label;
  final int availableCount;
  final int totalCount;
  const ResourceTile({
    super.key,
    required this.label,
    required this.availableCount,
    required this.totalCount,
  });

  // Stock status — checked in priority order: out > low > ok.
  // "Low" mirrors ResourceModel.isLowStock (utilization > 0.8 with total > 0).
  ({String label, Color color}) _stockStatus() {
    if (availableCount <= 0) {
      return (label: 'Out of stock', color: AppTheme.red);
    }
    if (totalCount > 0) {
      final used = totalCount - availableCount;
      final utilization = (used / totalCount).clamp(0.0, 1.0);
      if (utilization > 0.8) {
        return (label: 'Low', color: AppTheme.orange);
      }
    }
    return (label: 'OK', color: AppTheme.green);
  }

  double _progressValue() {
    if (totalCount <= 0) return 0;
    return (availableCount / totalCount).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final status = _stockStatus();
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.dividerColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppTheme.transparentColor.withValues(alpha: 0.10),
            offset: const Offset(0, 1),
            blurRadius: 3.r,
            spreadRadius: 0.r,
          ),
          BoxShadow(
            color: AppTheme.transparentColor.withValues(alpha: 0.10),
            offset: const Offset(0, 1),
            blurRadius: 2.r,
            spreadRadius: -1.r,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  gradient: AppTheme.primaryGradient,
                ),
                child: SvgPicture.asset(
                  AppAssets.cubeIcon,
                  width: 25.w,
                  height: 25.h,
                  colorFilter: ColorFilter.mode(
                    AppTheme.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.headlineMedium),
                  SizedBox(height: 10.h),
                  Text(
                    '$availableCount / $totalCount',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              Spacer(),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: status.color.withValues(alpha: 0.30),
                  ),
                ),
                child: Text(
                  status.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Override the global progressIndicatorTheme.linearMinHeight (10.h)
          // — that height is appropriate for full-screen loaders but reads
          // heavy inside an inline tile.
          LinearProgressIndicator(
            value: _progressValue(),
            minHeight: 4.h,
          ),
        ],
      ),
    );
  }
}
