import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final Widget upPadding = SizedBox(height: height / 3.1);
    final Widget downPadding = SizedBox(height: 90);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
                Column(
                  children: [
                    Text(
                      'from',
                      style: GoogleFonts.roboto(color: Color(0XFF867373)),
                    ),
                    Text(
                      'FACEBOOK',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    downPadding,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
