class FleetCampaign {
  final String campaignId;
  final String campaignName;
  final String status;
  final double targetKilometers;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime assignedAt;
  final String fleetName;

  FleetCampaign({
    required this.campaignId,
    required this.campaignName,
    required this.status,
    required this.targetKilometers,
    required this.startDate,
    required this.endDate,
    required this.assignedAt,
    required this.fleetName,
  });

  factory FleetCampaign.fromJson(Map<String, dynamic> json, String fleetName) {
    return FleetCampaign(
      campaignId: json['campaign_id'].toString(),
      campaignName: json['campaign_name'] ?? '',
      status: json['status'] ?? '',
      targetKilometers: (json['target_kilometers'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      assignedAt: DateTime.parse(json['assigned_at']),
      fleetName: fleetName,
    );
  }
}