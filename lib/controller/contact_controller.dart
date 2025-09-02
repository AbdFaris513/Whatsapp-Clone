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

  // RxList<ContactData> contactData = <ContactData>[].obs;
  RxList<ContactData> messagedContacts = <ContactData>[].obs; // New list for messaged contacts

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

  /// *************************************************************** //
  // New function to get only contacts that have existing messages
  Future<void> getMessagedContacts() async {
    try {
      debugPrint('Come here msg');
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserId = prefs.getString('loggedInPhone');

      if (currentUserId == null) {
        debugPrint('No logged in user found');
        return;
      }

      // Clear the list first
      messagedContacts.clear();

      // Get all chats where current user is a participant
      final chatsQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('participantIds', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      for (final chatDoc in chatsQuery.docs) {
        final chatData = chatDoc.data();
        final List<dynamic> participantIds = chatData['participantIds'] ?? [];

        // Find the other participant (not the current user)
        final String otherParticipantId = participantIds.firstWhere(
          (id) => id != currentUserId,
          orElse: () => null,
        );

        // Get user details for the other participant
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherParticipantId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          // Get the last message details from the chat
          final lastMessage = chatData['lastMessage'] ?? '';
          final lastMessageTime = (chatData['lastMessageTime'] as Timestamp?)?.toDate();
          final lastMessageType = chatData['lastMessageType'] ?? 'text';
          final lastMessageSender = chatData['lastMessageSender'] ?? '';

          // Get unread count for current user
          final unreadCounts = chatData['unreadCounts'] as Map<String, dynamic>? ?? {};
          final unreadMessages = unreadCounts[currentUserId] ?? 0;

          // Check if this contact is already in our contact list
          final existingContact = contactData.firstWhere(
            (contact) => contact.contactNumber == otherParticipantId,
            orElse: () => ContactData(
              id: otherParticipantId,
              contactFirstName: 'Unknown',
              contactNumber: otherParticipantId,
            ),
          );

          print('sxcsd ${userData['lastSeen']}');

          // Create ContactData with message history
          final ContactData messagedContact = ContactData(
            id: otherParticipantId,
            contactFirstName: userData['name'] ?? existingContact.contactFirstName,
            contactSecondName: existingContact.contactSecondName,
            contactBusinessName: existingContact.contactBusinessName,
            contactNumber: otherParticipantId,
            contactStatus: userData['about'] ?? existingContact.contactStatus,
            contactImage: userData['profilePicture'] ?? existingContact.contactImage,
            contactLastSeen: DateTime.tryParse(
              userData['lastSeen'].toString(),
            ), // (userData['lastSeen'] as Timestamp?)?.toDate(),
            contactLastMsgTime: lastMessageTime,
            contactLastMsg: lastMessage,
            contactLastMsgType: lastMessageType,
            unreadMessages: unreadMessages,
            isContactPinned: existingContact.isContactPinned,
            isContactMuted: existingContact.isContactMuted,
            isContactBlocked: existingContact.isContactBlocked,
            isContactArchived: existingContact.isContactArchived,
            isOnline: userData['isOnline'] ?? false,
            about: userData['about'] ?? existingContact.about,
            lastMessageId: chatDoc.id,
            lastInteraction: lastMessageTime,
            labels: existingContact.labels,
          );

          messagedContacts.add(messagedContact);
        }
      }

      // Sort by last message time (most recent first)
      messagedContacts.sort((a, b) {
        final aTime = a.contactLastMsgTime ?? DateTime(0);
        final bTime = b.contactLastMsgTime ?? DateTime(0);
        return bTime.compareTo(aTime);
      });

      messagedContacts.refresh();
      debugPrint('Found ${messagedContacts.length} messaged contacts');
    } catch (e) {
      debugPrint('Error getting messaged contacts: $e');
    }
  }

  // Optional: Stream version for real-time updates
  Stream<List<ContactData>> getMessagedContactsStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participantIds', arrayContains: _getCurrentUserId())
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((chatsSnapshot) async {
          final List<ContactData> contacts = [];
          final String? currentUserId = await _getCurrentUserIdAsync();

          if (currentUserId == null) return contacts;

          for (final chatDoc in chatsSnapshot.docs) {
            final chatData = chatDoc.data();
            final List<dynamic> participantIds = chatData['participantIds'] ?? [];

            final String otherParticipantId = participantIds.firstWhere(
              (id) => id != currentUserId,
              orElse: () => null,
            );

            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(otherParticipantId)
                .get();

            if (userDoc.exists) {
              final userData = userDoc.data() as Map<String, dynamic>;
              final existingContact = contactData.firstWhere(
                (contact) => contact.contactNumber == otherParticipantId,
                orElse: () => ContactData(
                  id: otherParticipantId,
                  contactFirstName: 'Unknown',
                  contactNumber: otherParticipantId,
                ),
              );

              final lastMessageTime = (chatData['lastMessageTime'] as Timestamp?)?.toDate();

              contacts.add(
                ContactData(
                  id: otherParticipantId,
                  contactFirstName: userData['name'] ?? existingContact.contactFirstName,
                  contactNumber: otherParticipantId,
                  contactStatus: userData['about'],
                  contactImage: userData['profilePicture'],
                  contactLastSeen: (userData['lastSeen'] as Timestamp?)?.toDate(),
                  contactLastMsgTime: lastMessageTime,
                  contactLastMsg: chatData['lastMessage'] ?? '',
                  contactLastMsgType: chatData['lastMessageType'] ?? 'text',
                  unreadMessages:
                      (chatData['unreadCounts'] as Map<String, dynamic>?)?[currentUserId] ?? 0,
                  isOnline: userData['isOnline'] ?? false,
                  about: userData['about'],
                  lastInteraction: lastMessageTime,
                ),
              );
            }
          }

          return contacts;
        });
  }

  // Helper method to get current user ID
  Future<String?> _getCurrentUserIdAsync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedInPhone');
  }

  // Helper method for stream version (you might need to adjust this)
  String _getCurrentUserId() {
    // This is a simplified version - you might want to use a different approach
    // for getting the current user ID synchronously
    return Get.find<SharedPreferences>().getString('loggedInPhone') ?? '';
  }

  // Call this function when you want to refresh messaged contacts
  Future<void> refreshMessagedContacts() async {
    await getMessagedContacts();
  }
}
