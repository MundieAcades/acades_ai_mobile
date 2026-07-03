import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  final bool showPrivacy;
  const TermsScreen({super.key, this.showPrivacy = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          showPrivacy ? 'Privacy Policy' : 'Terms of Service',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: showPrivacy ? const _PrivacyContent() : const _TermsContent(),
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LastUpdated('June 2025'),
        SizedBox(height: 20),
        _Section(
          title: '1. Acceptance of Terms',
          body:
              'By using Acades AI, you agree to these Terms of Service. If you do not agree, please do not use the app. These terms apply to all users of the Acades AI mobile application.',
        ),
        _Section(
          title: '2. What Acades AI Does',
          body:
              'Acades AI provides agricultural guidance, crop advice, weather alerts, and farm record management powered by artificial intelligence. Our advice is informational only and should not replace professional agronomist consultation.',
        ),
        _Section(
          title: '3. AI Limitations',
          body:
              'Acades AI uses large language models to generate farming advice. These models can occasionally produce incorrect or outdated information. Always verify critical decisions with a qualified agricultural officer. We display a disclaimer in the chat for this reason.',
        ),
        _Section(
          title: '4. Your Account',
          body:
              'You register with your mobile phone number. You are responsible for keeping your number and OTP codes secure. Do not share verification codes with anyone. Acades AI staff will never ask for your OTP.',
        ),
        _Section(
          title: '5. Data You Provide',
          body:
              'During onboarding you share your crops, district, land size, and gender. This data is used only to personalise your farming advice. We do not sell this data.',
        ),
        _Section(
          title: '6. Acceptable Use',
          body:
              'You agree not to misuse the app, attempt to reverse-engineer the AI models, submit harmful content, or use the service for commercial data harvesting.',
        ),
        _Section(
          title: '7. Changes to Terms',
          body:
              'We may update these terms as Acades AI grows. We will notify you via SMS when material changes occur. Continued use after notification constitutes acceptance.',
        ),
        _Section(
          title: '8. Contact',
          body:
              'For questions about these terms, contact us at legal@acadesai.mw or through the app\'s Help section.',
        ),
      ],
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LastUpdated('June 2025'),
        SizedBox(height: 20),
        _Section(
          title: '1. What We Collect',
          body:
              'We collect: your mobile phone number (for authentication), onboarding data (crops, district, land size, gender), chat messages you send to the AI, and usage analytics to improve the app.',
        ),
        _Section(
          title: '2. How We Use Your Data',
          body:
              'Your data is used to: verify your identity, personalise farming advice, improve our AI models (anonymised), send SMS alerts you opt into, and generate aggregate farming statistics for Malawi.',
        ),
        _Section(
          title: '3. Data We Do NOT Collect',
          body:
              'We do not collect your real name, email address, location GPS data, financial information, or contacts. We do not track your browsing outside Acades AI.',
        ),
        _Section(
          title: '4. Data Sharing',
          body:
              'We do not sell your personal data. We may share anonymised, aggregated farming statistics with the Ministry of Agriculture and NGO partners to improve agricultural planning in Malawi.',
        ),
        _Section(
          title: '5. Your Rights',
          body:
              'You can request deletion of your account and all associated data at any time from Settings → Account → Delete Account. Deletion is permanent and processed within 30 days.',
        ),
        _Section(
          title: '6. Data Security',
          body:
              'Your data is encrypted in transit (TLS 1.3) and at rest (AES-256). Phone numbers are hashed in our database. We conduct regular security audits.',
        ),
        _Section(
          title: '7. Children',
          body:
              'Acades AI is intended for farmers aged 16 and above. We do not knowingly collect data from children under 16.',
        ),
        _Section(
          title: '8. Contact',
          body:
              'Privacy questions: privacy@acadesai.mw. You may also reach our Data Protection Officer at dpo@acadesai.mw.',
        ),
      ],
    );
  }
}

class _LastUpdated extends StatelessWidget {
  final String date;
  const _LastUpdated(this.date);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryIcon,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryBorder, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 13, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'Last updated: $date',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
