import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

/// Service to handle Firebase Authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs in the user anonymously using Firebase Auth.
  /// Returns the [UserCredential] if successful, otherwise throws an error.
  Future<UserCredential?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential;
    } catch (e) {
      // Log or handle error as needed
      debugPrint('Error during anonymous sign-in: $e');
      return null;
    }
  }

  /// Returns the current user's UID, or null if not signed in.
  String? get currentUserUid {
    final user = _auth.currentUser;
    return user?.uid;
  }

  /// Stream of current user changes (UID)
  Stream<String?> get userUidStream =>
      _auth.authStateChanges().map((user) => user?.uid);
}
