import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rate_limiter.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Sign up ───────────────────────────────────────────────
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (!RateLimiter.allow('signup')) {
      final secs = RateLimiter.cooldownRemaining('signup');
      _showErrorSnackBar(context, 'Too many attempts. Try again in ${secs}s.');
      return null;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      RateLimiter.reset('signup');
      return cred;
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBarM(messenger, _getErrorMessage(e.code));
      return null;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      _showErrorSnackBarM(messenger, 'An unexpected error occurred');
      return null;
    }
  }

  // ── Google Sign-In ────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle({
    required BuildContext context,
    String role = 'user',
  }) async {
    if (!RateLimiter.allow('google_signin')) {
      final secs = RateLimiter.cooldownRemaining('google_signin');
      _showErrorSnackBar(context, 'Too many attempts. Try again in ${secs}s.');
      return null;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        final user = userCredential.user!;
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fullName': user.displayName ?? '',
          'email': user.email ?? '',
          'mobile': '',
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      RateLimiter.reset('google_signin');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBarM(messenger, _getErrorMessage(e.code));
      return null;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      _showErrorSnackBarM(messenger, 'Google Sign-In failed. Please try again.');
      return null;
    }
  }

  // ── Sign in ───────────────────────────────────────────────
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (!RateLimiter.allow('login')) {
      final secs = RateLimiter.cooldownRemaining('login');
      _showErrorSnackBar(context, 'Too many attempts. Try again in ${secs}s.');
      return null;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      RateLimiter.reset('login');
      return cred;
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBarM(messenger, _getErrorMessage(e.code));
      return null;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      _showErrorSnackBarM(messenger, 'An unexpected error occurred');
      return null;
    }
  }

  // ── Sign out ──────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // ── Password reset ────────────────────────────────────────
  Future<bool> sendPasswordResetEmail({
    required String email,
    required BuildContext context,
  }) async {
    if (!RateLimiter.allow('password_reset')) {
      final secs = RateLimiter.cooldownRemaining('password_reset');
      _showErrorSnackBar(context, 'Too many requests. Try again in ${secs}s.');
      return false;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _showSuccessSnackBarM(messenger, 'Password reset email sent! Check your inbox.');
      return true;
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBarM(messenger, _getErrorMessage(e.code));
      return false;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      _showErrorSnackBarM(messenger, 'Failed to send reset email');
      return false;
    }
  }

  // ── Update profile ────────────────────────────────────────
  Future<bool> updateProfile({required String displayName, String? photoURL}) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      if (photoURL != null) await currentUser?.updatePhotoURL(photoURL);
      await currentUser?.reload();
      return true;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      return false;
    }
  }

  // ── Delete account ────────────────────────────────────────
  Future<bool> deleteAccount(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await currentUser?.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showErrorSnackBarM(messenger, 'Please sign in again to delete your account');
      } else {
        _showErrorSnackBarM(messenger, 'Failed to delete account');
      }
      return false;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      _showErrorSnackBarM(messenger, 'An error occurred');
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':         return 'Password is too weak. Use at least 8 characters.';
      case 'email-already-in-use':  return 'An account already exists with this email.';
      case 'invalid-email':         return 'Invalid email address.';
      case 'user-not-found':        return 'No account found with this email.';
      case 'wrong-password':        return 'Incorrect password.';
      case 'user-disabled':         return 'This account has been disabled.';
      case 'too-many-requests':     return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed': return 'Email/password sign-in is not enabled.';
      case 'network-request-failed':return 'Network error. Check your connection.';
      default:                      return 'Authentication failed. Please try again.';
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) =>
      _showErrorSnackBarM(ScaffoldMessenger.of(context), message);

  void _showErrorSnackBarM(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14))),
      ]),
      backgroundColor: const Color(0xFFFF3B30),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 4),
    ));
  }

  void _showSuccessSnackBarM(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14))),
      ]),
      backgroundColor: const Color(0xFF34C759),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }
}
