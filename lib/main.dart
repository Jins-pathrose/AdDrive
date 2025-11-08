import 'package:addrive/Controller/Login/login_provider.dart';
import 'package:addrive/Controller/ProfileRegistration/bank_details.dart';
import 'package:addrive/Controller/ProfileRegistration/personal_details.dart';
import 'package:addrive/Controller/ProfileRegistration/vehicle_details.dart';
import 'package:addrive/Controller/SignUp/email_otp_provider.dart';
import 'package:addrive/Controller/SignUp/signup_provider.dart';
import 'package:addrive/Controller/campaigns_tab.dart';
import 'package:addrive/Controller/notifications_tab.dart';
import 'package:addrive/View/Screens/entrypage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  // Request location permission at app start
  await Geolocator.requestPermission();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CampaignTabProvider()),
        ChangeNotifierProvider(create: (_)=> NotificationTabProvider()),
        ChangeNotifierProvider(create: (_)=> PersonalDetailsProvider()),
        ChangeNotifierProvider(create: (_)=>VehicleDetailsProviderclass()),
        ChangeNotifierProvider(create: (_)=>BankDetailsProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_)=> AuthProvider()),
        ChangeNotifierProvider(create: (_)=>OtpProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AdDriveWelcomeScreen(),
    );
  }
}
