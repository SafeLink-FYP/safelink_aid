import 'dart:math';
import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/features/dashboard/models/team_model.dart';
import 'package:safelink_aid/features/dashboard/models/team_member_model.dart';

class TeamService extends GetxService {
  final _supabase = SupabaseService.instance;

  static const _codeChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  String _generateTeamCode() {
    final rng = Random.secure();
    return List.generate(6, (_) => _codeChars[rng.nextInt(_codeChars.length)])
        .join();
  }

  Future<TeamModel?> getTeamById(String id) async {
    final data = await _supabase.teams.select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return TeamModel.fromJson(data);
  }

  Future<TeamModel> createTeam({
    required String name,
    required String organizationId,
    String? description,
    List<String> specialization = const [],
    String? region,
    double? latitude,
    double? longitude,
    int capacity = 10,
  }) async {
    final userId = _supabase.userId!;
    final teamCode = _generateTeamCode();

    final data = await _supabase.teams
        .insert({
          'name': name,
          'description': description,
          'team_lead_id': null,
          'organization_id': organizationId,
          'specialization': specialization,
          'region': region,
          'latitude': latitude,
          'longitude': longitude,
          'capacity': capacity,
          'status': 'available',
          'created_by': userId,
          'is_approved': false,
          'team_code': teamCode,
        })
        .select()
        .single();
    return TeamModel.fromJson(data);
  }

  Future<List<TeamMemberModel>> getTeamMembers(String teamId) async {
    final data = await _supabase.teamMembers
        .select(
          '*, profiles!team_members_user_id_fkey(full_name, phone, avatar_url)',
        )
        .eq('team_id', teamId)
        .eq('is_active', true)
        .order('joined_at');
    return (data as List)
        .map((e) => TeamMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> removeMember(String memberId) async {
    await _supabase.teamMembers
        .update({'is_active': false}).eq('id', memberId);
  }
}
