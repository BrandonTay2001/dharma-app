---
name: supabase-email-password-auth
description: 'Implement Supabase email/password auth in a SwiftUI app. Use when adding sign in, sign up, sign out, session restore, user metadata display, settings/profile identity UI, and avatar initials backed by Supabase Auth.'
argument-hint: 'Describe what auth behavior or screen wiring you need'
user-invocable: true
---

# Supabase Email/Password Auth

## What This Skill Produces

This skill adds or updates a complete Supabase email/password authentication flow for a SwiftUI frontend.

Expected outcomes:
- A configured Supabase Swift client for the app
- An auth view model that owns auth state and current user identity
- SwiftUI sign-in and sign-up screens
- Root app wiring that gates the app behind auth
- Sign-out from settings, profile, or account UI
- Profile display that prefers display name and falls back to email
- Avatar initials derived from display name or email
- A final validation pass over the touched Swift files

## When To Use

Use this skill when the request includes any of these:
- Supabase auth
- email/password sign in
- email/password sign up
- restore current session
- sign out from settings
- show current user email
- show display name from user metadata
- avatar initial from user identity
- SwiftUI auth flow backed by Supabase

Do not use this skill for:
- OAuth providers like Apple or Google
- password reset only
- backend auth proxy work
- database RLS policy design without frontend auth wiring

## Project Assumptions

- The target project is a SwiftUI app using the Supabase Swift SDK
- Shared auth state should be owned in one place and reused across screens
- SwiftUI environment injection is preferred when the app already uses it, but `ObservableObject` or dependency injection are also acceptable if that project standard already exists
- Supabase Swift package presence must be verified before coding
- Display name metadata should use a stable key such as `display_name` unless the project already has an existing convention

## Procedure

### 1. Gather Current State

Read the relevant instruction files and current auth-related code before changing anything.

Inspect at minimum:
- project-level instructions such as `AGENTS.md` or `copilot-instructions.md`
- the SwiftUI app entry point such as `App.swift`
- the root content shell such as `ContentView.swift`
- any existing auth view model or session manager
- auth-related views such as sign-in, sign-up, settings, profile, or home header views
- Xcode scheme or project files if auth configuration or package presence is uncertain

Confirm:
- whether auth files already exist
- whether Supabase Swift is already linked in the project
- where settings, profile, or header UI pull their identity state from

### 2. Verify Supabase Client Setup

Create or update a shared Supabase client for the frontend.

Requirements:
- Use the Supabase Swift SDK
- Keep the client accessible to the auth view model and other views
- Do not use the service role key on the client
- Prefer the anon key only

If configuration is missing:
- add a dedicated frontend client file such as `SupabaseClient.swift`
- wire `supabaseURL` and `supabaseKey`
- prefer reading from project configuration that is appropriate for the app instead of hardcoding secrets if the project already has a configuration pattern

### 3. Build The Auth State Model

Implement or update a shared auth state model such as `AuthViewModel` as the single source of truth for frontend auth.

It should own:
- form fields for sign in and sign up
- loading state
- error state
- `isAuthenticated`
- current signed-in email
- current display name from user metadata
- a computed primary identity label
- a computed secondary identity label when display name exists
- a computed avatar initial

Core actions:
1. `checkSession()`
2. `signIn()`
3. `signUp()`
4. `signOut()`

Behavior rules:
- On launch, check for an existing Supabase session
- After sign in or sign up with a session, update the stored current user identity
- On sign out, clear both auth state and current identity state
- On sign up, send optional `display_name` metadata when provided
- Prefer `display_name`, then `full_name`, then email when resolving the visible identity label
- If the project already uses a profile table or a different metadata key, reuse that convention instead of forcing a new one

### 4. Build The SwiftUI Auth Screens

Create or update:
- sign-in screen
- sign-up screen

The screens should include:
- email field
- password field
- confirm password on sign up
- optional display name on sign up
- loading treatment
- visible error messaging
- navigation between sign in and sign up

- Keep styling aligned with the project design system or current SwiftUI component patterns.

### 5. Gate The App At Launch

Update the app entry point so the authenticated shell and auth screens are driven by shared auth state.

Expected structure:
1. Create a shared auth state model in the app root
2. Show the signed-in app content when `isAuthenticated` is true
3. Show sign-in UI otherwise
4. Inject or pass the shared auth model into authenticated views using the project standard

### 6. Wire Settings Sign-Out And Identity Display

Update settings, profile, or account UI so it consumes the shared auth model.

Expected behavior:
- show a profile row near the top
- show display name if present, otherwise email
- show email as a secondary line when display name exists
- sign out from Supabase when the user taps Log Out

### 7. Wire The Home Header Avatar

Update any avatar, profile chip, home header badge, or account circle so it uses the shared computed avatar initial.

Rules:
- use the first letter of display name if available
- otherwise use the first letter of email
- uppercase the result
- keep the visual style consistent with the project theme

### 8. Validate The Result

After edits, run a targeted error pass on every changed Swift file.

Minimum validation:
- no Swift compile diagnostics in the changed files
- previews updated if a view now depends on environment state
- sign-up metadata path does not rely on guessed SDK APIs
- the auth state source is not duplicated across multiple views

If the SDK surface is uncertain:
- verify against the upstream `supabase/supabase-swift` API before editing

## Decision Points

### If Supabase Swift Is Already Installed
- reuse the existing package
- do not change package wiring unless necessary

### If Supabase Swift Is Not Installed
- add the package in the Xcode project before implementing auth code

### If Display Name Is Not Part Of The UX Yet
- add an optional display name field in sign up
- store it in Supabase user metadata as `display_name`

### If The Project Already Has A Profile Screen But No Settings Screen
- wire sign out and identity display into the profile screen instead of inventing a new settings screen

### If The Project Already Uses `ObservableObject` Instead Of `@Observable`
- follow the existing project pattern rather than rewriting state management across the app

### If The User Only Wants Identity Display Updates
- avoid rewriting the auth flow
- reuse existing auth state and only add computed identity fields plus UI bindings

### If Email Confirmation Is Enabled
- handle the no-session sign-up response path
- keep the user unauthenticated and show a confirmation message

## Completion Checks

The work is complete when all of the following are true:
- sign in works with email and password
- sign up supports email/password and optional display name
- session restore flips the app into authenticated mode on launch
- settings, profile, or account UI can sign the user out
- settings, profile, or account UI shows display name or email correctly
- at least one user-facing avatar or account badge uses the correct first letter
- the current user identity is resolved in one shared place, not duplicated across views
- changed Swift files report no errors

## Common Mistakes To Avoid

- Do not expose the Supabase service role key in the iOS client
- Do not duplicate identity formatting logic in multiple views
- Do not hardcode the home avatar initial
- Do not leave previews broken after adding environment dependencies
- Do not assume the SDK metadata API shape without checking it
- Do not clear only the form fields on sign out while leaving stale current user identity behind

## Example Prompts

- `/supabase-email-password-auth Add Supabase email/password auth to my SwiftUI app with sign in, sign up, and session restore`
- `/supabase-email-password-auth Show the signed-in user display name in settings or profile and use its first letter in the avatar`
- `/supabase-email-password-auth Update my current auth flow to store optional display_name metadata in Supabase on sign up`

## Scope Note

This file lives under `.github/skills/`, so it is available to this repository.

If you want the same skill available in future unrelated SwiftUI projects, copy this folder to a personal skills location such as:
- `~/.agents/skills/supabase-email-password-auth/`
- `~/.claude/skills/supabase-email-password-auth/`
- `~/.copilot/skills/supabase-email-password-auth/`

Keep the folder name and the `name` field identical.
