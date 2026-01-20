// Controller/ProfileRegistration/vehicle_details.dart
import 'dart:convert';
import 'dart:io';
import 'package:addrive/Model/apiclient.dart';
import 'package:addrive/Model/apiconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleDetailsProviderclass extends ChangeNotifier {
        final ApiClient api = ApiClient();

  // Individual image files for each view
  File? _frontViewImage;
  File? _backViewImage;
  File? _rightSideImage;
  File? _leftSideImage;
  final ImagePicker _picker = ImagePicker();

  // Text field controllers
  final TextEditingController vehicleNumberCtrl = TextEditingController();
  final TextEditingController vehicleModelCtrl = TextEditingController();
  final TextEditingController ownerNameCtrl = TextEditingController();

  // Loading states
  bool _isLoading = false;
  bool _isFetching = false;
  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;

  // Existing data flag
  bool _hasExistingData = false;
  bool get hasExistingData => _hasExistingData;

  // Getters for each image
  File? get frontViewImage => _frontViewImage;
  File? get backViewImage => _backViewImage;
  File? get rightSideImage => _rightSideImage;
  File? get leftSideImage => _leftSideImage;
  Map<String, String> _existingImageUrls = {};
  Map<String, String> get existingImageUrls => _existingImageUrls;


  // Method to pick image for specific view
  // Update the pickImage method
Future<void> pickImage(ImageSource source, String viewType) async {
  final XFile? pickedFile = await _picker.pickImage(source: source);

  if (pickedFile != null) {
    File? imageFile = File(pickedFile.path);
    
    // ALWAYS compress the image, even if it's below 1MB
    imageFile = await _compressVehicleImage(imageFile);
    
    if (imageFile != null) {
      final fileSize = await imageFile.length();
      print("Final ${viewType} image size: ${fileSize / 1024} KB");
      
      // Check if file is still too large
      if (fileSize > 1024 * 1024) {
        print("WARNING: ${viewType} image is still ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB");
        // You could show a toast or alert here
      }
    }
    
    switch (viewType) {
      case 'front':
        _frontViewImage = imageFile;
        break;
      case 'back':
        _backViewImage = imageFile;
        break;
      case 'right':
        _rightSideImage = imageFile;
        break;
      case 'left':
        _leftSideImage = imageFile;
        break;
    }
    notifyListeners();
  }
}

  // Clear specific image
void clearImage(String viewType) {
  switch (viewType) {
    case 'front':
      _frontViewImage = null;
      _existingImageUrls['front'] = '';
      break;
    case 'back':
      _backViewImage = null;
      _existingImageUrls['back'] = '';
      break;
    case 'right':
      _rightSideImage = null;
      _existingImageUrls['right'] = '';
      break;
    case 'left':
      _leftSideImage = null;
      _existingImageUrls['left'] = '';
      break;
  }
  notifyListeners();
}

  // Clear all images
  void clearAllImages() {
    _frontViewImage = null;
    _backViewImage = null;
    _rightSideImage = null;
    _leftSideImage = null;
    notifyListeners();
  }

  // Validation method
 bool get canProceed {
  final hasTextData = vehicleNumberCtrl.text.trim().isNotEmpty &&
      vehicleModelCtrl.text.trim().isNotEmpty &&
      ownerNameCtrl.text.trim().isNotEmpty;

  // Check if we have images (either new files or existing URLs)
  final hasFrontImage = _frontViewImage != null || 
      (_existingImageUrls['front']?.isNotEmpty == true);
  final hasBackImage = _backViewImage != null || 
      (_existingImageUrls['back']?.isNotEmpty == true);
  final hasRightImage = _rightSideImage != null || 
      (_existingImageUrls['right']?.isNotEmpty == true);
  final hasLeftImage = _leftSideImage != null || 
      (_existingImageUrls['left']?.isNotEmpty == true);

  return hasTextData && hasFrontImage && hasBackImage && hasRightImage && hasLeftImage;
}

  // Fetch existing vehicle details
  Future<bool> fetchVehicleDetails() async {
    _isFetching = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) {
        _isFetching = false;
        notifyListeners();
        return false;
      }

      final response = await api.get(
       ApiConfig.vehicleDetailsUrl
      );

      _isFetching = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        // Check if we have vehicle details
        if (data is List && data.isNotEmpty) {
          final vehicleData = data[0]; // Assuming first item is the vehicle data
          _populateFields(vehicleData);
          _hasExistingData = true;
          notifyListeners();
          return true;
        } else if (data is Map && data.containsKey('vehicle_number')) {
          _populateFields(data);
          _hasExistingData = true;
          notifyListeners();
          return true;
        }
        
        // No existing data found
        _hasExistingData = false;
        return true;
      } else {
        debugPrint('Fetch failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      _isFetching = false;
      notifyListeners();
      debugPrint('Fetch error: $e');
      return false;
    }
  }

  // Populate fields with existing data
  void _populateFields(Map<dynamic, dynamic> data) {
  vehicleNumberCtrl.text = data['vehicle_number'] ?? '';
  vehicleModelCtrl.text = data['vehicle_model'] ?? '';
  ownerNameCtrl.text = data['owner_name'] ?? '';

  // Store image URLs directly
  _existingImageUrls = {
    'front': data['front_view'] ?? '',
    'back': data['back_view'] ?? '',
    'right': data['right_view'] ?? '',
    'left': data['left_view'] ?? '',
  };
  
  notifyListeners();
}

// Add this method to compress image
// Update the _compressVehicleImage method to compress images more aggressively
Future<File?> _compressVehicleImage(File originalImage) async {
  try {
    final originalSize = await originalImage.length();
    print("Original vehicle image size: ${originalSize / 1024} KB");
    
    // Compress ALL images, not just those above 1MB
    // Set a safer target like 800KB
    final int targetSize = 800 * 1024; // 800KB target
    
    if (originalSize <= targetSize) {
      print("Vehicle image already below ${targetSize~/1024}KB");
      return originalImage;
    }
    
    // Get file path
    final filePath = originalImage.path;
    
    // Create compressed file path
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp|.png'));
    final splitted = filePath.substring(0, lastIndex);
    final outPath = "${splitted}_compressed${filePath.substring(lastIndex)}";
    
    // Start with lower quality for larger files
    int quality;
    if (originalSize > 2 * 1024 * 1024) { // > 2MB
      quality = 60;
    } else if (originalSize > 1.5 * 1024 * 1024) { // > 1.5MB
      quality = 70;
    } else {
      quality = 75; // Start lower for files near 1MB
    }
    
    File? compressedFile;
    
    // Try multiple compression levels if needed
    while (quality >= 40) {
      var result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: quality,
        minWidth: 800,  // Reduce from 1024 to 800px
        minHeight: 800, // Reduce from 1024 to 800px
        autoCorrectionAngle: true,
        keepExif: false, // Remove EXIF data to save space
      );
      
      if (result != null) {
        compressedFile = File(result.path);
        final compressedSize = await compressedFile.length();
        print("Compressed vehicle image size with quality $quality: ${compressedSize / 1024} KB");
        
        // If file is below target size, we're good
        if (compressedSize <= targetSize) {
          print("Vehicle image compressed to below ${targetSize~/1024}KB with quality: $quality%");
          return compressedFile;
        }
      }
      
      // Reduce quality more aggressively
      quality -= 10;
    }
    
    // If we still didn't get below target size, use the smallest we got
    if (compressedFile != null) {
      final finalSize = await compressedFile.length();
      print("Using smallest compressed vehicle image: ${finalSize / 1024} KB");
      return compressedFile;
    }
    
    // If all else fails, return the smallest possible compression
    var result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 40,
      minWidth: 640,  // Smaller dimensions
      minHeight: 640,
      autoCorrectionAngle: true,
      keepExif: false,
    );
    
    if (result != null) {
      final finalFile = File(result.path);
      final finalSize = await finalFile.length();
      print("Final compressed image: ${finalSize / 1024} KB");
      return finalFile;
    }
    
    return originalImage;
    
  } catch (e) {
    print("Error compressing vehicle image: $e");
    return originalImage; // Return original if compression fails
  }
}
  // API call to save/update vehicle details
// API call to save/update vehicle details
Future<bool> saveVehicleDetails() async {
  _isLoading = true;
  notifyListeners();

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Determine the API endpoint and method based on whether we have existing data
    final String apiUrl;
    final String method;
    
    if (_hasExistingData) {
      // Use update endpoint with PUT/PATCH
      apiUrl = ApiConfig.vehicleDetailsUrl;
      method = 'PUT'; // or 'PATCH' depending on your API
    } else {
      // Use create endpoint with POST
      apiUrl = ApiConfig.vehicleDetailsUrl;
      method = 'POST';
    }

    // Create multipart request
    var request = http.MultipartRequest(method, Uri.parse(apiUrl));

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    request.fields['vehicle_number'] = vehicleNumberCtrl.text.trim();
    request.fields['vehicle_model'] = vehicleModelCtrl.text.trim();
    request.fields['owner_name'] = ownerNameCtrl.text.trim();

    // Helper function to add compressed image to request
    Future<void> addCompressedImageToRequest(File? image, String fieldName) async {
      if (image != null) {
        try {
          // Compress the image before uploading
          final compressedImage = await _compressVehicleImage(image);
          
          if (compressedImage != null) {
            // Check final size after compression
            final finalSize = await compressedImage.length();
            print("Final ${fieldName} image size: ${finalSize / 1024} KB");
            
            // If still above 1MB after compression, show warning but continue
            if (finalSize > 1024 * 1024) {
              print("Warning: ${fieldName} image still above 1MB after compression");
            }
            
            // Add the compressed image to request
            request.files.add(await http.MultipartFile.fromPath(
              fieldName,
              compressedImage.path,
            ));
          } else {
            print("Failed to compress $fieldName image, using original");
            request.files.add(await http.MultipartFile.fromPath(
              fieldName,
              image.path,
            ));
          }
        } catch (e) {
          print("Error processing $fieldName image: $e, using original");
          // If compression fails, use original image
          request.files.add(await http.MultipartFile.fromPath(
            fieldName,
            image.path,
          ));
        }
      } else {
        // If no new image but we have existing URL, we might want to send empty string
        // to keep the existing image (if API supports it)
        print("No new $fieldName image selected, keeping existing if available");
      }
    }

    // Add image files only if they are newly selected
    await addCompressedImageToRequest(_frontViewImage, 'front_view');
    await addCompressedImageToRequest(_backViewImage, 'back_view');
    await addCompressedImageToRequest(_leftSideImage, 'left_view');
    await addCompressedImageToRequest(_rightSideImage, 'right_view');

    // Send request
    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    _isLoading = false;
    notifyListeners();

    // Parse response
    final responseData = json.decode(respStr);
    print('Vehicle details Response status: ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('Vehicle details ${_hasExistingData ? 'updated' : 'saved'} successfully');
      
      // Update local state with response data if available
      if (responseData is Map) {
        // Clear the image files after successful upload
        if (responseData.containsKey('front_view')) {
          _frontViewImage = null;
        }
        if (responseData.containsKey('back_view')) {
          _backViewImage = null;
        }
        if (responseData.containsKey('left_view')) {
          _leftSideImage = null;
        }
        if (responseData.containsKey('right_view')) {
          _rightSideImage = null;
        }
        
        // Update existing image URLs from response
        _existingImageUrls = {
          'front': responseData['front_view'] ?? _existingImageUrls['front'] ?? '',
          'back': responseData['back_view'] ?? _existingImageUrls['back'] ?? '',
          'right': responseData['right_view'] ?? _existingImageUrls['right'] ?? '',
          'left': responseData['left_view'] ?? _existingImageUrls['left'] ?? '',
        };
      }
      
      _hasExistingData = true;
      notifyListeners();
      return true;
    } else {
      debugPrint('Save failed: ${response.statusCode} - $respStr');
      
      // Try to extract error message from response
      String errorMessage = 'Failed to save vehicle details';
      if (responseData is Map) {
        errorMessage = responseData['message'] ?? 
                      responseData['error'] ?? 
                      responseData['detail'] ?? 
                      errorMessage;
      }
      
      // You might want to store this error message somewhere to show to user
      debugPrint('Error: $errorMessage');
      
      return false;
    }
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    debugPrint('Save error: $e');
    return false;
  }
}

  // Add this method to validate vehicle images
String? validateVehicleImage(File? image, String viewType) {
  if (image == null) {
    return null; // Return null if no image (images might be optional or already existing)
  }

  // Check file size (max 1MB)
  if (image.lengthSync() > 1 * 1024 * 1024) {
    return '$viewType image is too large (max 1MB)';
  }

  // Check file extension
  final fileName = image.path.split('/').last;
  final extension = fileName.split('.').last.toLowerCase();
  final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];

  if (!allowedExtensions.contains(extension)) {
    return 'Please select a valid image for $viewType view';
  }

  return null;
}
}