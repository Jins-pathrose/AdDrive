import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BankDetailsProvider extends ChangeNotifier {
  File? _passbook;
  final ImagePicker _picker = ImagePicker();

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
    notifyListeners();
  }
}