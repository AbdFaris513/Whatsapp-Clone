class ContactData {
  final String id; // unique contact id
  final String contactFirstName;
  final String? contactSecondName;
  final String? contactBusinessName;
  final String contactNumber;
  final String? contactStatus; // "Busy", "Available", etc.
  final String? contactImage;
  final DateTime? contactLastSeen;
  final DateTime? contactLastMsgTime;
  final String? contactLastMsg;
  final String? contactLastMsgType; // text, image, video, audio
  final int unreadMessages;
  final bool isContactPinned;
  final bool isContactMuted;
  final bool isContactBlocked;
  final bool isContactArchived;
  final bool isOnline; // live presence
  final String? about; // "Hey there! I am using WhatsApp"
  final String? lastMessageId; // for message referencing
  final DateTime? lastInteraction; // for sorting chats
  final List<String>? labels; // WhatsApp Business tags

  ContactData({
    required this.id,
    required this.contactFirstName,
    this.contactSecondName,
    this.contactBusinessName,
    required this.contactNumber,
    this.contactStatus,
    this.contactImage,
    this.contactLastSeen,
    this.contactLastMsgTime,
    this.contactLastMsg,
    this.contactLastMsgType,
    this.unreadMessages = 0,
    this.isContactPinned = false,
    this.isContactMuted = false,
    this.isContactBlocked = false,
    this.isContactArchived = false,
    this.isOnline = false,
    this.about,
    this.lastMessageId,
    this.lastInteraction,
    this.labels,
  });
}

enum MessageType {
  text,
  image,
  video,
  audio,
  document,
  contact,
  location,
  gif,
  sticker,
  voiceNote,
  callLog, // missed/incoming call logs
}

enum MessageStatus { sending, sent, delivered, seen, failed }
