// Controller/ProfileRegistration/bank_details.dart
import 'dart:convert';
import 'dart:io';
import 'package:addrive/Model/apiconfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BankDetailsProvider extends ChangeNotifier {
  File? _passbook;
  final ImagePicker _picker = ImagePicker();

  // Text field controllers
  final TextEditingController accountNumberCtrl = TextEditingController();
  final TextEditingController ifscCodeCtrl = TextEditingController();
  final TextEditingController bankNameCtrl = TextEditingController();
  final TextEditingController branchNameCtrl = TextEditingController();

  // Loading states
  bool _isLoading = false;
  bool _isFetching = false;
  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;

  // Existing data flag
  bool _hasExistingData = false;
  bool get hasExistingData => _hasExistingData;

  // Existing image URL
  String _existingPassbookUrl = '';
  String get existingPassbookUrl => _existingPassbookUrl;

  File? get passbook => _passbook;

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _passbook = File(pickedFile.path);
      notifyListeners();
    }
  }

  void clearImage() {
    _passbook = null;
    _existingPassbookUrl = '';
    notifyListeners();
  }

  // Validation method
  bool get canProceed {
    return accountNumberCtrl.text.trim().isNotEmpty &&
        ifscCodeCtrl.text.trim().isNotEmpty &&
        bankNameCtrl.text.trim().isNotEmpty &&
        branchNameCtrl.text.trim().isNotEmpty &&
        (_passbook != null || _existingPassbookUrl.isNotEmpty);
  }

  // Fetch existing bank details
  Future<bool> fetchBankDetails() async {
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
        Uri.parse(ApiConfig.bankDetailsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _isFetching = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        // Check if we have bank details
        if (data is List && data.isNotEmpty) {
          final bankData = data[0];
          _populateFields(bankData);
          _hasExistingData = true;
          notifyListeners();
          return true;
        } else if (data is Map && data.containsKey('account_number')) {
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
    accountNumberCtrl.text = data['account_number'] ?? '';
    ifscCodeCtrl.text = data['ifsc_code'] ?? '';
    bankNameCtrl.text = data['bank_name'] ?? '';
    branchNameCtrl.text = data['branch_name'] ?? '';
    _existingPassbookUrl = data['passbook_image'] ?? '';
    
    notifyListeners();
  }

  // API call to save/update bank details
  Future<bool> saveBankDetails() async {
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

      // Determine the API endpoint and method
      final String apiUrl;
      final String method;
      
      if (_hasExistingData) {
        apiUrl = ApiConfig.bankDetailsUrl;
        method = 'PUT';
      } else {
        apiUrl = ApiConfig.bankDetailsUrl;
        method = 'POST';
      }

      // Create multipart request
      var request = http.MultipartRequest(method, Uri.parse(apiUrl));

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['account_number'] = accountNumberCtrl.text.trim();
      request.fields['ifsc_code'] = ifscCodeCtrl.text.trim();
      request.fields['bank_name'] = bankNameCtrl.text.trim();
      request.fields['branch_name'] = branchNameCtrl.text.trim();

      // Add passbook image file only if newly selected
      if (_passbook != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'passbook_image',
          _passbook!.path,
        ));
      }

      // Send request
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Bank details ${_hasExistingData ? 'updated' : 'saved'} successfully');
        _hasExistingData = true;
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ Save failed: ${response.statusCode} - $respStr');
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Save error: $e');
      return false;
    }
  }

  // Dispose controllers
  void dispose() {
    accountNumberCtrl.dispose();
    ifscCodeCtrl.dispose();
    bankNameCtrl.dispose();
    branchNameCtrl.dispose();
  }
}