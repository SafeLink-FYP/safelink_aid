import 'package:get/get.dart';
import 'package:safelink_aid/core/services/supabase_service.dart';
import 'package:safelink_aid/features/dashboard/models/dashboard_stats_model.dart';

class DashboardService extends GetxService {
  final _supabase = SupabaseService.instance;

  Future<DashboardStatsModel> getOrgStats(String orgId) async {
    try {
      final result = await _supabase.rpc(
        'get_aid_org_stats',
        params: {'p_org_id': orgId},
      );
      if (result == null) return const DashboardStatsModel();
      return DashboardStatsModel.fromJson(result as Map<String, dynamic>);
    } catch (e) {
      Get.log('Error fetching org stats: $e');
      return const DashboardStatsModel();
    }
  }
}
