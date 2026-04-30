import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:safelink_aid/features/dashboard/controllers/resource_controller.dart';
import 'package:safelink_aid/features/dashboard/controllers/team_controller.dart';
import 'package:safelink_aid/features/dashboard/models/resource_model.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/edit_resource_sheet.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/resource_summary_item.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/resource_tile.dart';

class ResourcesView extends StatefulWidget {
  const ResourcesView({super.key});

  @override
  State<ResourcesView> createState() => _ResourcesViewState();
}

class _ResourcesViewState extends State<ResourcesView> {
  final TextEditingController _searchCtrl = TextEditingController();

  // Must mirror the public.resource_type enum exactly
  // (food, water, medical_kits, other) plus an "all" pseudo-value.
  static const _filterChips = [
    ('all', 'All'),
    ('food', 'Food'),
    ('water', 'Water'),
    ('medical_kits', 'Medical Kits'),
    ('other', 'Other'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(
      BuildContext context, ResourceController ctrl, ResourceModel r) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete "${r.name}"?'),
        content: const Text(
          'This removes the resource from your inventory. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Delete',
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
      await ctrl.deleteResource(r.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final ctrl = Get.find<ResourceController>();
    final teamCtrl = Get.find<TeamController>();

    return Scaffold(
      // Leader-only: only team leaders add new resources to org inventory.
      floatingActionButton: Obx(() {
        if (!teamCtrl.isCurrentUserLeader) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () => Get.toNamed(AppRoutes.createResourceView),
          backgroundColor: AppTheme.primaryColor,
          child: Icon(Icons.add, color: AppTheme.white, size: 24.sp),
        );
      }),
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value && ctrl.resources.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: ctrl.refreshResources,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.cubeIcon,
                              width: 30.w,
                              height: 30.h,
                              colorFilter: const ColorFilter.mode(
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
                        SizedBox(height: 8.h),
                        Text(
                          'Inventory Management',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.white.withValues(alpha: 0.8),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        // Search
                        TextField(
                          controller: _searchCtrl,
                          onChanged: (val) {
                            ctrl.searchQuery.value = val;
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppTheme.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 15.h,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: const BorderSide(
                                  color: AppTheme.transparentColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: const BorderSide(
                                  color: AppTheme.transparentColor),
                            ),
                            hintText: 'Search resources...',
                            prefixIcon: Icon(
                              FontAwesomeIcons.magnifyingGlass,
                              color: AppTheme.darkGreyColor,
                              size: 18.sp,
                            ),
                            suffixIcon: _searchCtrl.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear',
                                    icon: Icon(
                                      Icons.close,
                                      size: 18.sp,
                                      color: AppTheme.darkGreyColor,
                                    ),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      ctrl.searchQuery.value = '';
                                      setState(() {});
                                    },
                                  ),
                          ),
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
                        // Summary row
                        Obx(() => Row(
                              children: [
                                ResourceSummaryItem(
                                  label: 'Overall Stock',
                                  count: ctrl.totalStock,
                                ),
                                SizedBox(width: 10.w),
                                ResourceSummaryItem(
                                  label: 'Categories',
                                  count: ctrl.totalCategories,
                                ),
                                SizedBox(width: 10.w),
                                ResourceSummaryItem(
                                  label: 'Low\nStock',
                                  count: ctrl.lowStockCount,
                                ),
                              ],
                            )),
                        SizedBox(height: 20.h),

                        // Type filter chips
                        SizedBox(
                          height: 36.h,
                          child: Obx(() => ListView(
                                scrollDirection: Axis.horizontal,
                                children: _filterChips
                                    .map((c) => Padding(
                                          padding:
                                              EdgeInsets.only(right: 8.w),
                                          child: _typeChip(
                                            theme,
                                            label: c.$2,
                                            value: c.$1,
                                            isSelected:
                                                ctrl.typeFilter.value == c.$1,
                                            onTap: () =>
                                                ctrl.typeFilter.value = c.$1,
                                          ),
                                        ))
                                    .toList(),
                              )),
                        ),
                        SizedBox(height: 20.h),

                        // Resource list
                        Obx(() {
                          final resources = ctrl.filteredResources;
                          if (resources.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(30.r),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                    color: theme.dividerColor, width: 1.w),
                              ),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    AppAssets.cubeIcon,
                                    width: 40.w,
                                    height: 40.h,
                                    colorFilter: ColorFilter.mode(
                                      theme.primaryIconTheme.color!,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Text('No resources match',
                                      style: theme.textTheme.headlineMedium),
                                  SizedBox(height: 5.h),
                                  Text(
                                    teamCtrl.isCurrentUserLeader
                                        ? 'Tap + to add a resource, or change the filter.'
                                        : 'Try changing the filter or search.',
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: resources
                                .map((r) => Padding(
                                      padding: EdgeInsets.only(bottom: 10.h),
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        onTap: teamCtrl.isCurrentUserLeader
                                            ? () => showEditResourceSheet(
                                                context, r)
                                            : null,
                                        onLongPress: teamCtrl
                                                .isCurrentUserLeader
                                            ? () => _confirmDelete(
                                                context, ctrl, r)
                                            : null,
                                        child: ResourceTile(
                                          label: r.name,
                                          availableCount: r.quantityAvailable,
                                          totalCount: r.quantityTotal,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          );
                        }),
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

  Widget _typeChip(
    ThemeData theme, {
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.15)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor.withValues(alpha: 0.40)
                : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? theme.primaryColor : null,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
