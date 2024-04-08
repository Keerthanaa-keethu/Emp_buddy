import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneOTPVerification extends StatefulWidget {
  const PhoneOTPVerification({Key? key}) : super(key: key);
  @override
  State<PhoneOTPVerification> createState() => _PhoneOTPVerificationState();
}

class _PhoneOTPVerificationState extends State<PhoneOTPVerification> {
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController otp = TextEditingController();
  bool isVisible = false; // Renamed for clarity
  String? verificationId; // To store Firebase verification ID
  @override
  void dispose() {
    phoneNumber.dispose();
    otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(1),
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(
                'assets/logo_opaque.webp',
                fit: BoxFit.contain,
              ), // Use your logo asset path here
            ),
          ),
          backgroundColor: Colors.white,
          toolbarHeight: 80),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            inputTextField("Contact Number", phoneNumber, context),
            isVisible ? inputTextField("OTP", otp, context) : const SizedBox(),
            !isVisible ? sendOTPButton("Send OTP") : submitOTPButton("Submit"),
          ],
        ),
      ),
    );
  }

  Widget sendOTPButton(String text) => ElevatedButton(
        onPressed: () async {
          setState(() {
            isVisible = true; // Show OTP input field
          });
          await sendOTP(phoneNumber.text);
        },
        child: Text(text),
      );
  Widget submitOTPButton(String text) => ElevatedButton(
        onPressed: () async {
          if (verificationId != null) {
            await authenticate(verificationId!, otp.text);
          }
        },
        child: Text(text),
      );
  Widget inputTextField(String labelText, TextEditingController controller,
          BuildContext context) =>
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          child: TextFormField(
            obscureText: labelText == "OTP",
            controller: controller,
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle: const TextStyle(color: Colors.blue),
              filled: true,
              fillColor: Colors.blue[100],
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(5.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(5.5),
              ),
            ),
          ),
        ),
      );
  // Function to send OTP
  Future<void> sendOTP(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("Verification Failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId =
            verificationId; // Store verification ID for later use
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Function to authenticate OTP
  Future<void> authenticate(String verificationId, String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp);
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      debugPrint(isNewUser ? "Authentication Successful" : "Welcome Back");
    } on FirebaseAuthException catch (e) {
      debugPrint("Error authenticating OTP: ${e.message}");
    }
  }
}
