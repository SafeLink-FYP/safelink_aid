import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/profile/controllers/profile_controller.dart';

class ContactInformation extends StatelessWidget {
  const ContactInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final ctrl = Get.find<ProfileController>();

    return Obx(() {
      final profile = ctrl.profile.value;
      final aidProfile = ctrl.aidProfile.value;

      final phone = (profile?.phone?.isNotEmpty ?? false)
          ? profile!.phone!
          : 'Not provided';
      final email = (profile?.email.isNotEmpty ?? false)
          ? profile!.email
          : 'Not provided';
      final location = _buildLocation(profile?.region, profile?.city);
      final cnic = (profile?.cnic?.isNotEmpty ?? false)
          ? profile!.cnic!
          : 'Not provided';
      final department = (aidProfile?.department?.isNotEmpty ?? false)
          ? aidProfile!.department!
          : 'Not assigned';

      return Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
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
            _buildRow(
              theme: theme,
              label: 'Phone',
              value: phone,
              icon: AppAssets.phoneIcon,
              gradient: AppTheme.primaryGradient,
            ),
            _buildDivider(),
            _buildRow(
              theme: theme,
              label: 'Email',
              value: email,
              icon: AppAssets.emailIcon,
              gradient: AppTheme.purpleGradient,
            ),
            _buildDivider(),
            _buildRow(
              theme: theme,
              label: 'Location',
              value: location,
              icon: AppAssets.locationIcon,
              gradient: AppTheme.greenGradient,
            ),
            _buildDivider(),
            _buildRow(
              theme: theme,
              label: 'CNIC',
              value: cnic,
              icon: AppAssets.shieldIcon,
              gradient: AppTheme.orangeGradient,
            ),
            _buildDivider(),
            _buildRow(
              theme: theme,
              label: 'Department',
              value: department,
              icon: AppAssets.buildingIcon,
              gradient: AppTheme.primaryGradient,
            ),
          ],
        ),
      );
    });
  }

  String _buildLocation(String? region, String? city) {
    final parts = [city, region].where((s) => s != null && s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Not provided';
  }

  Widget _buildRow({
    required ThemeData theme,
    required String label,
    required String value,
    required String icon,
    required Gradient gradient,
  }) {
    return Padding(
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
              colorFilter: const ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
