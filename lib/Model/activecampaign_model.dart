class ActivecampaignModel {
  final int id;
  final String campaignName;
  final String startDate;
  final String endDate;
  final String status;
  final String? campaignProfile;
  final int? targetKilometers; // Add this field

  ActivecampaignModel({
    required this.id,
    required this.campaignName,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.campaignProfile,
    this.targetKilometers, // Add this
  });

  factory ActivecampaignModel.fromJson(Map<String, dynamic> json) {
    return ActivecampaignModel(
      id: json['id'],
      campaignName: json['campaign_name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      campaignProfile: json['campaign_profile'],
      targetKilometers: json['target_kilometers'], // Add this
    );
  }
}