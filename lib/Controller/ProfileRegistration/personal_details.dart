// Controller/ProfileRegistration/personal_details.dart
import 'dart:io';

import 'package:addrive/Model/apiconfig.dart';
import 'package:addrive/Model/fleetmodel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class PersonalDetailsProvider extends ChangeNotifier {
  int selectindex = 0;               // 0 = self, 1 = fleet
  bool isLoading = true;
  bool isSaving = false;
  List<Fleet> fleets = [];
  Fleet? selectedFleet;
  bool isLoadingFleets = false;

  // ---- data that comes from the server ----
  String firstName = '';
  String lastName = '';
  String profilePictureUrl = ''; 
  String phone = '';  
  String email = '';              
  String address = '';
  String gender = '';
  String paymentOption = 'self';      // default

  // Gender dropdown options
  final List<String> genderOptions = ['Male', 'Female'];
  String? selectedGender;

  // local controllers
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  // -------------------------------------------------
   void setTab(int index) {
    selectindex = index;
    paymentOption = index == 0 ? 'self' : 'fleet';
    
    // Fetch fleets when fleet tab is selected
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
Future<void> fetchPersonalDetails() async {
  isLoading = true;
  notifyListeners();

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? 'your_token_here';
    
    final response = await http.get(
      Uri.parse(ApiConfig.personalDetailsUrl),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
 
      firstName         = data['first_name'] ?? '';
      lastName          = data['last_name'] ?? '';
      phone             = data['phone_number'] ?? '';
      email             = data['email'] ?? '';
      profilePictureUrl = data['profile_picture'] ?? '';
      paymentOption     = data['payment_option'] ?? 'self';
      address           = data['address'] ?? '';
      gender            = data['gender'] ?? '';

      // Set phone number in controller
      phoneCtrl.text = phone;
      addressCtrl.text = address;
      
      
      // FIX: Properly set selected gender - capitalize first letter to match dropdown
      if (gender.isNotEmpty) {
        selectedGender = gender[0].toUpperCase() + gender.substring(1).toLowerCase();
      } else {
        selectedGender = null;
      }

      selectindex = paymentOption == 'self' ? 0 : 1;
    }
  } catch (e) {
    debugPrint('API error: $e');
  } finally {
    isLoading = false;
    notifyListeners();
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
        
        fleets = fleetsData.map((fleetJson) => Fleet.fromJson(fleetJson)).toList();
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
  // In saveProfileDetails method, after successful save:
final prefs = await SharedPreferences.getInstance();
await prefs.setInt('payment_option', selectindex);
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
    // FIXED: Handle profile picture properly
    if (profilePictureUrl.isNotEmpty) {
      if (profilePictureUrl.startsWith('/') && 
          !profilePictureUrl.startsWith('/media/') && 
          await File(profilePictureUrl).exists()) {
        // This is a valid local file that exists - upload it
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          profilePictureUrl,
        ));
        debugPrint('Uploading local profile picture: $profilePictureUrl');
      } else if (profilePictureUrl.startsWith('http') || profilePictureUrl.startsWith('/media/')) {
        // This is already on server - DO NOT include it in the request
        // The server should keep the existing image
        debugPrint('Profile picture already on server, not sending in request');
        // Don't add any profile_picture field or file
      } else {
        debugPrint('Invalid profile picture path, not sending any image');
        // Don't add any profile_picture field or file
      }
    } else {
      // No profile picture - explicitly set to null/empty if API requires it
      // request.fields['profile_picture'] = ''; // Only if API requires this
      debugPrint('No profile picture specified');
    }

    debugPrint('Sending request...');
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    
    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: $respStr');

    isSaving = false;
    notifyListeners();

    if (response.statusCode == 200 || response.statusCode == 201) {
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

  // ---------- validation ----------
    bool get canProceed =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      phoneCtrl.text.trim().isNotEmpty &&
      addressCtrl.text.trim().isNotEmpty &&
      selectedGender != null &&
      selectedGender!.isNotEmpty &&
      (selectindex == 0 || (selectindex == 1 && selectedFleet != null));
}