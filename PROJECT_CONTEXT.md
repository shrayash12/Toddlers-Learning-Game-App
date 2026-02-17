# Baby Learning Games - Project Context

## Overview
A Flutter-based educational game app for toddlers and preschoolers with 20 interactive learning games, parental controls, and in-app purchase monetization via Google Play Billing.

- **Package Name (Android):** `com.babylearninggames.app`
- **Bundle ID (iOS):** `com.example.babygamesdemo`
- **Version:** 1.2.5+8
- **Flutter SDK:** ^3.8.1
- **Material Design 3:** Enabled

---

## Project Structure

```
babygamesdemo/
├── lib/
│   ├── main.dart                        # Entry point, theme, timer lock wrapper
│   ├── screens/                         # 20 game screens + premium screen
│   │   ├── home_screen.dart             # Main menu (1,086 lines)
│   │   ├── abc_screen.dart              # Alphabet learning (A-Z) with TTS
│   │   ├── numbers_screen.dart          # Counting 1-10 with TTS
│   │   ├── colors_shapes_screen.dart    # 8 colors & shapes with custom painters
│   │   ├── animals_screen.dart          # 12 animals with real sound effects
│   │   ├── matching_game_screen.dart    # Quiz matching game
│   │   ├── memory_game_screen.dart      # Card matching game (premium)
│   │   ├── puzzle_game_screen.dart      # Drag-and-drop puzzles (premium, 1,798 lines)
│   │   ├── spelling_game_screen.dart    # Spelling practice (premium)
│   │   ├── math_game_screen.dart        # Addition/subtraction (premium)
│   │   ├── phonics_game_screen.dart     # Letter sounds (premium)
│   │   ├── organizing_game_screen.dart  # Sorting/categorizing (premium)
│   │   ├── maze_game_screen.dart        # Maze navigation (premium)
│   │   ├── hide_seek_game_screen.dart   # Find hidden animals (premium)
│   │   ├── find_difference_game_screen.dart  # Spot differences (premium)
│   │   ├── connect_dots_game_screen.dart     # Dot-to-dot drawing (premium)
│   │   ├── draw_lines_game_screen.dart       # Line tracing (premium)
│   │   ├── coloring_game_screen.dart         # Free-form coloring (premium)
│   │   ├── potty_training_game_screen.dart   # Life skills (premium)
│   │   └── premium_screen.dart          # Purchase UI with parental gate
│   ├── services/
│   │   ├── billing_service.dart         # Google Play Billing (in_app_purchase)
│   │   ├── premium_service.dart         # Legacy premium status wrapper
│   │   ├── razorpay_service.dart        # Razorpay payment (alternate, unused)
│   │   ├── screen_lock_service.dart     # Parental screen lock
│   │   └── play_timer_service.dart      # Play session timer (10-120 min)
│   ├── widgets/
│   │   ├── screen_lock_wrapper.dart     # Back button lock + parental gate
│   │   └── play_timer_widgets.dart      # Timer display, settings, expired overlay
│   ├── utils/
│   │   └── slide_route.dart             # Custom slide-left page transition
│   └── models/                          # (empty)
├── assets/
│   ├── sounds/                          # 14 animal sound MP3 files
│   ├── images/                          # Game images
│   ├── app_icon.png                     # App icon source
│   └── app_icon_foreground.png          # Android adaptive icon
├── android/
│   └── app/
│       ├── build.gradle.kts             # Kotlin DSL, signing via key.properties
│       └── src/main/AndroidManifest.xml # INTERNET + BILLING permissions
├── ios/
│   └── Runner/Info.plist                # iOS config, all orientations
├── pubspec.yaml                         # Dependencies & assets
└── test/
```

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| audioplayers | ^5.2.1 | Animal sound playback |
| confetti | ^0.7.0 | Celebration animations |
| flutter_tts | ^4.2.0 | Text-to-speech for letters, numbers, phonics |
| shared_preferences | ^2.2.2 | Local storage for premium status & settings |
| in_app_purchase | ^3.2.0 | Google Play Billing integration |
| cupertino_icons | ^1.0.8 | iOS-style icons |
| flutter_launcher_icons | ^0.14.3 | App icon generation (dev) |

---

## Architecture

### State Management
- **ChangeNotifier** pattern for services (BillingService, PlayTimerService)
- **Singleton pattern** for all services (global state)
- **SharedPreferences** for persistence

### App Initialization (main.dart)
```
1. PremiumService.initialize()
2. BillingService.initialize()
3. ScreenLockService.initialize()
4. PlayTimerService.initialize()
5. runApp → AppWithTimerLock → ScreenLockWrapper → HomeScreen
```

### Page Transitions
- Custom `SlidePageTransitionsBuilder` — slides right on forward, left on back (300ms, easeInOut)

---

## Monetization

### In-App Purchase (Primary)
- **Product ID:** `premium_bundle`
- **Type:** Non-consumable (one-time purchase, lifetime access)
- **Price:** Fetched dynamically from store (country-localized)
- **Storage Key:** `billing_premium_unlocked`
- **Flow:** Unlock button → Parental gate (math problem) → Google Play purchase

### Premium Status Checks
- `BillingService.isPremium` (primary)
- `PremiumService.isPremium` (legacy fallback)
- HomeScreen checks both services

### Free vs Premium Games
- **Free (6):** ABC, Numbers, Colors & Shapes, Animals, Matching, Memory
- **Premium (14):** Spelling, Math, Phonics, Organizing, Puzzles, Maze, Hide & Seek, Find Differences, Connect Dots, Draw Lines, Coloring, Potty Training

---

## Parental Controls

### Screen Lock
- Prevents children from exiting the app via back button
- Toggle in HomeScreen with parental gate to disable
- Storage key: `screen_lock_enabled`

### Play Timer
- Configurable time limit (10-120 minutes, default 30)
- Full-screen overlay when time expires
- Parental gate required to unlock or extend time
- Storage keys: `play_time_limit_minutes`, `play_session_start`, `play_timer_locked`, `play_timer_enabled`

### Parental Gate
- Random addition problem (two numbers: 10-24 + 5-14)
- Used before: purchase, exit (when locked), timer settings, timer unlock

---

## Key SharedPreferences Keys

| Key | Type | Purpose |
|-----|------|---------|
| `billing_premium_unlocked` | bool | Premium purchased via Google Play |
| `premium_unlocked` | bool | Legacy premium status |
| `screen_lock_enabled` | bool | Screen lock active |
| `play_timer_enabled` | bool | Play timer active |
| `play_time_limit_minutes` | int | Timer duration (default 30) |
| `play_session_start` | string | Session start timestamp |
| `play_timer_locked` | bool | Timer expired, app locked |

---

## Codebase Stats

- **Total Dart files:** ~31
- **Total lines of Dart:** ~13,100
- **Largest screen:** puzzle_game_screen.dart (1,798 lines)
- **Largest UI file:** home_screen.dart (1,086 lines)
