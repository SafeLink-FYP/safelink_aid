import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:safelink_aid/core/utilities/validators.dart';
import 'package:safelink_aid/features/authorization/controllers/auth_controller.dart';
import 'package:safelink_aid/features/authorization/controllers/image_picking_controller.dart';
import 'package:safelink_aid/core/widgets/custom_elevated_button.dart';
import 'package:safelink_aid/features/authorization/controllers/sign_up_page_controller.dart';
import 'package:safelink_aid/features/authorization/models/auth_models.dart';
import 'package:safelink_aid/features/authorization/presentation/widgets/custom_text_form_field.dart';
import 'package:safelink_aid/features/authorization/presentation/widgets/date_picker_text_field.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  // One form key per step — prevents cross-page validation interference
  final _step0Key = GlobalKey<FormState>();
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  final AuthController _authController = Get.find<AuthController>();
  final ImagePickingController _imagePickingController = Get.put(
    ImagePickingController(),
  );
  final SignUpPageController _pageController = Get.put(SignUpPageController());

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ISO date stored separately; the text field shows the display-friendly format
  String? _selectedDobIso;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView.builder(
          itemCount: 4,
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController.pageController,
          onPageChanged: (v) => _pageController.currentPage.value = v,
          itemBuilder: (context, index) {
            final formKeys = [_step0Key, _step1Key, _step2Key, _step3Key];
            final Widget content;
            final theme = Get.theme;

            switch (index) {
              case 0:
                content = _buildEmailStep(theme);
                break;
              case 1:
                content = _buildDetailsStep(theme);
                break;
              case 2:
                content = _buildPasswordStep(theme);
                break;
              case 3:
                content = _buildProfilePictureStep(theme);
                break;
              default:
                content = const SizedBox.shrink();
            }

            return Form(
              key: formKeys[index],
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => _pageController.previousPage(),
                        ),
                        _buildStepIndicator(theme, index, 4),
                        SizedBox(width: 48.w),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    content,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 0 — Email
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmailStep(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Create a New Account',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
        Text(
          'Join the relief network to stay updated and connected.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30.h),
        CustomTextFormField(
          label: 'Email',
          hintText: 'Enter your email',
          controller: _emailController,
          validator: Validators.validateEmail,
          icon: CupertinoIcons.envelope,
        ),
        SizedBox(height: 30.h),
        CustomElevatedButton(
          label: 'Continue',
          onPressed: () {
            if (_step0Key.currentState!.validate()) {
              _pageController.nextPage();
            }
          },
        ),
        SizedBox(height: 30.h),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyLarge,
            children: [
              const TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Sign In',
                style: theme.textTheme.displayLarge,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.offAllNamed(AppRoutes.signInView),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 1 — Personal details
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDetailsStep(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Tell us about yourself',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
        Text(
          'Help us personalise your experience.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30.h),
        CustomTextFormField(
          label: 'Full Name',
          hintText: 'Enter your full name',
          controller: _fullNameController,
          validator: Validators.validateName,
          icon: CupertinoIcons.person,
        ),
        SizedBox(height: 20.h),
        CustomTextFormField(
          label: 'Phone (Optional)',
          hintText: 'Enter phone number',
          controller: _phoneController,
          validator: Validators.validatePhoneNumber,
          icon: CupertinoIcons.phone,
        ),
        SizedBox(height: 20.h),
        CustomTextFormField(
          label: 'CNIC',
          hintText: 'Enter CNIC (xxxxx-xxxxxxx-x)',
          controller: _cnicController,
          validator: Validators.validateCNIC,
          icon: CupertinoIcons.creditcard,
        ),
        SizedBox(height: 20.h),
        DatePickerTextField(
          label: 'Date of Birth',
          hintText: 'Select Date of Birth',
          icon: Icons.calendar_month,
          controller: _dobController,
          validator: Validators.validateDOB,
          onDateSelected: (iso) => _selectedDobIso = iso,
        ),
        SizedBox(height: 30.h),
        CustomElevatedButton(
          label: 'Continue',
          onPressed: () {
            if (_step1Key.currentState!.validate()) {
              _pageController.nextPage();
            }
          },
        ),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: () => _pageController.previousPage(),
          child: Text('Go Back', style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 2 — Password
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPasswordStep(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Create a password',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
        Text(
          'Make it strong and memorable.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30.h),
        CustomTextFormField(
          label: 'Password',
          hintText: 'Create a password',
          isPassword: true,
          icon: CupertinoIcons.lock,
          controller: _passwordController,
          validator: Validators.validatePassword,
          onChanged: _pageController.onPasswordChanged,
        ),
        SizedBox(height: 20.h),
        CustomTextFormField(
          label: 'Confirm Password',
          hintText: 'Confirm your password',
          isPassword: true,
          icon: CupertinoIcons.lock,
          controller: _confirmPasswordController,
          validator: (v) =>
              Validators.validateConfirmPassword(v, _passwordController.text),
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.50),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password must contain:',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(height: 10.h),
              _buildPasswordRule(
                'At least 8 characters',
                _pageController.hasMinLength,
              ),
              _buildPasswordRule(
                'One uppercase letter',
                _pageController.hasUppercase,
              ),
              _buildPasswordRule('One number', _pageController.hasNumber),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        CustomElevatedButton(
          label: 'Continue',
          onPressed: () {
            if (_step2Key.currentState!.validate()) {
              _pageController.nextPage();
            }
          },
        ),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: () => _pageController.previousPage(),
          child: Text('Go Back', style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildPasswordRule(String label, RxBool isValid) {
    final theme = Get.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(
          () => Checkbox(
            value: isValid.value,
            onChanged: null,
            checkColor: AppTheme.white,
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              return isValid.value ? AppTheme.green : Colors.grey.shade400;
            }),
            side: BorderSide(
              color: isValid.value ? AppTheme.green : Colors.grey.shade400,
              width: 1.w,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity,
            ),
          ),
        ),
        SizedBox(width: 5.w),
        Text(label, style: theme.textTheme.headlineSmall),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 3 — Profile picture (optional)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProfilePictureStep(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Add a profile picture',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
        Text(
          'Optional — add a photo to make your profile more personal.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30.h),
        Obx(() {
          final image = _imagePickingController.selectedImage.value;
          return Stack(
            children: [
              Container(
                height: 200.h,
                width: 200.w,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.30),
                      offset: const Offset(0, 25),
                      blurRadius: 50.r,
                      spreadRadius: -12.r,
                    ),
                  ],
                ),
                child: image != null
                    ? Image.file(File(image.path), fit: BoxFit.fill)
                    : Container(
                        padding: EdgeInsets.all(50.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.30),
                              offset: const Offset(0, 25),
                              blurRadius: 50.r,
                              spreadRadius: -12.r,
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          AppAssets.cameraIcon,
                          width: 50.w,
                          height: 50.h,
                        ),
                      ),
              ),
              if (image != null)
                Positioned(
                  bottom: 20.h,
                  right: 10.w,
                  child: InkWell(
                    onTap: () =>
                        _imagePickingController.selectedImage.value = null,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: const BoxDecoration(
                        color: AppTheme.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
        SizedBox(height: 35.h),
        InkWell(
          borderRadius: BorderRadius.circular(15.r),
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.08),
          hoverColor: theme.colorScheme.primary.withValues(alpha: 0.05),
          onTap: () => _imagePickingController.pickImage(),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 25.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              color: theme.colorScheme.surfaceContainerHigh,
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppAssets.uploadIcon,
                  colorFilter: ColorFilter.mode(
                    theme.iconTheme.color!,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 10.w),
                Text('Upload Photo', style: theme.textTheme.headlineLarge),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'Recommended: square image, at least 400×400 px',
          style: theme.textTheme.bodySmall,
        ),
        SizedBox(height: 30.h),
        Obx(() => CustomElevatedButton(
              label: 'Complete Registration',
              isLoading: _authController.isLoading.value,
              onPressed: _submitRegistration,
            )),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: () => _pageController.previousPage(),
          child: Text('Go Back', style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(ThemeData theme, int currentIndex, int total) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == currentIndex;
        return Container(
          width: active ? 18.w : 8.w,
          height: 8.h,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: active ? theme.primaryColor : theme.dividerColor,
            borderRadius: BorderRadius.circular(50.r),
          ),
        );
      }),
    );
  }

  void _submitRegistration() {
    _authController.signUp(
      SignUpModel(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        cnic: _cnicController.text.trim(),
        dateOfBirth: _selectedDobIso ?? _dobController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        profilePicture: _imagePickingController.selectedImage.value != null
            ? File(_imagePickingController.selectedImage.value!.path)
            : null,
      ),
    );
  }
}
