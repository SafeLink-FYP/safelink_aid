import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/features/authorization/presentation/widgets/custom_text_form_field.dart';

class DatePickerTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final Color? backgroundColor;
  final Color? iconColor;
  final TextInputType? keyboardType;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  /// Called with the ISO-8601 date string (YYYY-MM-DD) when the user picks a date.
  /// Use this value when sending the date to the backend.
  final void Function(String isoDate)? onDateSelected;

  /// Initial date the picker opens on. Defaults to ~25 years ago, which is
  /// a sane DOB landing point. Override for non-DOB use cases.
  final DateTime? defaultDate;

  const DatePickerTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.backgroundColor,
    this.keyboardType,
    required this.icon,
    this.iconColor,
    this.validator,
    this.onDateSelected,
    this.defaultDate,
  });

  Future<void> _selectDate(BuildContext context) async {
    final theme = Get.theme;
    final now = DateTime.now();
    final initial = defaultDate ??
        DateTime(now.year - 25, now.month, now.day);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select Date',
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              confirmButtonStyle: TextButton.styleFrom(
                textStyle: theme.textTheme.labelSmall,
              ),
              cancelButtonStyle: TextButton.styleFrom(
                textStyle: theme.textTheme.labelSmall,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Display-friendly format kept in the visible text field
      controller.text =
          '${pickedDate.day} ${_monthName(pickedDate.month)}, ${pickedDate.year}';

      // ISO 8601 format for backend storage
      final iso =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      onDateSelected?.call(iso);
    }
  }

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: CustomTextFormField(
          label: label,
          hintText: hintText,
          icon: icon,
          controller: controller,
          validator: validator,
        ),
      ),
    );
  }
}
