// models/completed_campaign_model.dart
import 'package:intl/intl.dart';
class CompletedCampaign {
  final String campaignId;
  final String campaignName;
  final DateTime startDate;
  final DateTime endDate;
  final double targetKilometers;
  final double targetRewardAmount;
  final double additionalPaymentPerKm;
  final String status;
  final DateTime joinedAt;
  final double totalKilometers;
  final double totalEarnedAmount;
  final double bonusEarnedAmount;
  final String progressStatus;

  CompletedCampaign({
    required this.campaignId,
    required this.campaignName,
    required this.startDate,
    required this.endDate,
    required this.targetKilometers,
    required this.targetRewardAmount,
    required this.additionalPaymentPerKm,
    required this.status,
    required this.joinedAt,
    required this.totalKilometers,
    required this.totalEarnedAmount,
    required this.bonusEarnedAmount,
    required this.progressStatus,
  });

  factory CompletedCampaign.fromJson(Map<String, dynamic> json) {
    final campaign = json['campaign'] ?? {};
    final participation = json['participation'] ?? {};

    return CompletedCampaign(
      campaignId: campaign['id']?.toString() ?? '',
      campaignName: campaign['campaign_name'] ?? 'Unnamed Campaign',
      startDate: DateTime.parse(campaign['start_date'] ?? DateTime.now().toString()),
      endDate: DateTime.parse(campaign['end_date'] ?? DateTime.now().toString()),
      targetKilometers: (campaign['target_kilometers'] as num?)?.toDouble() ?? 0.0,
      targetRewardAmount: (campaign['target_reward_amount'] as num?)?.toDouble() ?? 0.0,
      additionalPaymentPerKm: (campaign['additional_payment_per_km'] as num?)?.toDouble() ?? 0.0,
      status: campaign['status'] ?? 'inactive',
      joinedAt: DateTime.parse(participation['joined_at'] ?? DateTime.now().toString()),
      totalKilometers: (participation['total_kilometers'] as num?)?.toDouble() ?? 0.0,
      totalEarnedAmount: (participation['total_earned_amount'] as num?)?.toDouble() ?? 0.0,
      bonusEarnedAmount: (participation['bonus_earned_amount'] as num?)?.toDouble() ?? 0.0,
      progressStatus: participation['progress_status'] ?? 'completed',
    );
  }

  String get formattedStartDate {
    return DateFormat('MMM dd, yyyy').format(startDate);
  }

  String get formattedEndDate {
    return DateFormat('MMM dd, yyyy').format(endDate);
  }

  String get formattedJoinedAt {
    return DateFormat('MMM dd, yyyy').format(joinedAt);
  }

  String get formattedTargetKm {
    return '${targetKilometers.toStringAsFixed(0)} km';
  }

  String get formattedTotalKm {
    return '${totalKilometers.toStringAsFixed(1)} km';
  }

  String get formattedEarnedAmount {
    return '₹${totalEarnedAmount.toStringAsFixed(0)}';
  }

  String get formattedBonusAmount {
    return '₹${bonusEarnedAmount.toStringAsFixed(0)}';
  }
}