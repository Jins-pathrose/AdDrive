import 'dart:convert';
import 'dart:io';
import 'package:addrive/Model/apiconfig.dart';
import 'package:addrive/View/Screens/ProfileRegistration/personaldetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Add this import

class RegisterProvider with ChangeNotifier {
  bool isLoading = false;
  String? _errorMessage;
  File? _imageFile;

  String? get errorMessage => _errorMessage;
  File? get imageFile => _imageFile;

  // Method to set the selected image
  void setImageFile(File? image) {
    _imageFile = image;
    print("Image set: ${_imageFile?.path}"); // DEBUG
    notifyListeners();
  }

  // Validation method for image
  String? validateImage() {
    if (_imageFile == null) {
      print("Validating image: $_imageFile"); // DEBUG
      return 'Please select a profile picture';
    }

    // Check file size (max 5MB)
    if (_imageFile!.lengthSync() > 5 * 1024 * 1024) {
      return 'Image size should be less than 5MB';
    }

    // Check file extension
    final fileName = _imageFile!.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];

    if (!allowedExtensions.contains(extension)) {
      return 'Please select a valid image (JPG, JPEG, PNG, GIF, BMP)';
    }

    return null;
  }

  Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    // Validate image before proceeding
    final imageError = validateImage();
    if (imageError != null) {
      _errorMessage = imageError;
      notifyListeners();
      return false;
    }

    isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('http://192.168.1.31:8001/api/driver/register/');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add text fields
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['email'] = email;
      request.fields['phone_number'] = phone;
      request.fields['password'] = password;

      // Add image file if exists
      if (_imageFile != null) {
        final fileName = _imageFile!.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        final multipartFile = await http.MultipartFile.fromPath(
          'profile_picture',
          _imageFile!.path,
          contentType: MediaType('image', extension),
          filename: fileName,
        );
        request.files.add(multipartFile);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
        
      } else {
        final responseBody = jsonDecode(response.body);
        print("Response body: $responseBody");
        _errorMessage =
            responseBody['message'] ??
            responseBody['error'] ??
            'Registration failed with status code: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      isLoading = false;
      _errorMessage = 'Registration failed. Please try again.';
      print("Network error: ${e.toString()}");
      notifyListeners();
      return false;
    }
  }

  void clearImage() {
    _imageFile = null;
    notifyListeners();
  }
}
