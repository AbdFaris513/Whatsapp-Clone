import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/model/message_model.dart';

class ChatScreenController extends GetxController {
  RxList<MessageModel> messages = <MessageModel>[].obs;

  /// expose messages as stream for StreamBuilder
  Stream<List<MessageModel>> get chatStream => messages.stream;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// load messages from Firestore in real-time
  void listenToMessages(String chatId) {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sendTime', descending: false)
        .snapshots()
        .listen((snapshot) {
          final msgList = snapshot.docs.map((doc) {
            final data = doc.data();
            return MessageModel(
              id: doc.id,
              msg: data['msg'] ?? '',
              msgSender: data['msgSender'] ?? '',
              msgReceiver: data['msgReceiver'] ?? '',
              type: MessageType.text, // you can map enum properly if stored
              status: MessageStatus.delivered, // map from data if stored
              sendTime: (data['sendTime'] as Timestamp).toDate(),
              receiveTime: (data['receiveTime'] as Timestamp?)?.toDate(),
              viewTime: (data['viewTime'] as Timestamp?)?.toDate(),
            );
          }).toList();

          messages.assignAll(msgList);
        });
  }

  /// send a message to Firestore
  Future<void> sendMessage({required String chatId, required MessageModel msg}) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'msg': msg.msg,
      'msgSender': msg.msgSender,
      'msgReceiver': msg.msgReceiver,
      'sendTime': msg.sendTime,
      'receiveTime': msg.receiveTime,
      'viewTime': msg.viewTime,
      'type': msg.type.toString(),
      'status': msg.status.toString(),
    });
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
