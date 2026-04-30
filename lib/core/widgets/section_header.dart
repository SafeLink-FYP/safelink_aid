import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool showViewAll;
  final VoidCallback? onViewAllTap;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.showViewAll = false,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppTheme.primaryColor),
        SizedBox(width: 10.w),
        Text(title, style: theme.textTheme.headlineLarge),
        if (showViewAll) ...[
          const Spacer(),
          RichText(
            text: TextSpan(
              style: theme.textTheme.displayMedium,
              children: [
                TextSpan(
                  text: 'View All',
                  recognizer: TapGestureRecognizer()..onTap = onViewAllTap,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
