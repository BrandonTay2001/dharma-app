# Paywall Integration

This document captures the current Superwall integration for the Dharma iOS app.

## Purpose

The app uses Superwall to gate account access before authentication.

Users must encounter the pre-login paywall before they can sign up or sign in.
The `pre_login_access` placement is expected to be configured as a gated placement in Superwall.

## Files

- `dharma/APIConfig.swift`: Stores `superwallPublicAPIKey`
- `dharma/ViewModels/SuperwallViewModel.swift`: Configures Superwall, tracks subscription state, and presents placements
- `dharma/Views/Onboarding/WelcomeView.swift`: Welcome screen shown before auth; Continue triggers the pre-login placement
- `dharma/dharmaApp.swift`: Root flow that decides whether to show onboarding, auth, or the main app
- `dharma/ViewModels/AuthViewModel.swift`: Syncs Supabase auth identity into Superwall via `identify` and `reset`

## Placements

### `pre_login_access`

Used from the onboarding welcome screen.

Expected behavior:
- Triggered only when the user taps Continue on `WelcomeView`
- Configured as gated in Superwall
- If the user purchases, Superwall unlocks the auth flow
- If the user dismisses the paywall, the app remains on the welcome screen

## Runtime Flow

1. `dharmaApp` creates the shared `SuperwallViewModel`
2. `SuperwallViewModel` configures Superwall with `APIConfig.superwallPublicAPIKey`
3. If `hasUnlockedAuthFlow` is `false`, the app shows `WelcomeView`
4. Tapping Continue calls `presentPreLoginPaywall()`
5. `Superwall.shared.register(placement: "pre_login_access")` runs
6. If the placement feature closure executes, `hasUnlockedAuthFlow` becomes `true`
7. The app then reveals sign in / sign up
8. After Supabase auth succeeds, the app identifies the user in Superwall using the Supabase user UUID
9. On sign out or account deletion, the app resets the Superwall identity and returns to the welcome screen when the user is not subscribed

## User Attributes

The app currently sends these user attributes to Superwall:
- `auth_state`
- `display_name`
- `email`
- `supabase_user_id`

Anonymous resets clear these values by setting them to `nil` where appropriate.

## Important Constraints

- Do not bypass the welcome screen when the API key is configured and the user is not subscribed
- Do not auto-present the pre-login paywall on launch; it should be triggered from the welcome CTA
- Do not add custom restore-purchases UI for the onboarding flow unless the product requirement changes
- Keep placement names stable unless they are changed in both code and Superwall dashboard
- Use `Superwall.shared.subscriptionStatus.isActive` as the local signal for whether the user currently has paid access

## Dashboard Assumptions

- A valid Superwall public API key is present in `APIConfig.superwallPublicAPIKey`
- `pre_login_access` exists and is gated

## When Updating This Flow

Update this file if any of the following changes:
- placement names
- onboarding paywall behavior
- auth unlock conditions
- identity attributes sent to Superwall
- file locations for the integration
