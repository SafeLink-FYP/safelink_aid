import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safelink_aid/core/themes/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Compact, lite-mode-on-Android Google Map showing a single pin for a
/// dispatched aid request. Tap opens the device's native maps app.
///
/// Caller must check the request has both lat and lng before rendering this
/// widget — there is no in-widget fallback for missing coordinates.
class CaseLocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String title;
  final String? snippet;

  const CaseLocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.snippet,
  });

  Future<void> _openExternal() async {
    final List<Uri> candidates;
    if (!kIsWeb && Platform.isIOS) {
      candidates = [
        Uri.parse('maps://?q=$latitude,$longitude'),
        Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'),
      ];
    } else if (!kIsWeb && Platform.isAndroid) {
      candidates = [
        Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude'),
        Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'),
      ];
    } else {
      candidates = [
        Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'),
      ];
    }
    for (final uri in candidates) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final position = LatLng(latitude, longitude);
    final marker = Marker(
      markerId: const MarkerId('case_location'),
      position: position,
      infoWindow: InfoWindow(title: title, snippet: snippet),
    );

    final useLite = !kIsWeb && Platform.isAndroid;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 180.h,
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
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: position, zoom: 15),
              markers: {marker},
              liteModeEnabled: useLite,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              // Lite mode swallows gestures already; on iOS we keep them off
              // to preserve the static feel and route taps through the
              // overlay below.
              gestureRecognizers: const {},
              onMapCreated: (_) {},
            ),
            // Transparent tap layer above the map so a single tap always
            // opens the native maps app, regardless of platform.
            Positioned.fill(
              child: Material(
                color: AppTheme.transparentColor,
                child: InkWell(
                  onTap: _openExternal,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
