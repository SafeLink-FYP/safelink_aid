import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:safelink_aid/core/utilities/dialog_helpers.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/core/widgets/custom_elevated_button.dart';

/// Forces every keystroke into uppercase as the user types, so the visible
/// text matches what the submit handler will eventually send.
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class JoinTeamView extends StatefulWidget {
  const JoinTeamView({super.key});

  @override
  State<JoinTeamView> createState() => _JoinTeamViewState();
}

class _JoinTeamViewState extends State<JoinTeamView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _codeController = TextEditingController();
  bool _isSubmitting = false;

  // Browse tab state
  List<Map<String, dynamic>> _teams = [];
  bool _isLoadingTeams = false;
  String? _browseError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0 && _teams.isEmpty && !_isLoadingTeams) {
        _loadApprovedTeams();
      }
    });
    _loadApprovedTeams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadApprovedTeams() async {
    setState(() {
      _isLoadingTeams = true;
      _browseError = null;
    });
    try {
      final res = await SupabaseService.instance.client
          .from('teams')
          .select(
              'id, name, description, region, capacity, specialization, team_code, organization_id, '
              'profiles!teams_team_lead_id_fkey(full_name), '
              'aid_organizations(name)')
          .eq('is_approved', true)
          .order('name');
      if (mounted) {
        setState(() {
          _teams = List<Map<String, dynamic>>.from(res);
          _isLoadingTeams = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _browseError = 'Failed to load teams. Pull down to retry.';
          _isLoadingTeams = false;
        });
      }
    }
  }

  Future<void> _submitJoinRequestForTeam(
      String teamId, String teamName, String? teamOrgId) async {
    if (teamOrgId == null || teamOrgId.isEmpty) {
      DialogHelpers.showFailure(
        title: 'Couldn\'t send join request',
        message:
            'This team has no organization assigned. Please pick another team.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    DialogHelpers.showLoadingDialog();
    try {
      final supa = SupabaseService.instance;
      final userId = supa.currentUser?.id;
      if (userId == null) throw Exception('No active session.');

      // UPSERT aid_worker_profiles with the team's org. The user inherits the
      // org of the team they're applying to. NOT NULL constraint on
      // organization_id requires the row to exist before the join_request
      // can be approved into team_members (RLS check on org match).
      await supa.aidWorkerProfiles.upsert({
        'id': userId,
        'organization_id': teamOrgId,
      });

      // request_team_join is a SECURITY DEFINER RPC that:
      //   - validates caller role + team approval state
      //   - inserts the join request
      //   - notifies the team lead (RLS-safe, since the lead is a different user)
      await SupabaseService.instance.rpc(
        'request_team_join',
        params: {'p_team_id': teamId},
      );

      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showSuccess(
        title: 'Request Sent',
        message: 'Your join request for $teamName has been sent!',
      );
      Get.offAllNamed(AppRoutes.waitingApprovalView);
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t send join request',
        error: e,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitJoinRequestByCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _isSubmitting = true);
    DialogHelpers.showLoadingDialog();
    try {
      final supa = SupabaseService.instance;
      final user = supa.currentUser;
      if (user == null) throw Exception('No active session.');

      final teamRes = await supa.teams
          .select('id, name, is_approved, organization_id')
          .eq('team_code', code)
          .maybeSingle();

      if (teamRes == null) throw Exception('Team with this code not found.');
      if (teamRes['is_approved'] != true) {
        throw Exception('This team is not yet approved by Government.');
      }

      await _submitJoinRequestForTeam(
        teamRes['id'] as String,
        teamRes['name'] as String,
        teamRes['organization_id'] as String?,
      );
    } catch (e) {
      DialogHelpers.hideLoadingDialog();
      DialogHelpers.showFailure(
        title: 'Couldn\'t send join request',
        error: e,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Team'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Browse Teams'),
            Tab(text: 'Enter Code'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBrowseTab(theme),
            _buildCodeTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseTab(ThemeData theme) {
    if (_isLoadingTeams) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (_browseError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(30.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_browseError!, style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center),
              SizedBox(height: 16.h),
              TextButton.icon(
                onPressed: _loadApprovedTeams,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_teams.isEmpty) {
      return Center(
        child: Text('No approved teams available.',
            style: theme.textTheme.bodyMedium),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApprovedTeams,
      child: ListView.builder(
        padding: EdgeInsets.all(20.r),
        itemCount: _teams.length,
        itemBuilder: (context, index) {
          final t = _teams[index];
          final leadName =
              t['profiles']?['full_name'] as String? ?? 'Unknown';
          final orgName = t['aid_organizations']?['name'] as String?;
          final rawSpecs = t['specialization'];
          final specs = rawSpecs is List
              ? rawSpecs.map((e) => e.toString()).toList()
              : <String>[];
          // Show up to 3 specialization chips inline; collapse the rest
          // into a "+N more" chip to keep the card visually balanced.
          final visibleSpecs = specs.take(3).toList();
          final extraSpecs = specs.length - visibleSpecs.length;
          return Container(
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.all(15.r),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['name'] ?? 'Unnamed',
                    style: theme.textTheme.headlineLarge),
                if (orgName != null && orgName.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(orgName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis),
                ],
                if (t['description'] != null &&
                    t['description'].toString().isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(t['description'],
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                SizedBox(height: 8.h),
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 13.sp, color: theme.hintColor),
                  SizedBox(width: 4.w),
                  Text(t['region'] ?? 'Unknown region',
                      style: theme.textTheme.bodySmall),
                  SizedBox(width: 12.w),
                  Icon(Icons.groups_outlined,
                      size: 13.sp, color: theme.hintColor),
                  SizedBox(width: 4.w),
                  Text('Capacity: ${t['capacity'] ?? '-'}',
                      style: theme.textTheme.bodySmall),
                ]),
                SizedBox(height: 6.h),
                Row(children: [
                  Icon(Icons.person_outline,
                      size: 13.sp, color: theme.hintColor),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text('Lead: $leadName',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                if (specs.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: visibleSpecs
                        .map((s) => _specChip(theme, s))
                        .toList()
                      ..addAll(extraSpecs > 0
                          ? [_specChip(theme, '+$extraSpecs more')]
                          : []),
                  ),
                ],
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => _submitJoinRequestForTeam(
                            t['id'] as String,
                            t['name'] as String,
                            t['organization_id'] as String?,
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: const Text('Request to Join',
                        style: TextStyle(color: AppTheme.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _specChip(ThemeData theme, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(50.r),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCodeTab(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(25.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter Team Code', style: theme.textTheme.titleMedium),
          SizedBox(height: 10.h),
          Text(
            'Ask your Team Leader for the 6-character team code.',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 40.h),
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              _UpperCaseTextFormatter(),
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              hintText: 'e.g. ALPHA1',
              filled: true,
              fillColor: theme.cardColor,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(color: theme.primaryColor),
              ),
            ),
            style: theme.textTheme.headlineMedium
                ?.copyWith(letterSpacing: 2.0),
            onChanged: (_) => setState(() {}),
          ),
          const Spacer(),
          CustomElevatedButton(
            label: 'Submit Request',
            isLoading: _isSubmitting,
            onPressed: _codeController.text.trim().isEmpty || _isSubmitting
                ? null
                : _submitJoinRequestByCode,
          ),
        ],
      ),
    );
  }
}
