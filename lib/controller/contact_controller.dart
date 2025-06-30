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
}
