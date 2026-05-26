# Notes App Flutter Firebase

A Flutter notes application connected to Firebase. The app supports user authentication and lets each signed-in user create, view, edit, and manage their own notes.

## Features

- Email and password authentication with Firebase Auth
- User-specific notes stored in Cloud Firestore
- Add, view, edit, and delete notes
- Firebase initialization with FlutterFire
- Firebase Cloud Messaging background handler
- Cross-platform Flutter project structure

## Tech Stack

- Flutter
- Dart
- Firebase Auth
- Cloud Firestore
- Firebase Core
- Firebase Messaging
- Firebase Storage

## Project Structure

```text
lib/
  main.dart
  login.dart
  signup.dart
  homepage.dart
  coud/
    addnotes.dart
    editnodes.dart
    viewnotes.dart
  component/
    alert.dart
```

## Getting Started

1. Install Flutter and set up your development environment.
2. Clone the repository.
3. Install dependencies:

```bash
flutter pub get
```

4. Configure Firebase for your own project:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

5. Add the required Firebase platform files, such as `google-services.json` for Android and `GoogleService-Info.plist` for iOS.
6. Run the app:

```bash
flutter run
```

## Firebase Files

Firebase configuration files are ignored by Git to avoid committing project-specific secrets and environment files. Generate them locally using FlutterFire before running the app.

## Repository About

Flutter Firebase notes app with authentication and user-specific Firestore notes.
