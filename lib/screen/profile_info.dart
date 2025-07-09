import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_clone/utils/my_colors.dart';

class ProfileInfoScreen extends StatelessWidget with MyColors {
  String phoneNumber;
  ProfileInfoScreen({super.key, required this.phoneNumber});

  final TextEditingController _nameController = TextEditingController();

  void addUser(BuildContext context) async {
    String name = _nameController.text.trim();

    if (name.isNotEmpty) {
      try {
        print('Name : $name = Number : $phoneNumber');
        CollectionReference users = FirebaseFirestore.instance.collection(
          'users',
        );
        await users.add({
          'name': name,
          'phone': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'suma': 'ds',
        });
      } catch (e) {
        debugPrint('Error on $e');
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter name')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.only(top: mediaQuery.width / 2.8),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Profile Info',
                    style: GoogleFonts.roboto(
                      color: MyColors.greenGroundColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 42.0,
                      vertical: 6,
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: MyColors.foregroundColor,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Please Provide Your Name and an optional profile photo',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 13),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(100),
                        child: Image.asset(
                          "assets/no_dp.jpeg",
                          width: 120,
                          height: 120,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(100),
                          child: Container(
                            color: Colors.white,
                            child: Icon(
                              Icons.add_circle_rounded,
                              color: MyColors.massageNotificationColor,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 13),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _nameController,
                                  cursorColor: Colors.white,
                                  style: GoogleFonts.roboto(
                                    color: MyColors.foregroundColor,
                                    fontSize: 18,
                                  ),
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: MyColors.greenGroundColor,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: MyColors.greenGroundColor,
                                        width: 2,
                                      ),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: MyColors.greenGroundColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.greenGroundColor,
                  foregroundColor: MyColors.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50),
                ),
                onPressed: () => addUser(context),
                child: Text(
                  'NEXT',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
