import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/in_app_notification_service.dart';
import '../services/qr_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import 'chat_info_screen.dart';

/// Chat screen displaying messages and input field
class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    // Mark chat as read when user enters the chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markChatAsRead();
    });
  }

  void _markChatAsRead() {
    final notificationService = Provider.of<InAppNotificationService>(
      context,
      listen: false,
    );
    notificationService.markChatAsRead(widget.chatId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<String?> _getChatTitle() async {
    final doc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();
    return doc.data()?['title'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return StreamBuilder<String?>(
      stream: Provider.of<AuthService>(context, listen: false).userUidStream,
      builder: (context, userSnapshot) {
        final currentUserUid = userSnapshot.data ?? '';
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: firestoreService.streamMessages(widget.chatId),
          builder: (context, snapshot) {
            // Auto-scroll logic with message count tracking
            if (snapshot.hasData) {
              final messages = snapshot.data?.docs ?? [];
              if (messages.length > _previousMessageCount) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
                _previousMessageCount = messages.length;
              }
            }

            return FutureBuilder<String?>(
              future: _getChatTitle(),
              builder: (context, titleSnapshot) {
                final chatTitle = titleSnapshot.data ?? 'Chat';
                return Scaffold(
                  appBar: AppBar(
                    title: Text(chatTitle),
                    centerTitle: true,
                    backgroundColor: const Color(0xFF263A4D),
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
                                  widget.chatId,
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
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'info') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatInfoScreen(
                                  chatId: widget.chatId,
                                  chatName: chatTitle,
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'info',
                            child: ListTile(
                              leading: Icon(Icons.info),
                              title: Text('Chat Info'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  body: Container(
                    color: const Color(0xFF222D36),
                    child: Column(
                      children: [
                        Expanded(
                          child:
                              StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>
                              >(
                                stream: firestoreService.streamMessages(
                                  widget.chatId,
                                ),
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
                                    controller: _scrollController,
                                    reverse:
                                        true, // Show newest messages at bottom
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      final reversedIndex =
                                          messages.length - 1 - index;
                                      final msg = messages[reversedIndex]
                                          .data();
                                      final senderId = msg['senderId'] ?? '';
                                      final senderName =
                                          msg['senderName'] ?? 'Unknown';
                                      final text = msg['text'] ?? '';
                                      final isCurrentUser =
                                          senderId == currentUserUid;
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

                              final success = await firestoreService
                                  .sendMessage(
                                    chatId: widget.chatId,
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
      },
    );
  }
}
