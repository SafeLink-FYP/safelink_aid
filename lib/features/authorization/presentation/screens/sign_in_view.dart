import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safelink_aid/core/constants/app_assets.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:safelink_aid/core/utilities/validators.dart';
import 'package:safelink_aid/features/authorization/controllers/auth_controller.dart';
import 'package:safelink_aid/core/widgets/custom_elevated_button.dart';
import 'package:safelink_aid/features/authorization/models/auth_models.dart';
import 'package:safelink_aid/features/authorization/presentation/widgets/custom_text_form_field.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 80.h, horizontal: 30.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppAssets.safeLinkLogo, width: 100.w, height: 100.h)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),
                SizedBox(height: 25.h),
                Text(
                  'Aid Worker Sign In',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.h),
                Text(
                  'Sign in to coordinate relief efforts and manage your team.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                CustomTextFormField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => Validators.validateEmail(value),
                  icon: CupertinoIcons.envelope,
                ),
                SizedBox(height: 20.h),
                CustomTextFormField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  isPassword: true,
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  icon: CupertinoIcons.lock,
                ),
                SizedBox(height: 25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.displayMedium,
                        children: [
                          TextSpan(
                            text: 'Forgot Password?',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Get.toNamed(AppRoutes.resetPasswordView),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25.h),
                Obx(() => CustomElevatedButton(
                      label: 'Sign In',
                      isLoading: _authController.isLoading.value,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _authController.signIn(
                            SignInModel(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            ),
                          );
                        }
                      },
                    )),
                SizedBox(height: 40.h),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyLarge,
                    children: [
                      TextSpan(text: "New to SafeLink? "),
                      TextSpan(
                        text: 'Register Here',
                        style: theme.textTheme.displayLarge,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.toNamed(AppRoutes.signUpView),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
