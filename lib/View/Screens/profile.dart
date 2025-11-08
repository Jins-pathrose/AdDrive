import 'package:addrive/View/Screens/ProfileRegistration/personaldetails.dart';
import 'package:addrive/View/Screens/loginpage.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
            child: SingleChildScrollView(
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: Colors.black87,
                                size: 24,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
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
                          colors: [Colors.blue.shade600, Colors.blue.shade400],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors
                            .transparent, // make background transparent to show gradient
                        backgroundImage: AssetImage(
                          'assets/images/Jins_Black.jpg',
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    // Name and Contact Info
                    Text(
                      'Pathrose Jinz',
                      style: AppTextStyle.base.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'pathrosetenrose@gmail.com',
                      style: AppTextStyle.base.copyWith(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '+91 97858 28487',
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
                            builder: (context) => PersonalDetails(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5F33E1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // keeps button compact
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
                          Icon(Icons.edit, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Vehicle Details Section
                    _buildSectionCard(
                      icon: Icons.directions_car,
                      title: 'Vehicle Details',
                      children: [
                        _buildDetailRow('Vehicle Number', 'KL-50-AN-5220'),
                        _buildDetailRow('Vehicle Model', 'Honda Civic'),
                        _buildDetailRow('Owner Name', 'Jinz Pathrose'),
                        _buildDetailRow('Vehicle Images', 'View', isLink: true),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Bank Details Section
                    _buildSectionCard(
                      icon: Icons.account_balance,
                      title: 'Bank Details',
                      children: [
                        _buildDetailRow('Account Number', 'ABCD0025587458'),
                        _buildDetailRow('Bank Name', 'HDFC Bank'),
                        _buildDetailRow('Branch Name', 'Palakkad'),
                        _buildDetailRow('IFSC Code', 'HDFP0258'),
                        _buildDetailRow('Passbook Image', 'View', isLink: true),
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
            ),
          ),
        ],
      ),
    );
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

  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
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
          Text(
            value,
            style: AppTextStyle.base.copyWith(
              fontSize: 14,
              color: isLink ? Colors.blue : Colors.black,
              fontWeight: FontWeight.w500,
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
                'On',
                style: AppTextStyle.base.copyWith(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 20, color: Colors.black),
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
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
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
}
