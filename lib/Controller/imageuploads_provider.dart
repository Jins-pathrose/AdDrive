import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageUploadProvider with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  
  // Images for each side of the car
  File? _frontImage;
  File? _backImage;
  File? _leftImage;
  File? _rightImage;
  
  bool _isSubmitting = false;
  String? _error;
  bool _isSuccess = false;
  
  File? get frontImage => _frontImage;
  File? get backImage => _backImage;
  File? get leftImage => _leftImage;
  File? get rightImage => _rightImage;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  bool get isSuccess => _isSuccess;
  
  bool get allImagesUploaded => 
      _frontImage != null && 
      _backImage != null && 
      _leftImage != null && 
      _rightImage != null;
  
  Future<void> captureImage(CarSide side) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        // Compress the image immediately after capture
        final compressedFile = await compressImage(File(image.path));
        
        switch (side) {
          case CarSide.front:
            _frontImage = compressedFile;
            break;
          case CarSide.back:
            _backImage = compressedFile;
            break;
          case CarSide.left:
            _leftImage = compressedFile;
            break;
          case CarSide.right:
            _rightImage = compressedFile;
            break;
        }
        
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to capture image: $e';
      notifyListeners();
    }
  }
  
  Future<File> compressImage(File file) async {
    try {
      // Get file extension
      final extension = file.path.split('.').last.toLowerCase();
      
      // Compress the image
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 1280,
        minHeight: 720,
        quality: 80,
        rotate: 0,
        format: extension == 'png' 
            ? CompressFormat.png 
            : CompressFormat.jpeg,
      );
      
      if (result == null) {
        return file; // Return original if compression fails
      }
      
      // Get the file name
      final filename = file.path.split('/').last;
      final compressedFilename = 'compressed_$filename';
      
      // Create new compressed file
      final compressedFile = File('${file.parent.path}/$compressedFilename')
        ..writeAsBytesSync(result);
      
      // Delete original file to save space
      if (file.existsSync() && file.path != compressedFile.path) {
        file.deleteSync();
      }
      
      return compressedFile;
    } catch (e) {
      print('Compression error: $e');
      return file; // Return original if compression fails
    }
  }
  
  void removeImage(CarSide side) {
    switch (side) {
      case CarSide.front:
        _deleteFileIfExists(_frontImage);
        _frontImage = null;
        break;
      case CarSide.back:
        _deleteFileIfExists(_backImage);
        _backImage = null;
        break;
      case CarSide.left:
        _deleteFileIfExists(_leftImage);
        _leftImage = null;
        break;
      case CarSide.right:
        _deleteFileIfExists(_rightImage);
        _rightImage = null;
        break;
    }
    notifyListeners();
  }
  
  void _deleteFileIfExists(File? file) {
    if (file != null && file.existsSync()) {
      try {
        file.deleteSync();
      } catch (e) {
        print('Error deleting file: $e');
      }
    }
  }
  
  Future<void> submitImages(String campaignId, BuildContext context) async {
    if (!allImagesUploaded) {
      _error = 'Please upload all 4 side images';
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    _error = null;
    _isSuccess = false;
    notifyListeners();

    try {
      // Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://addrive.kkms.co.in/api/campaign/weekly-upload/'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add campaign_id as field
      request.fields['campaign_id'] = campaignId;

      // Add compressed images with specific field names
      if (_frontImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image1',
          _frontImage!.path,
          filename: 'front_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      }
      
      if (_backImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image2',
          _backImage!.path,
          filename: 'back_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      }
      
      if (_leftImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image3',
          _leftImage!.path,
          filename: 'left_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      }
      
      if (_rightImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image4',
          _rightImage!.path,
          filename: 'right_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      }
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      final responseData = json.decode(response.body);
      print('Upload Response: $responseData');
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _isSuccess = true;
        
        // Clear images after successful upload
        clearAllImages();
        
      } else if (response.statusCode == 400) {
        // Bad request - show validation errors
        final errors = responseData['errors'] ?? responseData['message'] ?? 'Invalid request';
        throw Exception(errors.toString());
        
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
        
      } else {
        throw Exception('Upload failed: ${response.statusCode} - ${responseData['message'] ?? 'Unknown error'}');
      }
            print(response.statusCode);

      
    } catch (e) {
      _error = e.toString();
      print('Upload error: $e');
      print(error);
      
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
  
  void clearAllImages() {
    _deleteFileIfExists(_frontImage);
    _deleteFileIfExists(_backImage);
    _deleteFileIfExists(_leftImage);
    _deleteFileIfExists(_rightImage);
    
    _frontImage = null;
    _backImage = null;
    _leftImage = null;
    _rightImage = null;
    notifyListeners();
  }
  
  void clearMessages() {
    _error = null;
    _isSuccess = false;
    notifyListeners();
  }
}

enum CarSide {
  front,
  back,
  left,
  right,
}