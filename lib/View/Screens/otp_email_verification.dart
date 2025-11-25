import 'package:addrive/Controller/SignUp/email_otp_provider.dart';
import 'package:addrive/View/Screens/ProfileRegistration/personaldetails.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String email;
  
  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    // Remove the ChangeNotifierProvider here - use the global one from main.dart
    return _OtpVerificationScreenContent(email: email);
  }
}

class _OtpVerificationScreenContent extends StatelessWidget {
  final String email;
  
  const _OtpVerificationScreenContent({
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final otpProvider = Provider.of<OtpProvider>(context);
// Helper method to get current OTP from controllers
String _getCurrentOtp() {
  // You'll need to access the OtpInputFields state or use a GlobalKey
  final otpInputFieldsState = context.findAncestorStateOfType<_OtpInputFieldsState>();
  return otpInputFieldsState?._enteredOtp ?? '';
}

// Manual verification method
void _verifyOtpManually(String otp) async {
  final otpProvider = Provider.of<OtpProvider>(context, listen: false);
  
  await otpProvider.verifyOtp(email, otp);
  
  if (!context.mounted) return;
  
  await Future.delayed(Duration(milliseconds: 100));
  
  if (otpProvider.isVerified) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email verified successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const PersonalDetails())
    );
  }
}
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
                    height: MediaQuery.of(context).size.height * 0.08,
                  ),
                  // Back button
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Verification title
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Verify Email',
                        style: AppTextStyle.base.copyWith(
                          fontSize: 44,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            // Email icon
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF6C3FE4).withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.email_outlined,
                                size: 40,
                                color: Color(0xFF6C3FE4),
                              ),
                            ),
                            SizedBox(height: 30),
                            // Description text
                            Text(
                              'Enter the 6-digit code',
                              style: AppTextStyle.base.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'We sent a verification code to',
                              textAlign: TextAlign.center,
                              style: AppTextStyle.base.copyWith(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              email,
                              textAlign: TextAlign.center,
                              style: AppTextStyle.base.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6C3FE4),
                              ),
                            ),
                            SizedBox(height: 40),
                            // OTP input fields
                            OtpInputFields(email: email),
                            SizedBox(height: 20),
                            // Error message
                            if (otpProvider.errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  otpProvider.errorMessage,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.base.copyWith(
                                    fontSize: 13,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            SizedBox(height: 10),
                            // Resend code text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Didn't receive the code? ",
                                  style: AppTextStyle.base.copyWith(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Handle resend OTP
                                    if (!otpProvider.isLoading) {
          otpProvider.resendOtp(email);
                                    }
                                  },
                                  child: Text(
                                    'Resend',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6C3FE4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                            // Verify button (optional manual verification)
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
    onPressed: otpProvider.isLoading
        ? null
        : () {
            // Manual verification when button is pressed
            final otp = _getCurrentOtp();
            if (otp.length == 6) {
              _verifyOtpManually(otp);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter all 6 digits'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF6C3FE4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: otpProvider.isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Verify',
                                        style: AppTextStyle.base.copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
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
          ],
        ),
      ),
    );
  }
}

class OtpInputFields extends StatefulWidget {
  final String email;
  
  const OtpInputFields({
    super.key,
    required this.email,
  });

  @override
  State<OtpInputFields> createState() => _OtpInputFieldsState();
}

class _OtpInputFieldsState extends State<OtpInputFields> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String _enteredOtp = '';

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus && _controllers[i].text.isEmpty) {
          _controllers[i].text = '';
        }
      });
    }
  }

  void _onOtpChanged() {
    final otp = _controllers.map((controller) => controller.text).join();
    setState(() {
      _enteredOtp = otp;
    });

    // Auto-submit when all 6 digits are entered
    if (otp.length == 6) {
      _verifyOtp(otp);
    }
  }

  void _verifyOtp(String otp) async {
    final otpProvider = Provider.of<OtpProvider>(context, listen: false);
    
    // Call the verify method and wait for completion
    await otpProvider.verifyOtp(widget.email, otp);
    
    // Check if still mounted before navigation
    if (!mounted) return;
    
    // Add a small delay to ensure state is updated
    await Future.delayed(Duration(milliseconds: 100));
    
    // Navigate after verification
    if (otpProvider.isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Use pushReplacement to prevent going back to OTP screen
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const PersonalDetails())
      );
    } else {
      // Show error if verification failed
      final errorMsg = otpProvider.errorMessage.isNotEmpty 
          ? otpProvider.errorMessage 
          : 'Verification failed. Please try again.';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Clear OTP fields on error
      _clearOtp();
    }
  }

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() {
      _enteredOtp = '';
    });
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpProvider = Provider.of<OtpProvider>(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) => OtpInputField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              index: index,
              onChanged: _onOtpChanged,
              onBackspace: (currentIndex) {
                if (currentIndex > 0 && _controllers[currentIndex].text.isEmpty) {
                  _focusNodes[currentIndex - 1].requestFocus();
                }
              },
              isEnabled: !otpProvider.isLoading,
            ),
          ),
        ),
        SizedBox(height: 20),
        if (_enteredOtp.isNotEmpty && !otpProvider.isLoading)
          TextButton(
            onPressed: _clearOtp,
            child: Text(
              'Clear OTP',
              style: AppTextStyle.base.copyWith(
                fontSize: 13,
                color: Color(0xFF6C3FE4),
              ),
            ),
          ),
      ],
    );
  }
}

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int index;
  final VoidCallback onChanged;
  final Function(int) onBackspace;
  final bool isEnabled;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.index,
    required this.onChanged,
    required this.onBackspace,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focusNode.hasFocus ? Color(0xFF6C3FE4) : Colors.grey[300]!,
          width: focusNode.hasFocus ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: isEnabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTextStyle.base.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty) {
            onBackspace(index);
          }
          onChanged();
        },
        onTap: () {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
      ),
    );
  }
}