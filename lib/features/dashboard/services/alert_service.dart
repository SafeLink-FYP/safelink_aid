import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';

class AlertService extends GetxService {
  final _supabase = SupabaseService.instance;

  /// Read-only — aid workers can view active alerts but not create/manage them
  Future<List<Map<String, dynamic>>> getActiveAlerts() async {
    final data = await _supabase.alerts
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getAlertById(String id) async {
    final data =
        await _supabase.alerts.select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }
}
