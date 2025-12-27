import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

mixin TokenRefreshMixin {
  Future<String?> refreshAndGetAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse('https://addrive.kkms.co.in/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final access = data['access'];
        final refresh = data['refresh'];

        if (access != null) {
          await prefs.setString('access_token', access);
        }
        if (refresh != null) {
          await prefs.setString('refresh_token', refresh);
        }

        return access;
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }
    return null;
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
