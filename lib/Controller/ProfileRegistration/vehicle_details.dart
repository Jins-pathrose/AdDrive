// Controller/ProfileRegistration/vehicle_details.dart
import 'dart:convert';
import 'dart:io';
import 'package:addrive/Model/apiconfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleDetailsProviderclass extends ChangeNotifier {
  // Individual image files for each view
  File? _frontViewImage;
  File? _backViewImage;
  File? _rightSideImage;
  File? _leftSideImage;
  final ImagePicker _picker = ImagePicker();

  // Text field controllers
  final TextEditingController vehicleNumberCtrl = TextEditingController();
  final TextEditingController vehicleModelCtrl = TextEditingController();
  final TextEditingController ownerNameCtrl = TextEditingController();

  // Loading states
  bool _isLoading = false;
  bool _isFetching = false;
  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;

  // Existing data flag
  bool _hasExistingData = false;
  bool get hasExistingData => _hasExistingData;

  // Getters for each image
  File? get frontViewImage => _frontViewImage;
  File? get backViewImage => _backViewImage;
  File? get rightSideImage => _rightSideImage;
  File? get leftSideImage => _leftSideImage;
  Map<String, String> _existingImageUrls = {};
  Map<String, String> get existingImageUrls => _existingImageUrls;


  // Method to pick image for specific view
  Future<void> pickImage(ImageSource source, String viewType) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      switch (viewType) {
        case 'front':
          _frontViewImage = File(pickedFile.path);
          break;
        case 'back':
          _backViewImage = File(pickedFile.path);
          break;
        case 'right':
          _rightSideImage = File(pickedFile.path);
          break;
        case 'left':
          _leftSideImage = File(pickedFile.path);
          break;
      }
      notifyListeners();
    }
  }

  // Clear specific image
void clearImage(String viewType) {
  switch (viewType) {
    case 'front':
      _frontViewImage = null;
      _existingImageUrls['front'] = '';
      break;
    case 'back':
      _backViewImage = null;
      _existingImageUrls['back'] = '';
      break;
    case 'right':
      _rightSideImage = null;
      _existingImageUrls['right'] = '';
      break;
    case 'left':
      _leftSideImage = null;
      _existingImageUrls['left'] = '';
      break;
  }
  notifyListeners();
}

  // Clear all images
  void clearAllImages() {
    _frontViewImage = null;
    _backViewImage = null;
    _rightSideImage = null;
    _leftSideImage = null;
    notifyListeners();
  }

  // Validation method
 bool get canProceed {
  final hasTextData = vehicleNumberCtrl.text.trim().isNotEmpty &&
      vehicleModelCtrl.text.trim().isNotEmpty &&
      ownerNameCtrl.text.trim().isNotEmpty;

  // Check if we have images (either new files or existing URLs)
  final hasFrontImage = _frontViewImage != null || 
      (_existingImageUrls['front']?.isNotEmpty == true);
  final hasBackImage = _backViewImage != null || 
      (_existingImageUrls['back']?.isNotEmpty == true);
  final hasRightImage = _rightSideImage != null || 
      (_existingImageUrls['right']?.isNotEmpty == true);
  final hasLeftImage = _leftSideImage != null || 
      (_existingImageUrls['left']?.isNotEmpty == true);

  return hasTextData && hasFrontImage && hasBackImage && hasRightImage && hasLeftImage;
}

  // Fetch existing vehicle details
  Future<bool> fetchVehicleDetails() async {
    _isFetching = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) {
        _isFetching = false;
        notifyListeners();
        return false;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.vehicleDetailsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _isFetching = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        // Check if we have vehicle details
        if (data is List && data.isNotEmpty) {
          final vehicleData = data[0]; // Assuming first item is the vehicle data
          _populateFields(vehicleData);
          _hasExistingData = true;
          notifyListeners();
          return true;
        } else if (data is Map && data.containsKey('vehicle_number')) {
          _populateFields(data);
          _hasExistingData = true;
          notifyListeners();
          return true;
        }
        
        // No existing data found
        _hasExistingData = false;
        return true;
      } else {
        debugPrint('Fetch failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      _isFetching = false;
      notifyListeners();
      debugPrint('Fetch error: $e');
      return false;
    }
  }

  // Populate fields with existing data
  void _populateFields(Map<dynamic, dynamic> data) {
  vehicleNumberCtrl.text = data['vehicle_number'] ?? '';
  vehicleModelCtrl.text = data['vehicle_model'] ?? '';
  ownerNameCtrl.text = data['owner_name'] ?? '';

  // Store image URLs directly
  _existingImageUrls = {
    'front': data['front_view'] ?? '',
    'back': data['back_view'] ?? '',
    'right': data['right_view'] ?? '',
    'left': data['left_view'] ?? '',
  };
  
  notifyListeners();
}

  // API call to save/update vehicle details
  // API call to save/update vehicle details
Future<bool> saveVehicleDetails() async {
  _isLoading = true;
  notifyListeners();

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Determine the API endpoint and method based on whether we have existing data
    final String apiUrl;
    final String method;
    
    if (_hasExistingData) {
      // Use update endpoint with PUT/PATCH
      apiUrl = ApiConfig.vehicleDetailsUrl;
      method = 'PUT'; // or 'PATCH' depending on your API
    } else {
      // Use create endpoint with POST
      apiUrl = ApiConfig.vehicleDetailsUrl;
      method = 'POST';
    }

    // Create multipart request
    var request = http.MultipartRequest(method, Uri.parse(apiUrl));

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    request.fields['vehicle_number'] = vehicleNumberCtrl.text.trim();
    request.fields['vehicle_model'] = vehicleModelCtrl.text.trim();
    request.fields['owner_name'] = ownerNameCtrl.text.trim();

    // Add image files only if they are newly selected
    if (_frontViewImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'front_view',
        _frontViewImage!.path,
      ));
    }

    if (_backViewImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'back_view',
        _backViewImage!.path,
      ));
    }

    if (_leftSideImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'left_view',
        _leftSideImage!.path,
      ));
    }

    if (_rightSideImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'right_view',
        _rightSideImage!.path,
      ));
    }

    // Send request
    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    _isLoading = false;
    notifyListeners();

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('Vehicle details ${_hasExistingData ? 'updated' : 'saved'} successfully');
      _hasExistingData = true;
      notifyListeners();
      return true;
    } else {
      debugPrint('Save failed: ${response.statusCode} - $respStr');
      return false;
    }
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    debugPrint('Save error: $e');
    return false;
  }
}

  // Dispose controllers
  void dispose() {
    vehicleNumberCtrl.dispose();
    vehicleModelCtrl.dispose();
    ownerNameCtrl.dispose();
  }
}