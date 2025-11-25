
import 'dart:convert';
import 'dart:io';
import 'package:addrive/Model/apiconfig.dart';
import 'package:addrive/View/Screens/ProfileRegistration/personaldetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class RegisterProvider with ChangeNotifier {
  bool isLoading = false;
  String? _errorMessage;
  File? _imageFile;
  String? _accessToken;
  String? _refreshToken;

  String? get errorMessage => _errorMessage;
  File? get imageFile => _imageFile;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

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

  // Save tokens to SharedPreferences
  Future<void> _saveTokensToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_accessToken != null) {
        await prefs.setString('access_token', _accessToken!);
      }
      if (_refreshToken != null) {
        await prefs.setString('refresh_token', _refreshToken!);
      }
      print("Tokens saved to storage successfully");
    } catch (e) {
      print("Error saving tokens to storage: $e");
    }
  }

  // Load tokens from SharedPreferences
  Future<void> loadTokensFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      print("Tokens loaded from storage: Access Token - ${_accessToken != null ? 'exists' : 'null'}, Refresh Token - ${_refreshToken != null ? 'exists' : 'null'}");
      notifyListeners();
    } catch (e) {
      print("Error loading tokens from storage: $e");
    }
  }

  // Clear tokens from storage (for logout)
  Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      _accessToken = null;
      _refreshToken = null;
      print("Tokens cleared from storage");
      notifyListeners();
    } catch (e) {
      print("Error clearing tokens: $e");
    }
  }

  // Check if user is logged in
  bool get isLoggedIn {
    return _accessToken != null && _accessToken!.isNotEmpty;
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
    final url = Uri.parse(ApiConfig.registerdriverUrl);

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

    // Parse response BEFORE setting isLoading to false
    final responseBody = jsonDecode(response.body);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Registration successful. Response: $responseBody");

      // Extract tokens from response
      _accessToken = responseBody['access'] ?? '';
      _refreshToken = responseBody['refresh'] ?? '';

      // Check if tokens are properly received
      if (_accessToken!.isEmpty || _refreshToken!.isEmpty) {
        print("Warning: Tokens might be missing in response");
        // Check alternative token field names
        _accessToken = responseBody['access_token'] ?? _accessToken;
        _refreshToken = responseBody['refresh_token'] ?? _refreshToken;
      }

      print("Access Token: ${_accessToken != null && _accessToken!.isNotEmpty ? 'Received' : 'Missing'}");
      print("Refresh Token: ${_refreshToken != null && _refreshToken!.isNotEmpty ? 'Received' : 'Missing'}");

      // Save tokens to persistent storage
      await _saveTokensToStorage();

      // Clear the image file after successful registration
      _imageFile = null;

      isLoading = false;
      notifyListeners();
      return true;
      
    } else {
      print("Registration failed. Status: ${response.statusCode}, Response: $responseBody");
      
      _errorMessage = responseBody['message'] ?? 
                      responseBody['error'] ??
                      responseBody['detail'] ??
                      'Registration failed with status code: ${response.statusCode}';
      
      isLoading = false;
      notifyListeners();
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

  // Method to refresh access token using refresh token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) {
      print("No refresh token available");
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('https://addrive.kkms.co.in/api/token/refresh/');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': _refreshToken,
        }),
      );

      isLoading = false;

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        _accessToken = responseBody['access'] ?? '';
        
        if (_accessToken!.isNotEmpty) {
          // Save new access token to storage
          await _saveTokensToStorage();
          notifyListeners();
          return true;
        }
      } else {
        print("Token refresh failed: ${response.statusCode}");
        // If refresh fails, clear tokens (user needs to login again)
        await clearTokens();
      }
    } catch (e) {
      isLoading = false;
      print("Token refresh error: $e");
      await clearTokens();
    }

    return false;
  }

  // Get headers with authorization token for API calls
  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_accessToken != null && _accessToken!.isNotEmpty)
        'Authorization': 'Bearer $_accessToken',
    };
  }

  void clearImage() {
    _imageFile = null;
    notifyListeners();
  }

  // Initialize provider - load tokens when app starts
  Future<void> initialize() async {
    await loadTokensFromStorage();
  }
}