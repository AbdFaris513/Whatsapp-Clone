import 'package:flutter/material.dart';
import 'package:whatsapp_clone/widget/search.dart';

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChartMenuSearchBar(),
        SizedBox(height: 12),
        Container(child: Row(children: [
            
          ],
        )),
      ],
    );
  }
}
