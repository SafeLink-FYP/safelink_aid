import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/resource_tile.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/resource_summary_item.dart';

class ResourcesView extends StatefulWidget {
  const ResourcesView({super.key});

  @override
  State<ResourcesView> createState() => _ResourcesViewState();
}

class _ResourcesViewState extends State<ResourcesView> {
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
                          AppAssets.cubeIcon,
                          width: 35.w,
                          height: 35.h,
                          colorFilter: ColorFilter.mode(
                            AppTheme.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Resource Management',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Inventory Management',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.white.withAlpha(225),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 25.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ResourceSummaryItem(label: 'Overall Stock', count: 89),
                        SizedBox(width: 10.w),
                        ResourceSummaryItem(label: 'Total Categories', count: 6),
                        SizedBox(width: 10.w),
                        ResourceSummaryItem(label: 'Low\nStock', count: 2),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    Column(
                      children: [
                        ResourceTile(
                          label: 'Food Supplies',
                          availableCount: 850,
                          totalCount: 1000,
                        ),
                        SizedBox(height: 10.h),
                        ResourceTile(
                          label: 'Medical Kits',
                          availableCount: 45,
                          totalCount: 100,
                        ),
                        SizedBox(height: 10.h),
                        ResourceTile(
                          label: 'Water Bottles',
                          availableCount: 3200,
                          totalCount: 5000,
                        ),
                        SizedBox(height: 10.h),
                        ResourceTile(
                          label: 'Blankets',
                          availableCount: 120,
                          totalCount: 500,
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
