import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

/// Service to handle Firebase Authentication
class AuthService {
  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs in the user anonymously using Firebase Auth.
  Future<UserCredential?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential;
    } catch (e) {
      debugPrint('Error during anonymous sign-in: $e');
      return null;
    }
  }

  /// Registers a user with email and password, sets display name, and sends verification email.
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.sendEmailVerification();
      return userCredential;
    } catch (e) {
      debugPrint('Error during registration: $e');
      return null;
    }
  }

  /// Logs in a user with email and password.
  Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      debugPrint('Error during login: $e');
      return null;
    }
  }

  /// Sends email verification to the current user.
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint('Error sending email verification: $e');
    }
  }

  /// Checks if the current user's email is verified.
  bool get isEmailVerified {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Gets the current user's display name.
  String? get currentUserName {
    final user = _auth.currentUser;
    return user?.displayName;
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
