import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/authorization/controllers/auth_controller.dart';

class WaitingApprovalView extends StatefulWidget {
  const WaitingApprovalView({super.key});

  @override
  State<WaitingApprovalView> createState() => _WaitingApprovalViewState();
}

class _WaitingApprovalViewState extends State<WaitingApprovalView> {
  bool _isLoadingContext = true;
  // true  = waiting for admin to approve their team creation request
  // false = waiting for team lead to approve their join request
  bool _isTeamCreation = false;
  String? _teamName;
  String? _teamCode;

  @override
  void initState() {
    super.initState();
    _loadContext();
  }

  Future<void> _loadContext() async {
    try {
      final supa = SupabaseService.instance;
      final user = supa.currentUser;
      if (user == null) return;

      // 1. Check for a pending join request first
      final joinReq = await supa.client
          .from('team_join_requests')
          .select('status, teams(name)')
          .eq('user_id', user.id)
          .eq('status', 'pending')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (joinReq != null) {
        final teamData = joinReq['teams'];
        if (mounted) {
          setState(() {
            _isTeamCreation = false;
            _teamName = teamData is Map ? teamData['name'] as String? : null;
            _isLoadingContext = false;
          });
        }
        return;
      }

      // 2. Check for a pending team creation request
      final pendingTeam = await supa.teams
          .select('name, team_code')
          .eq('created_by', user.id)
          .eq('is_approved', false)
          .maybeSingle();

      if (pendingTeam != null) {
        if (mounted) {
          setState(() {
            _isTeamCreation = true;
            _teamName = pendingTeam['name'] as String?;
            _teamCode = pendingTeam['team_code'] as String?;
            _isLoadingContext = false;
          });
        }
        return;
      }

      // Neither pending — something changed (approved/rejected). Re-evaluate routing.
      if (mounted) {
        setState(() => _isLoadingContext = false);
        await Get.find<AuthController>().evaluateRouting();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingContext = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(25.r),
          child: _isLoadingContext
              ? const Center(child: CircularProgressIndicator())
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: EdgeInsets.all(30.r),
                decoration: BoxDecoration(
                  color: AppTheme.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time_filled,
                  size: 80.sp,
                  color: AppTheme.orange,
                ),
              ),
              SizedBox(height: 35.h),
              Text(
                'Approval Pending',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              Text(
                _buildMessage(),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              // Team code badge (only for creation requests)
              if (_isTeamCreation && _teamCode != null) ...[
                SizedBox(height: 25.h),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color:
                      AppTheme.primaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Team Code',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _teamCode!,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Share this code with your teammates',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 45.h),
              OutlinedButton.icon(
                onPressed: () async {
                  setState(() => _isLoadingContext = true);
                  await _loadContext();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Check Status'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 30.w, vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _confirmLogout,
                child: Text(
                  'Log out',
                  style: TextStyle(
                    color: AppTheme.red,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You\'ll need to log in again to receive new assignments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Sign Out',
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
      await Get.find<AuthController>().signOut();
    }
  }

  String _buildMessage() {
    if (_isTeamCreation) {
      final name = _teamName != null ? '"$_teamName"' : 'your team';
      return 'Your request to create $name has been submitted and is waiting for Government approval.\n\n'
          'Dashboard access will be granted once the team is approved.';
    } else {
      final name = _teamName != null ? '"$_teamName"' : 'a team';
      return 'Your request to join $name is waiting for the Team Leader\'s approval.\n\n'
          'Dashboard access will be granted once you are accepted.';
    }
  }
}
