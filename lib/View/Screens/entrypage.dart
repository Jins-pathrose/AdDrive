import 'package:addrive/View/Screens/loginpage.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdDriveWelcomeScreen extends StatelessWidget {
  const AdDriveWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Blurred colored circles in background
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
                     Color.fromARGB(255, 124, 223, 236).withOpacity(0.6),
                    Color(0xFFE0F7FA).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 170,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                     Color.fromARGB(255, 124, 223, 236).withOpacity(0.6),
                    Color(0xFFE0F7FA).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 430,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                      Color.fromARGB(255, 124, 223, 236).withOpacity(0.6),
                    Color(0xFFE0F7FA).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Small decorative dots
          Positioned(
            top: 120,
            left: MediaQuery.of(context).size.width * 0.53,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
            ),
          ),
          Positioned(
            top: 110,
            right: MediaQuery.of(context).size.width * 0.35,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF64B5F6),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.45,
            right: MediaQuery.of(context).size.width * 0.22,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 149, 235, 245),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.40,
            right: MediaQuery.of(context).size.width * 0.30,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:  Colors.yellow,
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.40,
            right: MediaQuery.of(context).size.width * 0.61,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:  const Color.fromARGB(255, 244, 158, 248),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                Spacer(flex: 2),
                // Car image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Image.asset(
                    'assets/images/e6050dd6dc94d49bbfaae0d8d8dfabe89ab07961.png', // Replace with your car image path
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
                // Welcome text
                Text(
                  'Welcome to',
                  style: AppTextStyle.base.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                // Ad Drive title
                Text(
                  'Ad Drive',
                  style: AppTextStyle.base.copyWith(
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6C3FE4),
                  ),
                ),
                SizedBox(height: 20),
                // Subtitle text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                    'Earn while you riding your vehicle\nany time any where',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.base.copyWith(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Spacer(flex: 2),
                // Let's Start button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  LoginScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C3FE4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Let's Start",
                            style: AppTextStyle.base.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(LucideIcons.arrowRight, size: 24, color: const Color.fromARGB(255, 255, 255, 255))
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}