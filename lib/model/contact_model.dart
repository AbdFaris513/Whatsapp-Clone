class ContactData {
  final String contactFirstName;
  final String? contactSecondName;
  final String? contactBusinessName;
  final String contactNumber;
  final String? contactStatus;
  final String? contactImage;

  ContactData({
    required this.contactFirstName,
    this.contactSecondName,
    this.contactBusinessName,
    required this.contactNumber,
    this.contactStatus,
    this.contactImage,
  });
}
