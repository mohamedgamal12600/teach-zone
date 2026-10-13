// auth_service.dart
// Centralized Firebase Auth operations with resilient Firestore profile sync.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service encapsulating all Firebase Auth and user-profile Firestore calls.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The currently signed-in Firebase user, or `null` if not signed in.
  User? get currentUser => _auth.currentUser;

  /// Stream that emits the current user whenever the auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// `true` when a user is currently signed in.
  bool get isSignedIn => _auth.currentUser != null;

  /// Signs in with [email] and [password] with a timeout so UI never hangs indefinitely.
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .timeout(
          const Duration(seconds: 15),
          onTimeout:
              () =>
                  throw TimeoutException(
                    'Connection timed out. Check your internet connection.',
                  ),
        );
  }

  /// Creates a new account, sets display name, and persists the user profile.
  /// If Firestore is disabled or unreachable, account creation still succeeds
  /// without hanging the UI.
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    // 1. Create the user in Firebase Authentication with timeout
    final credential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .timeout(
          const Duration(seconds: 15),
          onTimeout:
              () =>
                  throw TimeoutException(
                    'Authentication service timed out. Check your internet connection.',
                  ),
        );

    final user = credential.user!;

    // 2. Set the display name directly on the Firebase Auth profile
    try {
      await user
          .updateDisplayName(fullName)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Non-fatal if display name update is delayed
    }

    // 3. Persist profile document in Firestore (with timeout and error tolerance)
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'fullName': fullName,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      // If Firestore is unavailable or rules reject it, allow the user to still log in
    }
  }

  /// Sends a password-reset e-mail to [email].
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .timeout(
          const Duration(seconds: 12),
          onTimeout:
              () =>
                  throw TimeoutException(
                    'Request timed out. Check your internet connection.',
                  ),
        );
  }

  /// Signs the current user out of Firebase Auth.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Updates the user's profile fields.
  Future<void> updateProfile({String? fullName}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (fullName != null) {
      await user.updateDisplayName(fullName);
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set({
              'fullName': fullName,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true))
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
    }

    await user.reload();
  }
}
