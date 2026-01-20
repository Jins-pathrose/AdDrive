import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FcmService {
  static const String _url =
      "https://addrive.kkms.co.in/api/save-fcm-token/";

  /// Get FCM token
  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  /// Send token to backend
  static Future<void> sendTokenToBackend(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
          if (accessToken != null && accessToken.isNotEmpty)
            "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode({
          "fcm_token": token,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ FCM token sent to backend");
      } else {
        print("❌ Failed to send FCM token: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending FCM token: $e");
    }
  }

  /// Handle token refresh
  static void listenTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      sendTokenToBackend(newToken);
    });
  }
}
