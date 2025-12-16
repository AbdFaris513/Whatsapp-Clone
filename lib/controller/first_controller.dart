import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/controller/chat_body_controller.dart';
import 'package:whatsapp_clone/controller/chat_screen_controller.dart';
import 'package:whatsapp_clone/controller/contact_controller.dart';
import 'package:whatsapp_clone/model/contact_model.dart';
import 'package:whatsapp_clone/screen/chats/chat_body.dart';
import 'package:whatsapp_clone/screen/chats/chats_screen.dart';
import 'package:whatsapp_clone/screen/first_screen.dart';

class FirstController extends GetxController {
  final ChatBodyController chatBodyController = Get.put(ChatBodyController());
  final ContactController contactController = Get.put(ContactController());
  final ChatScreenController chatScreenController = Get.put(ChatScreenController());

  void checkLoginStatus(final bool mounted, final BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    bool userExists = prefs.containsKey('loggedInPhone');

    if (userExists) {
      contactController.getMessagedContactsStream();
    }

    if (mounted) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => userExists ? ChatBodyScreen() : const FirstScreen(),
        ),
      );
    }
  }

  Future<void> getChatScreen({
    required final BuildContext context,
    required final ContactData contactData,
  }) async {
    String? currentUserId = await chatBodyController.getUserPhoneNumber();
    await chatScreenController.listenToMessages(currentUserId ?? 'null', contactData.contactNumber);
    Get.to(
      () => ChatsScreen(contactDetailData: contactData, currentUserId: currentUserId ?? 'null'),
    );
  }
}
