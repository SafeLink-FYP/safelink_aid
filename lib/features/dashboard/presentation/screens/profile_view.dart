import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/contact_information.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/resource_summary_item.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/settings.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                    Container(
                      padding: EdgeInsets.all(30.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.white.withValues(alpha: 0.20),
                        border: Border.all(
                          color: AppTheme.white.withValues(alpha: 0.30),
                          width: 5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            offset: const Offset(0, 25),
                            blurRadius: 50.r,
                            spreadRadius: -12.r,
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        AppAssets.buildingIcon,
                        width: 50.w,
                        height: 50.h,
                        colorFilter: ColorFilter.mode(
                          AppTheme.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Raja Hamid',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Islamabad Division',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppTheme.white.withValues(alpha: 0.30),
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppAssets.shieldIcon,
                            width: 15.w,
                            height: 15.h,
                            colorFilter: ColorFilter.mode(
                              AppTheme.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'Verified Organization',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ResourceSummaryItem(
                          label: 'Cases Resolved',
                          count: 142,
                        ),
                        SizedBox(width: 10.w),
                        ResourceSummaryItem(label: 'Team Members', count: 24),
                        SizedBox(width: 10.w),
                        ResourceSummaryItem(label: 'Service Rating', count: 4),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Text(
                      'Organization Information',
                      style: theme.textTheme.headlineLarge,
                    ),
                    SizedBox(height: 25.h),
                    ContactInformation(),
                    SizedBox(height: 25.h),
                    Text('Settings', style: theme.textTheme.headlineLarge),
                    SizedBox(height: 25.h),
                    Settings(),
                    SizedBox(height: 25.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed('signInView'),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            AppTheme.transparentColor,
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            AppTheme.red,
                          ),
                          side: WidgetStateProperty.all(
                            BorderSide(color: AppTheme.red, width: 1.w),
                          ),
                          minimumSize: WidgetStateProperty.all(
                            Size(double.infinity.w, 50.r),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          elevation: WidgetStateProperty.all(0.r),
                        ),
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            color: AppTheme.red,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
