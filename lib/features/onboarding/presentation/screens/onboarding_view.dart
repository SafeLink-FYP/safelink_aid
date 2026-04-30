import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/widgets/custom_elevated_button.dart';
import 'package:safelink_aid/features/onboarding/controllers/onboarding_navigation_controller.dart';
import 'package:safelink_aid/features/onboarding/presentation/widgets/carousal_indicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final OnboardingNavigationController navigationController = Get.put(
    OnboardingNavigationController(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.r,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -60.h,
            right: -40.w,
            child: Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80.h,
            left: -50.w,
            child: Container(
              width: 250.w,
              height: 250.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.purple.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 15.h,
                  ),
                  child: Obx(() {
                    return navigationController.currentPage.value < 2
                        ? Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              onPressed: () => navigationController.skip(),
                              child: Text(
                                'Skip',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(height: 50.h);
                  }),
                ),
                SizedBox(height: 15.h),
                Expanded(
                  child: PageView.builder(
                    itemCount: 3,
                    controller: navigationController.pageController,
                    onPageChanged: (value) =>
                        navigationController.currentPage.value = value,
                    itemBuilder: (context, index) {
                      Widget page;
                      switch (index) {
                        case 0:
                          page = _buildPageOne(theme);
                          break;
                        case 1:
                          page = _buildPageTwo(theme);
                          break;
                        case 2:
                          page = _buildPageThree(theme);
                          break;
                        default:
                          page = SizedBox.shrink();
                          break;
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.w,
                          vertical: 15.h,
                        ),
                        child: page,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(40.w, 0.h, 40.w, 50.h),
                  child: Column(
                    children: [
                      Obx(() {
                        return CarousalIndicator(
                          currentPage: navigationController.currentPage.value,
                          itemCount: 3,
                        );
                      }),
                      SizedBox(height: 50.h),
                      Obx(() {
                        return CustomElevatedButton(
                          label: navigationController.currentPage < 2
                              ? 'Next'
                              : 'Continue',
                          onPressed: () => navigationController.nextPage(),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageOne(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(35.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.white.withValues(alpha: 0.05),
                AppTheme.white.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(50.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: SvgPicture.asset(
              AppAssets.mindIcon,
              width: 90.w,
              height: 90.h,
              colorFilter: ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
            ),
          ),
        ),
        SizedBox(height: 50.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.r),
            border: Border.all(color: theme.primaryColor),
          ),
          child: Text(
            'Coordinate Relief, Together',
            style: theme.textTheme.headlineSmall,
          ),
        ),
        SizedBox(height: 25.h),
        Text(
          'Join Your Response Team',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 25.h),
        Text(
          'Create a new Government-approved Team or join one with a code. Once approved, you and your teammates respond to dispatched cases together.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPageTwo(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(35.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.white.withValues(alpha: 0.05),
                AppTheme.white.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(50.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: SvgPicture.asset(
              AppAssets.locationIcon,
              width: 90.w,
              height: 90.h,
              colorFilter: ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
            ),
          ),
        ),
        SizedBox(height: 50.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.r),
            border: Border.all(color: theme.primaryColor),
          ),
          child: Text(
            'See where you\'re dispatched',
            style: theme.textTheme.headlineSmall,
          ),
        ),
        SizedBox(height: 25.h),
        Text(
          'Receive Assigned Cases',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 25.h),
        Text(
          'Government dispatches aid requests to your Team in real time. Each case shows the requester\'s details and a map pinning the exact location.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPageThree(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(35.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.white.withValues(alpha: 0.05),
                AppTheme.white.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(50.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: SvgPicture.asset(
              AppAssets.chatIcon,
              width: 90.w,
              height: 90.h,
              colorFilter: ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
            ),
          ),
        ),
        SizedBox(height: 50.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.r),
            border: Border.all(color: theme.primaryColor),
          ),
          child: Text(
            'Respond and resolve, end to end',
            style: theme.textTheme.headlineSmall,
          ),
        ),
        SizedBox(height: 25.h),
        Text(
          'Manage Resources & Update Cases',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 25.h),
        Text(
          'Track your Team\'s inventory, mark cases in-progress, fulfill or reject requests with a reason, and keep citizens informed at every step.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
