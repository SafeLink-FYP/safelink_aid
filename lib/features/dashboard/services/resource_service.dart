import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/features/dashboard/models/resource_model.dart';

class ResourceService extends GetxService {
  final _supabase = SupabaseService.instance;

  /// RLS ensures only org resources are returned
  Future<List<ResourceModel>> getOrgResources() async {
    final data = await _supabase.resources
        .select()
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => ResourceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ResourceModel?> getResourceById(String id) async {
    final data =
    await _supabase.resources.select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return ResourceModel.fromJson(data);
  }

  Future<ResourceModel> createResource(ResourceModel resource) async {
    final data = await _supabase.resources
        .insert(resource.toInsertJson())
        .select()
        .single();
    return ResourceModel.fromJson(data);
  }

  Future<ResourceModel> updateResource(
      String id,
      Map<String, dynamic> updates,
      ) async {
    final data = await _supabase.resources
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return ResourceModel.fromJson(data);
  }

  Future<void> deleteResource(String id) async {
    await _supabase.resources.delete().eq('id', id);
  }
}
