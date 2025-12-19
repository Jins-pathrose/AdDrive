
class Profile {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String profilePicture;
  final String address;
  final String gender;
  final String paymentOption;
  final bool isAvailable;
  final bool isSelfDriver;

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    required this.address,
    required this.gender,
    required this.paymentOption,
    required this.isAvailable,
    required this.isSelfDriver,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '', 
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      paymentOption: json['payment_option'] ?? '',
      isAvailable: json['is_available'] ?? false,
      isSelfDriver: json['is_self_driver'] ?? false,
    );
  }

  String get fullName => '$firstName $lastName';
}