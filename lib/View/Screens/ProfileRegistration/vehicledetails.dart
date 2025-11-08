import 'dart:io';

import 'package:addrive/Controller/ProfileRegistration/vehicle_details.dart';
import 'package:addrive/View/Screens/ProfileRegistration/bankdetails.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/VehicleDetails/vehicledetails_widgets.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/headingtext.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/inputfields_registraton.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class VehicleDetails extends StatelessWidget {
   const VehicleDetails({super.key});

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
                    HeaderSection(title:'Vehicle Details', subtitle:'Page 2 of 3'),

                    const SizedBox(height: 35),

                    // Vehicle Details Title
                    HeadingText(title: 'Vehicle Details'),

                    const SizedBox(height: 25),

                    // Vehicle Number
                    InputfieldsRegistraton(label: 'Vehicle Number'),

                    const SizedBox(height: 16),

                    // Vehicle Model
                    InputfieldsRegistraton(
                      label: 'Vehicle Model',
                    ),

                    const SizedBox(height: 16),

                    // Owner Name
                    InputfieldsRegistraton(
                      label: 'Owner Name',
                    ),

                    const SizedBox(height: 28),

                    // Photo Grid
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Front View',
                                style: AppTextStyle.base.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildPhotoBox(context, 'front'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Back View',
                                style: AppTextStyle.base.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildPhotoBox(context, 'back'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Right Side',
                                style: AppTextStyle.base.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildPhotoBox(context, 'right'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Left Side',
                                style: AppTextStyle.base.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildPhotoBox(context, 'left'),
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BankDetailsPage()));
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



 Widget _buildPhotoBox(BuildContext context, String viewType) {
  final vehicledetailsprovider = Provider.of<VehicleDetailsProviderclass>(context);
  
  // Get the appropriate image for this view type
  File? currentImage;
  switch (viewType) {
    case 'front':
      currentImage = vehicledetailsprovider.frontViewImage;
      break;
    case 'back':
      currentImage = vehicledetailsprovider.backViewImage;
      break;
    case 'right':
      currentImage = vehicledetailsprovider.rightSideImage;
      break;
    case 'left':
      currentImage = vehicledetailsprovider.leftSideImage;
      break;
  }

  return GestureDetector(
    onTap: () {
      vehicledetailsprovider.pickImage(ImageSource.gallery, viewType);
    },
    child: Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 254, 254, 254),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
        image: currentImage != null
            ? DecorationImage(
                image: FileImage(currentImage),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          if (currentImage == null)
            Center(
              child: Icon(
                Icons.camera_alt_outlined,
                size: 45,
                color: Colors.grey[400],
              ),
            ),

          if (currentImage != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: GestureDetector(
                onTap: () => vehicledetailsprovider.clearImage(viewType),
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
}
