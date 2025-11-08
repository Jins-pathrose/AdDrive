// providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _accessToken = '';
  String _refreshToken = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;

  // Base URL - update with your actual IP
  static const String baseUrl = 'http://192.168.1.31:8001';
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.31:8001/api/driver/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        _accessToken = responseData['access'] ?? '';
        _refreshToken = responseData['refresh'] ?? '';
        
        // Save tokens to shared preferences
        await _saveTokens(_accessToken, _refreshToken);
        
        _errorMessage = '';
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? 'Login failed. Please try again.';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      print('Network error: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/driver/resend-otp/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        _errorMessage = '';
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to resend OTP.';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token') ?? '';
    _refreshToken = prefs.getString('refresh_token') ?? '';
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _accessToken = '';
    _refreshToken = '';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}