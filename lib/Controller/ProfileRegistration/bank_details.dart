// Controller/ProfileRegistration/bank_details.dart
import 'dart:convert';
import 'dart:io';
import 'package:addrive/Model/apiclient.dart';
import 'package:addrive/Model/apiconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BankDetailsProvider extends ChangeNotifier {
      final ApiClient api = ApiClient();

  File? _passbook;
  final ImagePicker _picker = ImagePicker();

  // Text field controllers
  final TextEditingController accountNumberCtrl = TextEditingController();
  final TextEditingController ifscCodeCtrl = TextEditingController();
  final TextEditingController bankNameCtrl = TextEditingController();
  final TextEditingController branchNameCtrl = TextEditingController();

  // Loading states
  bool _isLoading = false;
  bool _isFetching = false;
  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;

  // Existing data flag
  bool _hasExistingData = false;
  bool get hasExistingData => _hasExistingData;

  // Existing image URL
  String _existingPassbookUrl = '';
  String get existingPassbookUrl => _existingPassbookUrl;

  File? get passbook => _passbook;

  Future<void> pickImage() async {
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    File? imageFile = File(pickedFile.path);
    
    // ALWAYS compress the image
    imageFile = await _compressPassbookImage(imageFile);
    
    if (imageFile != null) {
      final fileSize = await imageFile.length();
      print("Final passbook image size: ${fileSize / 1024} KB");
      
      // Check if still too large
      if (fileSize > 1024 * 1024) {
        print("WARNING: Passbook image is still ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB");
        // You could show a warning to user here
      }
    }
    
    _passbook = imageFile;
    notifyListeners();
  }
}

  void clearImage() {
    _passbook = null;
    _existingPassbookUrl = '';
    notifyListeners();
  }

  // Validation method
  bool get canProceed {
    return accountNumberCtrl.text.trim().isNotEmpty &&
        ifscCodeCtrl.text.trim().isNotEmpty &&
        bankNameCtrl.text.trim().isNotEmpty &&
        branchNameCtrl.text.trim().isNotEmpty &&
        (_passbook != null || _existingPassbookUrl.isNotEmpty);
  }

  // Fetch existing bank details
  Future<bool> fetchBankDetails() async {
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
        ApiConfig.bankDetailsUrl
      );

      _isFetching = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        // Check if we have bank details
        if (data is List && data.isNotEmpty) {
          final bankData = data[0];
          _populateFields(bankData);
          _hasExistingData = true;
          notifyListeners();
          return true;
        } else if (data is Map && data.containsKey('account_number')) {
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
    accountNumberCtrl.text = data['account_number'] ?? '';
    ifscCodeCtrl.text = data['ifsc_code'] ?? '';
    bankNameCtrl.text = data['bank_name'] ?? '';
    branchNameCtrl.text = data['branch_name'] ?? '';
    _existingPassbookUrl = data['passbook_image'] ?? '';
    
    notifyListeners();
  }

// Add this method to compress passbook image
// Update the _compressPassbookImage method to be more aggressive
Future<File?> _compressPassbookImage(File originalImage) async {
  try {
    final originalSize = await originalImage.length();
    print("Original passbook image size: ${originalSize / 1024} KB");
    
    // Compress ALL images to a safer target (800KB)
    final int targetSize = 800 * 1024; // 800KB target
    
    if (originalSize <= targetSize) {
      print("Passbook image already below ${targetSize~/1024}KB");
      return originalImage;
    }
    
    // Get file path
    final filePath = originalImage.path;
    
    // Create compressed file path
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp|.png'));
    final splitted = filePath.substring(0, lastIndex);
    final outPath = "${splitted}_compressed${filePath.substring(lastIndex)}";
    
    // Start with appropriate quality based on original size
    int quality;
    if (originalSize > 2 * 1024 * 1024) { // > 2MB
      quality = 60;
    } else if (originalSize > 1.5 * 1024 * 1024) { // > 1.5MB
      quality = 70;
    } else {
      quality = 75; // Start lower for files near 1MB
    }
    
    File? compressedFile;
    
    // Try multiple compression levels
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
        print("Compressed passbook image size with quality $quality: ${compressedSize / 1024} KB");
        
        // If file is below target size, we're good
        if (compressedSize <= targetSize) {
          print("Passbook image compressed to below ${targetSize~/1024}KB with quality: $quality%");
          return compressedFile;
        }
      }
      
      // Reduce quality more aggressively
      quality -= 10;
    }
    
    // If we still didn't get below target size, use the smallest we got
    if (compressedFile != null) {
      final finalSize = await compressedFile.length();
      print("Using smallest compressed passbook image: ${finalSize / 1024} KB");
      return compressedFile;
    }
    
    // Final fallback with minimal settings
    var result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 40,
      minWidth: 640,
      minHeight: 640,
      autoCorrectionAngle: true,
      keepExif: false,
    );
    
    if (result != null) {
      final finalFile = File(result.path);
      final finalSize = await finalFile.length();
      print("Final compressed passbook image: ${finalSize / 1024} KB");
      return finalFile;
    }
    
    return originalImage;
    
  } catch (e) {
    print("Error compressing passbook image: $e");
    return originalImage;
  }
}
  // API call to save/update bank details
  // API call to save/update bank details
Future<bool> saveBankDetails() async {
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

    // Determine the API endpoint and method
    final String apiUrl;
    final String method;
    
    if (_hasExistingData) {
      apiUrl = ApiConfig.bankDetailsUrl;
      method = 'PUT';
    } else {
      apiUrl = ApiConfig.bankDetailsUrl;
      method = 'POST';
    }

    // Create multipart request
    var request = http.MultipartRequest(method, Uri.parse(apiUrl));

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    request.fields['account_number'] = accountNumberCtrl.text.trim();
    request.fields['ifsc_code'] = ifscCodeCtrl.text.trim();
    request.fields['bank_name'] = bankNameCtrl.text.trim();
    request.fields['branch_name'] = branchNameCtrl.text.trim();

    // Add passbook image file only if newly selected (with compression)
    if (_passbook != null) {
      try {
        // Compress the image before uploading
        final compressedImage = await _compressPassbookImage(_passbook!);
        
        if (compressedImage != null) {
          // Check final size after compression
          final finalSize = await compressedImage.length();
          print("Final passbook image size: ${finalSize / 1024} KB");
          
          // If still above 1MB after compression, show warning but continue
          if (finalSize > 1024 * 1024) {
            print("Warning: Passbook image still above 1MB after compression");
          }
          
          // Add the compressed image to request
          request.files.add(await http.MultipartFile.fromPath(
            'passbook_image',
            compressedImage.path,
          ));
        } else {
          print("Failed to compress passbook image, using original");
          request.files.add(await http.MultipartFile.fromPath(
            'passbook_image',
            _passbook!.path,
          ));
        }
      } catch (e) {
        print("Error compressing passbook image: $e, using original");
        // If compression fails, use original image
        request.files.add(await http.MultipartFile.fromPath(
          'passbook_image',
          _passbook!.path,
        ));
      }
    } else {
      print("No new passbook image selected, keeping existing if available");
    }

    // Send request
    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    _isLoading = false;
    notifyListeners();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(respStr);
      debugPrint('✅ Bank details ${_hasExistingData ? 'updated' : 'saved'} successfully');
      
      // Update local state with response data if available
      if (responseData is Map) {
        // Clear the passbook file after successful upload
        if (responseData.containsKey('passbook_image')) {
          _passbook = null;
          _existingPassbookUrl = responseData['passbook_image'] ?? _existingPassbookUrl;
        }
      }
      
      _hasExistingData = true;
      notifyListeners();
      return true;
    } else {
      debugPrint('❌ Save failed: ${response.statusCode} - $respStr');
      
      // Try to extract error message from response
      final responseData = json.decode(respStr);
      String errorMessage = 'Failed to save bank details';
      if (responseData is Map) {
        errorMessage = responseData['message'] ?? 
                      responseData['error'] ?? 
                      responseData['detail'] ?? 
                      errorMessage;
      }
      
      debugPrint('❌ Error: $errorMessage');
      return false;
    }
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    debugPrint('❌ Save error: $e');
    return false;
  }
}
// Add this method to validate passbook image
String? validatePassbookImage() {
  if (_passbook == null && _existingPassbookUrl.isEmpty) {
    return 'Please upload a passbook image';
  }

  if (_passbook != null) {
    // Check file size (max 1MB)
    if (_passbook!.lengthSync() > 1 * 1024 * 1024) {
      return 'Passbook image should be less than 1MB (will be compressed automatically)';
    }

    // Check file extension
    final fileName = _passbook!.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
    
    // For passbook, you might want to allow PDF as well
    if (!allowedExtensions.contains(extension)) {
      return 'Please select a valid image (JPG, JPEG, PNG) or PDF';
    }
  }

  return null;
}
}