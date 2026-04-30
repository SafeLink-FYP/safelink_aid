import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  static SupabaseService get instance => _instance;

  final SupabaseClient client = Supabase.instance.client;

  GoTrueClient get auth => client.auth;

  User? get currentUser => client.auth.currentUser;

  String? get userId => currentUser?.id;

  bool get isLoggedIn => currentUser != null;

  SupabaseQueryBuilder get profiles => client.from('profiles');

  SupabaseQueryBuilder get aidWorkerProfiles =>
      client.from('aid_worker_profiles');

  SupabaseQueryBuilder get aidOrganizations => client.from('aid_organizations');

  SupabaseQueryBuilder get alerts => client.from('alerts');

  SupabaseQueryBuilder get aidRequests => client.from('aid_requests');

  SupabaseQueryBuilder get aidRequestTimeline =>
      client.from('aid_request_timeline');

  SupabaseQueryBuilder get teams => client.from('teams');

  SupabaseQueryBuilder get teamMembers => client.from('team_members');

  SupabaseQueryBuilder get resources => client.from('resources');

  SupabaseQueryBuilder get resourceAllocations =>
      client.from('resource_allocations');

  SupabaseQueryBuilder get notifications => client.from('notifications');

  SupabaseStorageClient get storage => client.storage;

  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) {
    return client.rpc(functionName, params: params);
  }
}
