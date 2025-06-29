import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_clone/screen/chats/contact/add_contact.dart';
import 'package:whatsapp_clone/utils/my_colors.dart';
import 'package:whatsapp_clone/widget/search.dart';

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          ChartMenuSearchBar(),
          SizedBox(height: 12),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Contacts',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: MyColors.searchHintTextColor,
              ),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ContactDetailsContainer(),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  right: 6,
                  child: InkWell(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (context) => ContactPopup(),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.green,
                      ),

                      height: 50,
                      width: 50,
                      child: Center(child: Icon(Icons.group_add_outlined)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}

class ContactDetailsContainer extends StatelessWidget with MyColors {
  const ContactDetailsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(50),
                child: Image.asset("assets/no_dp.jpeg", height: 45, width: 45),
              ),
              SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Faris',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: MyColors.foregroundColor,
                    ),
                  ),
                  Text(
                    'A Sparrow Become an Egale',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: MyColors.searchHintTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Mobile',
                style: GoogleFonts.roboto(
                  fontSize: 11,
                  color: MyColors.searchHintTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
