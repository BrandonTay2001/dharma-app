# Dharma Privacy Policy

Last updated: April 2, 2026

This Privacy Policy explains how Dharma collects, uses, stores, and shares information when you use the Dharma mobile app and related services.

Dharma is a spirituality app focused on Buddhism and Hinduism. It currently includes account creation, daily verses, spiritual chat, guided practice features, gratitude journaling, subscription paywall access, and learning content.

By using Dharma, you agree to the practices described in this Privacy Policy.

## 1. Information We Collect

We collect the following categories of information depending on how you use the app.

### A. Account Information

When you create or use an account, we collect and process:

- Email address
- Password credentials through Supabase Auth
- Optional display name
- Internal user identifier associated with your account

### B. Content You Create in the App

If you use certain Dharma features, we may process or store:

- Gratitude journal entries you write in the app
- Messages you send through the spiritual chat feature
- Daily practice completion status and streak information

### C. Subscription and Paywall Data

If you encounter Dharma's subscription paywall, Dharma uses Superwall to manage paywall presentation and subscription state. In that flow, Dharma currently sends the following user attributes to Superwall:

- Auth state
- Display name
- Email address
- Supabase user ID

Purchases and subscription billing are handled through Apple and are also subject to Apple's privacy terms.

### D. Data Stored Only on Your Device

Some data is stored locally on your device and is not currently synced to Dharma's backend, including:

- Daily verse reflections saved for the current day
- Local daily task progress state used to track completion during the day

### E. Learn Content

Dharma serves article and spiritual learning content through its backend. This content is generally not personal data.

## 2. How We Use Information

We use information to:

- Create and manage your account
- Authenticate you and keep you signed in
- Save and display your gratitude journal entries
- Track daily completion history and streaks
- Generate responses in the spiritual chat feature
- Show and manage subscription paywalls and subscription access
- Operate, secure, maintain, and improve the app
- Respond to support, legal, or safety issues when necessary

## 3. How Dharma Processes and Stores Your Data

### A. Supabase

Dharma uses Supabase for authentication and app data storage.

Based on the current implementation, Dharma stores the following account-related and user-generated data in Supabase:

- User profile data, including email and optional display name
- Gratitude journal entries
- Streak records
- Daily completion records

These records are associated with your authenticated account.

### B. OpenAI

When you use the spiritual chat feature, the messages you send are transmitted through Dharma's backend to OpenAI to generate a response.

Dharma does not currently maintain a dedicated chat history table in its own database based on the current codebase. However, chat prompts and responses are processed by OpenAI to provide the feature. OpenAI's handling of data is governed by its own terms and privacy practices.

### C. Superwall

Dharma uses Superwall to present subscription paywalls, identify subscription status, and manage access to paid features.

### D. Local Device Storage

Some information is stored locally on your device using iOS local storage mechanisms, such as UserDefaults, to support app functionality.

## 4. When We Share Information

We do not sell your personal information.

We share information only as needed with service providers that help us run Dharma, including:

- Supabase, for authentication and database infrastructure
- OpenAI, for chat response generation
- Superwall, for paywall and subscription access management
- Apple, for in-app purchases and subscription billing

We may also disclose information if required by law, regulation, legal process, or to protect the safety, rights, or integrity of Dharma, our users, or others.

## 5. Data Retention

We retain data for as long as reasonably necessary to provide the app and operate the service, unless a longer retention period is required by law.

Based on the current product behavior:

- Account-related data remains associated with your account until deleted
- Gratitude journal entries, streak records, and daily completion records remain in Supabase until your account is deleted or the data is otherwise removed
- Locally stored reflections and task progress remain on your device until they are cleared by app behavior, overwritten, or the app is removed

## 6. Account Deletion

Dharma currently provides an in-app account deletion flow.

When you delete your account through the app, Dharma deletes your authenticated user and, based on the current database design, this cascades to associated user-owned records, including:

- Profile data in the public users table
- Gratitude journal entries
- Streak records
- Daily completion records

Locally stored data on your device may remain until it is cleared by the app or removed from the device.

## 7. Your Choices

You can choose whether to:

- Create an account
- Provide an optional display name
- Use the chat, journaling, and paid subscription features
- Delete your account from within the app

If you do not want Dharma to process chat content through OpenAI, do not use the chat feature.

If you do not want subscription-related data shared with Superwall, do not purchase or interact with Dharma's subscription flow.

## 8. Security

We use third-party infrastructure and authentication providers to help secure the service, but no method of transmission or storage is completely secure. We cannot guarantee absolute security.

## 9. Children's Privacy

Dharma is not directed to children under 13, and we do not knowingly collect personal information from children under 13. If you believe a child has provided personal information, contact us so we can review and address the issue.

## 10. International Processing

Your information may be processed and stored in countries other than your own depending on where our service providers operate their infrastructure.

## 11. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. If we make material changes, we will update the date at the top of this file and may provide additional notice where appropriate.

## 12. Contact Us

If you have questions about this Privacy Policy or Dharma's data practices, contact us at:

- [Add support email before publishing]
