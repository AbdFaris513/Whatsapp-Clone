import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_clone/model/message_model.dart';
import 'package:whatsapp_clone/utils/my_colors.dart';
import 'package:whatsapp_clone/widget/chat_style.dart';

class ChatsScreen extends StatelessWidget {
  String? userID;
  ChatsScreen({super.key, required this.userID});

  List<MessageModel> messages = [
    MessageModel(
      id: '1',
      msg: "Hey, how are you?",
      msgSender: "+911234567890",
      msgReceiver: "+911234567891",
      type: MessageType.text,
      status: MessageStatus.seen,
      sendTime: DateTime.now().subtract(const Duration(minutes: 30)),
      receiveTime: DateTime.now().subtract(const Duration(minutes: 29)),
      viewTime: DateTime.now().subtract(const Duration(minutes: 28)),
    ),
    MessageModel(
      id: '2',
      msg: "I'm good! Just working on Flutter 😊",
      msgSender: "+911234567891",
      msgReceiver: "+911234567890",
      type: MessageType.text,
      status: MessageStatus.delivered,
      sendTime: DateTime.now().subtract(const Duration(minutes: 29)),
      receiveTime: DateTime.now().subtract(const Duration(minutes: 28)),
    ),
    MessageModel(
      id: '3',
      msg: "Nicee 🔥, learning new widgets?",
      msgSender: "+911234567890",
      msgReceiver: "+911234567891",
      type: MessageType.text,
      status: MessageStatus.seen,
      sendTime: DateTime.now().subtract(const Duration(minutes: 27)),
      receiveTime: DateTime.now().subtract(const Duration(minutes: 26)),
      viewTime: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    MessageModel(
      id: '4',
      msg: "Yeah! Just implemented dark mode 🌙",
      msgSender: "+911234567891",
      msgReceiver: "+911234567890",
      type: MessageType.text,
      status: MessageStatus.seen,
      sendTime: DateTime.now().subtract(const Duration(minutes: 25)),
      receiveTime: DateTime.now().subtract(const Duration(minutes: 24)),
      viewTime: DateTime.now().subtract(const Duration(minutes: 23)),
    ),
    MessageModel(
      id: '5',
      msg: "Check out this photo!",
      msgSender: "+911234567890",
      msgReceiver: "+911234567891",
      type: MessageType.image,
      status: MessageStatus.sent,
      sendTime: DateTime.now().subtract(const Duration(minutes: 20)),
      mediaUrl: "https://picsum.photos/400/600",
      thumbnailUrl: "https://picsum.photos/80/120",
    ),
    MessageModel(
      id: '6',
      msg: "Wow, that's amazing 😍",
      msgSender: "+911234567891",
      msgReceiver: "+911234567890",
      type: MessageType.text,
      status: MessageStatus.seen,
      sendTime: DateTime.now().subtract(const Duration(minutes: 19)),
      isReplied: true,
      replyMsgId: "5",
    ),
    MessageModel(
      id: '7',
      msg: "Voice note",
      msgSender: "+911234567890",
      msgReceiver: "+911234567891",
      type: MessageType.audio,
      status: MessageStatus.sending,
      sendTime: DateTime.now().subtract(const Duration(minutes: 15)),
      mediaUrl: "https://example.com/audio.mp3",
      duration: const Duration(seconds: 15),
    ),
    MessageModel(
      id: '8',
      msg: "Couldn’t hear properly, send again?",
      msgSender: "+911234567891",
      msgReceiver: "+911234567890",
      type: MessageType.text,
      status: MessageStatus.delivered,
      sendTime: DateTime.now().subtract(const Duration(minutes: 14)),
    ),
    MessageModel(
      id: '9',
      msg: "Sure, here’s the updated one 🎙️",
      msgSender: "+911234567890",
      msgReceiver: "+911234567891",
      type: MessageType.audio,
      status: MessageStatus.delivered,
      sendTime: DateTime.now().subtract(const Duration(minutes: 13)),
      mediaUrl: "https://example.com/audio2.mp3",
      duration: const Duration(seconds: 22),
    ),
    MessageModel(
      id: '10',
      msg: "Perfect, now it’s clear 👌",
      msgSender: "+911234567891",
      msgReceiver: "+911234567890",
      type: MessageType.text,
      status: MessageStatus.seen,
      sendTime: DateTime.now().subtract(const Duration(minutes: 12)),
      receiveTime: DateTime.now().subtract(const Duration(minutes: 11)),
      viewTime: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    MessageModel(
      id: '11',
      msg: "By the way, meeting tomorrow at 10?",
      msgSender: "+911234567890",
      msgReceiver: "+911234567891",
      type: MessageType.text,
      status: MessageStatus.sent,
      sendTime: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    MessageModel(
      id: '12',
      msg: "Yes, don’t be late 😅",
      msgSender: "+911234567891",
      msgReceiver: "+911234567890",
      type: MessageType.text,
      status: MessageStatus.seen,
      sendTime: DateTime.now().subtract(const Duration(minutes: 5)),
      receiveTime: DateTime.now().subtract(const Duration(minutes: 4)),
      viewTime: DateTime.now().subtract(const Duration(minutes: 3)),
    ),

    MessageModel(
      id: '13',
      msg: "Bro, did you check the new Flutter 3.24 release? 🚀",
      msgSender: "+911234567890",
      msgReceiver: "+911234567891",
      type: MessageType.text,
      status: MessageStatus.delivered,
      sendTime: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    MessageModel(
      id: '14',
      msg: "They improved performance a lot 🔥",
      msgSender: "+911234567890",
      msgReceiver: "+911234567891",
      type: MessageType.text,
      status: MessageStatus.delivered,
      sendTime: DateTime.now().subtract(const Duration(minutes: 24)),
    ),
    MessageModel(
      id: '15',
      msg: "Oh really? I haven’t updated yet",
      msgSender: "+911234567891",
      msgReceiver: "+911234567890",
      type: MessageType.text,
      status: MessageStatus.seen,
      sendTime: DateTime.now().subtract(const Duration(minutes: 23)),
    ),
    MessageModel(
      id: '16',
      msg: "Update it bro, hot reload feels even faster 😎",
      msgSender: "+911234567890",
      msgReceiver: "+911234567891",
      type: MessageType.text,
      status: MessageStatus.seen,
      sendTime: DateTime.now().subtract(const Duration(minutes: 22)),
    ),
    MessageModel(
      id: '17',
      msg: "Okay, downloading now… 📥",
      msgSender: "+911234567891",
      msgReceiver: "+911234567890",
      type: MessageType.text,
      status: MessageStatus.sending,
      sendTime: DateTime.now().subtract(const Duration(minutes: 21)),
    ),
    MessageModel(
      id: '18',
      msg: "Meanwhile, check this doc I wrote 📄",
      msgSender: "+911234567890",
      msgReceiver: "+911234567891",
      type: MessageType.file,
      status: MessageStatus.sent,
      sendTime: DateTime.now().subtract(const Duration(minutes: 20)),
      mediaUrl: "https://example.com/doc.pdf",
    ),
    MessageModel(
      id: '19',
      msg: "Nice, thanks! I’ll read it.",
      msgSender: "+911234567891",
      msgReceiver: "+911234567890",
      type: MessageType.text,
      status: MessageStatus.delivered,
      sendTime: DateTime.now().subtract(const Duration(minutes: 19)),
    ),
    MessageModel(
      id: '20',
      msg: "Also, are you free tonight for a quick call?",
      msgSender: "+911234567891",
      msgReceiver: "+911234567890",
      type: MessageType.text,
      status: MessageStatus.delivered,
      sendTime: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
    MessageModel(
      id: '21',
      msg: "Yeah, after 9 PM works for me.",
      msgSender: "+911234567890",
      msgReceiver: "+911234567891",
      type: MessageType.text,
      status: MessageStatus.seen,
      sendTime: DateTime.now().subtract(const Duration(minutes: 17)),
    ),
    MessageModel(
      id: '22',
      msg: "Cool 👍 let’s do video then",
      msgSender: "+911234567891",
      msgReceiver: "+911234567890",
      type: MessageType.text,
      status: MessageStatus.seen,
      sendTime: DateTime.now().subtract(const Duration(minutes: 16)),
    ),
    MessageModel(
      id: '23',
      msg: "Perfect. I’ll send the link.",
      msgSender: "+911234567890",
      msgReceiver: "+911234567891",
      type: MessageType.text,
      status: MessageStatus.sent,
      sendTime: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    MessageModel(
      id: '24',
      msg: "Don’t forget your earphones this time 😅",
      msgSender: "+911234567891",
      msgReceiver: "+911234567890",
      type: MessageType.text,
      status: MessageStatus.seen,
      sendTime: DateTime.now().subtract(const Duration(minutes: 14)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: MyColors.cetagorySelectedContainerBackgroundColor,
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  ChatsScreenHeader(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ChatStyle(
                              messageDatas: messages[index],
                              isSender: messages[index].msgSender == userID, // just for demo
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ChatsScreenFooter(),
          ],
        ),
      ),
    );
  }
}

// Footer
class ChatsScreenFooter extends StatefulWidget with MyColors {
  const ChatsScreenFooter({super.key});

  @override
  State<ChatsScreenFooter> createState() => _ChatsScreenFooterState();
}

class _ChatsScreenFooterState extends State<ChatsScreenFooter> with MyColors {
  final TextEditingController _messageController = TextEditingController();

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      print("Send: $text");
      _messageController.clear();
    } else {
      print("Mic pressed");
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: MyColors.massageFieldBackGroundColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_emotions_outlined,
                  color: MyColors.massageFieldForeGroundColor,
                  size: 26,
                ),
                const SizedBox(width: 8),

                // ✅ Text field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: MyColors.massageFieldForeGroundColor,
                    ),
                    decoration: InputDecoration(
                      hintText: "Message",
                      hintStyle: GoogleFonts.roboto(
                        fontSize: 18,
                        color: MyColors.massageFieldForeGroundColor,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    textInputAction: TextInputAction.send, // ✅ enter = send
                    onSubmitted: (_) => _handleSendMessage(), // ✅ send on enter
                  ),
                ),

                Icon(
                  Icons.attach_file_sharp,
                  color: MyColors.massageFieldForeGroundColor,
                  size: 25,
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _messageController,
                  builder: (context, value, _) {
                    return value.text.isEmpty
                        ? Icon(
                            Icons.camera_alt_outlined,
                            color: MyColors.massageFieldForeGroundColor,
                            size: 25,
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),

        // ✅ Mic / Send button
        InkWell(
          onTap: _handleSendMessage,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MyColors.massageNotificationColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _messageController,
              builder: (context, value, _) {
                return Icon(
                  value.text.isEmpty ? Icons.mic : Icons.send_rounded,
                  color: MyColors.backgroundColor,
                  size: 21,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Header
class ChatsScreenHeader extends StatelessWidget with MyColors {
  const ChatsScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10, // <-- shadow depth
      shadowColor: MyColors.backgroundColor, // optional: customize shadow
      child: Container(
        color: MyColors.backgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(Icons.arrow_back_rounded, color: MyColors.foregroundColor, size: 26),
                ),
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(50),
                  child: Image.asset("assets/no_dp.jpeg", width: 37, height: 37),
                ),
                SizedBox(width: 8),
                Text(
                  'Abdullah',
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: MyColors.foregroundColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.videocam_outlined,
                    color: MyColors.foregroundColor,
                    size: 30,
                    weight: 0.5,
                  ),
                ),

                Icon(Icons.call_outlined, color: MyColors.foregroundColor, size: 25),
                Icon(Icons.more_vert, color: MyColors.foregroundColor, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
