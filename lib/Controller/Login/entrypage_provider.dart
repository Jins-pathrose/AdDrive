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
        final refreshResult = await _refreshAccessToken(refreshToken);
        print(refreshResult);
        print("ijijijijijijijij");
        if (refreshResult != null && refreshResult['access'] != null) {
          // Save both new tokens
          await prefs.setString('access_token', refreshResult['access']!);
          
          // Also save the new refresh token if provided
          if (refreshResult['refresh'] != null) {
            await prefs.setString('refresh_token', refreshResult['refresh']!);
          }
          
          _isCheckingToken = false;
          notifyListeners();
          return true;
        } else {
          // Refresh failed, clear tokens
          await prefs.remove('access_token');
          await prefs.remove('refresh_token');
          print('namskaaarammmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm');
          
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
      print(response.statusCode);
      print("15515151551515");
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Refresh access token using refresh token
  // Returns a map with 'access' and 'refresh' tokens or null if failed
  
  Future<Map<String, String>?> _refreshAccessToken(String refreshToken) async {
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
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        final accessToken = data['access'] as String?;
        final refreshToken = data['refresh'] as String?;
        
        if (accessToken != null) {
          return {
            'access': accessToken,
            if (refreshToken != null) 'refresh': refreshToken,
          };
        }
        print(response.statusCode);
        print("token refresh failed with status: ${response.statusCode}");
        return null;
      } else {
        print('Token refresh failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
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