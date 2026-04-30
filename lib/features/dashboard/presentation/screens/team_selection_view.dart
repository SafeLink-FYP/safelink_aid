import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';

class TeamSelectionView extends StatelessWidget {
  const TeamSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(25.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              Container(
                padding: EdgeInsets.all(25.r),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.30),
                      offset: const Offset(0, 20),
                      blurRadius: 40.r,
                      spreadRadius: -10.r,
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  AppAssets.teamIcon,
                  width: 60.w,
                  height: 60.h,
                  colorFilter: const ColorFilter.mode(
                    AppTheme.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(height: 35.h),
              Text(
                'Join or Create a Team',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              Text(
                'You must be part of an approved response team to access the dashboard and respond to emergencies.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 45.h),

              // Create Team Option
              _buildSelectionCard(
                theme: theme,
                title: 'Create a New Team',
                description:
                'Start a new response Team. Requires Government approval.',
                gradient: AppTheme.primaryGradient,
                icon: Icons.add_moderator,
                onTap: () => Get.toNamed(AppRoutes.createTeamView),
              ),
              SizedBox(height: 20.h),

              // Join Team Option
              _buildSelectionCard(
                theme: theme,
                title: 'Join Existing Team',
                description: 'Browse approved teams or enter a Team Code.',
                gradient: AppTheme.greenGradient,
                icon: Icons.group_add,
                onTap: () => Get.toNamed(AppRoutes.joinTeamView),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required ThemeData theme,
    required String title,
    required String description,
    required Gradient gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: theme.dividerColor, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withValues(alpha: 0.04),
              offset: const Offset(0, 4),
              blurRadius: 10.r,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(15.r),
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.white, size: 24.sp),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.headlineLarge),
                  SizedBox(height: 5.h),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16.sp, color: theme.hintColor),
          ],
        ),
      ),
    );
  }
}
