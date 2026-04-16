import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      if (context.mounted) _showErrorSnackBar(context, message);
      return null;
    } catch (e) {
      if (context.mounted) _showErrorSnackBar(context, 'An unexpected error occurred');
      return null;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      if (context.mounted) _showErrorSnackBar(context, message);
      return null;
    } catch (e) {
      if (context.mounted) _showErrorSnackBar(context, 'An unexpected error occurred');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      if (context.mounted) _showSuccessSnackBar(context, 'Password reset email sent! Check your inbox.');
      return true;
    } on FirebaseAuthException catch (e) {
      String message = _getErrorMessage(e.code);
      if (context.mounted) _showErrorSnackBar(context, message);
      return false;
    } catch (e) {
      if (context.mounted) _showErrorSnackBar(context, 'Failed to send reset email');
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String displayName,
    String? photoURL,
  }) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await currentUser?.updatePhotoURL(photoURL);
      }
      await currentUser?.reload();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount(BuildContext context) async {
    try {
      await currentUser?.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (context.mounted) _showErrorSnackBar(context, 'Please sign in again to delete your account');
      } else {
        if (context.mounted) _showErrorSnackBar(context, 'Failed to delete account');
      }
      return false;
    } catch (e) {
      if (context.mounted) _showErrorSnackBar(context, 'An error occurred');
      return false;
    }
  }

  // ─── Google Sign-In ──────────────────────────────────────

  /// Google se sign in karo — user aur manager dono ke liye
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // user ne cancel kiya

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return null;
    }
  }

  /// Google sign out
  Future<void> signOutGoogle() async {
    await GoogleSignIn().signOut();
  }

  // ─── Email Verification ───────────────────────────────────

  /// Verification email bhejo
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint('sendEmailVerification error: $e');
    }
  }

  /// Check karo email verified hai ya nahi (reload karke)
  Future<bool> isEmailVerified() async {
    await currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Get error message from Firebase error code
  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Show success snackbar
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
