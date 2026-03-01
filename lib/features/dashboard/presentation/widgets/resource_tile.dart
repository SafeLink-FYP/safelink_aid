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
              Container(decoration: BoxDecoration(), child: Text('Good Stock')),
            ],
          ),
          SizedBox(height: 20.h),
          LinearProgressIndicator(value: (availableCount / totalCount)),
        ],
      ),
    );
  }
}
