import 'package:addrive/Controller/Login/entrypage_provider.dart';
import 'package:addrive/View/BottomNavigator/bottomnavigator.dart';
import 'package:addrive/View/Screens/loginpage.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class AdDriveWelcomeScreen extends StatelessWidget {
  const AdDriveWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkInitialToken(context),
      builder: (context, snapshot) {
        // Show loading while checking token
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }
        
        // If token check is complete and valid, navigate immediately
        if (snapshot.hasData && snapshot.data == true) {
          // Use delayed navigation to ensure build completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => BottomNavigator()),
            );
          });
          return _buildLoadingScreen();
        }
        
        // Only show welcome screen if no valid token exists
        return _buildWelcomeScreen(context);
      },
    );
  }

  Future<bool> _checkInitialToken(BuildContext context) async {
    final provider = Provider.of<EntryPageProvider>(context, listen: false);
    provider.resetChecking();
    return await provider.checkAndValidateToken();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C3FE4)),
            ),
            SizedBox(height: 20),
            Text(
              'Wait a moment...',
              style: AppTextStyle.base.copyWith(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ... your existing welcome screen UI code ...
          // (keep all your existing UI here)
          
          SafeArea(
            child: Column(
              children: [
                Spacer(flex: 2),
                // Car image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Image.asset(
                    'assets/images/e6050dd6dc94d49bbfaae0d8d8dfabe89ab07961.png',
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
                // Let's Start button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
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
                          Icon(
                            LucideIcons.arrowRight,
                            size: 24,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          )
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