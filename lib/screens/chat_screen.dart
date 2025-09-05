import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/qr_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

/// Chat screen displaying messages and input field
class ChatScreen extends StatelessWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  Future<String?> _getChatTitle() async {
    final doc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .get();
    return doc.data()?['title'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<String?>(
      stream: authService.userUidStream,
      builder: (context, userSnapshot) {
        final currentUserUid = userSnapshot.data ?? '';
        return FutureBuilder<String?>(
          future: _getChatTitle(),
          builder: (context, snapshot) {
            final chatTitle = snapshot.data ?? 'Chat';
            return Scaffold(
              appBar: AppBar(
                title: Text(chatTitle),
                centerTitle: true,
                backgroundColor: const Color(0xFF232D36),
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: Colors.white70),
                    tooltip: 'Show QR Code',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF232D36),
                          title: const Text(
                            'Chat QR Code',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: SizedBox(
                            width: 220,
                            height: 220,
                            child: QrService().generateQrCode(
                              chatId,
                              size: 200,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Close',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(24),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Chat ID: $chatId',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),
              ),
              body: Container(
                color: const Color(0xFF222D36),
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: firestoreService.streamMessages(chatId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error loading messages'),
                            );
                          }
                          final messages = snapshot.data?.docs ?? [];
                          if (messages.isEmpty) {
                            return const Center(
                              child: Text('No messages yet.'),
                            );
                          }
                          return ListView.builder(
                            reverse: false,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index].data();
                              final senderId = msg['senderId'] ?? '';
                              final senderName = msg['senderName'] ?? 'Unknown';
                              final text = msg['text'] ?? '';
                              final isCurrentUser = senderId == currentUserUid;
                              return MessageBubble(
                                text: text,
                                senderName: senderName,
                                isCurrentUser: isCurrentUser,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MessageInput(
                        onSend: (text) async {
                          if (text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Message cannot be empty.'),
                              ),
                            );
                            return;
                          }
                          final senderId = currentUserUid;
                          final senderName =
                              Provider.of<AuthService>(
                                context,
                                listen: false,
                              ).currentUserName ??
                              'Unknown';
                          final success = await firestoreService.sendMessage(
                            chatId: chatId,
                            senderId: senderId,
                            senderName: senderName,
                            text: text,
                          );
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to send message.'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
