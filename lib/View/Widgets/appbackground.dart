import 'package:flutter/material.dart';

class BackgroundDecoration extends StatelessWidget {
  const BackgroundDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 50,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color.fromARGB(255, 124, 223, 236).withOpacity(0.6),
                  const Color(0xFFE0F7FA).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 430,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color.fromARGB(255, 124, 223, 236).withOpacity(0.6),
                  const Color(0xFFE0F7FA).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 170,
          right: -60,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color.fromARGB(255, 124, 223, 236).withOpacity(0.6),
                  const Color(0xFFE0F7FA).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}