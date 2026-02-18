# Evntly 🚀

Built this because I kept losing event links in college WhatsApp groups and it was driving me crazy lol. Evntly is a premium campus event discovery app where students can find, save, and post events easily.

## Features
- **Student App**: Personalized feed, explore all campus events, register in one tap.
- **Admin Panel**: Separate dashboard to review submissions, manage users, and pin featured events.
- **Vibe**: Dark mode by default, super smooth animations, and iOS-style feels.

## Tech Stack
- **Flutter**: For that buttery smooth UI.
- **Firebase**: Auth, Firestore (real-time!), and Storage for posters.
- **Riverpod**: State management because it's better than Provider.
- **GoRouter**: Handling all the role-based routing.

## Screenshots
> TODO: Add screenshots here after deployment!

## Setup Steps
1. Clone this repo.
2. Run `flutter pub get`.
3. Create a Firebase project and add your `google-services.json` and `GoogleService-Info.plist`.
4. Run `flutter run`.

## Known Issues / TODO
- [ ] Push notifications aren't fully hooked up yet.
- [ ] Need to add image cropping for posters.
- [ ] Registration link should open in-app browser.
- [ ] The card overflow on small screens is still slightly buggy.

## What I Learned
- Animations in Flutter are actually super fun with `flutter_animate`.
- Firestore security rules are a pain but necessary.
- Hardcoding the admin login was the easiest way for the demo lol.

## Suggested Commits
- "init project"
- "added home screen basic layout"
- "fixed that annoying card overflow bug"
- "event detail screen done finally"
- "admin panel working!!"
- "cleanup before push"
