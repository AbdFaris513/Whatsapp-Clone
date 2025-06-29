import 'package:flutter/material.dart';
import 'package:whatsapp_clone/utils/my_colors.dart';

class ContactPopup extends StatelessWidget with MyColors {
  ContactPopup({super.key});

  bool? thisPersonNotHaveAcount = false;

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
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
    );

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
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration.copyWith(
                        labelText: 'First name',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: Colors.transparent,
              ), // Hide
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration.copyWith(
                        labelText: 'Last name',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.add_business, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration.copyWith(
                    labelText: 'Business name',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.grey),
                        decoration: inputDecoration.copyWith(
                          labelText: 'Phone',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          thisPersonNotHaveAcount != null
              ? Row(
                  children: [
                    Icon(
                      thisPersonNotHaveAcount == true
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      color: thisPersonNotHaveAcount == true
                          ? Colors.green
                          : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      thisPersonNotHaveAcount == true
                          ? 'This person is on WhatsApp'
                          : 'This person does not have WhatsApp',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
              : SizedBox.shrink(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
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
