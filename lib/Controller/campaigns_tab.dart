// tab_provider.dart
import 'dart:convert';

import 'package:addrive/Model/apiconfig.dart';
import 'package:addrive/Model/campaigns_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CampaignTabProvider extends ChangeNotifier {
  int _selectedTab = 0;

  int get selectedTab => _selectedTab;

  void setTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }
}
// campaigns_provider.dart

class CampaignsProvider with ChangeNotifier {
  List<Campaign> _campaigns = [];
  List<Campaign> _completedCampaigns = [];
  bool _isLoading = false;
  String? _error;

  List<Campaign> get campaigns => _campaigns;
  List<Campaign> get completedCampaigns => _completedCampaigns;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCampaigns(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.campaignListingUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final campaignsData = data['campaigns'] as List<dynamic>? ?? [];

        // Convert JSON to Campaign models
        _campaigns = campaignsData.map((campaignJson) {
          return Campaign.fromJson(campaignJson);
        }).toList();

        // Filter completed campaigns
        _completedCampaigns = _campaigns.where((campaign) {
          return campaign.isCompleted;
        }).toList();

        _error = null;
      } else if (response.statusCode == 401) {
        _error = 'Authentication failed. Please login again.';
      } else if (response.statusCode == 404) {
        _error = 'Campaigns not found.';
      } else {
        _error = 'Failed to load campaigns: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching campaigns: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinCampaign(String campaignId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final url = Uri.parse(
        ApiConfig.joinCampaignUrl(campaignId),
      );

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",

        },
        body: "", // MUST send empty body so Content-Length=0
      );
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCampaigns(token!);
        return true;
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Campaign? getCampaignById(String id) {
    try {
      return _campaigns.firstWhere((campaign) => campaign.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Campaign> getActiveCampaigns() {
    return _campaigns.where((campaign) => campaign.isActive).toList();
  }

  List<Campaign> getUpcomingCampaigns() {
    return _campaigns.where((campaign) => campaign.isUpcoming).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  // campaigns_provider.dart - Add these methods to CampaignsProvider class

Future<Map<String, dynamic>?> checkCampaignStatus(String campaignId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  try {
    final url = Uri.parse(
      ApiConfig.joinCampaignUrl(campaignId),
    );

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'campaign_id': data['campaign_id'],
        'request_id': data['request_id'],
        'status': data['status'],
      };
    }
    return null;
  } catch (e) {
    print("Error checking campaign status: $e");
    return null;
  }
}

Future<bool> cancelCampaignRequest(String requestId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  print(requestId);
  print('0000000');
  try {
    final url = Uri.parse(
      ApiConfig.cancelRequestsUrl(requestId),
    );

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }
    print(response.statusCode);
    print(response.body);
    return false;
  } catch (e) {
    print("Error canceling campaign request: $e");
    return false;
  }
}
}
