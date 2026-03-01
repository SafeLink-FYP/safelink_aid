import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/resource_summary_item.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/team_card.dart';

class TeamView extends StatefulWidget {
  const TeamView({super.key});

  @override
  State<TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends State<TeamView> {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.analyticsIcon,
                          width: 35.w,
                          height: 35.h,
                          colorFilter: ColorFilter.mode(
                            AppTheme.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Team Management',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Field teams and coordination',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.white.withAlpha(225),
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
                        ResourceSummaryItem(label: 'Total\nTeams', count: 4),
                        SizedBox(width: 10.w),
                        ResourceSummaryItem(
                          label: 'On Field Members',
                          count: 2,
                        ),
                        SizedBox(width: 10.w),
                        ResourceSummaryItem(label: 'Total Members', count: 20),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TeamCard(
                          name: 'Team Alpha',
                          leader: 'Dr. Ahmed Khan',
                          currentStatus: 'On Field',
                          memberCount: 6,
                          location: 'F-7, Islamabad',
                          contactNumber: '+92 300 1234567',
                          profilePicture: AppAssets.teamIcon,
                        ),
                        SizedBox(height: 10.h),
                        TeamCard(
                          name: 'Team Bravo',
                          leader: 'Sarah Ali',
                          currentStatus: 'On Field',
                          memberCount: 5,
                          location: 'G-9, Islamabad',
                          contactNumber: '+92 300 7654321',
                          profilePicture: AppAssets.teamIcon,
                        ),
                        SizedBox(height: 10.h),
                        TeamCard(
                          name: 'Team Charlie',
                          leader: 'Hassan Raza',
                          currentStatus: 'Available',
                          memberCount: 4,
                          location: 'Base Camp',
                          contactNumber: '+92 300 1111222',
                          profilePicture: AppAssets.teamIcon,
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
