import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/widgets/custom_elevated_button.dart';
import 'package:safelink_aid/features/dashboard/controllers/team_controller.dart';

class CreateTeamView extends StatefulWidget {
  const CreateTeamView({super.key});

  @override
  State<CreateTeamView> createState() => _CreateTeamViewState();
}

class _CreateTeamViewState extends State<CreateTeamView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '10');
  final _specCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();

  // Organization picker state.
  final _orgs = <Map<String, dynamic>>[].obs;
  final _orgsLoading = true.obs;
  String? _selectedOrgId;

  // Local-only submit state — keeps the dashboard's KPI loading spinner
  // independent of this form's submit lifecycle.
  final _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    _loadOrgs();
  }

  Future<void> _loadOrgs() async {
    try {
      final res = await SupabaseService.instance.client
          .from('aid_organizations')
          .select('id, name')
          .order('name');
      _orgs.value = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      Get.log('Error loading orgs: $e');
    } finally {
      _orgsLoading.value = false;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _regionCtrl.dispose();
    _capacityCtrl.dispose();
    _specCtrl.dispose();
    _designationCtrl.dispose();
    _departmentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                    InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                            color: AppTheme.white,
                            size: 18.sp,
                            semanticLabel: 'Back'),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      'Create New Team',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Add a new response team to your organization',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: EdgeInsets.all(25.r),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(theme, 'Team Name *'),
                      SizedBox(height: 8.h),
                      _buildField(
                        controller: _nameCtrl,
                        hint: 'e.g. Team Alpha',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Team name is required'
                            : null,
                      ),
                      SizedBox(height: 20.h),

                      _buildLabel(theme, 'Organization *'),
                      SizedBox(height: 8.h),
                      Obx(() {
                        if (_orgsLoading.value) {
                          return Container(
                            height: 50.h,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          );
                        }
                        if (_orgs.isEmpty) {
                          return Text(
                            'No organisations found. Government must create one first.',
                            style: theme.textTheme.bodySmall,
                          );
                        }
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedOrgId,
                          isExpanded: true,
                          hint: const Text('Select organisation'),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.cardColor,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 15.h),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide:
                                  BorderSide(color: theme.dividerColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide:
                                  BorderSide(color: theme.primaryColor),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: const BorderSide(color: AppTheme.red),
                            ),
                          ),
                          items: _orgs
                              .map((o) => DropdownMenuItem<String>(
                                    value: o['id'] as String,
                                    child: Text(o['name'] as String),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedOrgId = v),
                          validator: (v) =>
                              v == null ? 'Please select an organisation' : null,
                        );
                      }),
                      SizedBox(height: 20.h),

                      _buildLabel(theme, 'Your Designation *'),
                      SizedBox(height: 8.h),
                      _buildField(
                        controller: _designationCtrl,
                        hint: 'e.g. Field Coordinator',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      SizedBox(height: 20.h),

                      _buildLabel(theme, 'Department (Optional)'),
                      SizedBox(height: 8.h),
                      _buildField(
                        controller: _departmentCtrl,
                        hint: 'e.g. Logistics',
                      ),
                      SizedBox(height: 20.h),

                      _buildLabel(theme, 'Description'),
                      SizedBox(height: 8.h),
                      _buildField(
                        controller: _descCtrl,
                        hint: 'Brief description of team purpose',
                        maxLines: 3,
                      ),
                      SizedBox(height: 20.h),

                      _buildLabel(theme, 'Region'),
                      SizedBox(height: 8.h),
                      _buildField(
                        controller: _regionCtrl,
                        hint: 'e.g. Islamabad Division',
                      ),
                      SizedBox(height: 20.h),

                      _buildLabel(theme, 'Capacity'),
                      SizedBox(height: 8.h),
                      _buildField(
                        controller: _capacityCtrl,
                        hint: '10',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final n = int.tryParse(v);
                          if (n == null || n < 1) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),

                      _buildLabel(theme, 'Specializations'),
                      SizedBox(height: 8.h),
                      _buildField(
                        controller: _specCtrl,
                        hint: 'Comma-separated: rescue, medical, logistics',
                      ),
                      SizedBox(height: 30.h),

                      // Submit
                      Obx(() => CustomElevatedButton(
                            label: 'Create Team',
                            isLoading: _isSubmitting.value,
                            onPressed: _submit,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting.value) return;
    if (!_formKey.currentState!.validate()) return;

    final specs = _specCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    _isSubmitting.value = true;
    try {
      await Get.find<TeamController>().createTeam(
        name: _nameCtrl.text.trim(),
        organizationId: _selectedOrgId!,
        designation: _designationCtrl.text.trim(),
        department: _departmentCtrl.text.trim().isEmpty
            ? null
            : _departmentCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        region:
            _regionCtrl.text.trim().isEmpty ? null : _regionCtrl.text.trim(),
        capacity: int.tryParse(_capacityCtrl.text) ?? 10,
        specialization: specs,
      );
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Text(text, style: theme.textTheme.headlineMedium);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Get.theme;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppTheme.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppTheme.red),
        ),
      ),
    );
  }
}
