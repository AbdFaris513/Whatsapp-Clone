import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/controller/chat_body_controller.dart';
import 'package:whatsapp_clone/controller/contact_controller.dart';
import 'package:whatsapp_clone/model/contact_model.dart';
import 'package:whatsapp_clone/screen/chats/chats_screen.dart';
import 'package:whatsapp_clone/screen/chats/empty_chat_screen.dart';
import 'package:whatsapp_clone/screen/first_screen.dart';
import 'package:whatsapp_clone/utils/my_colors.dart';
import 'package:whatsapp_clone/widget/search.dart';

class ChatMenusList extends StatelessWidget {
  ChatMenusList({super.key});
  final ChatBodyController chatBodyController = Get.put(ChatBodyController());
  final ContactController contactController = Get.put(ContactController());

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ChartMenuAppBar(),
          SizedBox(height: 12),

          if (true
          // chatBodyController.chatList.isNotEmpty
          ) ...[
            ChartMenuSearchBar(),
            SizedBox(height: 12),
            ChartMenuCategories(categoriesList: ['All', 'Unread', 'Favourites', 'Groups']),
            SizedBox(height: 12),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: contactController.messagedContacts.length,
                  itemBuilder: (context, index) {
                    return ChatsDetailsContainer(
                      contactData: contactController.messagedContacts[index],
                    );
                  },
                ),
              ),
            ),
            // ChatsDetailsContainer(
            //   contactData: ContactData(
            //     id: '',
            //     contactNumber: 'Munir',
            //     contactFirstName: 'Munir',
            //     contactLastMsg: 'Wa Alaikum Assalam',
            //     contactLastMsgTime: DateTime.now(),
            //     unreadMessages: 0,
            //   ),
            // ),
          ] else ...[
            EmptyChatScreen(),
          ],
        ],
      ),
    );
  }
}

class ChatsDetailsContainer extends StatefulWidget with MyColors {
  final ContactData contactData;

  ChatsDetailsContainer({super.key, required this.contactData});

  @override
  State<ChatsDetailsContainer> createState() => _ChatsDetailsContainerState();
}

class _ChatsDetailsContainerState extends State<ChatsDetailsContainer> {
  final ChatBodyController chatBodyController = Get.put(ChatBodyController());

  late final String? userID;

  @override
  void initState() {
    getAwaitFunctions();
    super.initState();
  }

  Future<void> getAwaitFunctions() async {
    userID = await chatBodyController.getUserPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        String? currentUserId = await chatBodyController.getUserPhoneNumber();
        Get.to(
          () => ChatsScreen(
            contactDetailData: widget.contactData,
            currentUserId: currentUserId ?? 'null',
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3),
        margin: EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(50),
                  child: Image.asset(
                    "assets/no_dp.jpeg",
                    // widget.contactData.contactImage == null
                    //     ? "assets/no_dp.jpeg"
                    //     : widget.contactData.contactImage!,
                    height: 45,
                    width: 45,
                  ),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.contactData.contactFirstName,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: MyColors.foregroundColor,
                      ),
                    ),
                    Text(
                      widget.contactData.contactLastMsg ?? '',
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
                  chatBodyController.formatLastInteraction(widget.contactData.contactLastMsgTime),
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: (widget.contactData.unreadMessages) > 0
                        ? MyColors.massageNotificationColor
                        : MyColors.searchHintTextColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: widget.contactData.unreadMessages > 0
                        ? MyColors.massageNotificationColor
                        : Colors.transparent,
                    foregroundColor: widget.contactData.unreadMessages > 0
                        ? MyColors.backgroundColor
                        : Colors.transparent,
                    child: Text(
                      widget.contactData.unreadMessages.toString(),
                      style: GoogleFonts.roboto(fontSize: 11, color: MyColors.backgroundColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

class _ChartMenuCategoriesState extends State<ChartMenuCategories> with MyColors {
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
                border: Border.all(color: MyColors.cetagoryContainerBorderColor),
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
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
