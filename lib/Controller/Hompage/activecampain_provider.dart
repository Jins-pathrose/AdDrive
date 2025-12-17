import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ActiveCampaignProvider with ChangeNotifier {
  Map<String, dynamic>? _campaignData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get campaignData => _campaignData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchActiveCampaign() async {
    _isLoading = true;
    notifyListeners();

    try {
       final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse('https://addrive.kkms.co.in/api/driver/active-campaign/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _campaignData = data;
        _error = null;
      } else {
        _error = 'Failed to load campaign data';
        _campaignData = null;
      }
    } catch (e) {
      _error = 'Error: $e';
      _campaignData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCampaignData() {
    _campaignData = null;
    _error = null;
    notifyListeners();
  }
}