// providers/otp_provider.dart
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OtpProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isVerified = false;
  String _accessToken = '';
  String _refreshToken = '';
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;
  String get errorMessage => _errorMessage;
  bool get isVerified => _isVerified;
  Map<String, dynamic>? get userData => _userData;

  Future<void> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = '';
    _isVerified = false;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.31:8001/api/driver/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );

      _isLoading = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ STATUS OK 200");
        print("Response body: ${response.body}");

        final res = jsonDecode(response.body);
        print("Response keys: ${res.keys}");

        // The tokens are nested inside 'tokens' object
        if (res['tokens'] != null) {
          _accessToken = res['tokens']['access'] ?? '';
          _refreshToken = res['tokens']['refresh'] ?? '';
          print("🔑 Tokens found in nested structure");
        } else {
          // Fallback to old structure if API changes
          _accessToken = res['access'] ?? '';
          _refreshToken = res['refresh'] ?? '';
          print("🔑 Tokens found in flat structure");
        }

        // Store user data if needed
        _userData = res['user'];

        print("Access Token Length: ${_accessToken.length}");
        print("Refresh Token Length: ${_refreshToken.length}");
        print("User Data: $_userData");

        if (_accessToken.isNotEmpty && _refreshToken.isNotEmpty) {
          await _saveTokens(_accessToken, _refreshToken);
          await _saveUserData(_userData);
          _isVerified = true;
          _errorMessage = '';
          print("✅ OTP Verified Successfully! _isVerified = $_isVerified");
        } else {
          _isVerified = false;
          _errorMessage = 'Failed to retrieve tokens';
          print("❌ ERROR: Tokens are empty");
          print("Access empty: ${_accessToken.isEmpty}, Refresh empty: ${_refreshToken.isEmpty}");
        }
      } else if (response.statusCode == 400) {
        final res = jsonDecode(response.body);
        _errorMessage = res['message'] ?? 'Invalid OTP. Please try again.';
        _isVerified = false;
        print("FAILED 400: ${response.body}");
      } else {
        _errorMessage = 'Verification failed. Please try again.';
        _isVerified = false;
        print("FAILED: ${response.statusCode}");
        print("BODY: ${response.body}");
      }
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Network error. Please check your connection.';
      _isVerified = false;
      print("ERROR: $error");
    }

    notifyListeners();
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      print("Tokens saved to SharedPreferences");
    } catch (e) {
      print("Error saving tokens: $e");
    }
  }

  Future<void> _saveUserData(Map<String, dynamic>? userData) async {
    if (userData == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(userData));
      await prefs.setInt('user_id', userData['id'] ?? 0);
      await prefs.setString('user_email', userData['email'] ?? '');
      await prefs.setString('first_name', userData['first_name'] ?? '');
      await prefs.setString('last_name', userData['last_name'] ?? '');
      print("User data saved to SharedPreferences");
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  Future<void> resendOtp(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.31:8001/api/driver/resend-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      _isLoading = false;

      if (response.statusCode == 200) {
        print("OTP Resent Successfully");
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to resend OTP. Please try again.';
        print("Resend failed: ${response.statusCode}");
      }
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Network error. Please check your connection.';
      print("Resend error: $error");
    }

    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _errorMessage = '';
    _isVerified = false;
    _accessToken = '';
    _refreshToken = '';
    _userData = null;
    notifyListeners();
  }
}