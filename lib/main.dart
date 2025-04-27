import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:railway_app/signup_login.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),      //actual app entry
    ),
  );
}

// root widget. 
class MyApp extends StatelessWidget {
  const MyApp({super.key});                     // super.key passes key to the parent class. Useful to identify widgets when they update
  
  @override                                     // Tells Flutter you're overriding a method from the parent class
  Widget build(BuildContext context) {
    return MaterialApp(                         // Creates a material design app wrapper
      builder: DevicePreview.appBuilder,        // Applies the device preview wrapper
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),    // Adapts to selected device locale
      title: 'Railway Booking',
      home: const Login(),
    );
  }
}
