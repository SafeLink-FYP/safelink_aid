class TeamMemberModel {
  final String id;
  final String teamId;
  final String userId;
  final String role;
  final bool isActive;
  final String? joinedAt;

  final String? userName;
  final String? userPhone;
  final String? avatarUrl;

  const TeamMemberModel({
    required this.id,
    required this.teamId,
    required this.userId,
    this.role = 'member',
    this.isActive = true,
    this.joinedAt,
    this.userName,
    this.userPhone,
    this.avatarUrl,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    String? userName;
    String? userPhone;
    String? avatar;
    final profile = json['profiles'];
    if (profile is Map<String, dynamic>) {
      userName = profile['full_name'] as String?;
      userPhone = profile['phone'] as String?;
      avatar = profile['avatar_url'] as String?;
    }
    return TeamMemberModel(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      isActive: json['is_active'] as bool? ?? true,
      joinedAt: json['joined_at'] as String?,
      userName: userName,
      userPhone: userPhone,
      avatarUrl: avatar,
    );
  }

}
