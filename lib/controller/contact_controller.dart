import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/model/contact_model.dart';

class ContactController extends GetxController {
  RxList<ContactData> contactData = <ContactData>[
    ContactData(
      contactFirstName: "Faris",
      contactNumber: "+9876543210",
      contactStatus: "A Sparrow Become an Egale",
    ),
    ContactData(contactFirstName: "Alice", contactNumber: "+1234567890"),
    ContactData(contactFirstName: "Bob", contactNumber: "+1987654321"),
    ContactData(contactFirstName: "Charlie", contactNumber: "+1122334455"),
    ContactData(contactFirstName: "Diana", contactNumber: "+1098765432"),
  ].obs;

  Future<void> addContact(ContactData newContact) async {
    try {
      contactData.add(newContact);
    } catch (e) {
      print("Error on Contact : $e");
    }
  }

  Future<void> getContacts() async {
    try {} catch (e) {
      debugPrint("Error on get contacts: $e");
    }
  }

  Future<void> getUserContactList(String phoneNumber) async {
    contactData.clear();
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .get();

      if (userDoc.exists) {
        List<dynamic> contactList = userDoc.get('contactList');

        // Convert to usable Dart Map/List
        List<Map<String, dynamic>> contacts = contactList.map((contact) {
          return {'contactName': contact['contactName'], 'phoneNumber': contact['phoneNumber']};
        }).toList();

        for (var contact in contacts) {
          contactData.add(
            ContactData(
              contactFirstName: contact['contactName'],
              contactNumber: contact['phoneNumber'],
            ),
          );
        }
        debugPrint('Con >> ');
        contactData.refresh();
      } else {
        debugPrint('User not found!');
      }
    } catch (e) {
      debugPrint('Error fetching contact list: $e');
    }
  }
}
