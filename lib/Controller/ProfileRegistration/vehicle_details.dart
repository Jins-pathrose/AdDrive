import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VehicleDetailsProviderclass extends ChangeNotifier {
  // Individual image files for each view
  File? _frontViewImage;
  File? _backViewImage;
  File? _rightSideImage;
  File? _leftSideImage;
  final ImagePicker _picker = ImagePicker();

  // Getters for each image
  File? get frontViewImage => _frontViewImage;
  File? get backViewImage => _backViewImage;
  File? get rightSideImage => _rightSideImage;
  File? get leftSideImage => _leftSideImage;

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
        break;
      case 'back':
        _backViewImage = null;
        break;
      case 'right':
        _rightSideImage = null;
        break;
      case 'left':
        _leftSideImage = null;
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
}