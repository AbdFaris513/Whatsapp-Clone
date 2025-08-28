import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/model/contact_model.dart';

class ContactController extends GetxController {
  RxList<ContactData> contactData = <ContactData>[
    // ContactData(
    //   contactFirstName: "Faris",
    //   contactNumber: "+9876543210",
    //   contactStatus: "A Sparrow Become an Egale",
    // ),
    // ContactData(contactFirstName: "Alice", contactNumber: "+1234567890"),
    // ContactData(contactFirstName: "Bob", contactNumber: "+1987654321"),
    // ContactData(contactFirstName: "Charlie", contactNumber: "+1122334455"),
    // ContactData(contactFirstName: "Diana", contactNumber: "+1098765432"),
  ].obs;

  Future<bool> doesUserExist(String phoneNumber) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(phoneNumber).get();
    return doc.exists;
  }

  Future<bool> contactExistsInUserList({
    required String userId,
    required String contactPhoneNumber,
  }) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) return false;

    final data = userDoc.data() as Map<String, dynamic>;
    final List<dynamic> contactList = List.from(data['contactList'] ?? []);

    return contactList.any(
      (contact) => contact is Map<String, dynamic> && contact['phoneNumber'] == contactPhoneNumber,
    );
  }

  Future<void> updateContactNameInList({
    required String userId,
    required String contactPhoneNumber,
    required String newContactName,
  }) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final List<dynamic> contactList = List.from(data['contactList'] ?? []);

    for (int i = 0; i < contactList.length; i++) {
      final contact = contactList[i];
      if (contact['phoneNumber'] == contactPhoneNumber) {
        contactList[i]['contactName'] = newContactName;
        break;
      }
    }

    await userRef.update({'contactList': contactList});
  }

  Future<void> addSingleContact({
    required String userId,
    required String phoneNumber,
    required String contactName,
  }) async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await userDocRef.update({
      'contactList': FieldValue.arrayUnion([
        {'phoneNumber': phoneNumber, 'contactName': contactName},
      ]),
    });

    print('Contact added successfully!');
  }

  Future<void> addContact(ContactData newContact, BuildContext context) async {
    try {
      final contactPhone = '+91${newContact.contactNumber}';
      bool itsHaveAccount = await doesUserExist(contactPhone);

      if (itsHaveAccount) {
        final prefs = await SharedPreferences.getInstance();
        String userId = prefs.getString('loggedInPhone') ?? '';

        bool isAlreadyHaveThisNumber = await contactExistsInUserList(
          userId: userId,
          contactPhoneNumber: contactPhone,
        );

        if (isAlreadyHaveThisNumber) {
          await updateContactNameInList(
            userId: userId,
            contactPhoneNumber: contactPhone,
            newContactName: newContact.contactFirstName,
          );
          await getUserContactList(userId);
        } else {
          await addSingleContact(
            userId: userId,
            phoneNumber: contactPhone,
            contactName: newContact.contactFirstName,
          );
          contactData.add(newContact);
        }
        contactData.refresh();
      } else {
        showTopSnackBarWithOTP(context);
      }
    } catch (e) {
      debugPrint("Error on Contact : $e");
      showTopSnackBarWithOTP(context);
    }
  }

  void showTopSnackBarWithOTP(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'This contact does not have an account on this app.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
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
              id: DateTime.now().millisecondsSinceEpoch.toString(),
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
