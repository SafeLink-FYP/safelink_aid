import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:safelink_aid/features/dashboard/controllers/aid_request_controller.dart';
import 'package:safelink_aid/features/dashboard/presentation/widgets/case_location_map.dart';

class RequestDetailView extends StatefulWidget {
  const RequestDetailView({super.key});

  @override
  State<RequestDetailView> createState() => _RequestDetailViewState();
}

class _RequestDetailViewState extends State<RequestDetailView> {
  final AidRequestController _ctrl = Get.find<AidRequestController>();

  @override
  void initState() {
    super.initState();
    final requestId = Get.arguments as String?;
    if (requestId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ctrl.selectRequest(requestId);
      });
    }
  }

  Future<void> _showRejectDialog(String requestId) async {
    final reasonCtrl = TextEditingController();
    // Drives both the live counter and the Confirm-button enabled state.
    final length = ValueNotifier<int>(0);
    const minLength = 10;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell the requester why this case was rejected. They\'ll see this '
              'reason in their notification.',
              style: Theme.of(Get.context!).textTheme.bodyMedium,
            ),
            SizedBox(height: 12.h),
            ValueListenableBuilder<int>(
              valueListenable: length,
              builder: (_, count, __) => TextField(
                controller: reasonCtrl,
                autofocus: true,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                onChanged: (v) => length.value = v.trim().length,
                decoration: InputDecoration(
                  hintText: 'e.g. Out of stock for this aid type.',
                  helperText: '$count / $minLength characters minimum',
                  helperStyle: TextStyle(
                    color: count >= minLength
                        ? AppTheme.green
                        : AppTheme.red.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ValueListenableBuilder<int>(
            valueListenable: length,
            builder: (_, count, __) => TextButton(
              onPressed: count >= minLength
                  ? () => Get.back(result: true)
                  : null,
              child: const Text('Confirm Reject'),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      // Await the controller before letting the dialog close path complete,
      // so the rejection_reason is persisted before the screen reacts via
      // Obx and the action button row vanishes.
      await _ctrl.rejectRequest(requestId, reason: reasonCtrl.text.trim());
    }
    reasonCtrl.dispose();
    length.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final ctrl = _ctrl;

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final req = ctrl.selectedRequest.value;
          if (req == null) {
            return const Center(child: CircularProgressIndicator());
          }

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
                        children: [
                          Expanded(
                            child: Text(
                              req.aidTypeDisplay,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                          _statusChip(theme, req.status, req.statusDisplay),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        req.timeAgo,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(25.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Requester Section
                      _sectionTitle(theme, 'Requester Information'),
                      SizedBox(height: 15.h),
                      _infoCard(theme, [
                        _infoRow(theme, 'Name', req.userName ?? 'Unknown'),
                        _infoRow(theme, 'Phone', req.userPhone ?? 'N/A'),
                      ]),

                      SizedBox(height: 25.h),

                      // Location Section
                      _sectionTitle(theme, 'Location'),
                      SizedBox(height: 15.h),
                      _infoCard(theme, [
                        _infoRow(
                            theme, 'Address', req.address ?? 'Not specified'),
                      ]),
                      if (req.latitude != null && req.longitude != null) ...[
                        SizedBox(height: 12.h),
                        CaseLocationMap(
                          latitude: req.latitude!,
                          longitude: req.longitude!,
                          title: req.aidTypeDisplay,
                          snippet: req.address,
                        ),
                      ],

                      SizedBox(height: 25.h),

                      // Request Details
                      _sectionTitle(theme, 'Request Details'),
                      SizedBox(height: 15.h),
                      _infoCard(theme, [
                        _infoRow(theme, 'Aid Type', req.aidTypeDisplay),
                        _infoRow(theme, 'Urgency',
                            req.urgency.capitalizeFirst ?? req.urgency),
                        _infoRow(theme, 'Quantity', '${req.quantity}'),
                        _infoRow(
                            theme, 'People Affected', '${req.peopleAffected}'),
                      ]),

                      SizedBox(height: 25.h),

                      // Description
                      _sectionTitle(theme, 'Description'),
                      SizedBox(height: 15.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15.r),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                              color: theme.dividerColor, width: 1.w),
                        ),
                        child: Text(
                          req.description.isEmpty
                              ? 'No description provided.'
                              : req.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),

                      SizedBox(height: 25.h),

                      // Images
                      if (req.imageUrls.isNotEmpty) ...[
                        _sectionTitle(theme, 'Attached Images'),
                        SizedBox(height: 15.h),
                        SizedBox(
                          height: 120.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: req.imageUrls.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(width: 10.w),
                            itemBuilder: (_, i) => InkWell(
                              onTap: () => _openImageViewer(req.imageUrls, i),
                              borderRadius: BorderRadius.circular(10.r),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Image.network(
                                  req.imageUrls[i],
                                  width: 120.w,
                                  height: 120.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 120.w,
                                    height: 120.h,
                                    color: theme.dividerColor,
                                    child: Icon(Icons.broken_image,
                                        size: 30.sp),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 25.h),
                      ],

                      // Timeline
                      _sectionTitle(theme, 'Timeline'),
                      SizedBox(height: 15.h),
                      Obx(() {
                        if (ctrl.timeline.isEmpty) {
                          return Text('No timeline data available.',
                              style: theme.textTheme.bodyMedium);
                        }
                        return Column(
                          children: ctrl.timeline.map((entry) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 10.w,
                                    height: 10.h,
                                    margin: EdgeInsets.only(top: 5.h),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (entry['status'] as String?)
                                              ?.replaceAll('_', ' ')
                                              .capitalizeFirst ??
                                              '',
                                          style: theme
                                              .textTheme.headlineMedium,
                                        ),
                                        Text(
                                          _friendlyTime(
                                              entry['created_at'] as String?),
                                          style:
                                          theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }),

                      SizedBox(height: 25.h),

                      // Action Buttons
                      Obx(() {
                        final status =
                            ctrl.selectedRequest.value?.status ?? '';
                        return Column(
                          children: [
                            if (status == 'pending')
                              _actionButton(
                                theme: theme,
                                label: 'Mark In Progress',
                                gradient: AppTheme.primaryGradient,
                                onTap: () =>
                                    ctrl.markInProgress(req.id),
                              ),
                            if (status == 'in_progress') ...[
                              _actionButton(
                                theme: theme,
                                label: 'Mark as Fulfilled',
                                gradient: AppTheme.greenGradient,
                                onTap: () =>
                                    ctrl.fulfillRequest(req.id),
                              ),
                              SizedBox(height: 10.h),
                              _actionButton(
                                theme: theme,
                                label: 'Reject Request',
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.red,
                                    AppTheme.red.withValues(alpha: 0.8),
                                  ],
                                ),
                                onTap: () => _showRejectDialog(req.id),
                              ),
                            ],
                          ],
                        );
                      }),
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

  Widget _sectionTitle(ThemeData theme, String title) {
    return Text(title, style: theme.textTheme.headlineLarge);
  }

  Widget _infoCard(ThemeData theme, List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: theme.textTheme.bodyMedium),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.headlineMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Status badge shown on the gradient header. Tinted-pill pattern with a
  /// translucent background so the chip reads cleanly on the gradient
  /// regardless of theme.
  Widget _statusChip(ThemeData theme, String status, String label) {
    Color color;
    switch (status) {
      case 'pending':
        color = AppTheme.orange;
        break;
      case 'in_progress':
        color = theme.primaryColor;
        break;
      case 'fulfilled':
        color = AppTheme.green;
        break;
      case 'rejected':
        color = AppTheme.red;
        break;
      case 'cancelled':
        // Fixed grey instead of theme.hintColor so contrast doesn't collapse
        // in dark mode.
        color = Colors.grey.shade500;
        break;
      default:
        color = AppTheme.white;
    }
    // On the gradient header background we keep a white-tinted pill so the
    // text colour pops. Border in the same color for definition.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// "5m ago · Apr 28, 14:23" — relative on top, absolute as context.
  String _friendlyTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    final String relative;
    if (diff.inMinutes < 1) {
      relative = 'just now';
    } else if (diff.inMinutes < 60) {
      relative = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      relative = '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      relative = '${diff.inDays}d ago';
    } else {
      relative = '${(diff.inDays / 7).floor()}w ago';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final absolute = '${months[dt.month - 1]} ${dt.day}, $hh:$mm';
    return '$relative · $absolute';
  }

  /// Full-screen image viewer with pinch-to-zoom and pan via the built-in
  /// InteractiveViewer (no external dep).
  void _openImageViewer(List<String> urls, int initialIndex) {
    final controller = PageController(initialPage: initialIndex);
    Get.dialog(
      Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: urls.length,
              itemBuilder: (_, i) => InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    urls[i],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16.h,
              right: 16.w,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required ThemeData theme,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: AppTheme.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
