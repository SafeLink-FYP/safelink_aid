import 'dart:async';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/features/dashboard/models/notification_model.dart';
import 'package:safelink_aid/features/dashboard/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show
        AuthChangeEvent,
        AuthState,
        PostgresChangeEvent,
        PostgresChangeFilter,
        PostgresChangeFilterType,
        RealtimeChannel;

class NotificationController extends GetxController {
  final NotificationService _service = Get.find<NotificationService>();

  final isLoading = false.obs;
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;

  String? _lastSeenUserId;
  StreamSubscription<AuthState>? _authSub;
  RealtimeChannel? _channel;

  @override
  void onInit() {
    super.onInit();
    _lastSeenUserId = SupabaseService.instance.currentUser?.id;
    _authSub = SupabaseService.instance.auth.onAuthStateChange
        .listen(_onAuthChange);
    loadNotifications();
    if (_lastSeenUserId != null) _subscribeRealtime(_lastSeenUserId!);
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _unsubscribeRealtime();
    super.onClose();
  }

  void _onAuthChange(AuthState state) {
    final newUserId = state.session?.user.id;
    switch (state.event) {
      case AuthChangeEvent.signedIn:
        if (newUserId == _lastSeenUserId) return;
        _lastSeenUserId = newUserId;
        _clearLocal();
        _unsubscribeRealtime();
        loadNotifications();
        if (newUserId != null) _subscribeRealtime(newUserId);
        break;
      case AuthChangeEvent.signedOut:
        _lastSeenUserId = null;
        _clearLocal();
        _unsubscribeRealtime();
        break;
      default:
        break;
    }
  }

  void _clearLocal() {
    notifications.clear();
    unreadCount.value = 0;
  }

  /// Subscribes to INSERT + UPDATE postgres_changes on `notifications` for
  /// this user. Inserts prepend; updates replace by id and recompute unread.
  /// DELETE intentionally not handled — current app has no deletion path.
  void _subscribeRealtime(String userId) {
    _channel = SupabaseService.instance.client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final row = payload.newRecord;
            try {
              final model = NotificationModel.fromJson(row);
              if (notifications.any((n) => n.id == model.id)) return;
              notifications.insert(0, model);
              if (!model.isRead) unreadCount.value = unreadCount.value + 1;
            } catch (e) {
              Get.log('Realtime INSERT decode failed: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final row = payload.newRecord;
            try {
              final model = NotificationModel.fromJson(row);
              final idx = notifications.indexWhere((n) => n.id == model.id);
              if (idx >= 0) {
                notifications[idx] = model;
                unreadCount.value =
                    notifications.where((n) => !n.isRead).length;
              }
            } catch (e) {
              Get.log('Realtime UPDATE decode failed: $e');
            }
          },
        )
        .subscribe();
  }

  void _unsubscribeRealtime() {
    final ch = _channel;
    if (ch == null) return;
    SupabaseService.instance.client.removeChannel(ch);
    _channel = null;
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      notifications.value = await _service.getMyNotifications();
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    } catch (e) {
      Get.log('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _service.markAsRead(id);
      final idx = notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        notifications[idx] = notifications[idx].copyWith(isRead: true);
      }
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    } catch (e) {
      Get.log('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      notifications.value =
          notifications.map((n) => n.copyWith(isRead: true)).toList();
      unreadCount.value = 0;
    } catch (e) {
      Get.log('Error marking all as read: $e');
    }
  }

  Future<void> refreshNotifications() => loadNotifications();
}
