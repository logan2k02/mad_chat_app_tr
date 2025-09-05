import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Service to handle Firestore chat operations
class FirestoreService {
  /// Deletes a chat and all its messages (shallow delete)
  Future<void> deleteChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).delete();
  }

  /// Deletes all chats in the collection
  Future<void> deleteAllChats() async {
    try {
      final chatsQuery = await _firestore.collection('chats').get();
      final batch = _firestore.batch();

      for (var doc in chatsQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting all chats: $e');
      rethrow;
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  /// Generates a new chatId locally
  String generateChatId() {
    return _uuid.v4();
  }

  /// Saves a chat session to Firestore
  Future<bool> saveChatSession({
    required String chatId,
    required String title,
  }) async {
    try {
      await _firestore.collection('chats').doc(chatId).set({
        'createdAt': FieldValue.serverTimestamp(),
        'title': title,
      });
      return true;
    } catch (e) {
      debugPrint('Error saving chat session: $e');
      return false;
    }
  }

  /// Sends a message to chats/{chatId}/messages
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      final batch = _firestore.batch();

      // Add message to messages subcollection
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();
      batch.set(messageRef, {
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update chat document with last message info and increment message count
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {
        'lastMessage': text,
        'lastMessageSender': senderName,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  /// Streams messages from chats/{chatId}/messages ordered by timestamp
  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages(String chatId) {
    try {
      return _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
    } catch (e) {
      debugPrint('Error streaming messages: $e');
      // Return an empty stream on error
      return const Stream.empty();
    }
  }

  /// Marks a chat as read for a specific user
  Future<bool> markChatAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('readStatus')
          .doc(userId)
          .set({
            'lastReadTimestamp': FieldValue.serverTimestamp(),
            'userId': userId,
          });
      return true;
    } catch (e) {
      debugPrint('Error marking chat as read: $e');
      return false;
    }
  }

  /// Gets unread message count for a user in a specific chat
  Future<int> getUnreadMessageCount({
    required String chatId,
    required String userId,
  }) async {
    try {
      // Get user's last read timestamp
      final readStatusDoc = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('readStatus')
          .doc(userId)
          .get();

      DateTime? lastReadTime;
      if (readStatusDoc.exists &&
          readStatusDoc.data()?['lastReadTimestamp'] != null) {
        final timestamp =
            readStatusDoc.data()!['lastReadTimestamp'] as Timestamp;
        lastReadTime = timestamp.toDate();
      }

      // Count messages after last read time
      Query<Map<String, dynamic>> messagesQuery = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages');

      if (lastReadTime != null) {
        messagesQuery = messagesQuery.where(
          'timestamp',
          isGreaterThan: Timestamp.fromDate(lastReadTime),
        );
      }

      // Exclude messages sent by the user themselves
      messagesQuery = messagesQuery.where('senderId', isNotEqualTo: userId);

      final unreadMessages = await messagesQuery.get();
      return unreadMessages.docs.length;
    } catch (e) {
      debugPrint('Error getting unread message count: $e');
      return 0;
    }
  }

  /// Streams all chats with their last message info
  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllChats() {
    try {
      return _firestore
          .collection('chats')
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots();
    } catch (e) {
      debugPrint('Error streaming all chats: $e');
      return const Stream.empty();
    }
  }
}
