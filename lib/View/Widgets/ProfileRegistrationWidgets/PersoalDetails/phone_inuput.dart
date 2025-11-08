// View/Widgets/ProfileRegistrationWidgets/PersoalDetails/phone_inuput.dart
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';

class PhoneInuput extends StatelessWidget {
  final TextEditingController? controller;
  const PhoneInuput({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Phone Number',
        labelStyle: AppTextStyle.base.copyWith(fontSize: 12, color: Colors.grey[600]),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5B4BDB), width: 1)),
      ),
    );
  }
}