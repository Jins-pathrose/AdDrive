// providers/entrypage_provider.dart
import 'package:addrive/Model/apiconfig.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EntryPageProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isCheckingToken = true;
  
  bool get isLoading => _isLoading;
  bool get isCheckingToken => _isCheckingToken;
  
  // Check if access token exists and is valid
  Future<bool> checkAndValidateToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');
      
      if (accessToken == null || refreshToken == null) {
        _isCheckingToken = false;
        notifyListeners();
        return false;
      }
      
      // First, check if current token is valid
      final isValid = await _verifyToken(accessToken);
      
      if (isValid) {
        _isCheckingToken = false;
        notifyListeners();
        return true;
      } else {
        // Token is invalid or expired, try to refresh
        final newToken = await _refreshAccessToken(refreshToken);
        
        if (newToken != null) {
          await prefs.setString('access_token', newToken);
          _isCheckingToken = false;
          notifyListeners();
          return true;
        } else {
          // Refresh failed, clear tokens
          await prefs.remove('access_token');
          await prefs.remove('refresh_token');
          _isCheckingToken = false;
          notifyListeners();
          return false;
        }
      }
    } catch (e) {
      print('Error checking token: $e');
      _isCheckingToken = false;
      notifyListeners();
      return false;
    }
  }
  
  // Verify if token is still valid
  Future<bool> _verifyToken(String token) async {
    try {
      // Make a simple API call to verify token
      // Adjust this endpoint based on your API
      final response = await http.get(
        Uri.parse(ApiConfig.fullDetailsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Refresh access token using refresh token
  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://addrive.kkms.co.in/api/token/refresh/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }
  
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void resetChecking() {
    _isCheckingToken = true;
    notifyListeners();
  }
}