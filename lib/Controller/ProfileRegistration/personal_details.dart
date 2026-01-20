// Controller/ProfileRegistration/personal_details.dart
import 'dart:io';

import 'package:addrive/Model/apiclient.dart';
import 'package:addrive/Model/apiconfig.dart';
import 'package:addrive/Model/fleetmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalDetailsProvider extends ChangeNotifier {
  final ApiClient api = ApiClient();

  int? selectindex; 
  bool isLoading = true;
  bool isSaving = false;
  List<Fleet> fleets = [];
  Fleet? selectedFleet;
  bool isLoadingFleets = false;

  // ---- data that comes from the server ----
  String firstName = '';
  String lastName = '';
  String phone = '';
  String email = '';
  String address = '';
  String gender = '';
  String paymentOption = ''; // default

  // Gender dropdown options
  final List<String> genderOptions = ['Male', 'Female'];
  String? selectedGender;

  // local controllers
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  // Add these fields to your class
  File? _profilePictureFile;
  String profilePictureUrl = ''; // Keep this for server URL

  // Add getter for the file
  File? get profilePictureFile => _profilePictureFile;
bool isEditMode = false;

  // Add a method to set profile picture from file
  void setProfilePictureFromFile(File? file) {
    _profilePictureFile = file;
    if (file != null) {
      profilePictureUrl = file.path; // Use file path temporarily
    }
    notifyListeners();
  }

  // -------------------------------------------------
  void setTab(int index) {
    selectindex = index;
    paymentOption = index == 0 ? 'self' : 'fleet';

    if (index == 1 && fleets.isEmpty) {
      fetchFleets();
    }

    notifyListeners();
  }

  // In PersonalDetailsProvider class, update setGender method:
  void setGender(String? value) {
    selectedGender = value;
    gender = value?.toLowerCase() ?? ''; // Store in lowercase for API
    notifyListeners();
  }

  // ------------------ API -----------------------
  // In fetchPersonalDetails method, update the gender setting:
  Future<void> fetchPersonalDetails({bool isEditing = false}) async {
      isEditMode = isEditing;

  // 🔥 HARD RESET – this is critical
  isLoading = true;
  selectindex = null;
  paymentOption = '';
  selectedFleet = null;

  notifyListeners();

  try {
    final response = await api.get(ApiConfig.personalDetailsUrl);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      firstName = data['first_name'] ?? '';
      lastName = data['last_name'] ?? '';
      phone = data['phone_number'] ?? '';
      email = data['email'] ?? '';
      profilePictureUrl = data['profile_picture'] ?? '';
      address = data['address'] ?? '';
      gender = data['gender'] ?? '';

      // ✅ READ API VALUE ONCE
      paymentOption = (data['payment_option'] ?? '').toString().trim();

      // Controllers
      phoneCtrl.text = phone;
      addressCtrl.text = address;

      // Gender
      if (gender.isNotEmpty) {
        selectedGender =
            gender[0].toUpperCase() + gender.substring(1).toLowerCase();
      } else {
        selectedGender = null;
      }

      // 🔥 SINGLE SOURCE OF TRUTH
      if (isEditMode) {
    // Set selectindex based on existing data or null
    if (paymentOption == 'self') {
      selectindex = 0;
    } else if (paymentOption == 'fleet') {
      selectindex = 1;
    } else {
      selectindex = null;
    }
  }

      // ✅ REAL LOGS (AFTER ASSIGNMENT)
      debugPrint('API payment_option: "$paymentOption"');
      debugPrint('FINAL selectindex: $selectindex');
    }
  } catch (e) {
    debugPrint('API error: $e');
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

// In PersonalDetailsProvider class

Future<void> pickImage() async {
  try {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      File originalFile = File(pickedFile.path);
      
      // Get the correct path without file:// prefix
      String filePath = originalFile.path;
      debugPrint('Original file path: $filePath');
      
      // Compress the image
      File? compressedFile = await _compressProfilePicture(originalFile);
      
      if (compressedFile != null) {
        _profilePictureFile = compressedFile;
        // Store just the path, not the full URI
        profilePictureUrl = compressedFile.path;
      } else {
        _profilePictureFile = originalFile;
        profilePictureUrl = filePath;
      }
      
      notifyListeners();
    }
  } catch (e) {
    debugPrint('Error picking image: $e');
  }
}

  // Add this method to compress profile picture
  Future<File?> _compressProfilePicture(File originalImage) async {
    try {
      final originalSize = await originalImage.length();
      print("Original profile picture size: ${originalSize / 1024} KB");

      // If image is already below 1MB, return as is
      if (originalSize <= 1024 * 1024) {
        print("Profile picture already below 1MB, skipping compression");
        return originalImage;
      }

      // Get file path
      final filePath = originalImage.path;

      // Create compressed file path
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp|.png'));
      final splitted = filePath.substring(0, lastIndex);
      final outPath =
          "${splitted}_compressed_profile${filePath.substring(lastIndex)}";

      // Determine compression quality
      int quality = 85;
      File? compressedFile;

      // Try multiple compression levels if needed
      while (quality >= 20) {
        var result = await FlutterImageCompress.compressAndGetFile(
          filePath,
          outPath,
          quality: quality,
          minWidth: 800, // Max width 800px (good for profile pictures)
          minHeight: 800, // Max height 800px
          rotate: 0, // Maintain orientation
        );

        if (result != null) {
          compressedFile = File(result.path);
          final compressedSize = await compressedFile.length();
          print(
            "Compressed profile picture size with quality $quality: ${compressedSize / 1024} KB",
          );

          // If file is below 1MB, we're good
          if (compressedSize <= 1024 * 1024) {
            print(
              "Profile picture compressed to below 1MB with quality: $quality%",
            );
            return compressedFile;
          }
        }

        // Reduce quality for next attempt
        quality -= 15;
      }

      // If we still didn't get below 1MB, use the smallest we got
      if (compressedFile != null) {
        print("Using smallest compressed profile picture available");
        return compressedFile;
      }

      return originalImage;
    } catch (e) {
      print("Error compressing profile picture: $e");
      return originalImage; // Return original if compression fails
    }
  }

  Future<void> fetchFleets() async {
    isLoadingFleets = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? 'your_token_here';

      final response = await http.get(
        Uri.parse(ApiConfig.fleetListingUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> fleetsData = data['fleets'] ?? [];

        fleets = fleetsData
            .map((fleetJson) => Fleet.fromJson(fleetJson))
            .toList();
      }
    } catch (e) {
      debugPrint('Fleets API error: $e');
    } finally {
      isLoadingFleets = false;
      notifyListeners();
    }
  }

  // Add method to set selected fleet
  void setSelectedFleet(Fleet? fleet) {
    selectedFleet = fleet;
    notifyListeners();
  }

  Future<bool> saveProfileDetails() async {
    isSaving = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (selectindex != null) {
      await prefs.setInt('payment_option', selectindex!);
    } else {
      await prefs.remove('payment_option'); // optional but clean
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      // Debug: Print the data being sent
      debugPrint('Sending data:');
      debugPrint('first_name: $firstName');
      debugPrint('last_name: $lastName');
      debugPrint('phone_number: ${phoneCtrl.text.trim()}');
      debugPrint('address: ${addressCtrl.text.trim()}');
      debugPrint('gender: ${selectedGender ?? ''}');
      debugPrint('payment_option: $paymentOption');
      debugPrint('profile_picture: $profilePictureUrl');

      // Prepare multipart request
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(ApiConfig.personalDetailsUrl),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields - make sure field names match API exactly
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['phone_number'] = phoneCtrl.text.trim();
      request.fields['address'] = addressCtrl.text.trim();
      request.fields['gender'] = (selectedGender ?? '').toLowerCase();
      request.fields['payment_option'] = paymentOption;

      // Add fleet ID if fleet is selected
      if (selectindex == 1 && selectedFleet != null) {
        request.fields['fleet'] = selectedFleet!.id.toString();
      }

      // Handle profile picture with compression
      if (_profilePictureFile != null) {
        try {
          // Compress the profile picture before uploading
          final compressedImage = await _compressProfilePicture(
            _profilePictureFile!,
          );

          if (compressedImage != null) {
            // Check final size after compression
            final finalSize = await compressedImage.length();
            debugPrint('Final profile picture size: ${finalSize / 1024} KB');

            // If still above 1MB after compression, show warning but continue
            if (finalSize > 1024 * 1024) {
              debugPrint(
                'Warning: Profile picture still above 1MB after compression',
              );
            }

            // Add the compressed image to request
            request.files.add(
              await http.MultipartFile.fromPath(
                'profile_picture',
                compressedImage.path,
              ),
            );
            debugPrint(
              'Uploading compressed profile picture: ${compressedImage.path}',
            );
          } else {
            // If compression fails, use original image
            debugPrint('Failed to compress profile picture, using original');
            request.files.add(
              await http.MultipartFile.fromPath(
                'profile_picture',
                _profilePictureFile!.path,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error compressing profile picture: $e, using original');
          // If compression fails, use original image
          request.files.add(
            await http.MultipartFile.fromPath(
              'profile_picture',
              _profilePictureFile!.path,
            ),
          );
        }
      } else if (profilePictureUrl.isNotEmpty &&
          !profilePictureUrl.startsWith('http') &&
          !profilePictureUrl.startsWith('/media/')) {
        // This is a local file path that we should upload
        final localFile = File(profilePictureUrl);
        if (await localFile.exists()) {
          try {
            // Compress the local file
            final compressedImage = await _compressProfilePicture(localFile);
            if (compressedImage != null) {
              request.files.add(
                await http.MultipartFile.fromPath(
                  'profile_picture',
                  compressedImage.path,
                ),
              );
            }
          } catch (e) {
            debugPrint('Error processing local profile picture: $e');
          }
        }
      } else {
        // No new profile picture - server will keep existing one
        debugPrint('No new profile picture specified, keeping existing');
      }

      debugPrint('Sending request...');
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: $respStr');

      isSaving = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(respStr);

        // Update profile picture URL from response if available
        if (responseData.containsKey('profile_picture')) {
          profilePictureUrl =
              responseData['profile_picture'] ?? profilePictureUrl;
          // Clear local file after successful upload
          _profilePictureFile = null;
        }

        debugPrint('Save successful!');
        return true;
      } else {
        final errorData = jsonDecode(respStr);
        debugPrint('Save failed with errors: $errorData');
        return false;
      }
    } catch (e) {
      debugPrint('Save error: $e');
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // Add this method to clear profile picture
  void clearProfilePicture() {
    _profilePictureFile = null;
    profilePictureUrl = '';
    notifyListeners();
  }

  // Add this method to validate profile picture
  String? validateProfilePicture() {
    if (_profilePictureFile != null) {
      // Check file size (max 1MB)
      try {
        final fileSize = _profilePictureFile!.lengthSync();
        if (fileSize > 1 * 1024 * 1024) {
          return 'Profile picture should be less than 1MB (will be compressed automatically)';
        }
      } catch (e) {
        // Ignore size check if file doesn't exist
      }

      // Check file extension
      final fileName = _profilePictureFile!.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png'];

      if (!allowedExtensions.contains(extension)) {
        return 'Please select a valid image (JPG, JPEG, PNG)';
      }
    }

    return null;
  }

  // ---------- validation ----------
 bool get canProceed {
  final basicInfoValid = firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      phoneCtrl.text.trim().isNotEmpty &&
      addressCtrl.text.trim().isNotEmpty &&
      selectedGender != null &&
      selectedGender!.isNotEmpty;
  
  // During edit mode, payment option is not required
  if (isEditMode) {
    return basicInfoValid;
  }
  
  // During registration, payment option is required
  return basicInfoValid &&
      selectindex != null &&
      (selectindex == 0 || (selectindex == 1 && selectedFleet != null));
}
}
