import 'dart:convert';

import 'package:addrive/Model/apiclient.dart';
import 'package:addrive/Model/apiconfig.dart';
import 'package:addrive/Model/profiledata_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  final ApiClient api = ApiClient();
  ProfileData? _profileData;
  bool _isLoading = false;
  String _error = '';

  ProfileData? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchProfileData() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Get access token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        _error = 'No access token found. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await api.get(ApiConfig.fullDetailsUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _profileData = ProfileData.fromJson(data);
        _error = '';
      } else if (response.statusCode == 401) {
        _error = 'Authentication failed. Please login again.';
        // Optionally clear the token if it's invalid
        await _clearToken();
      } else if (response.statusCode == 403) {
        _error = 'Access denied. Please check your permissions.';
      } else if (response.statusCode == 404) {
        _error = 'Profile data not found.';
      } else {
        _error = 'Failed to load profile data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching profile data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to clear token (useful for logout or when token is invalid)
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  // Method to manually set profile data (useful for testing or updates)
  void setProfileData(ProfileData data) {
    _profileData = data;
    notifyListeners();
  }

  // Method to update profile data after editing
  Future<void> updateProfileData() async {
    await fetchProfileData();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Optional: Method to check if user is authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }

  // Optional: Method to get token (useful for other API calls)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // In ProfileProvider class
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('payment_option');
      // Clear any other user-related data
      await prefs.clear(); // Optional: Clear all stored data

      // Reset provider state
      _profileData = null;
      _error = '';
      notifyListeners();
    } catch (e) {
      // Even if there's an error, we still clear tokens and redirect
      debugPrint('Logout error: $e');
      // Force clear tokens regardless of error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('payment_option');
    }
  }
}
