import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Service to handle Firestore chat operations
class FirestoreService {
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
    required String text,
  }) async {
    try {
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();
      await messageRef.set({
        'senderId': senderId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
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
}
