import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';

class CaseCard extends StatelessWidget {
  const CaseCard({super.key});

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
            color: AppTheme.transparentColor.withValues(alpha: 0.10),
            offset: const Offset(0, 1),
            blurRadius: 3.r,
            spreadRadius: 0.r,
          ),
          BoxShadow(
            color: AppTheme.transparentColor.withValues(alpha: 0.10),
            offset: const Offset(0, 1),
            blurRadius: 2.r,
            spreadRadius: -1.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Medical Aid', style: theme.textTheme.headlineLarge),
              SizedBox(width: 25.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: AppTheme.red.withValues(alpha: 0.05),
                  border: Border.all(
                    color: AppTheme.red.withValues(alpha: 0.20),
                  ),
                ),
                child: Text(
                  'Urgent',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.red,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text('REQ-2451', style: theme.textTheme.headlineMedium),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('User:', style: theme.textTheme.bodyMedium),
              Text('Ahmed Khan', style: theme.textTheme.headlineMedium),
            ],
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Location:', style: theme.textTheme.bodyMedium),
              Text('F-7, Islamabad', style: theme.textTheme.headlineMedium),
            ],
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Assigned to:', style: theme.textTheme.bodyMedium),
              Text('Team Alpha', style: theme.textTheme.headlineMedium),
            ],
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Time:', style: theme.textTheme.bodyMedium),
              Text('10 mins ago', style: theme.textTheme.headlineMedium),
            ],
          ),
          SizedBox(height: 20.h),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                gradient: AppTheme.primaryGradient,
              ),
              child: Text(
                'View Details',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: AppTheme.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
