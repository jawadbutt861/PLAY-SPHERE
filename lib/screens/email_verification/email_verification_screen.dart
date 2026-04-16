import 'dart:async';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  Timer? _checkTimer;
  bool _resendCooldown = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Verification email bhejo
    _authService.sendEmailVerification();
    // Har 3 saniye mein check karo
    _checkTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkVerification(),
    );
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    final verified = await _authService.isEmailVerified();
    if (verified && mounted) {
      _checkTimer?.cancel();
      Navigator.pushReplacementNamed(context, '/UserMain');
    }
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown) return;
    await _authService.sendEmailVerification();
    if (!mounted) return;
    setState(() {
      _resendCooldown = true;
      _cooldownSeconds = 60;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _cooldownSeconds--);
      if (_cooldownSeconds <= 0) {
        t.cancel();
        setState(() => _resendCooldown = false);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Verification email sent!',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email =
        _authService.currentUser?.email ?? '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ModernCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mark_email_unread_rounded,
                        size: 72, color: AppTheme.primaryColor),
                    const SizedBox(height: 20),
                    Text(
                      'Verify Your Email',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We sent a verification link to:\n$email\n\nPlease check your inbox and click the link.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Waiting for verification...',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 28),
                    GradientButton(
                      text: _resendCooldown
                          ? 'Resend in ${_cooldownSeconds}s'
                          : 'Resend Email',
                      icon: Icons.send_rounded,
                      onPressed: _resendCooldown ? () {} : _resendEmail,
                      width: double.infinity,
                      height: 50,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        await _authService.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
