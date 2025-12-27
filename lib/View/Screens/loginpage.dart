import 'package:addrive/Controller/Login/login_provider.dart';
import 'package:addrive/View/BottomNavigator/bottomnavigator.dart';
import 'package:addrive/View/Screens/forgotpassword.dart';
import 'package:addrive/View/Screens/signinpage.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Password visibility state
  bool _isPasswordVisible = false;

  void _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        // Login successful - show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to home screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigator()),
          (route) => false,
        );
      } else {
        // Show error message
        _showErrorDialog(context, authProvider.errorMessage);
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleForgotPassword(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ForgotPasswordScreen(),
    ),
  );
}

  void _navigateToRegister(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoading) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterScreen()),
      );
    }
  }

  // Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6C3FE4),
                  Color(0xFF7C4FFF),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.66,
                  left: 10,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                      ),
                      // Login title
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Login',
                            style: AppTextStyle.base.copyWith(
                              fontSize: 44,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      // White card container
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Color(0xFFF0F5F0),
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(40),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  // Email field
                                  Text(
                                    'Email',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your email',
                                      hintStyle: AppTextStyle.base.copyWith(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF6C3FE4),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 30),
                                  // Password field
                                  Text(
                                    'Password',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      hintStyle: AppTextStyle.base.copyWith(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.grey[400],
                                        ),
                                        onPressed: _togglePasswordVisibility,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF6C3FE4),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  // Forgot password
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(width: 50),
                                      GestureDetector(
                                        onTap: () => _handleForgotPassword(context),
                                        child: Text(
                                          'Forgot Password?',
                                          style: AppTextStyle.base.copyWith(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 35),
                                  // Login button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: authProvider.isLoading ? null : () => _login(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF6C3FE4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: authProvider.isLoading
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              'Login',
                                              style: AppTextStyle.base.copyWith(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  // Register text
                                  GestureDetector(
                                    onTap: () => _navigateToRegister(context),
                                    child: Center(
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "Don't have an account yet? ",
                                              style: AppTextStyle.base.copyWith(
                                                color: const Color.fromARGB(221, 75, 75, 75),
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Register ',
                                              style: AppTextStyle.base.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Here',
                                              style: AppTextStyle.base.copyWith(
                                                color: Color.fromARGB(255, 143, 63, 228),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}