import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';

class AssignedCases extends StatelessWidget {
  final String label;
  final String location;
  final String time;
  final String alertLevel;
  final String icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback? onManage;

  const AssignedCases({
    super.key,
    required this.label,
    required this.location,
    required this.time,
    required this.alertLevel,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(15.r),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: SvgPicture.asset(
              icon,
              width: 20.w,
              height: 20.h,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: theme.textTheme.headlineMedium),
                  SizedBox(width: 15.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 5.h,
                      horizontal: 10.w,
                    ),
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.10),
                        width: 1.w,
                      ),
                    ),
                    child: Text(
                      alertLevel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              Text(
                location.isEmpty ? time : '$location  ·  $time',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          Spacer(),
          InkWell(
            onTap: onManage,
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Text('Manage', style: theme.textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}
