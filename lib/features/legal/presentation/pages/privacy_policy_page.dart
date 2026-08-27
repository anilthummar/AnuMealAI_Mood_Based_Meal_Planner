import 'package:flutter/material.dart';
import 'legal_document_page.dart';

/// Complete In-App Privacy Policy Document (§42, §43, §76).
/// Strictly aligned with Google Play Developer Policy, Apple App Store Guidelines,
/// GDPR, and CCPA data privacy frameworks.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentPage(
      title: 'Privacy Policy',
      version: '1.1',
      effectiveDate: 'August 27, 2026',
      sections: [
        LegalSection(
          heading: '1. Overview & Commitment',
          content:
              'Welcome to AnuMealAI ("we", "our", or "us"). We are deeply committed to protecting your personal privacy. This Privacy Policy details the types of data we collect, how it is handled to provide artificial intelligence-powered culinary planning, how your permissions are used, and your comprehensive rights regarding your personal information.',
        ),
        LegalSection(
          heading: '2. Information We Collect',
          content:
              'We collect only the minimum information necessary to personalize and optimize your culinary experience:\n\n'
              '• Account Information: Your email address and chosen display name when creating an account or logging in.\n'
              '• Culinary Profile & Preferences: Cooking skill level, typical daily prep time targets, preferred cuisines, dietary goals (e.g., Vegan, Vegetarian, Keto), and food allergy restrictions.\n'
              '• Pantry & Meal Tracking Data: Custom ingredients added to your pantry, saved favorite recipes, weekly planner schedules, custom shopping list items, and cooked meal streak counts.\n'
              '• Mood & Recipe Prompts: Selected mood preferences used to generate mood-tailored culinary recommendations.\n'
              '• Subscription Metadata: In-app purchase entitlement status, expiration dates, and subscription tier indicators managed securely via RevenueCat and official platform stores.',
        ),
        LegalSection(
          heading: '3. Device Permissions & How They Are Used',
          content:
              'AnuMealAI requests explicit device permissions only when required for specific active features:\n\n'
              '• Camera Permission: Used exclusively when you choose to take a custom profile picture or capture photos of ingredients. We never access your camera without your explicit in-moment action.\n'
              '• Photo Library / Media Storage: Used to allow you to select existing photos from your device for your avatar. We only access the specific image you select.\n'
              '• Push Notifications: Used optionally to send daily dinner reminders and helpful meal prep prompts at your scheduled time. You can enable, disable, or adjust notification permissions at any time in app settings.',
        ),
        LegalSection(
          heading: '4. Third-Party Services & Data Processors',
          content:
              'We partner with reputable industry leaders strictly to power core app operations:\n\n'
              '• Firebase Authentication (Google LLC): Authenticates user accounts, secures sessions, and manages password resets.\n'
              '• Cloud Firestore (Google LLC): Provides encrypted cloud database storage and cross-device synchronization of user preferences, recipes, and pantry items.\n'
              '• Firebase Analytics & Crashlytics (Google LLC): Collects anonymous crash telemetry and aggregated usage patterns to maintain application stability.\n'
              '• Firebase Remote Config (Google LLC): Dynamically serves configuration flags, quota parameters, and maintenance notifications.\n'
              '• RevenueCat & Platform Billing (Google Play & Apple Store): Processes and verifies in-app subscriptions and purchase receipts securely without exposing your credit card details.',
        ),
        LegalSection(
          heading: '5. Data Security & Storage Isolation',
          content:
              'All communication between your device, our servers, and third-party APIs is encrypted in transit using industry-standard TLS/HTTPS protocols. Data stored in Cloud Firestore is protected by strict granular database security rules ensuring each user can only read and write their own records.',
        ),
        LegalSection(
          heading: '6. Data Retention & Account Deletion Rights (GDPR / CCPA)',
          content:
              'We respect your full legal right to access, export, or permanently delete your personal information:\n\n'
              '• Permanent Account Deletion: You can permanently delete your account and all associated cloud data at any time by navigating to Settings → Account & Security → Delete Account.\n'
              '• Immediate Erasure: When you initiate account deletion, your Firebase Auth record, Cloud Firestore user documents, pantry items, favorite recipes, and local database caches are completely and permanently erased.',
        ),
        LegalSection(
          heading: '7. Children’s Privacy',
          content:
              'AnuMealAI is not directed toward children under the age of 13. We do not knowingly collect personal identifiable information from children under 13. If you believe a child has provided us with personal data, please contact us for immediate removal.',
        ),
        LegalSection(
          heading: '8. Changes to This Privacy Policy',
          content:
              'We may periodically update this Privacy Policy to reflect app enhancements or regulatory changes. The current effective date will always be prominently displayed at the top of this document.',
        ),
        LegalSection(
          heading: '9. Contact Us',
          content:
              'If you have questions, feedback, or data privacy requests regarding this policy, please reach out to our team at:\n\n'
              'Email: privacy@anumealai.app\n'
              'Support: support@anumealai.app\n'
              'Website: https://anumealai.app',
        ),
      ],
    );
  }
}
