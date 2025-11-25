// In your profiledata_model.dart
import 'package:addrive/Model/bankdetails_model.dart';
import 'package:addrive/Model/personaldata_model.dart';

class ProfileData {
  final Profile profile;
  final Map<String, dynamic> vehicleDetails;
  final BankDetails? bankDetails;
  final Map<String, dynamic>? fleetDetails;

  ProfileData({
    required this.profile,
    required this.vehicleDetails,
    this.bankDetails,
    this.fleetDetails,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      profile: Profile.fromJson(json['profile']),
      vehicleDetails: json['vehicle_details'] ?? {},
      bankDetails: json['bank_details'] != null ? BankDetails.fromJson(json['bank_details']) : null,
      fleetDetails: json['fleet_details'] ?? {},
    );
  }
}