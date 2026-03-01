import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/case_card.dart';

class RequestsView extends StatefulWidget {
  const RequestsView({super.key});

  @override
  State<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends State<RequestsView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Active', 'Done'];

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
                padding: EdgeInsets.symmetric(vertical: 35.h, horizontal: 25.w),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.requestsIcon,
                          width: 35.w,
                          height: 35.h,
                          colorFilter: ColorFilter.mode(
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
                    SizedBox(height: 25.h),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 15.h,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppTheme.transparentColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppTheme.transparentColor,
                          ),
                        ),
                        hintText: 'Search cases...',
                        prefixIcon: Icon(
                          FontAwesomeIcons.magnifyingGlass,
                          color: AppTheme.darkGreyColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 25.h),
                    Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      height: 50.h,
                      child: Row(
                        children: _filters.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.w),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.white.withValues(alpha: 0.20)
                                      : AppTheme.transparentColor,
                                  borderRadius: BorderRadius.circular(50.r),
                                ),
                                child: Center(
                                  child: Text(
                                    filter,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 25.w),
                child: Column(
                  children: [
                    CaseCard(),
                    SizedBox(height: 15.h),
                    CaseCard(),
                    SizedBox(height: 15.h),
                    CaseCard(),
                    SizedBox(height: 15.h),
                    CaseCard(),
                    SizedBox(height: 15.h),
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
