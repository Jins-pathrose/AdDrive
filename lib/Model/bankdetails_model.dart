class BankDetails {
  final int id;
  final int driverId;
  final String accountNumber;
  final String bankName;
  final String branchName;
  final String ifscCode;
  final String passbookImage;

  BankDetails({
    required this.id,
    required this.driverId,
    required this.accountNumber,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
    required this.passbookImage,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      id: json['id'] ?? 0,
      driverId: json['driver_id'] ?? 0,
      accountNumber: json['account_number'] ?? '',
      bankName: json['bank_name'] ?? '',
      branchName: json['branch_name'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      passbookImage: json['passbook_image'] ?? '',
    );
  }
}