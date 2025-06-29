import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_clone/utils/my_colors.dart';
import 'package:whatsapp_clone/widget/from_facebook.dart';

class SplashScreen extends StatelessWidget with MyColors {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final Widget upPadding = SizedBox(height: height / 3.1);
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Stack(
        children: [
          SvgPicture.asset('assets/splash_screen.svg'),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    upPadding,
                    SvgPicture.asset('assets/logo.svg'),
                    SizedBox(height: 12),
                    Text(
                      'WhatsApp',
                      style: GoogleFonts.robotoCondensed(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                FromFacebook(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
