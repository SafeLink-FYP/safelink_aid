import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/utilities/error_message.dart';

class DialogHelpers {
  static void showLoadingDialog() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  static void hideLoadingDialog() => Get.back();

  static void showSuccess({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show a failure snackbar.
  ///
  /// Either pass a friendly [message] directly, or pass the raw [error] and
  /// it will be routed through [errorMessage] so Postgres / Supabase
  /// internals never leak to the user.
  static void showFailure({
    required String title,
    String? message,
    Object? error,
  }) {
    final body = message ??
        (error != null
            ? errorMessage(error)
            : 'Something went wrong. Please try again.');
    Get.snackbar(
      title,
      body,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
