import 'package:addrive/Model/apiclient.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ActiveCampaignProvider with ChangeNotifier {
  final ApiClient api = ApiClient();
  Map<String, dynamic>? _campaignData;
  bool _isLoading = false;
  String? _error;
  List<dynamic>? _sortedParticipants;

  Map<String, dynamic>? get campaignData => _campaignData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic>? get sortedParticipants => _sortedParticipants;

  Future<void> fetchActiveCampaign() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First fetch active campaign to get campaign ID
      final activeResponse = await api.get(
        'https://addrive.kkms.co.in/api/driver/active-campaign/',
      );

      if (activeResponse.statusCode == 200) {
        final activeData = jsonDecode(activeResponse.body);

        if (activeData['status'] == 'active_campaign') {
          final campaignId = activeData['campaign']['id'];
print(campaignId);
          // Now fetch campaign progress data
          final progressResponse = await api.get(
            'https://addrive.kkms.co.in/api/campaign/$campaignId/driver-progress/',
          );
          print(progressResponse.statusCode); 
          print(progressResponse.body);
          print('suiiiiiiiiiiiiiiiiiiiiiii');
          if (progressResponse.statusCode == 200) {
            final progressData = jsonDecode(progressResponse.body);

            // Combine both data
            _campaignData = {...activeData, 'progress': progressData};

            // Sort participants by percentage (descending)
            _sortParticipants(progressData);

            _error = null;
          } else {
            _error = 'Failed to load progress (${progressResponse.statusCode})';
            _campaignData = null;
          }
        } else {
          _campaignData = null;
          _sortedParticipants = null;
        }
      } else {
        _error = 'Failed (${activeResponse.statusCode})';
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

  void _sortParticipants(Map<String, dynamic> progressData) {
    final List<dynamic> allDrivers = [];

    // Add current driver first
    if (progressData['current_driver_progress'] != null) {
      allDrivers.add(progressData['current_driver_progress']);
    }

    // Add other drivers
    if (progressData['other_drivers_progress'] != null) {
      allDrivers.addAll(progressData['other_drivers_progress']);
    }

    // Sort by percentage (descending)
    allDrivers.sort((a, b) {
      final double percentA = double.parse(a['percentage'].replaceAll('%', ''));
      final double percentB = double.parse(b['percentage'].replaceAll('%', ''));
      return percentB.compareTo(percentA);
    });

    _sortedParticipants = allDrivers;
  }

  void clearCampaignData() {
    _campaignData = null;
    _error = null;
    _sortedParticipants = null;
    notifyListeners();
  }
}
