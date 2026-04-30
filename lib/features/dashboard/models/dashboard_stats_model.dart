/// Mirrors the JSON shape returned by the `get_aid_org_stats(p_org_id)` RPC.
class DashboardStatsModel {
  final int totalRequestsAssigned;
  final int activeRequests;
  final int fulfilledRequests;
  final int totalTeams;
  final int deployedTeams;
  final int totalMembers;
  final int totalResources;
  final int resourcesAvailable;

  const DashboardStatsModel({
    this.totalRequestsAssigned = 0,
    this.activeRequests = 0,
    this.fulfilledRequests = 0,
    this.totalTeams = 0,
    this.deployedTeams = 0,
    this.totalMembers = 0,
    this.totalResources = 0,
    this.resourcesAvailable = 0,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      DashboardStatsModel(
        totalRequestsAssigned:
            (json['total_requests_assigned'] as num?)?.toInt() ?? 0,
        activeRequests: (json['active_requests'] as num?)?.toInt() ?? 0,
        fulfilledRequests:
            (json['fulfilled_requests'] as num?)?.toInt() ?? 0,
        totalTeams: (json['total_teams'] as num?)?.toInt() ?? 0,
        deployedTeams: (json['deployed_teams'] as num?)?.toInt() ?? 0,
        totalMembers: (json['total_members'] as num?)?.toInt() ?? 0,
        totalResources: (json['total_resources'] as num?)?.toInt() ?? 0,
        resourcesAvailable:
            (json['resources_available'] as num?)?.toInt() ?? 0,
      );
}
