import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firestore_service.dart';

/// Screen displaying chat information and details
class ChatInfoScreen extends StatelessWidget {
  final String chatId;
  final String chatName;

  const ChatInfoScreen({
    super.key,
    required this.chatId,
    required this.chatName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Info'),
        backgroundColor: const Color(0xFF263A4D),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF222D36),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFF232D36),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chat, color: Colors.white70, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Chat Name',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      chatName,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFF232D36),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white70,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Chat Details',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text(
                            'Chat not found',
                            style: TextStyle(color: Colors.white54),
                          );
                        }

                        final chatData =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        final createdAt = chatData?['createdAt'] as Timestamp?;
                        final createdDate = createdAt?.toDate();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (createdDate != null) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Created: ${_formatDate(createdDate)}',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('chats')
                                  .doc(chatId)
                                  .collection('messages')
                                  .snapshots(),
                              builder: (context, messageSnapshot) {
                                final messageCount =
                                    messageSnapshot.data?.docs.length ?? 0;
                                return Row(
                                  children: [
                                    const Icon(
                                      Icons.message,
                                      color: Colors.white54,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Messages: $messageCount',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteConfirmation(context),
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  'Delete Chat',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF232D36),
        title: const Text('Delete Chat', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this chat? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await _deleteChat(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red.shade300)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChat(BuildContext context) async {
    try {
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      await firestoreService.deleteChat(chatId);

      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
