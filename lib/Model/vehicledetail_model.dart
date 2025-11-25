class VehicleDetails {
  final int id;
  final int driverId;
  final String vehicleNumber;
  final String vehicleModel;
  final String ownerName;
  final String frontView;
  final String backView;
  final String leftView;
  final String rightView;

  VehicleDetails({
    required this.id,
    required this.driverId,
    required this.vehicleNumber,
    required this.vehicleModel,
    required this.ownerName,
    required this.frontView,
    required this.backView,
    required this.leftView,
    required this.rightView,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      id: json['id'] ?? 0,
      driverId: json['driver_id'] ?? 0,
      vehicleNumber: json['vehicle_number'] ?? '',
      vehicleModel: json['vehicle_model'] ?? '',
      ownerName: json['owner_name'] ?? '',
      frontView: json['front_view'] ?? '',
      backView: json['back_view'] ?? '',
      leftView: json['left_view'] ?? '',
      rightView: json['right_view'] ?? '',
    );
  }
}