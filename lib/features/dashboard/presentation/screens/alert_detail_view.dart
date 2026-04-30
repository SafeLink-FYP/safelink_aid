import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/dashboard/controllers/alert_controller.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/case_location_map.dart';

class AlertDetailView extends StatefulWidget {
  const AlertDetailView({super.key});

  @override
  State<AlertDetailView> createState() => _AlertDetailViewState();
}

class _AlertDetailViewState extends State<AlertDetailView> {
  final AlertController _ctrl = Get.find<AlertController>();

  @override
  void initState() {
    super.initState();
    final id = Get.arguments as String?;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ctrl.selectAlert(id);
      });
    }
  }

  Color _severityColor(String s) {
    switch (s.toLowerCase()) {
      case 'critical':
        return AppTheme.red;
      case 'high':
        return AppTheme.orange;
      case 'medium':
        return AppTheme.primaryColor;
      case 'low':
      default:
        return AppTheme.green;
    }
  }

  IconData _typeIcon(String t) {
    switch (t.toLowerCase()) {
      case 'flood':
        return Icons.water;
      case 'earthquake':
        return Icons.landscape;
      case 'medical':
        return Icons.medical_services_outlined;
      case 'other':
      default:
        return Icons.warning_amber_rounded;
    }
  }

  String _friendlyDate(String? iso) {
    if (iso == null) return '—';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final a = _ctrl.selectedAlert.value;
          if (a == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final severity = (a['severity'] as String?) ?? 'medium';
          final title = (a['title'] as String?) ?? 'Alert';
          final description = (a['description'] as String?) ?? '';
          final type = (a['disaster_type'] as String?) ?? 'other';
          final location = a['location'] as String?;
          final lat = (a['latitude'] as num?)?.toDouble();
          final lng = (a['longitude'] as num?)?.toDouble();
          final radius = (a['radius_km'] as num?)?.toInt();
          final createdAt = a['created_at'] as String?;
          final isActive = a['is_active'] as bool? ?? true;
          final color = _severityColor(severity);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: AppTheme.white),
                            ),
                          ),
                          _severityChip(theme, severity, color),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Icon(_typeIcon(type),
                              size: 18.sp, color: AppTheme.white),
                          SizedBox(width: 6.w),
                          Text(
                            type
                                .replaceAll('_', ' ')
                                .capitalizeFirst!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.white.withValues(alpha: 0.9),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          if (!isActive)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppTheme.white.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Inactive',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(25.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(theme, 'Description'),
                      SizedBox(height: 12.h),
                      _card(
                        theme,
                        Text(
                          description.isEmpty
                              ? 'No description provided.'
                              : description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      _sectionTitle(theme, 'Location'),
                      SizedBox(height: 12.h),
                      _card(
                        theme,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _kv(theme, 'Address',
                                location ?? 'Not specified'),
                            if (radius != null) ...[
                              SizedBox(height: 4.h),
                              _kv(theme, 'Radius', '$radius km'),
                            ],
                          ],
                        ),
                      ),
                      if (lat != null && lng != null) ...[
                        SizedBox(height: 12.h),
                        CaseLocationMap(
                          latitude: lat,
                          longitude: lng,
                          title: title,
                          snippet: location,
                        ),
                      ],

                      SizedBox(height: 20.h),

                      _sectionTitle(theme, 'Issued'),
                      SizedBox(height: 12.h),
                      _card(
                        theme,
                        _kv(theme, 'At', _friendlyDate(createdAt)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _severityChip(ThemeData theme, String severity, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(
        severity.capitalizeFirst!,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String label) =>
      Text(label, style: theme.textTheme.headlineLarge);

  Widget _card(ThemeData theme, Widget child) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: theme.dividerColor, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withValues(alpha: 0.04),
              offset: const Offset(0, 2),
              blurRadius: 8.r,
            ),
          ],
        ),
        child: child,
      );

  Widget _kv(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: theme.textTheme.bodyMedium),
        SizedBox(width: 10.w),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.headlineMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
