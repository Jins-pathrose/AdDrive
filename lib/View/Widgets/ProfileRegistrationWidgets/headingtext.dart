import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';

class HeadingText extends StatelessWidget {
  final String title;
  const HeadingText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: AppTextStyle.base.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5B4BDB),
        ),
      ),
    );
  }
}
