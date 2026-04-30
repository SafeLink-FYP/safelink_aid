import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/dashboard/controllers/aid_request_controller.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/case_card.dart';

class RequestsView extends StatefulWidget {
  const RequestsView({super.key});

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final ctrl = Get.find<AidRequestController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 25.w),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.requestsIcon,
                        width: 30.w,
                        height: 30.h,
                        colorFilter: const ColorFilter.mode(
                          AppTheme.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Aid Requests',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
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
                        borderSide:
                        const BorderSide(color: AppTheme.transparentColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide:
                        const BorderSide(color: AppTheme.transparentColor),
                      ),
                      hintText: 'Search requests...',
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
                  SizedBox(height: 15.h),
                  // Filters
                  Obx(() => Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    height: 45.h,
                    child: Row(
                      children: [
                        _filterChip(theme, ctrl, 'All', 'all'),
                        _filterChip(theme, ctrl, 'Active', 'in_progress'),
                        _filterChip(theme, ctrl, 'Done', 'fulfilled'),
                        _filterChip(theme, ctrl, 'Rejected', 'rejected'),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            // List
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value && ctrl.requests.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filtered = ctrl.filteredRequests;
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppAssets.requestsIcon,
                          width: 50.w,
                          height: 50.h,
                          colorFilter: ColorFilter.mode(
                            theme.primaryIconTheme.color!,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Text('No requests found',
                            style: theme.textTheme.headlineMedium),
                        SizedBox(height: 5.h),
                        Text(
                          'Requests assigned to your teams will appear here.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: ctrl.refreshRequests,
                  child: ListView.separated(
                    padding: EdgeInsets.all(25.r),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => SizedBox(height: 15.h),
                    itemBuilder: (_, i) => CaseCard(request: filtered[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(
      ThemeData theme,
      AidRequestController ctrl,
      String label,
      String value,
      ) {
    final isSelected = ctrl.statusFilter.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => ctrl.statusFilter.value = value,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.white.withValues(alpha: 0.20)
                : AppTheme.transparentColor,
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
