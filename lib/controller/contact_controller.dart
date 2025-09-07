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
      final contactPhone = newContact.contactNumber;
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

  // Update the _createContactFromChat method to show phone number if contact is not saved
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

    // Check if contact exists in user's saved contacts
    bool isContactSaved = contactData.any((contact) => contact.contactNumber == otherParticipantId);

    // Determine the display name - use phone number if contact is not saved
    String displayName;

    if (isContactSaved) {
      // Use the saved contact name
      ContactData savedContact = contactData.firstWhere(
        (contact) => contact.contactNumber == otherParticipantId,
      );
      displayName = savedContact.contactFirstName;
    } else {
      // Use the phone number if contact is not saved
      displayName = otherParticipantId;
    }

    return ContactData(
      id: otherParticipantId,
      contactFirstName: displayName, // Use the determined display name
      contactSecondName: isContactSaved
          ? contactData
                .firstWhere((contact) => contact.contactNumber == otherParticipantId)
                .contactSecondName
          : null,
      contactBusinessName: isContactSaved
          ? contactData
                .firstWhere((contact) => contact.contactNumber == otherParticipantId)
                .contactBusinessName
          : null,
      contactNumber: otherParticipantId,
      contactStatus: userData['about']?.toString(),
      contactImage: userData['profilePicture']?.toString(),
      contactLastSeen: parseFirestoreDate(userData['lastSeen']),
      contactLastMsgTime: lastMessageTime,
      contactLastMsg: lastMessage,
      contactLastMsgType: lastMessageType,
      unreadMessages: unreadMessages,
      isContactPinned: isContactSaved
          ? contactData
                .firstWhere((contact) => contact.contactNumber == otherParticipantId)
                .isContactPinned
          : false,
      isContactMuted: isContactSaved
          ? contactData
                .firstWhere((contact) => contact.contactNumber == otherParticipantId)
                .isContactMuted
          : false,
      isContactBlocked: isContactSaved
          ? contactData
                .firstWhere((contact) => contact.contactNumber == otherParticipantId)
                .isContactBlocked
          : false,
      isContactArchived: isContactSaved
          ? contactData
                .firstWhere((contact) => contact.contactNumber == otherParticipantId)
                .isContactArchived
          : false,
      isOnline: userData['isOnline'] is bool ? userData['isOnline'] as bool : false,
      about: userData['about']?.toString(),
      lastMessageId: chatId,
      lastInteraction: lastMessageTime,
      labels: isContactSaved
          ? contactData.firstWhere((contact) => contact.contactNumber == otherParticipantId).labels
          : null,
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
  // Update the stream version to show phone number if contact is not saved
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

            // Check if contact exists in saved contacts
            bool isContactSaved = contactData.any(
              (contact) => contact.contactNumber == otherParticipantId,
            );

            String displayName;

            if (isContactSaved) {
              ContactData savedContact = contactData.firstWhere(
                (contact) => contact.contactNumber == otherParticipantId,
              );
              displayName = savedContact.contactFirstName;
            } else {
              displayName = otherParticipantId;
            }

            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(otherParticipantId)
                .get();

            if (userDoc.exists) {
              final userData = userDoc.data() as Map<String, dynamic>;
              final lastMessageTime = (chatData['lastMessageTime'] as Timestamp?)?.toDate();

              contacts.add(
                ContactData(
                  id: otherParticipantId,
                  contactFirstName: displayName,
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

  // Add these functions to your ContactController

  /// Mark messages as seen when user opens a chat
  Future<void> markMessagesAsSeen(String chatId, String contactPhoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserId = prefs.getString('loggedInPhone');

      if (currentUserId == null) return;

      // Get the chat document
      final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) return;

      final chatData = chatDoc.data() as Map<String, dynamic>;

      // Update unread count for current user to 0
      await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
        'unreadCounts.$currentUserId': 0,
      });

      // Also update the messagedContacts list locally
      final index = messagedContacts.indexWhere(
        (contact) => contact.contactNumber == contactPhoneNumber,
      );

      if (index != -1) {
        messagedContacts[index] = messagedContacts[index].copyWith(unreadMessages: 0);
        messagedContacts.refresh();
      }

      debugPrint('Messages marked as seen for chat: $chatId');
    } catch (e) {
      debugPrint('Error marking messages as seen: $e');
    }
  }

  /// Update user's last seen timestamp
  Future<void> updateLastSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserId = prefs.getString('loggedInPhone');

      if (currentUserId == null) return;

      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': true, // Set online status when active
      });

      debugPrint('Last seen updated for user: $currentUserId');
    } catch (e) {
      debugPrint('Error updating last seen: $e');
    }
  }

  /// Handle chat click - combines multiple operations
  Future<void> onChatClick({required String chatId, required String contactPhoneNumber}) async {
    try {
      // 1. Mark messages as seen
      await markMessagesAsSeen(chatId, contactPhoneNumber);

      // 2. Update user's last seen
      await updateLastSeen();

      // 3. Refresh the messaged contacts list
      await refreshMessagedContacts();

      debugPrint('Chat click handled successfully for: $contactPhoneNumber');
    } catch (e) {
      debugPrint('Error handling chat click: $e');
    }
  }

  /// Update online status when user becomes active
  Future<void> setUserOnline(bool isOnline) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserId = prefs.getString('loggedInPhone');

      if (currentUserId == null) return;

      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      debugPrint('User online status updated to: $isOnline');
    } catch (e) {
      debugPrint('Error updating online status: $e');
    }
  }

  /// Update message status to "seen" for specific messages
  Future<void> updateMessageStatusToSeen(String chatId, List<String> messageIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserId = prefs.getString('loggedInPhone');

      if (currentUserId == null) return;

      final batch = FirebaseFirestore.instance.batch();

      for (final messageId in messageIds) {
        final messageRef = FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId);

        batch.update(messageRef, {
          'status': 'seen',
          'seenAt': FieldValue.serverTimestamp(),
          'seenBy': FieldValue.arrayUnion([currentUserId]),
        });
      }

      await batch.commit();
      debugPrint('Message status updated to seen for $messageIds');
    } catch (e) {
      debugPrint('Error updating message status: $e');
    }
  }

  /// Get unread message IDs for a specific chat
  Future<List<String>> getUnreadMessageIds(String chatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? currentUserId = prefs.getString('loggedInPhone');

      if (currentUserId == null) return [];

      final querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('status', isEqualTo: 'delivered')
          .where('senderId', isNotEqualTo: currentUserId)
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error getting unread message IDs: $e');
      return [];
    }
  }

  /// Comprehensive chat click handler with message status updates
  Future<void> handleChatClick({required String chatId, required String contactPhoneNumber}) async {
    try {
      // 1. Get all unread message IDs
      final unreadMessageIds = await getUnreadMessageIds(chatId);

      // 2. Update message status to "seen"
      if (unreadMessageIds.isNotEmpty) {
        await updateMessageStatusToSeen(chatId, unreadMessageIds);
      }

      // 3. Mark messages as seen in chat document
      await markMessagesAsSeen(chatId, contactPhoneNumber);

      // 4. Update user's online status and last seen
      await setUserOnline(true);

      // 5. Refresh the contacts list
      await refreshMessagedContacts();

      debugPrint('Chat fully processed for: $contactPhoneNumber');
    } catch (e) {
      debugPrint('Error in comprehensive chat click handling: $e');
    }
  }
}
