import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/controller/chat_body_controller.dart';
import 'package:whatsapp_clone/screen/chats/empty_chat_screen.dart';
import 'package:whatsapp_clone/screen/first_screen.dart';
import 'package:whatsapp_clone/utils/my_colors.dart';
import 'package:whatsapp_clone/widget/search.dart';

class ChatMenusList extends StatelessWidget {
  ChatMenusList({super.key});
  final ChatBodyController chatBodyController = Get.put(ChatBodyController());

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChartMenuAppBar(),
          SizedBox(height: 12),

          if (chatBodyController.chatList.isNotEmpty) ...[
            ChartMenuSearchBar(),
            SizedBox(height: 12),
            ChartMenuCategories(
              categoriesList: ['All', 'Unread', 'Favourites', 'Groups'],
            ),
            SizedBox(height: 12),
          ] else ...[
            EmptyChatScreen(),
          ],
        ],
      ),
    );
  }
}

class ChartMenuCategories extends StatefulWidget with MyColors {
  final List<String> categoriesList;
  const ChartMenuCategories({super.key, required this.categoriesList});

  @override
  State<ChartMenuCategories> createState() => _ChartMenuCategoriesState();
}

class _ChartMenuCategoriesState extends State<ChartMenuCategories>
    with MyColors {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categoriesList.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? MyColors.cetagorySelectedContainerBackgroundColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: MyColors.cetagoryContainerBorderColor,
                ),
              ),
              child: Center(
                child: Text(
                  widget.categoriesList[index],
                  style: GoogleFonts.roboto(
                    color: isSelected
                        ? MyColors.cetagorySelectedContainerForegroundColor
                        : MyColors.searchHintTextColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChartMenuAppBar extends StatelessWidget with MyColors {
  const ChartMenuAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Chats',
          style: GoogleFonts.roboto(
            color: MyColors.foregroundColor,
            fontWeight: FontWeight.w900,
            fontSize: 34,
          ),
        ),
        Row(
          children: [
            SvgPicture.asset("assets/camera.svg", width: 25, height: 25),
            SizedBox(width: 6),
            InkWell(
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('loggedInPhone');

                  // Optional: Navigate to login screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => FirstScreen()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: ${e.toString()}')),
                  );
                }
              },
              child: CircleAvatar(radius: 14, child: Icon(Icons.add)),
            ),
          ],
        ),
      ],
    );
  }
}
