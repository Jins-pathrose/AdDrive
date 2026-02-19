import 'package:addrive/Model/apiclient.dart';
import 'package:addrive/Model/apiconfig.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
      // Get driver_id from SharedPreferences
      await _getdriverid();
      final prefs = await SharedPreferences.getInstance();
      final int? driverId = prefs.getInt('driver_id');

      if (driverId == null) {
        _error = 'Driver ID not found. Please login again.';
        _campaignData = null;
        _sortedParticipants = null;
        return;
      }

      // First check for active trip
      final startTripResponse = await api.get(
        'https://backend.drarifdentistry.com/api/start-trip?driver_id=$driverId',
      );

      if (startTripResponse.statusCode == 200) {
        final startTripData = jsonDecode(startTripResponse.body);

        print('Start Trip Response: $startTripData');

       if (startTripData['can_start_new'] == false && 
    startTripData['trip_details'] != null) {
  // Trip exists (whether active or paused)
  final tripDetails = startTripData['trip_details'];
  final campaignId = tripDetails['campaign_id'];
  
  print('Existing trip found with status: ${startTripData['status']}');

          print('Active trip found for campaign ID: $campaignId');

          // Fetch campaign analytics
          final analyticsResponse = await api.get(
            'https://backend.drarifdentistry.com/api/campaign-analytics/$campaignId/',
            
          );
          print('Analytics Data: $analyticsResponse');
          print('Analytics Response Status Code: ${analyticsResponse.statusCode}');
          print('44444444444444444444444444444444');
          if (analyticsResponse.statusCode == 200) {
            final analyticsData = jsonDecode(analyticsResponse.body);

            print('Analytics Data: $analyticsData');

            // Format data to match your existing structure
            _campaignData = {
              'status': 'active_campaign',
              'campaign': {
                'id': campaignId,
                'campaign_name': 'Active Trip Campaign',
                'start_date': tripDetails['createdAt'],
                'end_date': tripDetails['end_date'],
              },
              'progress': {
                'target_km': double.parse(analyticsData['target'].toString()),
                'total_covered': analyticsData['total_covered'],
                'overall_progress': analyticsData['overall_progress'],
                'current_driver_progress':
                    _getCurrentDriverProgressFromAnalytics(
                      analyticsData['drivers'],
                      driverId,
                    ),
                'drivers': analyticsData['drivers'],
              },
            };

            // Sort participants by contribution percentage
            _sortAnalyticsParticipants(analyticsData['drivers'], driverId);
            _error = null;
          } else {
            print('Analytics API failed: ${analyticsResponse.statusCode}');
            _error =
                'Failed to load analytics (${analyticsResponse.statusCode})';
            _campaignData = null;
          }
        } else {
          // No active trip - use the original flow
          print('No active trip, using original flow');
          await _fetchCampaignWithDriverProgress();
        }
      } else {
        // Fallback to original flow if start-trip API fails
        print('Start-trip API failed, using fallback');
        await _fetchCampaignWithDriverProgress();
      }
    } catch (e) {
      print('Error in fetchActiveCampaign: $e');
      _error = 'Error: $e';
      _campaignData = null;
      _sortedParticipants = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getdriverid() async {
    final response = await api.get(ApiConfig.personalDetailsUrl);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final int driverId = int.parse(data['id'].toString());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('driver_id', driverId);
    }
  }

  // Helper method to fetch campaign using driver-progress API (original flow)
  Future<void> _fetchCampaignWithDriverProgress() async {
    try {
      // First fetch active campaign to get campaign ID
      final activeResponse = await api.get(
        'https://addrive.kkms.co.in/api/driver/active-campaign/',
      );

      if (activeResponse.statusCode == 200) {
        final activeData = jsonDecode(activeResponse.body);

        print('Active Campaign Response: $activeData');

        if (activeData['status'] == 'active_campaign') {
          final campaignId = activeData['campaign']['id'];
          print('Campaign ID: $campaignId');

          // Fetch driver progress for this campaign
          final progressResponse = await api.get(
            'https://addrive.kkms.co.in/api/campaign/$campaignId/driver-progress/',
          );
          if (progressResponse.statusCode == 200) {
            final progressData = jsonDecode(progressResponse.body);

            print('Driver Progress Data: $progressData');

            // Combine both data
            _campaignData = {...activeData, 'progress': progressData};

            // Sort participants for the original API format
            _sortOriginalParticipants(progressData);
            _error = null;
          } else {
            print('Driver Progress API failed: ${progressResponse.statusCode}');
            _error = 'Failed to load progress (${progressResponse.statusCode})';
            _campaignData = null;
          }
        } else {
          print('No active campaign status');
          _campaignData = null;
          _sortedParticipants = null;
        }
      } else {
        print('Active Campaign API failed: ${activeResponse.statusCode}');
        _error = 'Failed (${activeResponse.statusCode})';
        _campaignData = null;
      }
    } catch (e) {
      print('Error in _fetchCampaignWithDriverProgress: $e');
      throw e; // Let the main catch block handle it
    }
  }

  // Helper method to extract current driver's progress from analytics data
  Map<String, dynamic> _getCurrentDriverProgressFromAnalytics(
    List<dynamic> drivers,
    int driverId,
  ) {
    try {
      final currentDriver = drivers.firstWhere(
        (driver) => driver['driver_id'] == driverId,
        orElse: () => null,
      );

      if (currentDriver != null) {
        return {
          'driver': currentDriver['name'],
          'cumulative_km': double.parse(
            currentDriver['total_lifetime_km'].toString(),
          ),
          'percentage': currentDriver['contribution'],
          'profile_image': currentDriver['image'],
          'km_today': currentDriver['km_today'],
          'driver_id': currentDriver['driver_id'],
        };
      }
    } catch (e) {
      print('Error getting current driver progress: $e');
    }

    return {
      'driver': 'Unknown',
      'cumulative_km': 0.0,
      'percentage': '0%',
      'profile_image': '',
      'km_today': '0',
      'driver_id': driverId,
    };
  }

  // Sorting method for analytics API data
  void _sortAnalyticsParticipants(List<dynamic> drivers, int currentDriverId) {
    try {
      // Create a copy of the list
      final List<dynamic> sortedDrivers = List.from(drivers);

      // Sort by contribution percentage (descending)
      sortedDrivers.sort((a, b) {
        try {
          final percentA = double.parse(
            a['contribution'].toString().replaceAll('%', ''),
          );
          final percentB = double.parse(
            b['contribution'].toString().replaceAll('%', ''),
          );
          return percentB.compareTo(percentA);
        } catch (e) {
          return 0;
        }
      });

      // Format the sorted list to match your UI expectations
      _sortedParticipants = sortedDrivers.map((driver) {
        return {
          'driver': driver['name'],
          'cumulative_km': double.parse(driver['total_lifetime_km'].toString()),
          'percentage': driver['contribution'],
          'profile_image': driver['image'],
          'km_today': driver['km_today'],
          'driver_id': driver['driver_id'],
        };
      }).toList();

      // Ensure current driver is marked
      for (var participant in _sortedParticipants!) {
       
        if (participant['driver_id'] == currentDriverId) {
          participant['is_current_user'] = true;
          break;
        }
      }
    } catch (e) {
      print('Error sorting analytics participants: $e');
      _sortedParticipants = null;
    }
  }

  // Sorting method for original API format
  void _sortOriginalParticipants(Map<String, dynamic> progressData) {
    try {
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
        try {
          final double percentA = double.parse(
            a['percentage'].toString().replaceAll('%', ''),
          );
          final double percentB = double.parse(
            b['percentage'].toString().replaceAll('%', ''),
          );
          return percentB.compareTo(percentA);
        } catch (e) {
          return 0;
        }
      });

      _sortedParticipants = allDrivers;
    } catch (e) {
      print('Error sorting original participants: $e');
      _sortedParticipants = null;
    }
  }

  // Unified sorting method (maintains backward compatibility)
  void _sortParticipants(Map<String, dynamic> progressData) {
    // Check if this is analytics format
    if (progressData.containsKey('drivers')) {
      // Get driver_id for current user marking
      SharedPreferences.getInstance().then((prefs) {
        final int? driverId = prefs.getInt('driver_id');

        if (driverId != null) {
          _sortAnalyticsParticipants(progressData['drivers'], driverId);
        } else {
          _sortAnalyticsParticipants(progressData['drivers'], -1);
        }
      });
    } else {
      // Original format
      _sortOriginalParticipants(progressData);
    }
  }

  void clearCampaignData() {
    _campaignData = null;
    _error = null;
    _sortedParticipants = null;
    notifyListeners();
  }

  // Helper method to determine data format
  bool get isAnalyticsFormat {
    return _campaignData?['progress']?['drivers'] != null;
  }

  // Fix - change return type to int?
int? get currentDriverId {
  try {
    return _campaignData?['progress']?['current_driver_progress']?['driver_id'];
  } catch (e) {
    return null;
  }
}

  // Helper method to get current driver progress
  Map<String, dynamic>? getCurrentDriverProgress() {
    if (_campaignData?['progress'] == null) return null;

    if (isAnalyticsFormat) {
      final drivers = _campaignData!['progress']['drivers'];
      return _campaignData!['progress']['current_driver_progress'];
    } else {
      return _campaignData!['progress']['current_driver_progress'];
    }
  }
}
