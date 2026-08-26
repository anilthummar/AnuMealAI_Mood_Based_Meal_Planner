import 'package:flutter/material.dart';
import 'legal_document_page.dart';

/// Complete In-App Privacy Policy Document (§42, §43, §76).
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentPage(
      title: 'Privacy Policy',
      version: '1.0',
      effectiveDate: 'August 27, 2026',
      sections: [
        LegalSection(
          heading: '1. Overview & Commitment',
          content:
              'At AnuMealAI, your culinary preferences, dietary needs, and personal data privacy are paramount. This Privacy Policy details the specific data we collect, how it is used to personalize your meal recommendations, and your control over your data.',
        ),
        LegalSection(
          heading: '2. Information We Collect',
          content:
              'We collect only the data necessary to provide personalized meal planning:\n'
              '• Account Information: Email address and display name (when creating an account).\n'
              '• Culinary Profile: Dietary goals, allergies, cuisine preferences, cooking skill level, and prep time preferences.\n'
              '• Pantry & Meal Data: Ingredients you enter into your pantry, saved favorite recipes, cooked meal history, and custom shopping lists.\n'
              '• Mood Data: Selected mood preferences used to tailor AI recipe generation.\n'
              '• Subscription Metadata: Subscription tier status and entitlement identifiers managed through RevenueCat.',
        ),
        LegalSection(
          heading: '3. Third-Party Services We Use',
          content:
              'We integrate trusted industry-standard service providers strictly for core functionality:\n'
              '• Firebase Authentication: Secure user account authentication and session restoration.\n'
              '• Cloud Firestore: Secure cloud synchronization of user preferences, favorites, and pantry items.\n'
              '• Firebase Remote Config: Remotely managed application configuration, update notifications, and quotas.\n'
              '• Firebase Analytics: Aggregated usage analytics to improve recipe algorithms and UI usability.\n'
              '• Firebase Crashlytics: Anonymous crash diagnostics and stability reporting.\n'
              '• RevenueCat: In-app purchase processing and subscription entitlement verification.\n'
              '• Apple App Store & Google Play Billing: Native store billing and payment processing.',
        ),
        LegalSection(
          heading: '4. How Your Data Is Used',
          content:
              'Your data is used solely to generate tailored recipes, synchronize meal plans across your devices, process subscription entitlements, and diagnose technical errors. We do NOT sell or rent your personal data to any third-party advertisers.',
        ),
        LegalSection(
          heading: '5. Data Security & Isolation',
          content:
              'All data transmission is encrypted using TLS/HTTPS. Cloud Firestore databases enforce strict per-user security rules ensuring only authenticated users can read or write their private account documents.',
        ),
        LegalSection(
          heading: '6. Your Rights & Account Deletion',
          content:
              'You have the right to access, edit, or delete your personal data at any time. You can permanently delete your account and all associated pantry, recipe, and preference data directly within the app via Profile → Settings → Account → Delete Account.',
        ),
        LegalSection(
          heading: '7. Contact Us',
          content:
              'If you have questions or requests regarding your data privacy, please contact our Privacy Team at privacy@anumealai.app.',
        ),
      ],
    );
  }
}
