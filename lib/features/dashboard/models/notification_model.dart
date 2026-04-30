class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String notificationType;
  final String? referenceId;
  final String? referenceType;
  final bool isRead;
  final String? createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.notificationType,
    this.referenceId,
    this.referenceType,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        notificationType: json['notification_type'] as String? ?? 'system',
        referenceId: json['reference_id'] as String?,
        referenceType: json['reference_type'] as String?,
        isRead: json['is_read'] as bool? ?? false,
        createdAt: json['created_at'] as String?,
      );

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id,
    userId: userId,
    title: title,
    body: body,
    notificationType: notificationType,
    referenceId: referenceId,
    referenceType: referenceType,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );

  String get timeAgo {
    if (createdAt == null) return '';
    final created = DateTime.tryParse(createdAt!);
    if (created == null) return '';
    final diff = DateTime.now().difference(created);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
