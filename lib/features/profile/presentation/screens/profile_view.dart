import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/authorization/controllers/auth_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/dashboard_controller.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/contact_information.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/resource_summary_item.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/settings.dart';
import 'package:safelink_aid/features/profile/controllers/profile_controller.dart';
import 'package:safelink_aid/features/profile/presentation/widgets/availability_toggle.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final profileCtrl = Get.find<ProfileController>();
    final dashCtrl = Get.find<DashboardController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (profileCtrl.isLoading.value &&
              profileCtrl.profile.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: profileCtrl.refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header
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
                        // Avatar
                        Obx(() {
                          final url = profileCtrl.avatarUrl;
                          return Container(
                            padding: EdgeInsets.all(url != null ? 0 : 30.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                              AppTheme.white.withValues(alpha: 0.20),
                              border: Border.all(
                                color:
                                AppTheme.white.withValues(alpha: 0.30),
                                width: 4.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.30),
                                  offset: const Offset(0, 20),
                                  blurRadius: 40.r,
                                  spreadRadius: -10.r,
                                ),
                              ],
                            ),
                            child: url != null
                                ? ClipOval(
                              child: Image.network(
                                url,
                                width: 80.w,
                                height: 80.h,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _defaultAvatar(),
                              ),
                            )
                                : _defaultAvatar(),
                          );
                        }),
                        SizedBox(height: 10.h),
                        Obx(() => Text(
                          profileCtrl.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.white,
                          ),
                        )),
                        SizedBox(height: 5.h),
                        Obx(() => Text(
                          profileCtrl.displayDesignation,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppTheme.white,
                          ),
                        )),
                        SizedBox(height: 15.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          alignment: WrapAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                AppTheme.white.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color:
                                  AppTheme.white.withValues(alpha: 0.30),
                                  width: 1.w,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.shieldIcon,
                                    width: 15.w,
                                    height: 15.h,
                                    colorFilter: const ColorFilter.mode(
                                      AppTheme.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    'Aid Worker',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(color: AppTheme.white),
                                  ),
                                ],
                              ),
                            ),
                            // Team Leader badge — only when the
                            // aid_worker_profiles row marks them as lead.
                            Obx(() {
                              final isLead = profileCtrl
                                      .aidProfile.value?.isTeamLead ==
                                  true;
                              if (!isLead) return const SizedBox.shrink();
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded,
                                        size: 14.sp,
                                        color: AppTheme.primaryColor),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Team Leader',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Padding(
                    padding: EdgeInsets.all(25.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats
                        Obx(() => Row(
                          children: [
                            ResourceSummaryItem(
                              label: 'Cases Resolved',
                              count: dashCtrl.fulfilledCount,
                            ),
                            SizedBox(width: 10.w),
                            ResourceSummaryItem(
                              label: 'Teams',
                              count: dashCtrl.teamCount,
                            ),
                            SizedBox(width: 10.w),
                            ResourceSummaryItem(
                              label: 'Resources',
                              count: dashCtrl.resourceCount,
                            ),
                          ],
                        )),
                        SizedBox(height: 25.h),
                        const AvailabilityToggle(),
                        SizedBox(height: 25.h),
                        Text(
                          'Worker Information',
                          style: theme.textTheme.headlineLarge,
                        ),
                        SizedBox(height: 25.h),
                        const ContactInformation(),
                        SizedBox(height: 25.h),
                        Text('Settings',
                            style: theme.textTheme.headlineLarge),
                        SizedBox(height: 25.h),
                        const Settings(),
                        SizedBox(height: 25.h),
                        // Sign out
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _confirmLogout(),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                AppTheme.transparentColor,
                              ),
                              foregroundColor:
                              WidgetStateProperty.all(AppTheme.red),
                              side: WidgetStateProperty.all(
                                BorderSide(
                                    color: AppTheme.red, width: 1.w),
                              ),
                              minimumSize: WidgetStateProperty.all(
                                Size(double.infinity, 50.r),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10.r),
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
          );
        }),
      ),
    );
  }

  Widget _defaultAvatar() {
    return SvgPicture.asset(
      AppAssets.personIcon,
      width: 50.w,
      height: 50.h,
      colorFilter: const ColorFilter.mode(
        AppTheme.white,
        BlendMode.srcIn,
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You\'ll need to log in again to receive new assignments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Sign Out',
              style: TextStyle(
                color: AppTheme.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await Get.find<AuthController>().signOut();
    }
  }
}
