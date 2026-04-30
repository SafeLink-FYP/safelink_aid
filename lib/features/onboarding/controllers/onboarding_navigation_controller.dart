import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/cache_service.dart';
import 'package:safelink_aid/core/utilities/app_routes.dart';

class OnboardingNavigationController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  void nextPage() {
    if (currentPage.value == 2) {
      _complete();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() => _complete();

  Future<void> _complete() async {
    await CacheService.instance.setOnboardingComplete();
    Get.offAllNamed(AppRoutes.signInView);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
