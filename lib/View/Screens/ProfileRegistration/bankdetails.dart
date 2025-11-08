import 'dart:io';

import 'package:addrive/Controller/ProfileRegistration/bank_details.dart';
import 'package:addrive/View/BottomNavigator/bottomnavigator.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/VehicleDetails/vehicledetails_widgets.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/headingtext.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/inputfields_registraton.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BankDetailsPage extends StatelessWidget {
  const BankDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
         BackgroundDecoration(),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                   HeaderSection(title: 'Bank Details', subtitle: 'Page 3 of 3'),

                    const SizedBox(height: 35),

                    // Vehicle Details Title
                    HeadingText(title: 'Bank Details'),

                    const SizedBox(height: 25),

                    InputfieldsRegistraton(label: 'Account Number'),

                    const SizedBox(height: 16),

                    InputfieldsRegistraton(label: 'IFSC Code'),

                    const SizedBox(height: 16),
                    InputfieldsRegistraton(label: 'Bank Name'),

                    const SizedBox(height: 16),

                    InputfieldsRegistraton(label: 'Branch Name'),

                    const SizedBox(height: 28),

                    // Photo Grid
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Passbook Photo',
                                style: AppTextStyle.base.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildPhotoBox(context),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Update Details Button
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BottomNavigator(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5B4BDB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Update Details',
                          style: AppTextStyle.base.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
}
Widget _buildPhotoBox(context) {
      final bankdetailsprovider =Provider.of<BankDetailsProvider>(context);
File? passbook = bankdetailsprovider.passbook;
  return GestureDetector(
    onTap: () {
      bankdetailsprovider.pickImage();
    },
    child: Container(
      height: 110,
      width: 200,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 254, 254, 254),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
        image: passbook != null
            ? DecorationImage(
                image: FileImage(passbook),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          if (passbook == null)
            Center(
              child: Icon(
                Icons.camera_alt_outlined,
                size: 45,
                color: Colors.grey[400],
              ),
            ),

          if (passbook != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: GestureDetector(
                onTap: () => bankdetailsprovider.clearImage(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
