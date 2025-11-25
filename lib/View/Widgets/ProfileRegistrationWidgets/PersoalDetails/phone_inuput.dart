// View/Widgets/ProfileRegistrationWidgets/PersoalDetails/phone_inuput.dart
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';

class PhoneInuput extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  const PhoneInuput({super.key, this.controller, this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? 'Phone Number',
          style: AppTextStyle.base.copyWith(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter phone number',
            hintStyle: AppTextStyle.base.copyWith(fontSize: 14, color: Colors.grey[500]),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5B4BDB), width: 1),
            ),
          ),
        ),
      ],
    );
  }
}