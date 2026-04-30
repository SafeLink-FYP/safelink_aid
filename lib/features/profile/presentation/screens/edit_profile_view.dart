import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/utilities/validators.dart';
import 'package:safelink_aid/features/authorization/presentation/widgets/custom_text_form_field.dart';
import 'package:safelink_aid/features/profile/controllers/profile_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = Get.find<ProfileController>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _regionCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _designationCtrl;
  late final TextEditingController _departmentCtrl;

  @override
  void initState() {
    super.initState();
    final p = _ctrl.profile.value;
    final ap = _ctrl.aidProfile.value;
    _nameCtrl = TextEditingController(text: p?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: p?.phone ?? '');
    _regionCtrl = TextEditingController(text: p?.region ?? '');
    _cityCtrl = TextEditingController(text: p?.city ?? '');
    _designationCtrl = TextEditingController(text: ap?.designation ?? '');
    _departmentCtrl = TextEditingController(text: ap?.department ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _regionCtrl.dispose();
    _cityCtrl.dispose();
    _designationCtrl.dispose();
    _departmentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profileUpdates = <String, dynamic>{};
    final apUpdates = <String, dynamic>{};

    final name = _nameCtrl.text.trim();
    final phone =
        _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim();
    final region =
        _regionCtrl.text.trim().isEmpty ? null : _regionCtrl.text.trim();
    final city = _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim();

    if (name != (_ctrl.profile.value?.fullName ?? '')) {
      profileUpdates['full_name'] = name;
    }
    if (phone != _ctrl.profile.value?.phone) profileUpdates['phone'] = phone;
    if (region != _ctrl.profile.value?.region) {
      profileUpdates['region'] = region;
    }
    if (city != _ctrl.profile.value?.city) profileUpdates['city'] = city;

    final designation = _designationCtrl.text.trim();
    final department =
        _departmentCtrl.text.trim().isEmpty ? null : _departmentCtrl.text.trim();

    if (designation != (_ctrl.aidProfile.value?.designation ?? '')) {
      apUpdates['designation'] = designation;
    }
    if (department != _ctrl.aidProfile.value?.department) {
      apUpdates['department'] = department;
    }

    if (profileUpdates.isNotEmpty) {
      await _ctrl.updateProfile(profileUpdates);
    }
    if (apUpdates.isNotEmpty) {
      await _ctrl.updateAidProfile(
        designation: apUpdates['designation'],
        department: apUpdates['department'],
      );
    }

    if (profileUpdates.isEmpty && apUpdates.isEmpty) {
      Get.snackbar('No Changes', 'Nothing was changed.');
      return;
    }

    Get.back();
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
                      'Edit Profile',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: AppTheme.white),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Update your personal and worker information',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.white.withValues(alpha: 0.8)),
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
                      _sectionLabel(theme, 'Profile Photo'),
                      SizedBox(height: 15.h),
                      _buildAvatarPicker(theme),
                      SizedBox(height: 25.h),
                      _sectionLabel(theme, 'Personal Information'),
                      SizedBox(height: 15.h),
                      CustomTextFormField(
                        label: 'Full Name',
                        hintText: 'Enter your full name',
                        controller: _nameCtrl,
                        validator: Validators.validateName,
                        icon: CupertinoIcons.person,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextFormField(
                        label: 'Phone (Optional)',
                        hintText: 'Enter phone number',
                        controller: _phoneCtrl,
                        validator: Validators.validatePhoneNumber,
                        icon: CupertinoIcons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRawField(
                              theme: theme,
                              label: 'Region',
                              hint: 'e.g. Punjab',
                              controller: _regionCtrl,
                            ),
                          ),
                          SizedBox(width: 15.w),
                          Expanded(
                            child: _buildRawField(
                              theme: theme,
                              label: 'City',
                              hint: 'e.g. Lahore',
                              controller: _cityCtrl,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
                      _sectionLabel(theme, 'Worker Information'),
                      SizedBox(height: 15.h),
                      CustomTextFormField(
                        label: 'Designation',
                        hintText: 'e.g. Field Coordinator',
                        controller: _designationCtrl,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                        icon: Icons.badge_outlined,
                      ),
                      SizedBox(height: 20.h),
                      _buildRawField(
                        theme: theme,
                        label: 'Department (Optional)',
                        hint: 'e.g. Logistics',
                        controller: _departmentCtrl,
                      ),
                      SizedBox(height: 35.h),

                      // Save button
                      Obx(() {
                        final saving = _ctrl.isSaving.value;
                        return InkWell(
                          onTap: saving ? null : _save,
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(15.r),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: saving
                                ? Center(
                                    child: SizedBox(
                                      width: 22.w,
                                      height: 22.h,
                                      child: const CircularProgressIndicator(
                                        color: AppTheme.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Save Changes',
                                    style: theme.textTheme.headlineLarge
                                        ?.copyWith(color: AppTheme.white),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        );
                      }),
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

  Future<void> _pickAndUploadAvatar() async {
    if (_ctrl.isUploadingAvatar.value) return;
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      await _ctrl.uploadAvatar(bytes);
    } catch (_) {
      Get.snackbar(
        'Couldn\'t update photo',
        'Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildAvatarPicker(ThemeData theme) {
    return Obx(() {
      final url = _ctrl.profile.value?.avatarUrl;
      final uploading = _ctrl.isUploadingAvatar.value;
      return Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 36.r,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                backgroundImage: url != null ? NetworkImage(url) : null,
                child: url == null
                    ? Icon(
                        CupertinoIcons.person_fill,
                        size: 32.sp,
                        color: theme.primaryColor,
                      )
                    : null,
              ),
              if (uploading)
                Positioned.fill(
                  child: CircleAvatar(
                    radius: 36.r,
                    backgroundColor: AppTheme.black.withValues(alpha: 0.45),
                    child: SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: const CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  url == null ? 'No photo set' : 'Profile photo',
                  style: theme.textTheme.headlineMedium,
                ),
                SizedBox(height: 4.h),
                Text(
                  'JPG/PNG from your gallery. Square image works best.',
                  style: theme.textTheme.bodySmall,
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: uploading ? null : _pickAndUploadAvatar,
                      icon: Icon(Icons.photo_library_outlined,
                          size: 16.sp),
                      label: Text(url == null
                          ? 'Add photo'
                          : 'Change photo'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _sectionLabel(ThemeData theme, String text) =>
      Text(text, style: theme.textTheme.headlineLarge);

  Widget _buildRawField({
    required ThemeData theme,
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.headlineMedium),
        SizedBox(height: 10.h),
        TextFormField(
          controller: controller,
          validator: validator,
          style: theme.textTheme.headlineMedium,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.cardColor,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
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
        ),
      ],
    );
  }
}
