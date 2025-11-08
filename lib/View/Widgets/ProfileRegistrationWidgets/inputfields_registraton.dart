// View/Widgets/ProfileRegistrationWidgets/inputfields_registraton.dart
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';

class InputfieldsRegistraton extends StatelessWidget {
  final String label;
  final TextEditingController? controller;   // <-- NEW
  const InputfieldsRegistraton({super.key, required this.label, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        labelStyle: AppTextStyle.base.copyWith(fontSize: 12, color: Colors.grey[600]),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5B4BDB), width: 1)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
      ),
    );
  }
}