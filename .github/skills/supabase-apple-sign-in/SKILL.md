---
name: supabase-apple-sign-in
description: 'Implement native Sign in with Apple in a SwiftUI app using ASAuthorizationAppleIDButton and Supabase auth.signInWithIdToken.'
argument-hint: 'Describe what Apple sign-in behavior or Supabase wiring you need'
user-invocable: true
---

# Supabase Apple Sign In

## What This Skill Produces

This skill adds or updates a native Sign in with Apple flow for a SwiftUI frontend backed by Supabase Auth.

Expected outcomes:
- A native `ASAuthorizationAppleIDButton` entry point in the auth UI
- Nonce generation and SHA-256 hashing for the Apple authorization request
- Supabase authentication using `auth.signInWithIdToken`
- Shared auth state updates that reuse the app's existing session model
- Apple Sign In capability enabled in the Xcode target
- A final validation pass over the changed Swift files

## When To Use

Use this skill when the request includes any of these:
- Sign in with Apple
- Apple auth in SwiftUI
- native Apple ID button
- `ASAuthorizationAppleIDButton`
- Supabase `signInWithIdToken`
- Apple ID token auth
- add Apple auth to an existing Supabase flow

Do not use this skill for:
- email/password auth only
- Google Sign-In
- generic OAuth browser flows when the user explicitly wants the native Apple button
- storing onboarding profile fields such as full name beyond the current auth request

## Project Assumptions

- The target project is a SwiftUI iOS app
- The app already uses or will use the Supabase Swift SDK
- Auth state should be owned in one shared place such as `AuthViewModel`
- The app should use the native Apple sign-in UI instead of a custom button replica
- User full name is optional and should not be persisted unless the product explicitly asks for it

## Procedure

### 1. Gather Current State

Read the relevant instructions and inspect the current auth flow before changing anything.

Inspect at minimum:
- project-level instructions such as `AGENTS.md` or `copilot-instructions.md`
- the SwiftUI app entry point such as `App.swift`
- the shared Supabase client file
- the existing auth state model such as `AuthViewModel`
- sign-in or onboarding views where the Apple button should live
- the Xcode project file if capabilities or entitlements are unclear

Confirm:
- whether Supabase Swift is already linked
- whether auth state already exists and should be reused
- whether Sign in with Apple capability is already configured
- where the Apple button should appear in the current auth UX

### 2. Verify Supabase SDK Support

Verify the installed Supabase Swift SDK supports `signInWithIdToken(credentials:)` and `OpenIDConnectCredentials`.

Requirements:
- use `provider: .apple`
- pass the Apple identity token as `idToken`
- pass the raw nonce when the Apple request includes a nonce
- do not guess SDK signatures when the version is uncertain

If the SDK surface is uncertain:
- verify against upstream `supabase/supabase-swift` sources before editing

### 3. Add Native Apple Request Handling

Implement Apple authorization request handling in the shared auth model.

The auth model should:
- clear prior auth errors before a new Apple attempt
- generate a random nonce
- store the raw nonce temporarily
- hash the nonce with SHA-256
- attach the hashed nonce to `ASAuthorizationAppleIDRequest.nonce`
- request only the scopes actually needed by the current product

If the product does not need name collection yet:
- request `.email` only or keep scopes minimal
- do not persist `fullName`

### 4. Exchange The Apple Token With Supabase

Implement the completion path using `signInWithIdToken`.

Expected flow:
1. Receive `ASAuthorization`
2. Extract `ASAuthorizationAppleIDCredential`
3. Read `identityToken` and convert it to a UTF-8 string
4. Retrieve the stored raw nonce
5. Call `supabase.auth.signInWithIdToken(credentials:)`
6. Reuse the app's existing signed-in state handling

After success:
- update the current user identity from the returned session
- set `isAuthenticated` or equivalent auth state
- clear transient form state if that matches the current flow
- identify the user with any other integrated SDKs only if the app already does so

### 5. Use A Real ASAuthorizationAppleIDButton

Expose the button in SwiftUI using the native Apple UI.

Requirements:
- use `ASAuthorizationAppleIDButton`
- present it directly or via `UIViewRepresentable` if needed
- do not replace it with a lookalike custom SwiftUI button
- keep sizing and spacing consistent with the existing design system
- disable it while auth is loading if the rest of the auth UI behaves that way

### 6. Enable The Apple Capability

Ensure the Xcode target is actually capable of using Sign in with Apple.

Check for:
- an entitlements file containing `com.apple.developer.applesignin`
- `CODE_SIGN_ENTITLEMENTS` pointing at that file in the target build settings

If missing:
- add an entitlements file
- wire it into Debug and Release build settings

### 7. Preserve The Existing Auth Architecture

Do not create a second auth state system just for Apple.

Rules:
- reuse the current `AuthViewModel` or equivalent shared auth owner
- reuse the same app gating logic already used for email/password sign-in
- reuse existing identity resolution logic for display name, email, and avatar
- keep Apple auth a new entry point into the same authenticated shell

### 8. Validate The Result

After edits, run a targeted error pass on every changed Swift file.

Minimum validation:
- no Swift diagnostics in the changed files
- the Apple request path compiles with `AuthenticationServices`
- the Supabase sign-in call matches the installed SDK surface
- previews still compile or remain valid for changed views
- the Xcode target references the entitlements file if one was added

## Decision Points

### If Auth State Already Exists
- extend it instead of introducing a separate Apple sign-in manager

### If The Current Auth UI Is In Onboarding
- place the Apple button in onboarding or sign-in where it matches the current user journey

### If Name Collection Belongs To Later Onboarding
- do not store Apple `fullName`
- leave profile completion for the later onboarding flow

### If The Project Already Has The Apple Capability
- do not add duplicate entitlements or duplicate build settings

### If The User Wants Google Or Other Providers Too
- keep this skill focused on Apple and create or use a separate provider-specific skill for the others

## Completion Checks

The work is complete when all of the following are true:
- the app shows a native Apple sign-in button in the intended auth UI
- the Apple request uses a hashed nonce
- Supabase authentication uses `signInWithIdToken(credentials:)`
- the existing auth state flips into the authenticated shell after success
- the implementation does not persist Apple full name unless explicitly requested
- the changed Swift files report no errors
- the target has the Sign in with Apple capability configured

## Common Mistakes To Avoid

- Do not use a fake Apple-styled button instead of `ASAuthorizationAppleIDButton`
- Do not omit nonce hashing when sending a nonce in the Apple request
- Do not pass the hashed nonce to Supabase; Supabase needs the raw nonce
- Do not store the user's full name when the product says onboarding will handle that later
- Do not create a parallel auth state system for Apple sign-in
- Do not forget the Xcode entitlement setup
- Do not assume the Supabase SDK signature without checking the installed version

## Example Prompts

- `/supabase-apple-sign-in Add native Sign in with Apple to my SwiftUI auth screen using Supabase signInWithIdToken`
- `/supabase-apple-sign-in Update my existing Supabase AuthViewModel to support ASAuthorizationAppleIDButton and nonce handling`
- `/supabase-apple-sign-in Add Sign in with Apple capability and wire the result into my current authenticated app shell`

## Scope Note

This file lives under `.github/skills/`, so it is available to this repository.

If you want the same skill available in future unrelated SwiftUI projects, copy this folder to a personal skills location such as:
- `~/.agents/skills/supabase-apple-sign-in/`
- `~/.claude/skills/supabase-apple-sign-in/`
- `~/.copilot/skills/supabase-apple-sign-in/`

Keep the folder name and the `name` field identical.
