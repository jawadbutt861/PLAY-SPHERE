import 'package:flutter/material.dart';
import '../../main.dart';

enum LegalType { terms, privacy }

class LegalScreen extends StatelessWidget {
  final LegalType type;
  const LegalScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isTerms = type == LegalType.terms;
    return Scaffold(
      appBar: ModernAppBar(
        title: isTerms ? 'Terms & Conditions' : 'Privacy Policy',
        gradient: AppTheme.primaryGradient,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: isTerms ? _termsContent() : _privacyContent(),
        ),
      ),
    );
  }

  List<Widget> _termsContent() => [
        _heading('Terms & Conditions'),
        _sub('Last updated: April 2026'),
        _spacer(),
        _section('1. Acceptance of Terms',
            'By using PlaySphere, you agree to these terms. If you do not agree, please do not use the app.'),
        _section('2. User Accounts',
            'You are responsible for maintaining the confidentiality of your account credentials. You must provide accurate information during registration.'),
        _section('3. Booking Policy',
            'Bookings are confirmed upon successful submission. Cancellations are subject to our refund policy:\n\n• 24+ hours before slot: Full refund\n• 6–24 hours before slot: 50% refund\n• Less than 6 hours: No refund'),
        _section('4. Prohibited Activities',
            'Users may not use PlaySphere for any unlawful purpose, to harass others, or to submit false information.'),
        _section('5. Venue Rules',
            'Users must follow all rules set by venue managers. PlaySphere is not responsible for incidents at venues.'),
        _section('6. Limitation of Liability',
            'PlaySphere is not liable for any indirect, incidental, or consequential damages arising from use of the app.'),
        _section('7. Changes to Terms',
            'We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of updated terms.'),
        _section('8. Contact',
            'For questions about these terms, contact us at support@playsphere.app'),
      ];

  List<Widget> _privacyContent() => [
        _heading('Privacy Policy'),
        _sub('Last updated: April 2026'),
        _spacer(),
        _section('1. Information We Collect',
            'We collect information you provide during registration (name, email, phone number) and usage data (bookings, preferences).'),
        _section('2. How We Use Your Information',
            'Your information is used to:\n\n• Process bookings\n• Send notifications\n• Improve our services\n• Communicate with you about your account'),
        _section('3. Data Storage',
            'Your data is stored securely using Firebase (Google Cloud). We implement industry-standard security measures.'),
        _section('4. Data Sharing',
            'We do not sell your personal data. We share data only with venue managers as necessary to process your bookings.'),
        _section('5. Profile Pictures',
            'Profile pictures are uploaded to Cloudinary CDN. You can remove your picture at any time from your profile settings.'),
        _section('6. Push Notifications',
            'We send push notifications for booking confirmations, reminders, and updates. You can disable these in your device settings.'),
        _section('7. Your Rights',
            'You have the right to access, correct, or delete your personal data. Contact us to exercise these rights.'),
        _section('8. Children\'s Privacy',
            'PlaySphere is not intended for users under 13 years of age.'),
        _section('9. Contact',
            'For privacy concerns, contact us at privacy@playsphere.app'),
      ];

  Widget _heading(String text) => Text(text,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold));

  Widget _sub(String text) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      );

  Widget _spacer() => const SizedBox(height: 20);

  Widget _section(String title, String body) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 14, height: 1.6)),
        ]),
      );
}
