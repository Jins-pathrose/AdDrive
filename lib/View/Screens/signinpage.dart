import 'dart:io';

import 'package:addrive/Controller/SignUp/signup_provider.dart';
import 'package:addrive/View/Screens/otp_email_verification.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Password visibility states
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Validation functions
  String? _validateFirstName(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return 'First name is required';
    if (v.length < 2) return 'First name must be at least 2 characters';
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(v))
      return 'First name can only contain letters';
    return null;
  }

  String? _validateLastName(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return 'Last name is required';
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(v))
      return 'Last name can only contain letters';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
      return 'Please enter a valid email address';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(
      r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
    ).hasMatch(value))
      return 'Please enter a valid phone number';
if (value.length != 10) return 'Phone number must be exactly 10 digits';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value))
      return 'Password must contain uppercase, lowercase & numbers';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  // Pick image using the correct context
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final provider = Provider.of<RegisterProvider>(context, listen: false);
        provider.setImageFile(File(pickedFile.path));
        print("Picked file path: ${pickedFile.path}"); // DEBUG
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  // Show dialog using screenContext (from build)
  void _showImageSourceDialog(BuildContext screenContext) {
    showDialog(
      context: screenContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _pickImage(screenContext, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _pickImage(screenContext, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Password visibility icon
  Widget _passwordVisibilityIcon(bool isPassword, bool isConfirm) {
    return IconButton(
      icon: Icon(
        isPassword
            ? (_isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined)
            : (isConfirm
                ? (_isConfirmPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined)
                : Icons.visibility_off_outlined),
        color: Colors.grey[400],
        size: 20,
      ),
      onPressed: () {
        setState(() {
          if (isPassword) {
            _isPasswordVisible = !_isPasswordVisible;
          } else if (isConfirm) {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final BuildContext screenContext = context;
    final registerProvider = Provider.of<RegisterProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C3FE4), Color(0xFF7C4FFF)],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: 130,
              left: -10,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.21,
              left: 25,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.09),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Register',
                        style: AppTextStyle.base.copyWith(
                          fontSize: 35,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, Color(0xFFF0F5F0)],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(35, 80, 35, 30),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // First Name
                                  Text(
                                    'First Name',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: firstNameCtrl,
                                    validator: _validateFirstName,
                                    decoration: _inputDecoration(
                                      'Your FirstName, e.g., John',
                                    ),
                                  ),
                                  SizedBox(height: 24),

                                  // Last Name
                                  Text(
                                    'Last Name',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: lastNameCtrl,
                                    validator: _validateLastName,
                                    decoration: _inputDecoration(
                                      'Your Lastname, e.g., Doe',
                                    ),
                                  ),
                                  SizedBox(height: 24),

                                  // Email
                                  Text(
                                    'Email',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: emailCtrl,
                                    validator: _validateEmail,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: _inputDecoration(
                                      'Your email, e.g., johndoe@gmail.com',
                                    ),
                                  ),
                                  SizedBox(height: 24),

                                  // Phone
                                  Text(
                                    'Phone Number',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: phoneCtrl,
                                    validator: _validatePhone,
                                    keyboardType: TextInputType.phone,
                                    decoration: _inputDecoration(
                                      'Your phone number, e.g., +01 12 xxx xxx',
                                    ),
                                  ),
                                  SizedBox(height: 24),

                                  // Password
                                  Text(
                                    'Password',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: passwordCtrl,
                                    validator: _validatePassword,
                                    obscureText: !_isPasswordVisible,
                                    decoration: _inputDecoration(
                                      'Your password, at least 8 character',
                                    ).copyWith(
                                      suffixIcon: _passwordVisibilityIcon(true, false),
                                    ),
                                  ),
                                  SizedBox(height: 24),

                                  // Confirm Password
                                  Text(
                                    'Confirm Password',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: confirmCtrl,
                                    validator: _validateConfirmPassword,
                                    obscureText: !_isConfirmPasswordVisible,
                                    decoration: _inputDecoration(
                                      'Re-type your password',
                                    ).copyWith(
                                      suffixIcon: _passwordVisibilityIcon(false, true),
                                    ),
                                  ),
                                  SizedBox(height: 40),

                                  // Register Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: registerProvider.isLoading
                                          ? null
                                          : () async {
                                              // Trigger form validation manually
                                              if (_formKey.currentState!.validate()) {
                                                // Only proceed if form is valid
                                                final imageError = registerProvider.validateImage();
                                                if (imageError != null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(imageError),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                if (passwordCtrl.text != confirmCtrl.text) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text("Passwords do not match"),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                final success = await registerProvider.registerUser(
                                                  firstName: firstNameCtrl.text.trim(),
                                                  lastName: lastNameCtrl.text.trim(),
                                                  email: emailCtrl.text.trim(),
                                                  phone: phoneCtrl.text.trim(),
                                                  password: passwordCtrl.text.trim(),
                                                );

                                                if (success) {
                                                  registerProvider.clearImage();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text("Registration Successful!"),
                                                      backgroundColor: Colors.green,
                                                    ),
                                                  );
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => OtpVerificationScreen(
                                                        email: emailCtrl.text.trim(),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Mobile number or email already registered",
                                                      ),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              } else {
                                                // Form is invalid, show error message
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Please fix the mistakes in the form"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: registerProvider.isLoading
                                            ? Colors.grey[400]
                                            : Color(0xFF6C3FE4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: registerProvider.isLoading
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              'Register',
                                              style: AppTextStyle.base.copyWith(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: 18),

                                  // Login Link
                                  Center(
                                    child: GestureDetector(
                                      onTap: registerProvider.isLoading
                                          ? null
                                          : () => Navigator.pop(context),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Already have an account? ',
                                              style: AppTextStyle.base,
                                            ),
                                            TextSpan(
                                              text: 'Login',
                                              style: AppTextStyle.base.copyWith(
                                                color: registerProvider.isLoading
                                                    ? Colors.grey
                                                    : Color(0xFF6C3FE4),
                                                fontWeight: FontWeight.w600,
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

                        // Image Preview with Consumer
                        Positioned(
                          top: -45,
                          left: 0,
                          right: 0,
                          child: Consumer<RegisterProvider>(
                            builder: (context, provider, child) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: registerProvider.isLoading
                                        ? null
                                        : () => _showImageSourceDialog(screenContext),
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color.fromARGB(255, 229, 228, 228),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 15,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: provider.imageFile != null
                                          ? ClipOval(
                                              child: Image.file(
                                                provider.imageFile!,
                                                width: 90,
                                                height: 90,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Icon(
                                              Icons.camera_alt,
                                              size: 35,
                                              color: Colors.grey[600],
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
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

  // Helper: Input decoration
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyle.base.copyWith(
        color: Colors.grey[350],
        fontSize: 12,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF6C3FE4), width: 2),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 8),
    );
  }
}