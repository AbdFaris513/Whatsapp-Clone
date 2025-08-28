import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_clone/controller/contact_controller.dart';
import 'package:whatsapp_clone/model/contact_model.dart';
import 'package:whatsapp_clone/screen/contact/add_contact.dart';
import 'package:whatsapp_clone/utils/my_colors.dart';
import 'package:whatsapp_clone/widget/search.dart';

class ContactListScreen extends StatelessWidget {
  ContactListScreen({super.key});

  final ContactController contactController = Get.put(ContactController());

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
                Obx(
                  () => ListView.builder(
                    itemCount: contactController.contactData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ContactDetailsContainer(
                          contactData: contactController.contactData[index],
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 6,
                  child: InkWell(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
  final ContactData contactData;
  ContactDetailsContainer({super.key, required this.contactData});

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
                child: Image.asset(
                  contactData.contactImage == null
                      ? "assets/no_dp.jpeg"
                      : contactData.contactImage!,
                  height: 45,
                  width: 45,
                ),
              ),
              SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    contactData.contactFirstName,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: MyColors.foregroundColor,
                    ),
                  ),
                  Text(
                    contactData.contactStatus ?? '',
                    style: GoogleFonts.roboto(fontSize: 14, color: MyColors.searchHintTextColor),
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
                style: GoogleFonts.roboto(fontSize: 11, color: MyColors.searchHintTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
