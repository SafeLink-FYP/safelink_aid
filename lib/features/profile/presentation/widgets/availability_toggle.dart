import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/profile/controllers/profile_controller.dart';

/// Three-segment toggle that writes the aid worker's availability status
/// to aid_worker_profiles.availability_status. The status is advisory —
/// gov dispatch uses it to sort teams but never blocks assignment, even
/// to teams whose members are partially off-duty (per PR-13 design).
class AvailabilityToggle extends StatelessWidget {
  const AvailabilityToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final ctrl = Get.find<ProfileController>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: theme.dividerColor, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Availability', style: theme.textTheme.headlineMedium),
          SizedBox(height: 5.h),
          Text(
            'Your status is visible to government dispatch when assigning '
            'teams. Off-duty members do not block dispatch — they only make '
            "their team rank lower in the picker.",
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          SizedBox(height: 15.h),
          Obx(() {
            final current = ctrl.availabilityStatus;
            return Row(
              children: [
                _Segment(
                  label: 'Available',
                  color: AppTheme.green,
                  selected: current == 'available',
                  onTap: () => ctrl.setAvailabilityStatus('available'),
                ),
                SizedBox(width: 8.w),
                _Segment(
                  label: 'Busy',
                  color: AppTheme.orange,
                  selected: current == 'busy',
                  onTap: () => ctrl.setAvailabilityStatus('busy'),
                ),
                SizedBox(width: 8.w),
                _Segment(
                  label: 'Off-duty',
                  color: AppTheme.red,
                  selected: current == 'off_duty',
                  onTap: () => ctrl.setAvailabilityStatus('off_duty'),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : theme.cardColor,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: selected ? color : theme.dividerColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
              ],
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: selected ? color : theme.hintColor,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
