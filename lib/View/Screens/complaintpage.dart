import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';

class ComplaintRegistrationPage extends StatefulWidget {
  const ComplaintRegistrationPage({super.key});

  @override
  State<ComplaintRegistrationPage> createState() => _ComplaintRegistrationPageState();
}

class _ComplaintRegistrationPageState extends State<ComplaintRegistrationPage> {
  final TextEditingController _complaintController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background decoration
          BackgroundDecoration(),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Register Complaint',
                        style: AppTextStyle.base.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Information card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your complaint will be reviewed by our support team. We\'ll get back to you within 24-48 hours.',
                            style: AppTextStyle.base.copyWith(
                              fontSize: 14,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Complaint form
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Describe your complaint',
                              style: AppTextStyle.base.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please provide detailed information about your issue',
                              style: AppTextStyle.base.copyWith(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Complaint text field
                            TextFormField(
                              controller: _complaintController,
                              maxLines: 8,
                              maxLength: 500,
                              decoration: InputDecoration(
                                hintText: 'Describe your complaint here...',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.blue[500]!, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please describe your complaint';
                                }
                                if (value.trim().length < 10) {
                                  return 'Please provide more details (at least 10 characters)';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 8),
                            Text(
                              '${_complaintController.text.length}/500 characters',
                              style: AppTextStyle.base.copyWith(
                                fontSize: 12,
                                color: _complaintController.text.length > 500 
                                  ? Colors.red 
                                  : Colors.grey[600],
                              ),
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Common complaint categories
                            Text(
                              'Common Complaint Categories',
                              style: AppTextStyle.base.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildCategoryChip('Vehicle Maintenance', Icons.directions_car),
                                _buildCategoryChip('Payment Issues', Icons.payment),
                                _buildCategoryChip('App Problems', Icons.phone_android),
                                _buildCategoryChip('Service Delay', Icons.access_time),
                                _buildCategoryChip('Account Issues', Icons.person),
                                _buildCategoryChip('Other Issues', Icons.more_horiz),
                              ],
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitComplaint,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5F33E1),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isSubmitting
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Submit Complaint',
                                        style: AppTextStyle.base.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Success message
                            if (_isSubmitted)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green[100]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green[700], size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Complaint Submitted Successfully!',
                                            style: AppTextStyle.base.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green[800],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Your complaint has been registered. Our support team will contact you soon.',
                                            style: AppTextStyle.base.copyWith(
                                              fontSize: 13,
                                              color: Colors.green[700],
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String text, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _complaintController.text = '$text: ';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.blue[600]),
            const SizedBox(width: 6),
            Text(
              text,
              style: AppTextStyle.base.copyWith(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      
      if (token.isEmpty) {
        throw Exception('Authentication required. Please login again.');
      }

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'complaint': _complaintController.text.trim(),
      };

      // Make API call
      final response = await http.post(
        Uri.parse('https://addrive.kkms.co.in/api/driver/complaints/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        // Success
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });

        // Clear form after successful submission
        _complaintController.clear();
Navigator.pop(context);
        // Hide success message after 5 seconds and navigate back
        

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint submitted successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Handle API error
        final responseData = json.decode(response.body);
        final errorMessage = responseData['error'] ?? 
                            responseData['message'] ?? 
                            'Failed to submit complaint. Status: ${response.statusCode}';
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}