# Dharma Onboarding

This document captures the intended onboarding flow, copy, and product context for the iOS frontend.

## Purpose

The onboarding flow should feel calm, premium, and guided.

It introduces the app, collects enough context to personalise the experience, explains data usage, previews the product, generates a plan, and ends on the premium value-proposition screen that leads into the pre-login paywall.

## Flow Overview

1. Get Started
2. Consent
3. Name
4. Spiritual Belief
5. Gender
6. Age Range
7. Goals
8. Why Dharma Helps
9. Practice Preferences
10. Time Available Daily
11. What Dharma Does
12. Social Proof
13. Notifications
14. Generating Your Plan
15. Premium Value Proposition

## Screen Details

### 1. Get Started

- Headline: "Your path to dharma begins here"
- Subheadline: "Guided by ancient wisdom. Built for your life today."
- Tagline: "Your AI spiritual mentor"
- Primary CTA: "Start my journey"
- Footer action: "I already have an account - Sign in"
- Existing-account behavior: check whether the user already has access; otherwise prompt them to continue onboarding first

### 2. Consent

- Headline: "Your journey, your data."
- Body: "Dharma personalises your spiritual path using the information you share. We never sell your data, and you can delete everything at any time."
- We collect: spiritual preferences, age range, goals, practice choices, only to personalise the experience
- Disclaimer: Dharma is built upon timeless Hindu and Buddhist teachings that are widely available in the public domain, presented as a clean sanctuary for modern mindfulness
- Primary CTA: "I understand - let's continue"
- Secondary action: privacy policy

### 3. Name

- Prompt: "What's your name?"

### 4. Spiritual Belief

- Question: "What tradition speaks to your soul?"
- Helper text: "This shapes your daily verse, mentor, and practice. You can change it anytime."
- Minimum selection: 1
- CTA: "Continue"
- Options:
  - Hinduism
  - Buddhism
  - Spiritual, not religious
  - I'm exploring both traditions

### 5. Gender

- Question: "How do you identify?"
- Helper text: optional, helps personalise some practice recommendations
- CTA: "Continue"
- Options:
  - Male
  - Female
  - Prefer not to say

### 6. Age Range

- Question: "What's your age range?"
- Helper text: optional, used to adjust depth and tone of content
- CTA: "Continue"
- Options:
  - Under 18
  - 18-24
  - 25-34
  - 35-44
  - 45-59
  - 60+

### 7. Goals

- Question: "What brings you here today?"
- Helper text: choose up to 2; the personalised plan will be built around these
- CTA: "Continue"
- Options:
  - Find inner peace and calm
  - Understand sacred texts
  - Build a daily spiritual practice
  - Find my spiritual path
  - Reconnect with my roots

### 8. Why Dharma Helps

- Placement: directly after Goals
- Headline: "One clear ritual beats starting from scratch"
- Body: explain that Dharma removes daily guesswork by packaging verse, meditation, mantra, and reflection into one calm plan
- Visual: side-by-side comparison between "On your own" and "With Dharma"
- Supporting points:
  - Daily verse
  - AI mentor
  - Personal rhythm built from goals and available time
- CTA: "Continue"

### 8. Practice Preferences

- Question: "Which practices call to you?"
- Helper text: your daily dharmic task will include these; select all that resonate
- CTA: "Continue"
- Options:
  - Breathwork
  - Guided meditation
  - Chanting / mantras
  - Scripture reading
  - Journaling / reflection

### 9. Time Available Daily

- Question: "How much time can you give to your practice each day?"
- Helper text: "Be realistic. 5 minutes done daily is more powerful than an hour done once a week."
- CTA: "Build my plan"
- Options:
  - 5 minutes
  - 10-15 minutes
  - 20-30 minutes
  - 30+ minutes

### 10. What Dharma Does

Three swipeable panels.

#### Panel 1

- Headline: "Your daily verse, delivered at dawn."
- Body: a new verse from the Bhagavad Gita, Dhammapada, or Tao Te Ching every morning, explained in plain language by your AI mentor

#### Panel 2

- Headline: "Ask anything. Get wisdom rooted in the Vedas."
- Body: your AI spiritual mentor answers questions about life, purpose, and practice with guidance shaped by sacred texts

#### Panel 3

- Headline: "Your daily dharmic task - always personalised."
- Body: Dharma tells the user exactly what to do each morning, aligned with the Hindu and Buddhist calendar
- Example: "Today is Ekadasi. Fast until sunset. Chant: Om Namo Bhagavate Vasudevaya. 7 min pranayama."

### 11. Social Proof

- Social proof / reassurance screen
- CTA: "Continue"

### 13. Notifications

- Headline: "Dharma keeps you consistent through routine notifications"
- Body: explain that gentle reminders help the user return for daily verse, meditation, mantra, and reflection
- Visual: stylised iOS-like permission card with "Don't Allow" and "Allow"
- Primary CTA: "Allow Notifications"
- Behavior: tapping the CTA should trigger the iOS notification permission prompt, then continue onboarding

### 14. Generating Your Plan

- Short loading phrases only
- Current timing target: 6 seconds total
- Completion text: "Your Dharma plan is ready."
- Fun fact: "The Bhagavad Gita contains 700 verses spoken over a single day on the battlefield of Kurukshetra."

### 15. Premium Value Proposition

- Heading: "Premium - what you unlock"
- Value points:
  - Full personalised daily dharmic task
  - Hindu and Buddhist calendar guidance including Ekadasi, festivals, and deity days
  - Unlimited AI spiritual mentor
  - All guided meditations and breathwork sessions
  - Full verse library with 700+ Gita, Dhammapada, and Upanishad entries
  - Progress tracking and streaks
- Primary CTA: "Let's go"

## Implementation Notes

- The onboarding UI should follow the app theme in `dharma/Theme.swift`
- The final premium screen is implemented in `Views/Onboarding/WelcomeView.swift`
- The onboarding flow should hand off to the existing Superwall pre-login gate rather than bypassing it
- Keep onboarding copy concise on the loading screen and premium screen