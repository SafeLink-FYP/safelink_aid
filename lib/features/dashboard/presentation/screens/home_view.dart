import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/assigned_cases.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/summary_item.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Relief Team Dashboard',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Stay Safe, Stay Connected',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                          ],
                        ),
                      ],
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ProfileSummaryItem(
                          label: 'Active Requests',
                          count: 18,
                          icon: AppAssets.clockIcon,
                          color: theme.primaryColor,
                          iconBackgroundGradient: AppTheme.primaryGradient,
                          onTap: () {},
                        ),
                        SizedBox(width: 15.w),
                        ProfileSummaryItem(
                          label: 'Completed Requests',
                          count: 142,
                          icon: AppAssets.checkIcon,
                          color: AppTheme.green,
                          iconBackgroundGradient: AppTheme.greenGradient,
                          onTap: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ProfileSummaryItem(
                          label: 'Team Members',
                          count: 24,
                          icon: AppAssets.teamIcon,
                          color: AppTheme.purple,
                          iconBackgroundGradient: AppTheme.purpleGradient,
                          onTap: () {},
                        ),
                        SizedBox(width: 15.w),
                        ProfileSummaryItem(
                          label: 'Resources',
                          count: 89,
                          icon: AppAssets.cubeIcon,
                          color: AppTheme.orange,
                          iconBackgroundGradient: AppTheme.orangeGradient,
                          onTap: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Assigned Cases',
                          style: theme.textTheme.headlineLarge,
                        ),
                        RichText(
                          text: TextSpan(
                            style: theme.textTheme.displayMedium,
                            children: [
                              TextSpan(
                                text: 'View All',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Get.toNamed(''),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Column(
                      children: [
                        AssignedCases(
                          label: 'Flood Warning',
                          location: 'Islamabad',
                          time: '5 hours ago',
                          alertLevel: 'Medium',
                          icon: AppAssets.dropletIcon,
                          iconColor: AppTheme.orange,
                          iconBackgroundColor: AppTheme.lightOrange,
                        ),
                        SizedBox(height: 10.h),
                        AssignedCases(
                          label: 'Aftershock Warning',
                          location: 'Rawalpindi',
                          time: '1 hour ago',
                          alertLevel: 'High',
                          icon: AppAssets.waveIcon,
                          iconColor: AppTheme.red,
                          iconBackgroundColor: AppTheme.lightRed,
                        ),
                        SizedBox(height: 10.h),
                        AssignedCases(
                          label: 'Heavy Rain',
                          location: 'Murree',
                          time: '8 hours ago',
                          alertLevel: 'High',
                          icon: AppAssets.dropletIcon,
                          iconColor: AppTheme.red,
                          iconBackgroundColor: AppTheme.lightRed,
                        ),
                      ],
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
