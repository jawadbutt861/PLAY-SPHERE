import 'package:flutter/material.dart';
import '../../main.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBar(title: 'Terms of Service'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _SectionTitle('Last Updated: April 2025'),
          SizedBox(height: 16),
          _SectionTitle('1. Acceptance of Terms'),
          _SectionBody(
            'By using PlaySphere, you agree to these Terms of Service. '
            'If you do not agree, please do not use the application.',
          ),
          _SectionTitle('2. User Accounts'),
          _SectionBody(
            'You are responsible for maintaining the confidentiality of your '
            'account credentials. You must be at least 13 years old to use '
            'PlaySphere. You agree to provide accurate and complete information '
            'when registering.',
          ),
          _SectionTitle('3. Booking Policy'),
          _SectionBody(
            '• Bookings are confirmed upon successful payment\n'
            '• Cancellations must be made at least 24 hours before the booking time\n'
            '• PlaySphere is not responsible for venue-side cancellations\n'
            '• Slot availability is shown in real-time but not guaranteed until confirmed',
          ),
          _SectionTitle('4. Venue Manager Responsibilities'),
          _SectionBody(
            'Venue managers are responsible for the accuracy of venue information, '
            'pricing, and availability. PlaySphere acts as a platform connecting '
            'users with venues and is not liable for disputes between users and managers.',
          ),
          _SectionTitle('5. Prohibited Conduct'),
          _SectionBody(
            'You agree not to:\n'
            '• Make fraudulent bookings\n'
            '• Misuse or attempt to hack the platform\n'
            '• Post false or misleading venue information\n'
            '• Harass other users or venue managers',
          ),
          _SectionTitle('6. Intellectual Property'),
          _SectionBody(
            'All content, logos, and branding within PlaySphere are the property '
            'of PlaySphere. You may not reproduce or distribute any content '
            'without written permission.',
          ),
          _SectionTitle('7. Limitation of Liability'),
          _SectionBody(
            'PlaySphere is provided "as is". We are not liable for any indirect, '
            'incidental, or consequential damages arising from your use of the app.',
          ),
          _SectionTitle('8. Changes to Terms'),
          _SectionBody(
            'We may update these terms at any time. Continued use of PlaySphere '
            'after changes constitutes acceptance of the new terms.',
          ),
          _SectionTitle('9. Contact'),
          _SectionBody(
            'For questions about these terms:\n'
            'legal@playsphere.app',
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
