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
    final Color? color = isCurrentUser ? Colors.blue[200] : Colors.grey[300];
    final BorderRadius borderRadius = isCurrentUser
        ? BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color, borderRadius: borderRadius),
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              isCurrentUser ? 'You' : senderName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(text, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
