import 'dart:io';
import 'package:addrive/Controller/ProfileRegistration/vehicle_details.dart';
import 'package:addrive/View/BottomNavigator/bottomnavigator.dart';
import 'package:addrive/View/Screens/ProfileRegistration/bankdetails.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/VehicleDetails/vehicledetails_widgets.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/headingtext.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/inputfields_registraton.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleDetails extends StatelessWidget {
  const VehicleDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VehicleDetailsProviderclass()..fetchVehicleDetails(),
      child: _VehicleDetailsBody(),
    );
  }
}

class _VehicleDetailsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleDetailsProviderclass>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          BackgroundDecoration(),

          // Main content
          SafeArea(
            child: vehicleProvider.isFetching
                ? _buildLoadingIndicator()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          HeaderSection(
                            title: 'Vehicle Details', 
                            subtitle: 'Page 2'
                          ),

                          const SizedBox(height: 35),

                          // Vehicle Details Title with existing data indicator
                          Row(
                            children: [
                              HeadingText(title: 'Vehicle Details'),
                            
                            ],
                          ),

                          const SizedBox(height: 25),

                          // Vehicle Number
                          InputfieldsRegistraton(
                            label: 'Vehicle Number',
                            controller: vehicleProvider.vehicleNumberCtrl,
                          ),

                          const SizedBox(height: 16),

                          // Vehicle Model
                          InputfieldsRegistraton(
                            label: 'Vehicle Model',
                            controller: vehicleProvider.vehicleModelCtrl,
                          ),

                          const SizedBox(height: 16),

                          // Owner Name
                          InputfieldsRegistraton(
                            label: 'Owner Name',
                            controller: vehicleProvider.ownerNameCtrl,
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
                              onPressed: vehicleProvider.canProceed && !vehicleProvider.isLoading
    ? () async {
        final success = await vehicleProvider.saveVehicleDetails();
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                vehicleProvider.hasExistingData
                    ? 'Vehicle details updated successfully!'
                    : 'Vehicle details saved successfully!'
              ),
              backgroundColor: Colors.green,
            ),
          );
          
          // Read payment option from SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final paymentOption = prefs.getInt('payment_option') ?? 0;
          print("Payment Option: $paymentOption");
          print('455445454545545445');
          if (paymentOption == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => BottomNavigator()),
              (route) => false,
            );
          } else {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => BankDetailsPage())
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save vehicle details. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B4BDB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: vehicleProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      vehicleProvider.hasExistingData
                                          ? 'Update Details'
                                          : 'Save Details',
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

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B4BDB)),
          ),
          SizedBox(height: 20),
          Text(
            'Loading vehicle details...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoBox(BuildContext context, String viewType) {
  final vehicleProvider = Provider.of<VehicleDetailsProviderclass>(context);
  
  // Get the appropriate image for this view type
  File? currentImage;
  String? imageUrl;
  
  switch (viewType) {
    case 'front':
      currentImage = vehicleProvider.frontViewImage;
      imageUrl = vehicleProvider.existingImageUrls['front'];
      break;
    case 'back':
      currentImage = vehicleProvider.backViewImage;
      imageUrl = vehicleProvider.existingImageUrls['back'];
      break;
    case 'right':
      currentImage = vehicleProvider.rightSideImage;
      imageUrl = vehicleProvider.existingImageUrls['right'];
      break;
    case 'left':
      currentImage = vehicleProvider.leftSideImage;
      imageUrl = vehicleProvider.existingImageUrls['left'];
      break;
  }

  bool hasExistingImage = imageUrl?.isNotEmpty == true;
  bool hasNewImage = currentImage != null;

  return GestureDetector(
    onTap: () {
      vehicleProvider.pickImage(ImageSource.gallery, viewType);
    },
    child: Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 254, 254, 254),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
        image: hasNewImage
            ? DecorationImage(
                image: FileImage(currentImage!),
                fit: BoxFit.cover,
              )
            : hasExistingImage
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
      ),
      child: Stack(
        children: [
          if (!hasNewImage && !hasExistingImage)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 35,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add Photo',
                    style: AppTextStyle.base.copyWith(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

          if (hasNewImage || hasExistingImage)
            Positioned(
              right: 8,
              bottom: 8,
              child: GestureDetector(
                onTap: () => vehicleProvider.clearImage(viewType),
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