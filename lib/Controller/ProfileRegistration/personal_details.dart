// import 'package:flutter/material.dart';

// class PersonalDetailsProvider extends ChangeNotifier {
//   int selectindex =0;

//   void setTab(int index) {
//     selectindex = index;
//     notifyListeners();
//   }
// }

// Controller/ProfileRegistration/personal_details.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PersonalDetailsProvider extends ChangeNotifier {
  int selectindex = 0;               // 0 = self, 1 = fleet
  bool isLoading = true;

  // ---- data that comes from the server ----
  String firstName = '';
  String lastName = '';
  String profilePictureUrl = '';      // empty → show placeholder
  String paymentOption = 'self';      // default

  // local controllers (for the fields that are NOT in the API yet)
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController genderCtrl = TextEditingController();

  // -------------------------------------------------
  void setTab(int index) {
    selectindex = index;
    paymentOption = index == 0 ? 'self' : 'fleet';
    notifyListeners();
  }

  // ------------------ API -----------------------
  Future<void> fetchPersonalDetails() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.31:8001/api/driver/profile-details/'), // <<< replace
        headers: {'Authorization': 'Bearer <token>'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        firstName         = data['first_name'] ?? '';
        lastName          = data['last_name'] ?? '';
        profilePictureUrl = data['profile_picture'] ?? '';
        paymentOption     = data['payment_option'] ?? 'self';

        selectindex = paymentOption == 'self' ? 0 : 1;
      }
    } catch (e) {
      debugPrint('API error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  // Controller/ProfileRegistration/personal_details.dart

// Add these imports at the top (if not already there)


// Inside the class, add this method:
Future<bool> saveProfileDetails() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');
    if (token == null) return false;

    // Prepare multipart request (for image + text fields)
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.31:8001/api/driver/profile-details/'),
    );

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Add text fields
    request.fields['first_name'] = firstName;
    request.fields['last_name'] = lastName;
    request.fields['phone_number'] = phoneCtrl.text.trim();
    request.fields['address'] = addressCtrl.text.trim();
    request.fields['gender'] = genderCtrl.text.trim();
    request.fields['payment_option'] = paymentOption;

    // Add profile picture if selected
    if (profilePictureUrl.isNotEmpty && !profilePictureUrl.startsWith('http')) {
      // Local file path → add as multipart file
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        profilePictureUrl,
      ));
    } else if (profilePictureUrl.startsWith('http')) {
      // Already uploaded (from API) → send URL
      request.fields['profile_picture'] = profilePictureUrl;
    }

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(respStr);
      // Optional: update local fields from response
      return true;
    } else {
      debugPrint('Save failed: ${response.statusCode} $respStr');
      return false;
    }
  } catch (e) {
    debugPrint('Save error: $e');
    return false;
  }
}

  // ---------- validation ----------
  bool get canProceed =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      phoneCtrl.text.trim().isNotEmpty &&
      addressCtrl.text.trim().isNotEmpty &&
      genderCtrl.text.trim().isNotEmpty &&
      profilePictureUrl.isNotEmpty;   // you will set it when user picks an image
}