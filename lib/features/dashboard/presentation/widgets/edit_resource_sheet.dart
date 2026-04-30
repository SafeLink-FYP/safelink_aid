import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/widgets/custom_elevated_button.dart';
import 'package:safelink_aid/features/dashboard/controllers/resource_controller.dart';
import 'package:safelink_aid/features/dashboard/models/resource_model.dart';

/// Bottom-sheet quick-edit for a single resource. Scope intentionally
/// narrow — name, resource_type and unit are read-only headers; only the
/// operationally meaningful fields are editable. The path for renaming or
/// retyping a resource is delete + recreate, which forces a deliberate
/// action.
Future<void> showEditResourceSheet(
  BuildContext context,
  ResourceModel resource,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => _EditResourceSheet(resource: resource),
  );
}

class _EditResourceSheet extends StatefulWidget {
  final ResourceModel resource;
  const _EditResourceSheet({required this.resource});

  @override
  State<_EditResourceSheet> createState() => _EditResourceSheetState();
}

class _EditResourceSheetState extends State<_EditResourceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _availCtrl;
  late final TextEditingController _totalCtrl;
  late final TextEditingController _locCtrl;
  final _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    // Pre-populate with current values so the user only types what they're
    // changing, not retyping every field.
    _availCtrl =
        TextEditingController(text: widget.resource.quantityAvailable.toString());
    _totalCtrl =
        TextEditingController(text: widget.resource.quantityTotal.toString());
    _locCtrl = TextEditingController(text: widget.resource.location ?? '');
  }

  @override
  void dispose() {
    _availCtrl.dispose();
    _totalCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSubmitting.value) return;
    if (!_formKey.currentState!.validate()) return;

    final available = int.parse(_availCtrl.text.trim());
    final total = int.parse(_totalCtrl.text.trim());
    if (available > total) {
      Get.snackbar(
        'Invalid quantities',
        'Available cannot exceed Total. Adjust the values and try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final loc = _locCtrl.text.trim();
    final updates = <String, dynamic>{
      'quantity_available': available,
      'quantity_total': total,
      'location': loc.isEmpty ? null : loc,
    };

    _isSubmitting.value = true;
    try {
      await Get.find<ResourceController>().updateResource(
        widget.resource.id,
        updates,
      );
      if (mounted) Get.back();
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  Future<void> _confirmAndDelete() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete "${widget.resource.name}"?'),
        content: const Text(
          'This removes the resource from your inventory. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppTheme.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await Get.find<ResourceController>().deleteResource(widget.resource.id);
    if (mounted) Get.back(); // close the bottom sheet too
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = widget.resource;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(25.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      r.name,
                      style: theme.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                '${r.resourceTypeDisplay}  ·  unit: ${r.unit}',
                style: theme.textTheme.bodySmall,
              ),
              SizedBox(height: 20.h),

              _label(theme, 'Available *'),
              SizedBox(height: 8.h),
              _qtyField(
                controller: _availCtrl,
                hint: '0',
              ),
              SizedBox(height: 16.h),

              _label(theme, 'Total *'),
              SizedBox(height: 8.h),
              _qtyField(
                controller: _totalCtrl,
                hint: '0',
              ),
              SizedBox(height: 16.h),

              _label(theme, 'Storage Location'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _locCtrl,
                decoration: _decoration(theme, 'e.g. Warehouse A, Islamabad'),
              ),
              SizedBox(height: 24.h),

              Obx(() => CustomElevatedButton(
                    label: 'Save Changes',
                    isLoading: _isSubmitting.value,
                    onPressed: _save,
                  )),
              SizedBox(height: 12.h),

              Center(
                child: TextButton.icon(
                  onPressed: _confirmAndDelete,
                  icon: Icon(Icons.delete_outline,
                      size: 18.sp, color: AppTheme.red),
                  label: Text(
                    'Delete resource',
                    style: TextStyle(
                      color: AppTheme.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(ThemeData theme, String text) =>
      Text(text, style: theme.textTheme.headlineMedium);

  Widget _qtyField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: _decoration(Theme.of(context), hint),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        final n = int.tryParse(v);
        if (n == null) return 'Enter a number';
        if (n < 0) return 'Cannot be negative';
        return null;
      },
    );
  }

  InputDecoration _decoration(ThemeData theme, String hint) {
    return InputDecoration(
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
    );
  }
}
