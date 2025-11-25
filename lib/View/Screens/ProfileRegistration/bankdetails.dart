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
    return ChangeNotifierProvider(
      create: (_) => BankDetailsProvider()..fetchBankDetails(),
      child: _BankDetailsBody(),
    );
  }
}

class _BankDetailsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bankProvider = Provider.of<BankDetailsProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          BackgroundDecoration(),
          // Main content
          SafeArea(
            child: bankProvider.isFetching
                ? _buildLoadingIndicator()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          HeaderSection(title: 'Bank Details', subtitle: 'Page 3'),

                          const SizedBox(height: 35),

                          // Bank Details Title with existing data indicator
                          Row(
                            children: [
                              HeadingText(title: 'Bank Details'),
                                
                            ],
                          ),

                          const SizedBox(height: 25),

                          // Account Number
                          InputfieldsRegistraton(
                            label: 'Account Number',
                            controller: bankProvider.accountNumberCtrl,
                          ),

                          const SizedBox(height: 16),

                          // IFSC Code
                          InputfieldsRegistraton(
                            label: 'IFSC Code',
                            controller: bankProvider.ifscCodeCtrl,
                          ),

                          const SizedBox(height: 16),

                          // Bank Name
                          InputfieldsRegistraton(
                            label: 'Bank Name',
                            controller: bankProvider.bankNameCtrl,
                          ),

                          const SizedBox(height: 16),

                          // Branch Name
                          InputfieldsRegistraton(
                            label: 'Branch Name',
                            controller: bankProvider.branchNameCtrl,
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
                              onPressed: bankProvider.canProceed && !bankProvider.isLoading
                                  ? () async {
                                      final success = await bankProvider.saveBankDetails();
                                      
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              bankProvider.hasExistingData
                                                  ? 'Bank details updated successfully!'
                                                  : 'Bank details saved successfully!'
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BottomNavigator(),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Failed to save bank details. Please try again.'),
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
                              child: bankProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      bankProvider.hasExistingData
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
            'Loading bank details...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoBox(BuildContext context) {
    final bankProvider = Provider.of<BankDetailsProvider>(context);
    File? passbook = bankProvider.passbook;
    bool hasExistingImage = bankProvider.existingPassbookUrl.isNotEmpty;
    
    return GestureDetector(
      onTap: () {
        bankProvider.pickImage();
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
              : hasExistingImage
                  ? DecorationImage(
                      image: NetworkImage(bankProvider.existingPassbookUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
        ),
        child: Stack(
          children: [
            if (passbook == null && !hasExistingImage)
              Center(
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 45,
                  color: Colors.grey[400],
                ),
              ),

            if (passbook != null || hasExistingImage)
              Positioned(
                right: 8,
                bottom: 8,
                child: GestureDetector(
                  onTap: () => bankProvider.clearImage(),
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