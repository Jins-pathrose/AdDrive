class ActivecampaignModel {
  final int id;
  final String campaignName;
  final String startDate;
  final String endDate;
  final String status;
  final String? campaignProfile;

  ActivecampaignModel({
    required this.id,
    required this.campaignName,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.campaignProfile,
  });

  factory ActivecampaignModel.fromJson(Map<String, dynamic> json) {
    return ActivecampaignModel(
      id: json['id'],
      campaignName: json['campaign_name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      campaignProfile: json['campaign_profile'],
    );
  }
}