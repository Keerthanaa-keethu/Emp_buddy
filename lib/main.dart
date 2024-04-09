import 'package:emp_buddy/phoneOTPVerification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Assuming you have generated this file with the `flutterfire` CLI.

void main() async {
//Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  (options: DefaultFirebaseOptions.currentPlatform,);

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
      home: PhoneOTPVerification(),
    );
  }
}
