import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/in_app_notification_service.dart';
import '../widgets/app_logo.dart';

/// Home screen with options to start or join a chat
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotificationService();
    });
  }

  void _initializeNotificationService() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final notificationService = Provider.of<InAppNotificationService>(
      context,
      listen: false,
    );

    final currentUserId = authService.currentUserUid;
    if (currentUserId != null) {
      notificationService.setCurrentUserId(currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );
    final authService = Provider.of<AuthService>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you really want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1B232A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              AppLogoPremium(size: 32),
              const SizedBox(width: 10),
              const Text(
                'Quick Chat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(width: 10),
              Consumer<InAppNotificationService>(
                builder: (context, notif, _) {
                  final unread = notif.totalUnread;
                  if (unread == 0) return SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: const Text('Do you really want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (shouldLogout == true) {
                  await authService.signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF232D36), Color(0xFF1B232A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('👋', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Hello, ',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  authService.currentUserName ?? 'User',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2AABEE),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Ready to chat instantly?',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.qr_code,
                            color: Color(0xFF2AABEE),
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start or join a chat with a QR code.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Fast, secure, and private.',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              top: 170,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      32,
                      24,
                      32,
                    ), // Extra top and bottom padding
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/qr_generator');
                            },
                            icon: const Icon(Icons.qr_code),
                            label: const Text('Start Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0099FF),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 22),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/qr_scanner');
                            },
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF2AABEE),
                            ),
                            label: const Text(
                              'Join Chat',
                              style: TextStyle(color: Color(0xFF2AABEE)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide.none,
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF2AABEE),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              top: 16,
                              bottom: 8,
                              right: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Recent Chats',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      _showClearAllChatsDialog(context),
                                  icon: const Icon(
                                    Icons.clear_all,
                                    size: 16,
                                    color: Colors.redAccent,
                                  ),
                                  label: const Text(
                                    'Clear All',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: firestoreService.streamAllChats(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return const Center(
                                    child: Text('Error loading chats'),
                                  );
                                }
                                final chats = snapshot.data?.docs ?? [];

                                // Refresh unread counts when chats are loaded
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  final notificationService =
                                      Provider.of<InAppNotificationService>(
                                        context,
                                        listen: false,
                                      );
                                  final chatIds = chats
                                      .map((chat) => chat.id)
                                      .toList();
                                  notificationService.refreshAllUnreadCounts(
                                    chatIds,
                                  );
                                });
                                if (chats.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'No recent chats found.',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  padding: const EdgeInsets.only(
                                    bottom: 8,
                                    left: 8,
                                    right: 8,
                                  ),
                                  itemCount: chats.length,
                                  separatorBuilder: (context, idx) =>
                                      const SizedBox(height: 6),
                                  itemBuilder: (context, index) {
                                    final chatId = chats[index].id;
                                    final chatData = chats[index].data();
                                    final title = chatData['title'] ?? 'Chat';
                                    final lastMessage = chatData['lastMessage'];
                                    final lastMessageSender =
                                        chatData['lastMessageSender'];

                                    return Consumer<InAppNotificationService>(
                                      builder: (context, notificationService, child) {
                                        final unread = notificationService
                                            .getUnreadCount(chatId);

                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF232D36),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                            leading: Stack(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF2AABEE,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          25,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.chat,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                                if (unread > 0)
                                                  Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.redAccent,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        unread.toString(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            title: Text(
                                              title,
                                              style: TextStyle(
                                                fontWeight: unread > 0
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            subtitle: lastMessage != null
                                                ? Text(
                                                    lastMessageSender != null
                                                        ? '$lastMessageSender: $lastMessage'
                                                        : lastMessage,
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                      fontWeight: unread > 0
                                                          ? FontWeight.w500
                                                          : FontWeight.normal,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : const Text(
                                                    'No messages yet',
                                                    style: TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.redAccent,
                                                  ),
                                                  onPressed: () async {
                                                    final shouldDelete = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        backgroundColor:
                                                            const Color(
                                                              0xFF232D36,
                                                            ),
                                                        title: const Text(
                                                          'Delete Chat',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        content: const Text(
                                                          'Are you sure you want to delete this chat?',
                                                          style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  context,
                                                                ).pop(false),
                                                            child: const Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white70,
                                                              ),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  context,
                                                                ).pop(true),
                                                            child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .redAccent,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (shouldDelete == true) {
                                                      await firestoreService
                                                          .deleteChat(chatId);
                                                      if (mounted) {
                                                        Provider.of<
                                                              InAppNotificationService
                                                            >(
                                                              context,
                                                              listen: false,
                                                            )
                                                            .clearUnread(
                                                              chatId,
                                                            );
                                                      }
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                '/chat',
                                                arguments: chatId,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows confirmation dialog for clearing all chats
  void _showClearAllChatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF232D36),
        title: const Text(
          '⚠️ Clear All Chats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete ALL chats? This action cannot be undone and will permanently remove all your chat history.',
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
              Navigator.of(context).pop(); // Close dialog first
              await _clearAllChats(context);
            },
            child: const Text(
              'Delete All',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Clears all chats from Firestore and resets unread counts
  Future<void> _clearAllChats(BuildContext context) async {
    try {
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      final notificationService = Provider.of<InAppNotificationService>(
        context,
        listen: false,
      );

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          backgroundColor: Color(0xFF232D36),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text(
                'Deleting all chats...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      await firestoreService.deleteAllChats();
      notificationService.clearAllUnread();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All chats cleared successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear chats: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
