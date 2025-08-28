import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_clone/utils/my_colors.dart';

class ChatBubble extends StatelessWidget with MyColors {
  final String message;
  final bool isSender;

  const ChatBubble({super.key, required this.message, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: CustomPaint(
        painter: BubblePainter(
          isSender: isSender,
          color: isSender ? MyColors.chatSenderContainerColor : MyColors.chatReciverContainerColor,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: EdgeInsets.only(
            left: isSender ? 50 : 8,
            right: isSender ? 8 : 50,
            top: 4,
            bottom: 4,
          ),
          child: Text(
            message,
            style: GoogleFonts.roboto(color: MyColors.foregroundColor),
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final bool isSender;
  final Color color;

  BubblePainter({required this.isSender, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final r = 12.0; // corner radius
    final path = Path();

    if (isSender) {
      // Bubble on the right
      path.moveTo(r, 0);
      path.lineTo(size.width - r, 0);
      path.quadraticBezierTo(size.width, 0, size.width, r);
      path.lineTo(size.width, size.height - r - 10);
      path.quadraticBezierTo(size.width, size.height - 10, size.width - r, size.height - 10);

      // Tail (right side)
      path.lineTo(size.width - 6, size.height - 10);
      path.lineTo(size.width + 6, size.height);
      path.lineTo(size.width - 14, size.height);

      path.quadraticBezierTo(size.width - r - 14, size.height, size.width - r - 14, size.height);

      path.lineTo(r, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - r);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
    } else {
      // Bubble on the left
      path.moveTo(r, 0);
      path.lineTo(size.width - r, 0);
      path.quadraticBezierTo(size.width, 0, size.width, r);
      path.lineTo(size.width, size.height - r);
      path.quadraticBezierTo(size.width, size.height, size.width - r, size.height);

      path.lineTo(14, size.height);
      path.lineTo(-6, size.height);
      path.lineTo(6, size.height - 10);

      path.quadraticBezierTo(r, size.height - 10, r, size.height - 10);
      path.lineTo(r, 0);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
