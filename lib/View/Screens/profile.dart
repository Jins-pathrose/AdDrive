import 'package:addrive/Controller/Profile/myprofile.dart';
import 'package:addrive/View/Screens/ProfileRegistration/personaldetails.dart';
import 'package:addrive/View/Screens/accountmanagment.dart';
import 'package:addrive/View/Screens/complaintpage.dart';
import 'package:addrive/View/Screens/loginpage.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Fetch profile data when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Blurred colored circles in background
          BackgroundDecoration(),
          // Main content
          SafeArea(
            child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                if (profileProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (profileProvider.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Please check your internet connection and try again.',
                            style: AppTextStyle.base.copyWith(color: Color(0xFF5B4BDB)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            profileProvider.fetchProfileData();
                          },
                          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
            ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final profileData = profileProvider.profileData;
                if (profileData == null) {
                  return Center(
                    child: Text(
                      'No profile data found',
                      style: AppTextStyle.base.copyWith(color: Colors.grey),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Profile',
                              style: AppTextStyle.base.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                children: [
                                  // Replace your current settings icon container with this:
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      cardColor: Colors.white,
                                      popupMenuTheme: PopupMenuThemeData(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 4,
                                      ),
                                    ),
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.settings_outlined,
                                        color: Colors.black87,
                                        size: 24,
                                      ),
                                      onSelected: (value) {
                                        _handleSettingsMenuSelection(
                                          value,
                                          context,
                                        );
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          PopupMenuItem<String>(
                                            value: 'account',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.person_outline,
                                                  size: 20,
                                                  color: Colors.black87,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Account Management'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'complaint',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.report_problem_outlined,
                                                  size: 20,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Complaint Registration',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ];
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Profile Image
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.blue.shade600,
                                Colors.blue.shade400,
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                profileData.profile.profilePicture.isNotEmpty
                                ? NetworkImage(
                                    '${profileData.profile.profilePicture}',
                                  )
                                : const AssetImage(
                                        'assets/images/Jins_Black.jpg',
                                      )
                                      as ImageProvider,
                          ),
                        ),

                        const SizedBox(height: 10),
                        // Name and Contact Info
                        Text(
                          profileData.profile.fullName,
                          style: AppTextStyle.base.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          profileData.profile.email,
                          style: AppTextStyle.base.copyWith(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          profileData.profile.phoneNumber,
                          style: AppTextStyle.base.copyWith(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Edit Profile Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PersonalDetails(
                                  isEditing: true,
                                ), // Add this
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5F33E1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Edit Profile',
                                style: AppTextStyle.base.copyWith(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.edit, color: Colors.white),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Vehicle Details Section
                        // Vehicle Details Section
                        _buildSectionCard(
                          icon: Icons.directions_car,
                          title: 'Vehicle Details',
                          children: [
                            _buildDetailRow(
                              'Vehicle Number',
                              profileData.vehicleDetails['vehicle_number'] ??
                                  'N/A',
                            ),
                            _buildDetailRow(
                              'Vehicle Model',
                              profileData.vehicleDetails['vehicle_model'] ??
                                  'N/A',
                            ),
                            _buildDetailRow(
                              'Owner Name',
                              profileData.vehicleDetails['owner_name'] ?? 'N/A',
                            ),
                            _buildDetailRow(
                              'Vehicle Images',
                              'View',
                              isLink: true,
                              onTap: () => _showVehicleImages(
                                profileData.vehicleDetails,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Bank/Fleet Details Section
                        _buildSectionCard(
                          icon: profileData.bankDetails == null
                              ? Icons.business
                              : Icons.account_balance,
                          title: profileData.bankDetails == null
                              ? 'Fleet Details'
                              : 'Bank Details',
                          children: profileData.bankDetails == null
                              ? [
                                  // Fleet Details
                                  _buildDetailRow(
                                    'Fleet Name',
                                    profileData.fleetDetails?['fleet_name'] ??
                                        'N/A',
                                  ),
                                  _buildDetailRow(
                                    'Fleet Owner',
                                    profileData.fleetDetails?['fleet_owner'] ??
                                        'N/A',
                                  ),
                                  _buildDetailRow(
                                    'Phone Number',
                                    profileData.fleetDetails?['phone_number'] ??
                                        'N/A',
                                  ),
                                  _buildDetailRow(
                                    'Fleet Profile',
                                    'View',
                                    isLink: true,
                                    onTap: () => _showImagePopup(
                                      profileData
                                              .fleetDetails?['fleet_profile'] ??
                                          '',
                                      'Fleet Profile',
                                    ),
                                  ),
                                ]
                              : [
                                  // Bank Details
                                  _buildDetailRow(
                                    'Account Number',
                                    _maskAccountNumber(
                                      profileData.bankDetails?.accountNumber ??
                                          '',
                                    ),
                                  ),
                                  _buildDetailRow(
                                    'Bank Name',
                                    profileData.bankDetails?.bankName ?? 'N/A',
                                  ),
                                  _buildDetailRow(
                                    'Branch Name',
                                    profileData.bankDetails?.branchName ??
                                        'N/A',
                                  ),
                                  _buildDetailRow(
                                    'IFSC Code',
                                    profileData.bankDetails?.ifscCode ?? 'N/A',
                                  ),
                                  _buildDetailRow(
                                    'Passbook Image',
                                    'View',
                                    isLink: true,
                                    onTap: () => _showImagePopup(
                                      profileData.bankDetails?.passbookImage ??
                                          '',
                                      'Passbook Image',
                                    ),
                                  ),
                                ],
                        ),
                        const SizedBox(height: 20),
                        // Notifications
                        _buildSettingRow(
                          context: context,
                          icon: Icons.notifications,
                          title: 'Notifications',
                          value: 'On',
                          isLink: true,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    return 'XXXX${accountNumber.substring(accountNumber.length - 4)}';
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyle.base.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyle.base.copyWith(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: isLink ? onTap : null,
            child: Text(
              value,
              style: AppTextStyle.base.copyWith(
                fontSize: 14,
                color: isLink ? Colors.blue : Colors.black,
                fontWeight: FontWeight.w500,
                decoration: isLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    bool isLink = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: Colors.black),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: AppTextStyle.base.copyWith(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: AppTextStyle.base.copyWith(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 20, color: Colors.black),
                  const SizedBox(width: 12),
                  Text(
                    'Account',
                    style: AppTextStyle.base.copyWith(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showLogoutConfirmation(),
                child: Text(
                  'Logout',
                  style: AppTextStyle.base.copyWith(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVehicleImages(Map<String, dynamic> vehicleDetails) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Vehicle Images',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                child: Column(
                  children: [
                    if (vehicleDetails['front_view'] != null &&
                        vehicleDetails['front_view'].isNotEmpty)
                      _buildImagePreview(
                        'Front View',
                        vehicleDetails['front_view'],
                      ),
                    if (vehicleDetails['back_view'] != null &&
                        vehicleDetails['back_view'].isNotEmpty)
                      _buildImagePreview(
                        'Back View',
                        vehicleDetails['back_view'],
                      ),
                    if (vehicleDetails['right_view'] != null &&
                        vehicleDetails['right_view'].isNotEmpty)
                      _buildImagePreview(
                        'Right Side',
                        vehicleDetails['right_view'],
                      ),
                    if (vehicleDetails['left_view'] != null &&
                        vehicleDetails['left_view'].isNotEmpty)
                      _buildImagePreview(
                        'Left Side',
                        vehicleDetails['left_view'],
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePopup(String imageUrl, String title) {
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No $title image available')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(String title, String imageUrl) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Colors.grey),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout from your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog

              // Perform logout and redirect immediately
              final profileProvider = context.read<ProfileProvider>();
              await profileProvider.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: Text('Yes, Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleSettingsMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'account':
        // Navigate to Account Management page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AccountManagementPage(), // Replace with your actual page
          ),
        );
        break;
      case 'complaint':
        // Navigate to Complaint Registration page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ComplaintRegistrationPage(), // Replace with your actual page
          ),
        );
        break;
    }
  }
}
