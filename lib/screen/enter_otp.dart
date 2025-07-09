import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_clone/screen/profile_info.dart';
import 'package:whatsapp_clone/utils/my_colors.dart';

class EnterOtpScreen extends StatelessWidget with MyColors {
  final String verificationId;
  final String phoneNumber;

  EnterOtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  final TextEditingController _controller = TextEditingController(
    text: "- - - - - -",
  );

  void _verifyOtp(BuildContext context) async {
    String rawInput = _controller.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (rawInput.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a 6-digit OTP")),
      );
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: rawInput,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Phone number verified!")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileInfoScreen(phoneNumber: phoneNumber),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("OTP verification failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text(
                "Verify your number",
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  color: MyColors.greenGroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.roboto(
                    fontSize: 14.3,
                    color: MyColors.foregroundColor,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          "Waiting to automatically detect an SMS sent to your number ",
                    ),
                    TextSpan(
                      text: phoneNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ". "),
                    TextSpan(
                      text: "Wrong number?",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pop(context);
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: TextField(
                  controller: _controller,
                  inputFormatters: [OtpInputFormatter()],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.backgroundColorShade,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    counterText: "",
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: MyColors.foregroundColor,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => print("Resend SMS tapped"),
                        child: const Text(
                          "Resend SMS",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () => print("Call Me tapped"),
                        child: const Text(
                          "Call Me",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.greenGroundColor,
                  foregroundColor: MyColors.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                ),
                onPressed: () => _verifyOtp(context),
                child: Text(
                  'Verify',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpInputFormatter extends TextInputFormatter {
  final int maxLength = 6;

  String _formatDigits(String digits) {
    String result = '';
    for (int i = 0; i < maxLength; i++) {
      if (i < digits.length) {
        result += digits[i];
      } else {
        result += '-';
      }
      if (i != maxLength - 1) {
        result += ' ';
      }
    }
    return result;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    final oldDigits = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final newDigitsRaw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    String newDigits = newDigitsRaw;

    // Detect backspace
    final isDeleting =
        newValue.selection.baseOffset < oldValue.selection.baseOffset;

    if (isDeleting && oldDigits.isNotEmpty) {
      newDigits = oldDigits.substring(0, oldDigits.length - 1);
    }

    // Limit to maxLength
    if (newDigits.length > maxLength) {
      newDigits = newDigits.substring(0, maxLength);
    }

    final formatted = _formatDigits(newDigits);

    // Place cursor at the end
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
