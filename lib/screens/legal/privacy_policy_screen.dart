import 'package:flutter/material.dart';
import '../../main.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBar(title: 'Privacy Policy'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _SectionTitle('Last Updated: April 2025'),
          SizedBox(height: 16),
          _SectionTitle('1. Information We Collect'),
          _SectionBody(
            'We collect information you provide when registering an account, '
            'including your name, email address, and phone number. We also collect '
            'booking data, location information (when you use venue maps), and '
            'usage data to improve our services.',
          ),
          _SectionTitle('2. How We Use Your Information'),
          _SectionBody(
            'Your information is used to:\n'
            '• Process and manage venue bookings\n'
            '• Send booking confirmations and notifications\n'
            '• Improve app functionality and user experience\n'
            '• Communicate important updates about PlaySphere\n'
            '• Ensure platform security and prevent fraud',
          ),
          _SectionTitle('3. Data Sharing'),
          _SectionBody(
            'We do not sell your personal data. We share information only with '
            'venue managers to facilitate your bookings, and with Firebase/Google '
            'for authentication and data storage services.',
          ),
          _SectionTitle('4. Data Security'),
          _SectionBody(
            'Your data is stored securely using Firebase (Google Cloud). We use '
            'industry-standard encryption and authentication measures to protect '
            'your personal information.',
          ),
          _SectionTitle('5. Location Data'),
          _SectionBody(
            'Location access is used only to show nearby venues on the map. '
            'We do not store or share your precise location data.',
          ),
          _SectionTitle('6. Your Rights'),
          _SectionBody(
            'You may request deletion of your account and associated data at any '
            'time from your Profile settings. You can also update your personal '
            'information from the Profile screen.',
          ),
          _SectionTitle('7. Contact Us'),
          _SectionBody(
            'For privacy-related questions, contact us at:\n'
            'support@playsphere.app',
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;
  const _SectionBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.7,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}
