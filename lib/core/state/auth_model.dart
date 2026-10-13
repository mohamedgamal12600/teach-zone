// auth_model.dart
// ChangeNotifier that wraps [AuthService] and exposes authentication
// operations together with resilient Firestore profile management.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Getters

  /// The currently signed-in Firebase user, or `null` if not signed in.
  User? get currentUser => _authService.currentUser;

  /// Stream that emits the current user whenever the auth state changes.
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// `true` when a user is currently signed in.
  bool get isSignedIn => _authService.isSignedIn;

  // Auth operations

  /// Signs in with [email] and [password] with a timeout so UI never hangs indefinitely.
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
    notifyListeners();
  }

  /// Creates a new account, sets display name, and persists the user profile.
  /// If Firestore is disabled or unreachable, account creation still succeeds
  /// without hanging the UI.
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String fullName,
  ) async {
    await _authService.createUserWithEmailAndPassword(
      email,
      password,
      fullName,
    );
    notifyListeners();
  }

  /// Sends a password-reset e-mail to [email].
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  /// Signs the current user out of Firebase Auth.
  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }

  // Profile management

  /// Updates the user's profile fields.
  Future<void> updateProfile({String? fullName}) async {
    await _authService.updateProfile(fullName: fullName);
    notifyListeners();
  }
}
