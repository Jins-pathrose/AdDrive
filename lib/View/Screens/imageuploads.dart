import 'dart:io';

import 'package:addrive/Controller/imageuploads_provider.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageUploads extends StatelessWidget {
  final String campaignId; // Store campaignId as a field
  
  const ImageUploads({
    super.key, 
    required this.campaignId, // Required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        
        title:  Text('Upload Car Images', style: AppTextStyle.base.copyWith(color: Colors.white)),
        backgroundColor: Color(0xFF6C3FE4),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: 
        [
          const BackgroundDecoration(),
           SafeArea(
            
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<ImageUploadProvider>(
              builder: (context, provider, child) {
                // Listen for success to show snackbar and navigate back
                if (provider.isSuccess) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Images uploaded successfully!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                    
                    Future.delayed(const Duration(seconds: 2), () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    });
                  });
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 24),
        
                    // Image Grid
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                        children: [
                          _buildImageCard(
                            context: context,
                            title: 'FRONT SIDE',
                            side: CarSide.front,
                            image: provider.frontImage,
                            icon: Icons.car_repair,
                          ),
                          _buildImageCard(
                            context: context,
                            title: 'BACK SIDE',
                            side: CarSide.back,
                            image: provider.backImage,
                            icon: Icons.car_repair,
                          ),
                          _buildImageCard(
                            context: context,
                            title: 'LEFT SIDE',
                            side: CarSide.left,
                            image: provider.leftImage,
                            icon: Icons.car_repair,
                          ),
                          _buildImageCard(
                            context: context,
                            title: 'RIGHT SIDE',
                            side: CarSide.right,
                            image: provider.rightImage,
                            icon: Icons.car_repair,
                          ),
                        ],
                      ),
                    ),
        
                    const SizedBox(height: 24),
        
                    // Status Messages
                    if (provider.error != null) _buildErrorCard(provider.error!),
        
                    const SizedBox(height: 16),
        
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            provider.allImagesUploaded && !provider.isSubmitting
                            ? () async {
                                // Clear any previous messages
                                provider.clearMessages();
                                
                                // Submit images with the campaignId
                                await provider.submitImages(campaignId, context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B4AC7),
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: provider.isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'SUBMIT IMAGES',
                                style: AppTextStyle.base.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: provider.allImagesUploaded
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        ]
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Car Images',
          style: AppTextStyle.base.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please capture clear images of all 4 sides of your car',
          style: AppTextStyle.base.copyWith(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildImageCard({
    required BuildContext context,
    required String title,
    required CarSide side,
    required File? image,
    required IconData icon,
  }) {
    final provider = Provider.of<ImageUploadProvider>(context, listen: false);

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => provider.captureImage(side),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image or Placeholder
              Expanded(
                child: image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder(icon);
                          },
                        ),
                      )
                    : _buildPlaceholder(icon),
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: AppTextStyle.base.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: image != null ? Colors.green : Colors.grey[700],
                ),
              ),

              const SizedBox(height: 4),

              // Status or Button
              if (image != null)
                TextButton(
                  onPressed: () => provider.removeImage(side),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child:  Text(
                    'Retake',
                    style: AppTextStyle.base.copyWith(fontSize: 12, color: Colors.red),
                  ),
                )
              else
                 Text(
                  'Tap to capture',
                  style: AppTextStyle.base.copyWith(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(IconData icon) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
           Text(
            'No Image',
            style: AppTextStyle.base.copyWith(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Please try again later',
              style: TextStyle(fontSize: 14, color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
}