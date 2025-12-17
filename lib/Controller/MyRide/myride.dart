import 'package:addrive/View/Screens/imageuploads.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RideProvider with ChangeNotifier {
  LatLng? _currentLocation;
  bool _isLoading = true;
  Map<String, dynamic>? _weeklyUploadStatus;
  String? _error;

  LatLng? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get weeklyUploadStatus => _weeklyUploadStatus;
  String? get error => _error;

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

Future<void> checkWeeklyUploadStatus(BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('https://addrive.kkms.co.in/api/campaign/weekly-upload/?campaign_id='),
      headers: {
        'Content-Type': 'application/json',
        // Add your authorization headers here
        'Authorization': 'Bearer $token',
      },
    );
    final data = json.decode(response.body);
    print(data);
    print('555555555555555555555');
    if(data['submission_status'] == 'pending') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ImageUploads()),
      );
    }

      if (response.statusCode == 200) {
        _weeklyUploadStatus = json.decode(response.body);
        _error = null;
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

  Future<bool> canStartRide(BuildContext context) async {
    await checkWeeklyUploadStatus(context);
    
    if (_weeklyUploadStatus != null && 
        _weeklyUploadStatus!['submission_status'] == 'pending') {
      return true;
    }
    return false;
  }

  void updateLocation(LatLng newLocation) {
    _currentLocation = newLocation;
    notifyListeners();
  }
}