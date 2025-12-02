// models/campaign_model.dart
class Campaign {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final double targetKilometers;
  final String logoPath;
  final String status;
  final int driverCount;
  final String? description;
  final double? progress;
  final double? reward;

  Campaign({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.targetKilometers,
    required this.logoPath,
    required this.status,
    required this.driverCount,
    this.description,
    this.progress,
    this.reward,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id']?.toString() ?? '',
      name: json['campaign_name'] ?? 'Unnamed Campaign',
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toString()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toString()),
      targetKilometers: (json['target_kilometers'] as num?)?.toDouble() ?? 0.0,
      logoPath: json['campaign_profile'] ?? '',
      status: json['status'] ?? 'Upcoming',
      driverCount: json['driver_count'] as int? ?? 0,
      description: json['description'],
      progress: (json['progress'] as num?)?.toDouble(),
      reward: (json['reward'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'target_kilometers': targetKilometers,
      'campaign_profile': logoPath,
      'status': status,
      'driver_count': driverCount,
      'description': description,
      'progress': progress,
      'reward': reward,
    };
  }

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isUpcoming => status.toLowerCase() == 'upcoming';
  
  bool get isJoinable => isActive || isUpcoming;
  
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  
  bool get isExpired => endDate.isBefore(DateTime.now());
  
  double get progressPercentage {
    if (progress == null || targetKilometers == 0) return 0.0;
    return (progress! / targetKilometers * 100).clamp(0.0, 100.0);
  }
}