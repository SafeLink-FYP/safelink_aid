import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/features/dashboard/models/notification_model.dart';

class NotificationService extends GetxService {
  final _supabase = SupabaseService.instance;

  Future<List<NotificationModel>> getMyNotifications() async {
    final userId = _supabase.userId;
    if (userId == null) return [];
    final data = await _supabase.notifications
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final userId = _supabase.userId;
    if (userId == null) return 0;
    final data = await _supabase.notifications
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);
    return (data as List).length;
  }

  Future<void> markAsRead(String id) async {
    await _supabase.notifications.update({'is_read': true}).eq('id', id);
  }

  Future<void> markAllAsRead() async {
    final userId = _supabase.userId;
    if (userId == null) return;
    await _supabase.notifications
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }
}
