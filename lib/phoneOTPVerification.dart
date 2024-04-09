import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'benefitsScreen.dart';

class PhoneOTPVerification extends StatefulWidget {
  const PhoneOTPVerification({Key? key}) : super(key: key);

  @override
  State<PhoneOTPVerification> createState() => _PhoneOTPVerificationState();
}

class _PhoneOTPVerificationState extends State<PhoneOTPVerification> {
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController otp = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool isOtpVisible = false;
  bool isVisible = false;
  String? verificationId;
  bool isLoading = false;

  @override
  void dispose() {
    phoneNumber.dispose();
    otp.dispose();
    otpControllers.forEach((controller) => controller.dispose());
    otpFocusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  bool get isOtpComplete =>
      otpControllers.every((controller) => controller.text.length == 1);

  Widget buildOtpBox(int index) {
    return Container(
      width: 30,
      height: 50,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Colors.blue)),
      ),
      child: TextFormField(
        controller: otpControllers[index],
        focusNode: otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        obscureText: !isOtpVisible, // Updated based on isOtpVisible state
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "", // Hide the counter text
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).requestFocus(otpFocusNodes[index + 1]);
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(otpFocusNodes[index - 1]);
          }
          setState(() {}); // Trigger UI update for the Verify OTP button
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: isVisible
            ? IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Colors
                        .blue), // Ensure the icon color contrasts with the AppBar background
                onPressed: resetToPhoneNumberInput,
              )
            : null, // No leading widget when not in OTP state, allowing the title (logo) to be more centered
        title: isVisible
            ? Text("Enter OTP",
                style: TextStyle(
                    color: Colors.blue)) // Display text when in OTP state
            : SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  'assets/logo_opaque.webp', // Centered logo when not in OTP state
                  fit: BoxFit.contain,
                ),
              ),
        centerTitle:
            true, // This attempts to center the title content, but exact centering may be affected by the presence of leading/back button
        backgroundColor: Colors.white,
        toolbarHeight:
            80, // Customize with your color // Customize with your color
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isVisible) ...[
                    Text(
                      "Enter your phone number",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: phoneNumber,
                      enabled: !isVisible,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        // Trigger a rebuild whenever the text changes to reflect button enabled state
                        setState(() {});
                      },
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length != 10) {
                          return 'Please enter a valid phone number.';
                        }
                        return null;
                      },
                    ),
                  ],
                  if (isVisible)
                    Text(
                      "OTP sent to your phone number ${phoneNumber.text}",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  SizedBox(height: 30),
                  if (!isVisible) // Show "Send OTP" only if isVisible is false
                    ElevatedButton(
                      onPressed: phoneNumber.text.length == 10 && !isLoading
                          ? () async {
                              setState(() {
                                isLoading = true;
                              });
                              await sendOTP(phoneNumber.text.trim());
                              setState(() {
                                isLoading = false;
                                isVisible =
                                    true; // Show OTP input fields after sending OTP
                              });
                            }
                          : null,
                      child: Text(
                        'Send OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Larger font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  if (isVisible)
                    // Show OTP input fields if isVisible is true
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ...List.generate(6, (index) => buildOtpBox(index)),
                        IconButton(
                          icon: Icon(
                            isOtpVisible
                                ? Icons.visibility
                                : Icons
                                    .visibility_off, // Toggle icon based on isOtpVisible
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              isOtpVisible = !isOtpVisible;
                            });
                          },
                        ),
                      ],
                    ),
                  SizedBox(height: 30),
                  if (isVisible) // Show "Verify OTP" only if isVisible is true
                    ElevatedButton(
                      onPressed: isOtpComplete && !isLoading
                          ? () async {
                              // Combine the OTP digits and authenticate
                              final combinedOtp = otpControllers
                                  .map((controller) => controller.text)
                                  .join('');
                              otp.text = combinedOtp;
                              if (verificationId != null) {
                                await authenticate(
                                    verificationId!, otp.text.trim());
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Verify OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Larger font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void resetToPhoneNumberInput() {
    setState(() {
      isVisible = false; // Hide the OTP fields
      // Optionally reset the phone number and OTP controllers if needed
      // phoneNumber.clear();
      otpControllers.forEach((controller) => controller.clear());
    });
  }

  // Function to send OTP
  Future<void> sendOTP(String phoneNumber) async {
    setState(() {
      isVisible = true; // Show OTP input field
    });
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
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BenefitsScreen()));
    } on FirebaseAuthException catch (e) {
      debugPrint("Error authenticating OTP: ${e.message}");
    }
  }
}
