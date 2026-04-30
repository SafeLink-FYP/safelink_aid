import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/core/widgets/custom_elevated_button.dart';
import 'package:safelink_aid/features/dashboard/controllers/resource_controller.dart';

class CreateResourceView extends StatefulWidget {
  const CreateResourceView({super.key});

  @override
  State<CreateResourceView> createState() => _CreateResourceViewState();
}

class _CreateResourceViewState extends State<CreateResourceView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _qtyAvailCtrl = TextEditingController();
  final _qtyTotalCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'units');
  final _locationCtrl = TextEditingController();
  String _selectedType = 'food';
  final _isSubmitting = false.obs;

  // Must match the public.resource_type enum (food, water, medical_kits, other).
  final _resourceTypes = [
    {'value': 'food', 'label': 'Food Supplies'},
    {'value': 'water', 'label': 'Water'},
    {'value': 'medical_kits', 'label': 'Medical Kits'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _qtyAvailCtrl.dispose();
    _qtyTotalCtrl.dispose();
    _unitCtrl.dispose();
    _locationCtrl.dispose();
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
                      'Add Resource',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Add a new resource to your organization inventory',
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
                      _buildLabel(theme, 'Resource Name *'),
                      SizedBox(height: 8.h),
                      _buildField(
                        controller: _nameCtrl,
                        hint: 'e.g. Food Supplies',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                      SizedBox(height: 20.h),

                      _buildLabel(theme, 'Resource Type *'),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedType,
                            isExpanded: true,
                            items: _resourceTypes
                                .map((t) => DropdownMenuItem(
                              value: t['value'],
                              child: Text(t['label']!),
                            ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedType = v!),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      _buildLabel(theme, 'Description'),
                      SizedBox(height: 8.h),
                      _buildField(
                        controller: _descCtrl,
                        hint: 'Brief description',
                        maxLines: 3,
                      ),
                      SizedBox(height: 20.h),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(theme, 'Available *'),
                                SizedBox(height: 8.h),
                                _buildField(
                                  controller: _qtyAvailCtrl,
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    if (int.tryParse(v) == null) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 15.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(theme, 'Total *'),
                                SizedBox(height: 8.h),
                                _buildField(
                                  controller: _qtyTotalCtrl,
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    if (int.tryParse(v) == null) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      _buildLabel(theme, 'Unit'),
                      SizedBox(height: 8.h),
                      _buildField(
                        controller: _unitCtrl,
                        hint: 'e.g. units, kg, liters',
                      ),
                      SizedBox(height: 20.h),

                      _buildLabel(theme, 'Storage Location'),
                      SizedBox(height: 8.h),
                      _buildField(
                        controller: _locationCtrl,
                        hint: 'e.g. Warehouse A, Islamabad',
                      ),
                      SizedBox(height: 30.h),

                      // Submit
                      Obx(() => CustomElevatedButton(
                            label: 'Add Resource',
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

    final available = int.parse(_qtyAvailCtrl.text.trim());
    final total = int.parse(_qtyTotalCtrl.text.trim());
    if (available > total) {
      Get.snackbar(
        'Invalid quantities',
        'Available cannot exceed Total. Adjust the values and try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _isSubmitting.value = true;
    try {
      await Get.find<ResourceController>().createResource(
        name: _nameCtrl.text.trim(),
        resourceType: _selectedType,
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        quantityAvailable: available,
        quantityTotal: total,
        unit: _unitCtrl.text.trim().isEmpty ? 'units' : _unitCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
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
