import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/theme_toggle.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

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
            color: AppTheme.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8.r,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTile(
            theme: theme,
            label: 'Edit Profile',
            icon: AppAssets.personIcon,
            gradient: AppTheme.primaryGradient,
            trailing: Icon(Icons.arrow_forward_ios, size: 15.sp, color: theme.hintColor),
            onTap: () => Get.toNamed(AppRoutes.editProfileView),
          ),
          _buildDivider(),
          _buildTile(
            theme: theme,
            label: 'Dark Mode',
            icon: AppAssets.settingsIcon,
            gradient: AppTheme.purpleGradient,
            trailing: const ThemeToggle(),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required ThemeData theme,
    required String label,
    required String icon,
    required Gradient gradient,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
              ),
              child: SvgPicture.asset(
                icon,
                width: 16.w,
                height: 16.h,
                colorFilter:
                    const ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
              ),
            ),
            SizedBox(width: 12.w),
            Text(label, style: theme.textTheme.headlineMedium),
            const Spacer(),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      color: Get.theme.dividerColor,
    );
  }
}
