import 'package:addrive/Model/activecampaign_model.dart';
import 'package:addrive/Model/apiclient.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RideProvider with ChangeNotifier {
  final ApiClient api = ApiClient();
  static const MethodChannel _gpsChannel = MethodChannel('gps_service');

  LatLng? _currentLocation;
  bool _isLoading = true;
  Map<String, dynamic>? _weeklyUploadStatus;
  String? _error;
  ActivecampaignModel? _activeCampaign;
  bool _isFetchingCampaign = false;
  // Add this variable to track ride state
  bool _isRideActive = false;
  int? _currentTripId;

  bool get isRideActive => _isRideActive;
  int? get currentTripId => _currentTripId;

  ActivecampaignModel? get activeCampaign => _activeCampaign;
  bool get isFetchingCampaign => _isFetchingCampaign;

  LatLng? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get weeklyUploadStatus => _weeklyUploadStatus;
  String? get error => _error;
  final MapController mapController = MapController();

  // Add these constants at the top of RideProvider class
  static const String _rideActiveKey = 'ride_active';
  static const String _currentTripIdKey = 'current_trip_id';

  // Add this method to save ride state to SharedPreferences
  Future<void> _saveRideState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rideActiveKey, _isRideActive);
      if (_currentTripId != null) {
        await prefs.setInt(_currentTripIdKey, _currentTripId!);
      } else {
        await prefs.remove(_currentTripIdKey);
      }
      print('Saved ride state: active=$_isRideActive, trip_id=$_currentTripId');
    } catch (e) {
      print('Failed to save ride state: $e');
    }
  }

  // Add this method to load ride state from SharedPreferences
  Future<void> loadRideState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedActive = prefs.getBool(_rideActiveKey) ?? false;
      final savedTripId = prefs.getInt(_currentTripIdKey);

      if (savedActive && savedTripId != null) {
        _isRideActive = savedActive;
        _currentTripId = savedTripId;
        print(
          'Loaded ride state: active=$_isRideActive, trip_id=$_currentTripId',
        );

        // Verify with server that trip is still active
        await _verifyTripStatus();
      } else {
        // Clear any invalid state
        _isRideActive = false;
        _currentTripId = null;
        await _clearRideState();
        print('No valid ride state found or cleared invalid state');
      }

      notifyListeners();
    } catch (e) {
      print('Failed to load ride state: $e');
      _isRideActive = false;
      _currentTripId = null;
      notifyListeners();
    }
  }

  // Add method to verify trip status with server
  Future<void> _verifyTripStatus() async {
    // try {
    //   if (_currentTripId == null) return;

    //   final prefs = await SharedPreferences.getInstance();
    //   final token = prefs.getString('access_token');

    //   if (token == null) {
    //     print('No token for trip verification');
    //     await _clearRideState();
    //     return;
    //   }

    //   // Call API to check if trip is still active
    //   final response = await http.get(
    //     Uri.parse('https://addrive.kkms.co.in/api/trip-status/$_currentTripId/'),
    //     headers: {
    //       'Content-Type': 'application/json',
    //       'Authorization': 'Bearer $token',
    //     },
    //   );

    //   if (response.statusCode == 200) {
    //     final data = json.decode(response.body);
    //     final isActive = data['is_active'] ?? false;

    //     if (!isActive) {
    //       print('Trip $_currentTripId is no longer active on server');
    //       await _clearRideState();
    //     } else {
    //       print('Trip $_currentTripId is still active on server');
    //     }
    //   } else {
    //     print('Failed to verify trip status: ${response.statusCode}');
    //     // If we can't verify, assume trip is inactive for safety
    //     await _clearRideState();
    //   }
    // } catch (e) {
    //   print('Trip verification error: $e');
    //   await _clearRideState();
    // }
  }

  // Add method to clear ride state
  Future<void> _clearRideState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_rideActiveKey);
      await prefs.remove(_currentTripIdKey);

      _isRideActive = false;
      _currentTripId = null;

      print('Cleared ride state from SharedPreferences');
    } catch (e) {
      print('Failed to clear ride state: $e');
    }
  }

  // Add this method to end/cancel ride (for pause button)
  Future<bool> pauseRide() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null && _currentTripId != null) {
        // Call API to pause/end the trip
        final response = await http.post(
          Uri.parse(
            'https://backend.drarifdentistry.com/gps/pause',
          ), // Update with your endpoint
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'access_token': token,
            'status': 'paused', // or 'ended' based on your needs
          }),
        );

        print('Pause ride response: ${response.statusCode}');
      }

      // Clear local state
      _isRideActive = false;
      await _clearRideState();

      // 🛑 STOP FOREGROUND SERVICE
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _gpsChannel.invokeMethod('stopGpsService');
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('Failed to pause ride: $e');
      // Still clear local state even if API fails
      _isRideActive = false;
      await _clearRideState();
      notifyListeners();
      return false;
    }
  }

  // Method to start trip (create or get existing trip)
  Future<Map<String, dynamic>> startTrip(String campaignId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // First, try to get active trip
      final getResponse = await http.get(
        Uri.parse('https://addrive.kkms.co.in/api/start-trip/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (getResponse.statusCode == 200) {
        final data = json.decode(getResponse.body);

        // Check if there's an active trip_id in response
        if (data.containsKey('trip_id') && data['trip_id'] != null) {
          _currentTripId = data['trip_id'];
          // DON'T set _isRideActive here yet
          return {'success': true, 'trip_id': _currentTripId, 'existing': true};
        }
      }

      // If no active trip, create a new one
      final postResponse = await http.post(
        Uri.parse('https://addrive.kkms.co.in/api/start-trip/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'campaign_id': campaignId}),
      );

      if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
        final data = json.decode(postResponse.body);
        if (data.containsKey('trip_id') && data['trip_id'] != null) {
          _currentTripId = data['trip_id'];
          // DON'T set _isRideActive here yet
          return {
            'success': true,
            'trip_id': _currentTripId,
            'existing': false,
          };
        } else {
          throw Exception('No trip_id in response');
        }
      } else {
        throw Exception('Failed to create trip: ${postResponse.statusCode}');
      }
    } catch (e) {
      _error = 'Failed to start trip: $e';
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }
void recenterMap() {
  if (_currentLocation != null) {
    mapController.move(_currentLocation!, 16.0);
    notifyListeners();
  }
}
  // Method to send GPS update
  Future<bool> sendGpsUpdate(double latitude, double longitude) async {
    try {
      if (_currentTripId == null) {
        print('No active trip ID for GPS update');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        print('No access token for GPS update');
        return false;
      }

      print('Sending GPS update for trip $_currentTripId');
      print('Latitude: $latitude, Longitude: $longitude');

      // Try different endpoint variations
      final endpoints = ['https://backend.drarifdentistry.com/gps/update'];

      for (String endpoint in endpoints) {
        try {
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
            body: json.encode({
              // 'access_token': token,
              'trip_id': _currentTripId,
              'latitude': latitude,
              'longitude': longitude,
            }),
          );

          print('Trying endpoint: $endpoint');
          print('Response status: ${response.statusCode}');

          if (response.statusCode == 200) {
            print('GPS update successful on endpoint: $endpoint');
            return true;
          }
        } catch (e) {
          print('Failed on endpoint $endpoint: $e');
        }
      }

      print('All GPS endpoints failed');
      return false;
    } catch (e) {
      print('GPS update error: $e');
      return false;
    }
  }

  // Method to start ride with all steps
  Future<bool> startRideWithTracking(
    BuildContext context,
    String campaignId,
  ) async {
    try {
      // 1. Check if user can start ride
      bool canStart = await canStartRide(context, campaignId);

      if (!canStart) {
        _error = 'Cannot start ride. Please check your upload status.';
        notifyListeners();
        return false;
      }

      // 2. Start/Create trip (but don't mark as active yet)
      final tripResult = await startTrip(campaignId);

      if (!tripResult['success']) {
        _error = 'Failed to start trip';
        notifyListeners();
        return false;
      }

      print('Trip created successfully. Trip ID: $_currentTripId');

      // 3. Try to send initial GPS update - THIS MUST SUCCEED
      bool gpsSuccess = false;
      if (_currentLocation != null) {
        gpsSuccess = await sendGpsUpdate(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );
      } else {
        // If no location available, try to get it
        await initializeLocation();
        if (_currentLocation != null) {
          gpsSuccess = await sendGpsUpdate(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          );
        } else {
          _error = 'Cannot start ride: Location not available';
          // We should cancel/delete the trip since GPS failed
          await cancelTripIfNeeded();
          notifyListeners();
          return false;
        }
      }

      // 4. Only mark ride as active if GPS update succeeded
      if (gpsSuccess) {
        _isRideActive = true;

        await _saveRideState();

        // 🔥 START ANDROID FOREGROUND GPS SERVICE
        if (defaultTargetPlatform == TargetPlatform.android) {
          await _gpsChannel.invokeMethod('startGpsService');
        }

        notifyListeners();
        return true;
      } else {
        _error = 'Cannot start ride: GPS tracking failed';
        // Cancel/delete the trip since GPS failed
        await cancelTripIfNeeded();
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to start ride: $e';
      // Ensure any created trip is cancelled
      await cancelTripIfNeeded();
      notifyListeners();
      return false;
    }
  }

  Future<void> cancelTripIfNeeded() async {
    if (_currentTripId != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');

        if (token != null) {
          // Try to cancel/end the trip
          final response = await http.post(
            Uri.parse('https://addrive.kkms.co.in/api/end-trip/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'trip_id': _currentTripId,
              'status': 'cancelled',
            }),
          );

          print('Trip cancellation response: ${response.statusCode}');
        }
      } catch (e) {
        print('Failed to cancel trip: $e');
      }

      // Reset trip state and clear from SharedPreferences
      await _clearRideState();
    }
  }

  Future<void> initializeLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (!serviceEnabled || permission == LocationPermission.denied) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      _currentLocation = LatLng(position.latitude, position.longitude);
      _error = null;
    } catch (e) {
      _error = 'Failed to get location: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchActiveCampaign() async {

    _isFetchingCampaign = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        _error = 'Authentication token not found';
        return;
      }

      final response = await api.get(
      'https://addrive.kkms.co.in/api/driver/active-campaign/',
    );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'active_campaign' && data['campaign'] != null) {
          _activeCampaign = ActivecampaignModel.fromJson(data['campaign']);
        } else {
          _activeCampaign = null;
        }
      }
      
       else {
        _error = 'Failed to fetch campaign: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isFetchingCampaign = false;
      notifyListeners();
    }
  }

  Future<bool> canStartRide(BuildContext context, String campaignId) async {
    await checkWeeklyUploadStatus(context, campaignId);

    if (_weeklyUploadStatus != null) {
      final hasUploadedBefore =
          _weeklyUploadStatus!['has_uploaded_before'] ?? false;

      print('has_uploaded_before: $hasUploadedBefore');

      // Only allow ride if user has uploaded before
      // i.e., has_uploaded_before must be TRUE to start ride
      if (hasUploadedBefore) {
        print('User has uploaded before - allowing ride start');
        return true;
      } else {
        print('User has NOT uploaded before - disallowing ride start');
        return false;
      }
    }

    print('No weekly upload status data - disallowing ride start');
    return false;
  }

  Future<void> checkWeeklyUploadStatus(
    BuildContext context,
    String campaignId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        _error = 'Authentication token not found';
        return;
      }

      final response = await http.get(
        Uri.parse(
          'https://addrive.kkms.co.in/api/campaign/weekly-upload/?campaign_id=$campaignId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);
      print('Weekly upload status: $data');

      if (response.statusCode == 200) {
        _weeklyUploadStatus = data;
        _error = null;

        // Navigation logic should be in the UI layer, not here
        // Remove the Navigator.push from here
      } else if (response.statusCode == 401) {
        _error = 'Unauthorized - Please check your authentication';
      } else {
        _error = 'Failed to check upload status: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: $e';
    }
    notifyListeners();
  }

  void updateLocation(LatLng newLocation) {
    _currentLocation = newLocation;
    notifyListeners();
  }
}
