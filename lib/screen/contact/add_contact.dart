import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/controller/contact_controller.dart';
import 'package:whatsapp_clone/model/contact_model.dart';
import 'package:whatsapp_clone/utils/my_colors.dart';

class ContactPopup extends StatefulWidget {
  const ContactPopup({super.key});

  @override
  State<ContactPopup> createState() => _ContactPopupState();
}

class _ContactPopupState extends State<ContactPopup> with MyColors {
  final ContactController contactController = Get.find<ContactController>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secoundNameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool? thisPersonNotHaveAcount = false;
  String? firstNameError;
  String? phoneNumberError;

  final InputDecoration baseDecoration = InputDecoration(
    labelStyle: const TextStyle(color: Colors.grey),
    hintStyle: const TextStyle(color: Colors.grey),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: MyColors.massageNotificationColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );

  Future<void> addSingleContact({
    required String userId,
    required String phoneNumber,
    required String contactName,
  }) async {
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);

    await userDocRef.update({
      'contactList': FieldValue.arrayUnion([
        {'phoneNumber': phoneNumber, 'contactName': contactName},
      ]),
    });

    print('Contact added successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'New contact',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // First Name
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: _firstNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: baseDecoration.copyWith(
                        labelText: 'First name',
                        errorText: firstNameError,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Last Name
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.transparent),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _secoundNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: baseDecoration.copyWith(labelText: 'Last name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Business Name
          Row(
            children: [
              const Icon(Icons.add_business, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _businessNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: baseDecoration.copyWith(
                    labelText: 'Business name',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Phone Number
          Row(
            children: [
              const Icon(Icons.call_outlined, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.black,
                          style: const TextStyle(color: Colors.white),
                          value: '+91',
                          items: const [
                            DropdownMenuItem(
                              value: '+91',
                              child: Text('IN +91'),
                            ),
                            DropdownMenuItem(value: '+1', child: Text('US +1')),
                            DropdownMenuItem(
                              value: '+44',
                              child: Text('UK +44'),
                            ),
                          ],
                          onChanged: (val) {},
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: baseDecoration.copyWith(
                          labelText: 'Phone',
                          errorText: phoneNumberError,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (thisPersonNotHaveAcount != null)
            Row(
              children: [
                Icon(
                  thisPersonNotHaveAcount == true
                      ? Icons.cloud_done
                      : Icons.cloud_off,
                  color: thisPersonNotHaveAcount == true
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  thisPersonNotHaveAcount == true
                      ? 'This person is on WhatsApp'
                      : 'This person does not have WhatsApp',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  firstNameError = _firstNameController.text.isEmpty
                      ? 'First name is required'
                      : null;
                  phoneNumberError = _phoneNumberController.text.isEmpty
                      ? 'Phone number is required'
                      : null;
                });

                if (firstNameError != null || phoneNumberError != null) return;
                final prefs = await SharedPreferences.getInstance();
                String userId = '';
                if (prefs.containsKey('loggedInPhone')) {
                  userId = prefs.getString('loggedInPhone') ?? '';
                  print('Logged in phone: $userId');
                }
                await addSingleContact(
                  userId: userId,
                  phoneNumber: _phoneNumberController.text,
                  contactName: _firstNameController.text,
                );
                contactController.addContact(
                  ContactData(
                    contactFirstName: _firstNameController.text.trim(),
                    contactSecondName: _secoundNameController.text.trim(),
                    contactBusinessName: _businessNameController.text.trim(),
                    contactNumber: _phoneNumberController.text.trim(),
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
