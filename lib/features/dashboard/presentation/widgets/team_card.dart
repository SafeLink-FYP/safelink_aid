import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';

class TeamCard extends StatelessWidget {
  final String name;
  final String leader;
  final String currentStatus;
  final int memberCount;
  final String location;
  final String contactNumber;
  final String profilePicture;

  const TeamCard({
    super.key,
    required this.name,
    required this.leader,
    required this.currentStatus,
    required this.memberCount,
    required this.location,
    required this.contactNumber,
    required this.profilePicture,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return Container(
      padding: EdgeInsets.all(20.r),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 15.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                ),
                child: SvgPicture.asset(
                  profilePicture,
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
                  Text('Team Alpha', style: theme.textTheme.headlineMedium),
                  SizedBox(height: 5.h),
                  Text('Led by $leader', style: theme.textTheme.bodyMedium),
                ],
              ),
              Spacer(),
              Container(
                decoration: BoxDecoration(),
                child: Text(currentStatus, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Row(
            children: [
              SvgPicture.asset(
                AppAssets.teamIcon,
                width: 20.w,
                height: 20.h,
                colorFilter: ColorFilter.mode(
                  theme.primaryIconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 5.w),
              Text('$memberCount members', style: theme.textTheme.bodyMedium),
            ],
          ),
          SizedBox(height: 5.h),
          Row(
            children: [
              SvgPicture.asset(
                AppAssets.locationIcon,
                width: 20.w,
                height: 20.h,
                colorFilter: ColorFilter.mode(
                  theme.primaryIconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 5.w),
              Text(location, style: theme.textTheme.bodyMedium),
            ],
          ),
          SizedBox(height: 5.h),
          Row(
            children: [
              SvgPicture.asset(
                AppAssets.phoneIcon,
                width: 20.w,
                height: 20.h,
                colorFilter: ColorFilter.mode(
                  theme.primaryIconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 10.w),
              Text(contactNumber, style: theme.textTheme.bodyMedium),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppTheme.transparentColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: theme.primaryColor),
                  ),
                  child: Text(
                    'View Details',
                    style: theme.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: Text(
                    'Contact',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
