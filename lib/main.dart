import 'package:emp_buddy/phoneOTPVerificationcopy.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Assuming you have generated this file with the `flutterfire` CLI.
import 'phoneOTPVerification.dart'; // Adjust the path as necessary based on your project structure.

void main() async {
//Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

//Default screen for application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the
  // root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emp Buddy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PhoneOTPVerificationcopy(),
    );
  }
}
