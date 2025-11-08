import 'package:addrive/Controller/ProfileRegistration/personal_details.dart';
import 'package:addrive/View/Screens/ProfileRegistration/vehicledetails.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/PersoalDetails/phone_inuput.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/VehicleDetails/vehicledetails_widgets.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/headingtext.dart';
import 'package:addrive/View/Widgets/ProfileRegistrationWidgets/inputfields_registraton.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalDetails extends StatelessWidget {
  const PersonalDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PersonalDetailsProvider()..fetchPersonalDetails(),
      child: _PersonalDetailsBody(),
    );
  }
}

class _PersonalDetailsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<PersonalDetailsProvider>(context);

    // ---------- show loader while API is fetching ----------
    if (prov.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          BackgroundDecoration(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderSection(title: 'Personal Details', subtitle: 'Page 1 of 3'),
                    const SizedBox(height: 30),
                    HeadingText(title: 'Personal Details'),
                    const SizedBox(height: 24),

                    // ---------- PROFILE PICTURE ----------
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF5B4BDB),
                              image: prov.profilePictureUrl.isEmpty
                                  ? const DecorationImage(
                                      image: AssetImage('assets/images/Jins_Black.jpg'),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: NetworkImage(prov.profilePictureUrl),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                // TODO: open image picker & upload → set prov.profilePictureUrl
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: const Icon(Icons.edit, color: Color(0xFF5B4BDB), size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ---------- TEXT FIELDS ----------
                    _buildTextField('First Name', prov.firstName, (v) => prov.firstName = v),
                    const SizedBox(height: 16),
                    _buildTextField('Last Name', prov.lastName, (v) => prov.lastName = v),
                    const SizedBox(height: 16),
                    _buildTextField('email', '', (_) {}), // email not in API → keep empty
                    const SizedBox(height: 16),

                    // Phone (controller)
                    PhoneInuput(controller: prov.phoneCtrl),
                    const SizedBox(height: 16),

                    // Gender (controller)
                    InputfieldsRegistraton(label: 'Gender', controller: prov.genderCtrl),
                    const SizedBox(height: 16),

                    // Address (controller)
                    InputfieldsRegistraton(label: 'Address', controller: prov.addressCtrl),
                    const SizedBox(height: 20),

                    // ---------- PAYMENT OPTION ----------
                    Text('Payment Option', style: AppTextStyle.base.copyWith(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildPaymentButton(icon: Icons.person, label: 'Self', isSelected: prov.selectindex == 0, onTap: () => prov.setTab(0))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPaymentButton(icon: Icons.directions_car, label: 'Fleet', isSelected: prov.selectindex == 1, onTap: () => prov.setTab(1))),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (prov.selectindex == 1) _buildDropdownField(),
                    const SizedBox(height: 30),

                    // ---------- UPDATE BUTTON ----------
                    // Inside _PersonalDetailsBody → replace the ElevatedButton
SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: prov.canProceed
        ? () async {
            // Show loading
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saving...'), duration: Duration(seconds: 10)),
            );

            final success = await prov.saveProfileDetails();

            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile saved successfully!')),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VehicleDetails()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to save. Please try again.')),
              );
            }
          }
        : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5B4BDB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    ),
    child: prov.isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
        : Text(
            'Update Details',
            style: AppTextStyle.base.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
  ),
),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- helper widgets ----------
  Widget _buildTextField(String label, String initial, Function(String) onChanged) {
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        labelStyle: AppTextStyle.base.copyWith(fontSize: 12, color: Colors.grey[600]),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5B4BDB), width: 1)),
      ),
      onChanged: onChanged,
    );
  }

  // copy of your original payment button (unchanged)
  Widget _buildPaymentButton({required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B4BDB).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF5B4BDB) : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF5B4BDB) : Colors.grey[600], size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyle.base.copyWith(
                    color: isSelected ? const Color(0xFF5B4BDB) : Colors.grey[700], fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fleet',
          style: AppTextStyle.base.copyWith(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select your fleet',
                style: AppTextStyle.base.copyWith(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[600],
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
