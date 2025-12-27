import 'package:addrive/Model/apiclient.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ActiveCampaignProvider with ChangeNotifier{
  final ApiClient api = ApiClient();
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
    final response = await api.get(
      'https://addrive.kkms.co.in/api/driver/active-campaign/',
    );

    if (response.statusCode == 200) {
      _campaignData = jsonDecode(response.body);
      _error = null;
    } else {
      _error = 'Failed (${response.statusCode})';
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