import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/screen/chats/chat_body.dart';

class ChatBodyController extends GetxController {
  RxInt bottonNavigatorIndex = (0).obs;

  RxList<String> chatList = <String>[].obs;

  Future<String?> getUserPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    String? phoneNumber = prefs.getString('loggedInPhone');
    return phoneNumber;
  }

  Future<void> addUser({
    required BuildContext context,
    required String name,
    required String phoneNumber,
  }) async {
    if (name.isNotEmpty) {
      try {
        CollectionReference users = FirebaseFirestore.instance.collection('users');
        await users.doc(phoneNumber).set({
          'name': name,
          'phone': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'profilePicture': '',
          'lastSeen': '',
          'isOnline': true,
          'about': '',
          'contactList': [],
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('loggedInPhone', phoneNumber);
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => ChatBodyScreen()),
        );
      } catch (e) {
        debugPrint('Error on $e');
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter name')));
    }
  }

  // ************************** Business logic to handle ************************** //

  String formatLastInteraction(DateTime? dateTime) {
    if (dateTime == null) return "";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      // same day → show time like 10:22 pm
      return DateFormat("h:mm a").format(dateTime).toLowerCase();
    } else if (dateToCheck == yesterday) {
      return "Yesterday";
    } else {
      // show full date like 18/08/2025
      return DateFormat("dd/MM/yyyy").format(dateTime);
    }
  }
}
