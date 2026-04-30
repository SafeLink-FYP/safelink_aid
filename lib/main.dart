import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/controllers/theme_controller.dart';
import 'package:safelink_aid/core/secrets/app_secrets.dart';
import 'package:safelink_aid/core/services/cache_service.dart';
import 'package:safelink_aid/core/services/initial_bindings.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  await ScreenUtil.ensureScreenSize();
  await CacheService.instance.init();
  await ThemeController.instance.init();
  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 915),
      minTextAdapt: true,
      builder: (context, child) {
        final controller = ThemeController.instance;
        return Obx(() {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: controller.themeMode,
            defaultTransition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 300),
            initialBinding: InitialBindings(),
            initialRoute: AppRoutes.splashView,
            getPages: AppRoutes.routes,
          );
        });
      },
    );
  }
}
