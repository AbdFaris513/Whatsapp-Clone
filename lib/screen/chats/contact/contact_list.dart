import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_clone/widget/search.dart';

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChartMenuSearchBar(),
        SizedBox(height: 12),
        Container(
          child: Row(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(50),
                    child: Image.asset(
                      "assets/no_dp.jpeg",
                      height: 45,
                      width: 45,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text('Faris', style: GoogleFonts.roboto()),
                  Text('Egale'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
