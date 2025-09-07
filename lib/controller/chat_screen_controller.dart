import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/model/message_model.dart';

// Your MessageModel code here (unchanged)

class ChatScreenController extends GetxController {
  RxList<MessageModel> messages = <MessageModel>[].obs;
  StreamSubscription? _messagesSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxString _currentChatId = ''.obs;

  Stream<List<MessageModel>> get chatStream => messages.stream;
  String get currentChatId => _currentChatId.value;

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    super.onClose();
  }

  // Generate a consistent chat ID between two users
  String generateChatId(String user1, String user2) {
    final sortedIds = [user1, user2]..sort();
    return 'chat_${sortedIds[0]}_${sortedIds[1]}';
  }

  // Ensure chat document exists
  Future<void> _ensureChatExists(String chatId, String user1, String user2) async {
    final chatDoc = _firestore.collection('chats').doc(chatId);
    final docSnapshot = await chatDoc.get();

    if (!docSnapshot.exists) {
      await chatDoc.set({
        'participants': {user1: true, user2: true},
        'participantIds': [user1, user2],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': '',
        'unreadCounts': {user1: 0, user2: 0},
      });
    }
  }

  // Start listening to messages for a chat
  Future<void> listenToMessages(String user1, String user2) async {
    _messagesSubscription?.cancel();

    final chatId = generateChatId(user1, user2);
    _currentChatId.value = chatId;

    _messagesSubscription = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sendTime', descending: false)
        .snapshots()
        .listen(
          (snapshot) {
            final msgList = snapshot.docs.map((doc) {
              final data = doc.data();
              return MessageModel(
                id: doc.id,
                msg: data['msg'] ?? '',
                msgSender: data['msgSender'] ?? '',
                msgReceiver: data['msgReceiver'] ?? '',
                type: MessageType.values.firstWhere(
                  (e) => e.name == data['type'],
                  orElse: () => MessageType.text,
                ),
                status: MessageStatus.values.firstWhere(
                  (e) => e.name == data['status'],
                  orElse: () => MessageStatus.sent,
                ),
                sendTime: (data['sendTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
                receiveTime: (data['receiveTime'] as Timestamp?)?.toDate(),
                viewTime: (data['viewTime'] as Timestamp?)?.toDate(),

                isForward: data['isForward'] ?? false,
                originalSender: data['originalSender'],
                isReplied: data['isReplied'] ?? false,
                replyMsgId: data['replyMsgId'],
                isStarred: data['isStarred'] ?? false,
                isEdited: data['isEdited'] ?? false,
                mediaUrl: data['mediaUrl'],
                thumbnailUrl: data['thumbnailUrl'],
                duration: data['duration'] != null
                    ? Duration(milliseconds: data['duration'])
                    : null,
              );
            }).toList();

            messages.assignAll(msgList);
          },
          onError: (error) {
            debugPrint('Error listening to messages: $error');
          },
        );
  }

  // Send a message
  Future<void> sendMessage({required MessageModel msg}) async {
    try {
      final chatId = generateChatId(msg.msgSender, msg.msgReceiver);

      // Ensure chat exists first
      await _ensureChatExists(chatId, msg.msgSender, msg.msgReceiver);

      // Prepare message data for Firestore
      final messageData = {
        'msg': msg.msg,
        'msgSender': msg.msgSender,
        'msgReceiver': msg.msgReceiver,
        'type': msg.type.name,
        'status': MessageStatus.sent.name,
        'sendTime': FieldValue.serverTimestamp(),
        'receiveTime': null,
        'viewTime': null,
        'isForward': msg.isForward,
        'originalSender': msg.originalSender,
        'isReplied': msg.isReplied,
        'replyMsgId': msg.replyMsgId,
        'isStarred': msg.isStarred,
        'isEdited': msg.isEdited,
        'mediaUrl': msg.mediaUrl,
        'thumbnailUrl': msg.thumbnailUrl,
        'duration': msg.duration?.inMilliseconds,
      };

      // Use batch write for atomic operations
      final batch = _firestore.batch();

      // Add message to subcollection
      final messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();

      batch.set(messageRef, messageData);

      // Update chat document with last message info
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {
        'lastMessage': msg.msg,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': msg.msgSender,
        'lastMessageType': msg.type.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCounts.${msg.msgReceiver}': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  // Update message status
  Future<void> updateMessageStatus({
    required String messageId,
    required MessageStatus status,
    required String userId,
  }) async {
    try {
      final chatId = currentChatId;
      if (chatId.isEmpty) return;

      final updateData = {'status': status.name, 'updatedAt': FieldValue.serverTimestamp()};

      // Add timestamp based on status
      if (status == MessageStatus.delivered) {
        updateData['receiveTime'] = FieldValue.serverTimestamp();
      } else if (status == MessageStatus.seen) {
        updateData['viewTime'] = FieldValue.serverTimestamp();

        // Reset unread count for this user
        await _firestore.collection('chats').doc(chatId).update({'unreadCounts.$userId': 0});
      }

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update(updateData);
    } catch (e) {
      debugPrint('Error updating message status: $e');
    }
  }

  // Get all chats for a user
  Stream<QuerySnapshot> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}

// Example UI for the chat screen
class ChatScreen extends StatelessWidget {
  final String currentUserId;
  final String otherUserId;

  ChatScreen({super.key, required this.currentUserId, required this.otherUserId});

  final ChatScreenController controller = Get.put(ChatScreenController());
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Start listening to messages when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.listenToMessages(currentUserId, otherUserId);
    });

    return Scaffold(
      appBar: AppBar(title: Text('Chat with $otherUserId')),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMe = message.msgSender == currentUserId;

                  return ChatMessageBubble(message: message, isMe: isMe);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (messageController.text.trim().isNotEmpty) {
                      final message = MessageModel(
                        id: '', // Will be generated by Firestore
                        msg: messageController.text,
                        msgSender: currentUserId,
                        msgReceiver: otherUserId,
                        type: MessageType.text,
                        status: MessageStatus.sending,
                        sendTime: DateTime.now(),
                      );

                      await controller.sendMessage(msg: message);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Chat message bubble widget
class ChatMessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const ChatMessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isReplied && message.replyMsgId != null)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Replying to message',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            if (message.isForward)
              Text(
                'Forwarded from ${message.originalSender}',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            Text(message.msg),
            SizedBox(height: 4),
            Text(message.messageTime, style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
  // RxList<MessageModel> messages = [
  //   MessageModel(
  //     id: '1',
  //     msg: "Hey, how are you?",
  //     msgSender: "+911234567890",
  //     msgReceiver: "+911234567891",
  //     type: MessageType.text,
  //     status: MessageStatus.seen,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 30)),
  //     receiveTime: DateTime.now().subtract(const Duration(minutes: 29)),
  //     viewTime: DateTime.now().subtract(const Duration(minutes: 28)),
  //   ),
  //   MessageModel(
  //     id: '2',
  //     msg: "I'm good! Just working on Flutter 😊",
  //     msgSender: "+911234567891",
  //     msgReceiver: "+911234567890",
  //     type: MessageType.text,
  //     status: MessageStatus.delivered,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 29)),
  //     receiveTime: DateTime.now().subtract(const Duration(minutes: 28)),
  //   ),
  //   MessageModel(
  //     id: '3',
  //     msg: "Nicee 🔥, learning new widgets?",
  //     msgSender: "+911234567890",
  //     msgReceiver: "+911234567891",
  //     type: MessageType.text,
  //     status: MessageStatus.seen,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 27)),
  //     receiveTime: DateTime.now().subtract(const Duration(minutes: 26)),
  //     viewTime: DateTime.now().subtract(const Duration(minutes: 25)),
  //   ),
  //   MessageModel(
  //     id: '4',
  //     msg: "Yeah! Just implemented dark mode 🌙",
  //     msgSender: "+911234567891",
  //     msgReceiver: "+911234567890",
  //     type: MessageType.text,
  //     status: MessageStatus.seen,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 25)),
  //     receiveTime: DateTime.now().subtract(const Duration(minutes: 24)),
  //     viewTime: DateTime.now().subtract(const Duration(minutes: 23)),
  //   ),
  //   MessageModel(
  //     id: '5',
  //     msg: "Check out this photo!",
  //     msgSender: "+911234567890",
  //     msgReceiver: "+911234567891",
  //     type: MessageType.image,
  //     status: MessageStatus.sent,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 20)),
  //     mediaUrl: "https://picsum.photos/400/600",
  //     thumbnailUrl: "https://picsum.photos/80/120",
  //   ),
  //   MessageModel(
  //     id: '6',
  //     msg: "Wow, that's amazing 😍",
  //     msgSender: "+911234567891",
  //     msgReceiver: "+911234567890",
  //     type: MessageType.text,
  //     status: MessageStatus.seen,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 19)),
  //     isReplied: true,
  //     replyMsgId: "5",
  //   ),
  //   MessageModel(
  //     id: '7',
  //     msg: "Voice note",
  //     msgSender: "+911234567890",
  //     msgReceiver: "+911234567891",
  //     type: MessageType.audio,
  //     status: MessageStatus.sending,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 15)),
  //     mediaUrl: "https://example.com/audio.mp3",
  //     duration: const Duration(seconds: 15),
  //   ),
  //   MessageModel(
  //     id: '8',
  //     msg: "Couldn’t hear properly, send again?",
  //     msgSender: "+911234567891",
  //     msgReceiver: "+911234567890",
  //     type: MessageType.text,
  //     status: MessageStatus.delivered,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 14)),
  //   ),
  //   MessageModel(
  //     id: '9',
  //     msg: "Sure, here’s the updated one 🎙️",
  //     msgSender: "+911234567890",
  //     msgReceiver: "+911234567891",
  //     type: MessageType.audio,
  //     status: MessageStatus.delivered,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 13)),
  //     mediaUrl: "https://example.com/audio2.mp3",
  //     duration: const Duration(seconds: 22),
  //   ),
  //   MessageModel(
  //     id: '10',
  //     msg: "Perfect, now it’s clear 👌",
  //     msgSender: "+911234567891",
  //     msgReceiver: "+911234567890",
  //     type: MessageType.text,
  //     status: MessageStatus.seen,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 12)),
  //     receiveTime: DateTime.now().subtract(const Duration(minutes: 11)),
  //     viewTime: DateTime.now().subtract(const Duration(minutes: 10)),
  //   ),
  //   MessageModel(
  //     id: '11',
  //     msg: "By the way, meeting tomorrow at 10?",
  //     msgSender: "+911234567890",
  //     msgReceiver: "+911234567891",
  //     type: MessageType.text,
  //     status: MessageStatus.sent,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 8)),
  //   ),
  //   MessageModel(
  //     id: '12',
  //     msg: "Yes, don’t be late 😅",
  //     msgSender: "+911234567891",
  //     msgReceiver: "+911234567890",
  //     type: MessageType.text,
  //     status: MessageStatus.seen,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 5)),
  //     receiveTime: DateTime.now().subtract(const Duration(minutes: 4)),
  //     viewTime: DateTime.now().subtract(const Duration(minutes: 3)),
  //   ),

  //   MessageModel(
  //     id: '13',
  //     msg: "Bro, did you check the new Flutter 3.24 release? 🚀",
  //     msgSender: "+911234567890",
  //     msgReceiver: "+911234567891",
  //     type: MessageType.text,
  //     status: MessageStatus.delivered,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 25)),
  //   ),
  //   MessageModel(
  //     id: '14',
  //     msg: "They improved performance a lot 🔥",
  //     msgSender: "+911234567890",
  //     msgReceiver: "+911234567891",
  //     type: MessageType.text,
  //     status: MessageStatus.delivered,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 24)),
  //   ),
  //   MessageModel(
  //     id: '15',
  //     msg: "Oh really? I haven’t updated yet",
  //     msgSender: "+911234567891",
  //     msgReceiver: "+911234567890",
  //     type: MessageType.text,
  //     status: MessageStatus.seen,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 23)),
  //   ),
  //   MessageModel(
  //     id: '16',
  //     msg: "Update it bro, hot reload feels even faster 😎",
  //     msgSender: "+911234567890",
  //     msgReceiver: "+911234567891",
  //     type: MessageType.text,
  //     status: MessageStatus.seen,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 22)),
  //   ),
  //   MessageModel(
  //     id: '17',
  //     msg: "Okay, downloading now… 📥",
  //     msgSender: "+911234567891",
  //     msgReceiver: "+911234567890",
  //     type: MessageType.text,
  //     status: MessageStatus.sending,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 21)),
  //   ),
  //   MessageModel(
  //     id: '18',
  //     msg: "Meanwhile, check this doc I wrote 📄",
  //     msgSender: "+911234567890",
  //     msgReceiver: "+911234567891",
  //     type: MessageType.file,
  //     status: MessageStatus.sent,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 20)),
  //     mediaUrl: "https://example.com/doc.pdf",
  //   ),
  //   MessageModel(
  //     id: '19',
  //     msg: "Nice, thanks! I’ll read it.",
  //     msgSender: "+911234567891",
  //     msgReceiver: "+911234567890",
  //     type: MessageType.text,
  //     status: MessageStatus.delivered,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 19)),
  //   ),
  //   MessageModel(
  //     id: '20',
  //     msg: "Also, are you free tonight for a quick call?",
  //     msgSender: "+911234567891",
  //     msgReceiver: "+911234567890",
  //     type: MessageType.text,
  //     status: MessageStatus.delivered,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 18)),
  //   ),
  //   MessageModel(
  //     id: '21',
  //     msg: "Yeah, after 9 PM works for me.",
  //     msgSender: "+911234567890",
  //     msgReceiver: "+911234567891",
  //     type: MessageType.text,
  //     status: MessageStatus.seen,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 17)),
  //   ),
  //   MessageModel(
  //     id: '22',
  //     msg: "Cool 👍 let’s do video then",
  //     msgSender: "+911234567891",
  //     msgReceiver: "+911234567890",
  //     type: MessageType.text,
  //     status: MessageStatus.seen,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 16)),
  //   ),
  //   MessageModel(
  //     id: '23',
  //     msg: "Perfect. I’ll send the link.",
  //     msgSender: "+911234567890",
  //     msgReceiver: "+911234567891",
  //     type: MessageType.text,
  //     status: MessageStatus.sent,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 15)),
  //   ),
  //   MessageModel(
  //     id: '24',
  //     msg: "Don’t forget your earphones this time 😅",
  //     msgSender: "+911234567891",
  //     msgReceiver: "+911234567890",
  //     type: MessageType.text,
  //     status: MessageStatus.seen,
  //     sendTime: DateTime.now().subtract(const Duration(minutes: 14)),
  //   ),
  // ].obs;
