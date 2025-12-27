// api_client.dart
import 'dart:convert';
import 'package:addrive/Model/tokenrefresh.dart';
import 'package:http/http.dart' as http;

class ApiClient with TokenRefreshMixin {
  Future<http.Response> get(String url) async {
    return _sendWithRetry(() async {
      final token = await getAccessToken();
      return http.get(
        Uri.parse(url),
        headers: _headers(token),
      );
    });
  }

  Future<http.Response> post(String url, {Map<String, dynamic>? body}) async {
    return _sendWithRetry(() async {
      final token = await getAccessToken();
      return http.post(
        Uri.parse(url),
        headers: _headers(token),
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function() request,
  ) async {
    http.Response response = await request();

    if (response.statusCode == 401) {
      final newToken = await refreshAndGetAccessToken();
      if (newToken != null) {
        response = await request(); // 🔁 retry once
      }
    }
    return response;
  }
}
