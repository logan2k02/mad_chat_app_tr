/// Widget to display a chat message bubble with sender identification
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final String senderName;
  final bool isCurrentUser;

  const MessageBubble({
    Key? key,
    required this.text,
    required this.senderName,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Alignment alignment = isCurrentUser
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final Color color = isCurrentUser
        ? const Color(0xFF2AABEE) // Telegram blue
        : const Color(0xFF343A40); // Lighter dark for receiver bubble
    final BorderRadius borderRadius = isCurrentUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(6),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              isCurrentUser ? 'You' : senderName,
              style: TextStyle(
                fontSize: 12,
                color: isCurrentUser ? Colors.white70 : Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isCurrentUser ? Colors.white : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
