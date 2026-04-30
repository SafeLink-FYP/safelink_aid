import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/dashboard/controllers/team_controller.dart';

class MyTeamView extends StatelessWidget {
  const MyTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final ctrl = Get.find<TeamController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value && ctrl.myTeam.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final team = ctrl.myTeam.value;

          return RefreshIndicator(
            onRefresh: ctrl.refreshMyTeam,
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
                              AppAssets.teamIcon,
                              width: 30.w,
                              height: 30.h,
                              colorFilter: const ColorFilter.mode(
                                AppTheme.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'My Team',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          team?.name ?? 'Your assigned response team',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (team == null)
                    Padding(
                      padding: EdgeInsets.all(30.r),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            AppAssets.teamIcon,
                            width: 40.w,
                            height: 40.h,
                            colorFilter: ColorFilter.mode(
                              theme.primaryIconTheme.color!,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text('No team assigned',
                              style: theme.textTheme.headlineMedium),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.all(25.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Team Info
                          _sectionTitle(theme, 'Team Information'),
                          SizedBox(height: 15.h),
                          _infoCard(theme, [
                            if (team.description != null)
                              _infoRow(theme, 'Description', team.description!),
                            if (team.region != null)
                              _infoRow(theme, 'Region', team.region!),
                            _infoRow(theme, 'Capacity', '${team.capacity}'),
                            _infoRow(theme, 'Status', team.statusDisplay),
                            if (team.teamCode != null &&
                                team.teamCode!.isNotEmpty)
                              _teamCodeRow(theme, team.teamCode!),
                            if (team.specialization.isNotEmpty)
                              _infoRow(theme, 'Specialization',
                                  team.specialization.join(', ')),
                          ]),

                          SizedBox(height: 25.h),

                          // Pending Join Requests (leader only)
                          Obx(() {
                            if (!ctrl.isCurrentUserLeader ||
                                ctrl.joinRequests.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(theme, 'Pending Join Requests'),
                                SizedBox(height: 15.h),
                                ...ctrl.joinRequests.map((req) {
                                  final profile = req['profiles'] as Map?;
                                  // aid_worker_profiles is nested inside
                                  // profiles in the new embed shape.
                                  final aidProfile =
                                      profile?['aid_worker_profiles'] as Map?;
                                  final fullName = profile?['full_name']
                                          as String? ??
                                      'Unknown applicant';
                                  final email =
                                      profile?['email'] as String?;
                                  final designation =
                                      aidProfile?['designation'] as String?;
                                  final avatarUrl =
                                      profile?['avatar_url'] as String?;
                                  final createdAt =
                                      req['created_at'] as String?;
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 10.h),
                                    padding: EdgeInsets.all(15.r),
                                    decoration: BoxDecoration(
                                      color: AppTheme.orange
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(10.r),
                                      border: Border.all(
                                          color: AppTheme.orange, width: 1.w),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: avatarUrl != null
                                                  ? NetworkImage(avatarUrl)
                                                  : null,
                                              child: avatarUrl == null
                                                  ? const Icon(Icons.person,
                                                      color: AppTheme.white)
                                                  : null,
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(fullName,
                                                      style: theme.textTheme
                                                          .headlineMedium,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                  if (designation != null &&
                                                      designation.isNotEmpty) ...[
                                                    SizedBox(height: 2.h),
                                                    Text(designation,
                                                        style: theme.textTheme
                                                            .bodySmall,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ],
                                                  if (email != null &&
                                                      email.isNotEmpty) ...[
                                                    SizedBox(height: 2.h),
                                                    Text(email,
                                                        style: theme.textTheme
                                                            .bodySmall,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ],
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    'Wants to join · ${_timeAgo(createdAt)}',
                                                    style: theme.textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                      color: AppTheme.orange,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'Approve',
                                              onPressed: () =>
                                                  ctrl.approveJoinRequest(
                                                      req['id'],
                                                      req['user_id'],
                                                      team.id),
                                              icon: const Icon(
                                                  Icons.check_circle,
                                                  color: AppTheme.green),
                                            ),
                                            IconButton(
                                              tooltip: 'Reject',
                                              onPressed: () =>
                                                  ctrl.rejectJoinRequest(
                                                      req['id'],
                                                      req['user_id']
                                                          as String),
                                              icon: const Icon(Icons.cancel,
                                                  color: AppTheme.red),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                SizedBox(height: 25.h),
                              ],
                            );
                          }),

                          // Members
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _sectionTitle(theme, 'Team Members'),
                              Obx(() => Text(
                                    '${ctrl.members.length} members',
                                    style: theme.textTheme.bodyMedium,
                                  )),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          Obx(() {
                            if (ctrl.members.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20.r),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                      color: theme.dividerColor, width: 1.w),
                                ),
                                child: Text(
                                  'No members in this team yet.',
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return Column(
                              children: ctrl.members.map((m) {
                                final isLeader = ctrl.isCurrentUserLeader;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 10.h),
                                  padding: EdgeInsets.all(15.r),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                        color: theme.dividerColor, width: 1.w),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20.r,
                                        backgroundColor: theme.primaryColor
                                            .withValues(alpha: 0.15),
                                        backgroundImage: m.avatarUrl != null
                                            ? NetworkImage(m.avatarUrl!)
                                            : null,
                                        child: m.avatarUrl == null
                                            ? SvgPicture.asset(
                                                AppAssets.personIcon,
                                                width: 18.w,
                                                height: 18.h,
                                                colorFilter: ColorFilter.mode(
                                                  theme.primaryColor,
                                                  BlendMode.srcIn,
                                                ),
                                              )
                                            : null,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              m.userName ?? 'Unknown Member',
                                              style: theme
                                                  .textTheme.headlineMedium,
                                            ),
                                            SizedBox(height: 3.h),
                                            Text(
                                              m.role.capitalizeFirst ?? m.role,
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Only team leader can remove non-leader members
                                      if (isLeader && m.role != 'leader')
                                        IconButton(
                                          onPressed: () =>
                                              ctrl.removeMember(m.id),
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                            color: AppTheme.red,
                                            size: 20.sp,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          }),
                          SizedBox(height: 25.h),
                          Obx(() {
                            return ctrl.isCurrentUserLeader
                                ? _transferLeadershipPlaceholder(theme)
                                : _leaveTeamButton(theme, ctrl);
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

  Widget _transferLeadershipPlaceholder(ThemeData theme) {
    return Tooltip(
      message: 'Coming soon',
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: Icon(Icons.swap_horiz, size: 18.sp),
          label: const Text('Transfer Leadership'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _leaveTeamButton(ThemeData theme, TeamController ctrl) {
    Future<void> confirmLeave() async {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Leave this team?'),
          content: const Text(
            'You\'ll need to be re-approved if you want to come back. '
            'Active assignments stay with the team.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(
                'Leave Team',
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
        await ctrl.leaveTeam();
      }
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: confirmLeave,
        icon: Icon(Icons.logout, size: 18.sp, color: AppTheme.red),
        label: Text(
          'Leave Team',
          style: TextStyle(
            color: AppTheme.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          side: BorderSide(color: AppTheme.red, width: 1.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  Widget _sectionTitle(ThemeData theme, String title) =>
      Text(title, style: theme.textTheme.headlineLarge);

  Widget _infoCard(ThemeData theme, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.r),
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
      child: Column(children: children),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: theme.textTheme.bodyMedium),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.headlineMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamCodeRow(ThemeData theme, String code) {
    Future<void> copy() async {
      await Clipboard.setData(ClipboardData(text: code));
      Get.snackbar(
        'Copied',
        'Team code "$code" is on your clipboard. Share it with teammates to invite them.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    return InkWell(
      onTap: copy,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Team Code:', style: theme.textTheme.bodyMedium),
            SizedBox(width: 10.w),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    code,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.primaryColor,
                      letterSpacing: 4.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.copy_rounded,
                    size: 18.sp,
                    color: theme.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
