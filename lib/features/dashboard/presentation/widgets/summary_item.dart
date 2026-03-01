import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';

class ProfileSummaryItem extends StatelessWidget {
  final String label;
  final int count;
  final String icon;
  final Color color;
  final Gradient iconBackgroundGradient;
  final void Function()? onTap;

  const ProfileSummaryItem({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.iconBackgroundGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: theme.dividerColor, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: AppTheme.transparentColor.withValues(alpha: 0.10),
                offset: Offset(0, 1),
                blurRadius: 3.r,
                spreadRadius: 0.r,
              ),
              BoxShadow(
                color: AppTheme.transparentColor.withValues(alpha: 0.10),
                offset: Offset(0, 1),
                blurRadius: 2.r,
                spreadRadius: -1.r,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  gradient: iconBackgroundGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      offset: Offset(0, 10),
                      blurRadius: 15.r,
                      spreadRadius: -3.r,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      offset: Offset(0, 4),
                      blurRadius: 6.r,
                      spreadRadius: -4.r,
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  icon,
                  width: 20.w,
                  height: 20.h,
                  colorFilter: ColorFilter.mode(
                    AppTheme.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                '$count',
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
              SizedBox(height: 5.h),
              Text(
                label,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
