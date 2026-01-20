import 'dart:convert';
import 'package:addrive/Model/apiconfig.dart';
import 'package:addrive/Model/fcmtokenpassing.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _accessToken = '';
  String _refreshToken = '';
  int _userId = 0;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;
  String get userId => _userId.toString();

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // FIX: Tokens are nested under 'data' object
        if (responseData.containsKey('data')) {
          final Map<String, dynamic> data = responseData['data'];
          _accessToken = data['access'] ?? '';
          _refreshToken = data['refresh'] ?? '';
          _userId = data['user_id'] ?? 0;

          print('Access Token: $_accessToken');
          print('Refresh Token: $_refreshToken');
          print('Tokens extracted successfully from data object');

          // Save tokens to shared preferences
          await _saveTokens(_accessToken, _refreshToken, _userId.toString());

          // 🔔 Send FCM token after login
          final String? fcmToken = await FcmService.getToken();
          print('FCM Token: $fcmToken');
          if (fcmToken != null) {
            await FcmService.sendTokenToBackend(fcmToken);
            FcmService.listenTokenRefresh();
          }

          _errorMessage = '';

          _isLoading = false;
          notifyListeners(); 
          return true; // Return true for success
        } else {
          _errorMessage = 'Invalid response format: missing data object';
          _isLoading = false;
          notifyListeners();
          return false; // Return false for failure
        }
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage =
            errorData['message'] ??
            errorData['error'] ??
            'Login failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false; // Return false for failure
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      print('Network error: ${e.toString()}');
      _isLoading = false;
      notifyListeners();
      return false; // Return false for failure
    }
  }

  Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
    String userId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      await prefs.setString('user_id', userId);

      print("═══════════════════════════════════════");
      print("✅ TOKENS SAVED SUCCESSFULLY");
      print("═══════════════════════════════════════");
      print("Access Token saved: ${accessToken.isNotEmpty ? 'YES' : 'NO'}");
      print("Refresh Token saved: ${refreshToken.isNotEmpty ? 'YES' : 'NO'}");
      print("Access Token length: ${accessToken.length}");
      print("Refresh Token length: ${refreshToken.length}");
      print(userId);
      print("═══════════════════════════════════════");

      // Verify the tokens were actually saved
      final savedAccess = prefs.getString('access_token');
      final savedRefresh = prefs.getString('refresh_token');

      print(
        "Verification - Saved Access Token: ${savedAccess != null ? 'EXISTS' : 'MISSING'}",
      );
      print(
        "Verification - Saved Refresh Token: ${savedRefresh != null ? 'EXISTS' : 'MISSING'}",
      );
    } catch (e) {
      print("❌ ERROR SAVING TOKENS: $e");
    }
  }

  Future<void> loadTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token') ?? '';
      _refreshToken = prefs.getString('refresh_token') ?? '';

      print("═══════════════════════════════════════");
      print("🔍 LOADED TOKENS FROM SHARED PREFERENCES");
      print("═══════════════════════════════════════");
      print("Access Token loaded: ${_accessToken.isNotEmpty ? 'YES' : 'NO'}");
      print("Refresh Token loaded: ${_refreshToken.isNotEmpty ? 'YES' : 'NO'}");
      print("Access Token: $_accessToken");
      print("Refresh Token: $_refreshToken");
      print("═══════════════════════════════════════");

      notifyListeners();
    } catch (e) {
      print("❌ ERROR LOADING TOKENS: $e");
    }
  }

  Future<Map<String, String?>> getStoredTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final access = prefs.getString('access_token');
      final refresh = prefs.getString('refresh_token');

      print("🔍 GET STORED TOKENS:");
      print("Access Token: ${access != null ? 'EXISTS' : 'NULL'}");
      print("Refresh Token: ${refresh != null ? 'EXISTS' : 'NULL'}");

      return {'access_token': access, 'refresh_token': refresh};
    } catch (e) {
      print("❌ ERROR GETTING STORED TOKENS: $e");
      return {'access_token': null, 'refresh_token': null};
    }
  }

  Future<void> resendOtp(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://addrive.kkms.co.in/api/driver/resend-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
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

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      _accessToken = '';
      _refreshToken = '';

      print("✅ LOGOUT: Tokens cleared from SharedPreferences");
      notifyListeners();
    } catch (e) {
      print("❌ ERROR DURING LOGOUT: $e");
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  //forgot password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        // Uri.parse(ApiConfig.forgotPasswordUrl),
        Uri.parse('https://addrive.kkms.co.in/api/driver/forgot-password/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print('Forgot Password Response status: ${response.statusCode}');
      print('Forgot Password Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _errorMessage = responseData['message'] ?? 'OTP sent to your email';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage =
            errorData['message'] ?? errorData['error'] ?? 'Failed to send OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      print("❌ ERROR DURING FORGOT PASSWORD: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendForgotOtp(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/driver/resend-forgot-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print('Resend Forgot OTP Response status: ${response.statusCode}');
      print('Resend Forgot OTP Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _errorMessage = responseData['message'] ?? 'OTP resent to your email';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage =
            errorData['message'] ??
            errorData['error'] ??
            'Failed to resend OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyForgotOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://addrive.kkms.co.in/api/driver/verify-forgot-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );

      print('Verify Forgot OTP Response status: ${response.statusCode}');
      print('Verify Forgot OTP Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _errorMessage = responseData['message'] ?? 'OTP verified successfully';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage =
            errorData['message'] ?? errorData['Oops!'] ?? 'Invalid OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://addrive.kkms.co.in/api/driver/reset-password/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'new_password': newPassword}),
      );

      print('Reset Password Response status: ${response.statusCode}');
      print('Reset Password Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _errorMessage =
            responseData['message'] ?? 'Password reset successfully';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage =
            errorData['message'] ??
            errorData['error'] ??
            'Failed to reset password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
