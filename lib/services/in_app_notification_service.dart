import 'package:flutter/material.dart';
import 'firestore_service.dart';

class InAppNotificationService extends ChangeNotifier {
  final Map<String, int> _unreadCounts = {};
  final FirestoreService _firestoreService = FirestoreService();
  String? _currentUserId;

  int getUnreadCount(String chatId) => _unreadCounts[chatId] ?? 0;

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  /// Refreshes unread count for a specific chat from Firestore
  Future<void> refreshUnreadCount(String chatId) async {
    if (_currentUserId == null) return;

    try {
      final count = await _firestoreService.getUnreadMessageCount(
        chatId: chatId,
        userId: _currentUserId!,
      );
      _unreadCounts[chatId] = count;
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing unread count: $e');
    }
  }

  /// Refreshes unread counts for all chats
  Future<void> refreshAllUnreadCounts(List<String> chatIds) async {
    if (_currentUserId == null) return;

    for (final chatId in chatIds) {
      await refreshUnreadCount(chatId);
    }
  }

  /// Marks a chat as read and clears unread count
  Future<void> markChatAsRead(String chatId) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.markChatAsRead(
        chatId: chatId,
        userId: _currentUserId!,
      );
      _unreadCounts[chatId] = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking chat as read: $e');
    }
  }

  void clearUnread(String chatId) {
    markChatAsRead(chatId);
  }

  void clearAllUnread() {
    _unreadCounts.clear();
    notifyListeners();
  }

  int get totalUnread => _unreadCounts.values.fold(0, (a, b) => a + b);
}
