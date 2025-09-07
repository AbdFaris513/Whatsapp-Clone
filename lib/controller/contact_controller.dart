import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/model/contact_model.dart';

class ContactController extends GetxController {
  RxList<ContactData> contactData = <ContactData>[].obs;
  RxList<ContactData> messagedContacts = <ContactData>[].obs; // New list for messaged contacts

  // Add this to your ContactController
  StreamSubscription? _chatsSubscription;

  @override
  void onClose() {
    _chatsSubscription?.cancel();
    super.onClose();
  }

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

    debugPrint('Contact added successfully!');
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
          await getUserContactList(phoneNumber: userId);
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
        // ignore: use_build_context_synchronously
        showTopSnackBarWithOTP(context);
      }
    } catch (e) {
      debugPrint("Error on Contact : $e");
      // ignore: use_build_context_synchronously
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

  Future<void> getUserContactList({required String phoneNumber}) async {
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
  Future<void> setupMessagedContactsStream() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserId = prefs.getString('loggedInPhone');

      if (currentUserId == null) {
        debugPrint('No logged in user found');
        return;
      }

      // Cancel any existing subscription
      _chatsSubscription?.cancel();

      // Set up real-time stream
      _chatsSubscription = FirebaseFirestore.instance
          .collection('chats')
          .where('participantIds', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .listen(
            (chatsSnapshot) async {
              await _processChatsSnapshot(chatsSnapshot, currentUserId);
            },
            onError: (error) {
              debugPrint('Error in messaged contacts stream: $error');
            },
          );
    } catch (e) {
      debugPrint('Error setting up messaged contacts stream: $e');
    }
  }

  // Helper method to process the snapshot
  Future<void> _processChatsSnapshot(QuerySnapshot chatsSnapshot, String currentUserId) async {
    final List<ContactData> tempContacts = [];

    for (final chatDoc in chatsSnapshot.docs) {
      final chatData = chatDoc.data() as Map<String, dynamic>;
      final List<dynamic> participantIds = chatData['participantIds'] ?? [];

      // Find the other participant
      final String? otherParticipantId = participantIds.cast<String?>().firstWhere(
        (id) => id != currentUserId,
        orElse: () => null,
      );

      if (otherParticipantId != null && otherParticipantId.isNotEmpty) {
        try {
          // Get user details
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(otherParticipantId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;

            // Process the chat data
            final contact = await _createContactFromChat(
              chatData,
              userData,
              otherParticipantId,
              currentUserId,
              chatDoc.id,
            );

            tempContacts.add(contact);
          }
        } catch (e) {
          debugPrint('Error processing chat for $otherParticipantId: $e');
        }
      }
    }

    // Update the observable list
    messagedContacts.assignAll(tempContacts);
    debugPrint('Updated messaged contacts: ${messagedContacts.length}');
  }

  // Helper to create ContactData from chat
  Future<ContactData> _createContactFromChat(
    Map<String, dynamic> chatData,
    Map<String, dynamic> userData,
    String otherParticipantId,
    String currentUserId,
    String chatId,
  ) async {
    // Safely extract data
    final lastMessage = chatData['lastMessage']?.toString() ?? '';
    final lastMessageType = chatData['lastMessageType']?.toString() ?? 'text';

    DateTime? lastMessageTime;
    final lastMessageTimeData = chatData['lastMessageTime'];
    if (lastMessageTimeData is Timestamp) {
      lastMessageTime = lastMessageTimeData.toDate();
    }

    int unreadMessages = 0;
    final unreadCounts = chatData['unreadCounts'];
    if (unreadCounts is Map<String, dynamic>) {
      final userUnread = unreadCounts[currentUserId];
      if (userUnread is int) {
        unreadMessages = userUnread;
      }
    }

    // Get existing contact if available
    ContactData? existingContact;
    try {
      existingContact = contactData.firstWhere(
        (contact) => contact.contactNumber == otherParticipantId,
      );
    } catch (e) {
      // Contact not found, that's okay
    }

    return ContactData(
      id: otherParticipantId,
      contactFirstName: userData['name']?.toString() ?? 'Unknown',
      contactSecondName: existingContact?.contactSecondName,
      contactBusinessName: existingContact?.contactBusinessName,
      contactNumber: otherParticipantId,
      contactStatus: userData['about']?.toString(),
      contactImage: userData['profilePicture']?.toString(),
      contactLastSeen: parseFirestoreDate(userData['lastSeen']),
      contactLastMsgTime: lastMessageTime,
      contactLastMsg: lastMessage,
      contactLastMsgType: lastMessageType,
      unreadMessages: unreadMessages,
      isContactPinned: existingContact?.isContactPinned ?? false,
      isContactMuted: existingContact?.isContactMuted ?? false,
      isContactBlocked: existingContact?.isContactBlocked ?? false,
      isContactArchived: existingContact?.isContactArchived ?? false,
      isOnline: userData['isOnline'] is bool ? userData['isOnline'] as bool : false,
      about: userData['about']?.toString(),
      lastMessageId: chatId,
      lastInteraction: lastMessageTime,
      labels: existingContact?.labels,
    );
  }

  DateTime? parseFirestoreDate(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null; // fallback
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
    getMessagedContactsStream();
  }
}
