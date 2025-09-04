import 'package:flutter/material.dart';

/// Widget to display a chat message bubble with sender identification
class MessageBubble extends StatelessWidget {
  final String text;
  final String senderId;
  final bool isCurrentUser;

  const MessageBubble({
    Key? key,
    required this.text,
    required this.senderId,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alignment = isCurrentUser
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final color = isCurrentUser ? Colors.blue[200] : Colors.grey[300];
    final borderRadius = isCurrentUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          )
        : const BorderRadius.only(
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
          children: [
            Text(
              isCurrentUser ? 'You' : senderId,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
