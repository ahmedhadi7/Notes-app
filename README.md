# 📝 Notes App — Flutter & Firebase

A full-featured **Notes mobile application** built with Flutter and Firebase. Users can register, log in, and manage personal notes with image attachments — all synced in real-time to the cloud.

---

## 📱 Screenshots

> _Coming soon_

---

## ✨ Features

- 🔐 **Authentication** — Register & Login with Email/Password via Firebase Auth
- 📝 **Create Notes** — Add notes with a title, content, and an image
- 🖼️ **Image Upload** — Pick images from Gallery or Camera, uploaded to Firebase Storage
- ✏️ **Edit Notes** — Update title, content, or replace the image
- 🗑️ **Delete Notes** — Swipe to delete; removes both Firestore document and Storage image
- 👁️ **View Notes** — Full detail screen for each note
- ⚡ **Real-time Sync** — Notes update instantly using Firestore Streams
- 🔔 **Push Notifications** — Firebase Cloud Messaging (FCM) support
- 🔒 **Per-user Data** — Each user only sees their own notes (filtered by UID)

---

## 🛠️ Tech Stack

| Technology | Usage |
|------------|-------|
| Flutter | UI Framework |
| Dart | Programming Language |
| Firebase Auth | User Authentication |
| Cloud Firestore | Real-time Database |
| Firebase Storage | Image Storage |
| Firebase Messaging | Push Notifications (FCM) |
| ImagePicker | Camera & Gallery Access |

---

## 🗄️ Firebase Structure

```
Firebase
│
├── 🔐 Authentication
│   └── Email & Password
│
├── 📁 Firestore Database
│   ├── users (collection)
│   │   └── {docId}
│   │       ├── username: String
│   │       └── email: String
│   │
│   └── notes (collection)
│       └── {docId}
│           ├── title: String
│           ├── note: String
│           ├── imageurl: String   ← Firebase Storage download URL
│           └── userid: String     ← Owner's UID
│
└── 📦 Firebase Storage
    └── images/
        └── {randomNumber + filename}
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point + routing + FCM background handler
├── login.dart                   # Login screen
├── signup.dart                  # Register screen
├── homepage.dart                # Home screen — notes list with swipe-to-delete
├── component/
│   └── alert.dart               # Shared Loading & Error dialog helpers
└── coud/
    ├── addnotes.dart            # Add new note screen
    ├── editnodes.dart           # Edit existing note screen
    └── viewnotes.dart           # View note detail screen
```

---

## 🔀 App Navigation Flow

```
Launch
  ├── User logged in  → Homepage
  └── Not logged in   → Login
                           └── Sign Up ←→ Login
                                  └── Homepage
                                        ├── View Note
                                        ├── Edit Note
                                        └── Add Note (FAB)
```

---

## 🔑 Key Implementation Details

### Auth State Check on Launch
```dart
var user = FirebaseAuth.instance.currentUser;
islogin = user != null;
// Routes to Homepage if logged in, Login if not
```

### Notes filtered by current user
```dart
notesref.where("userid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
```

### Image Upload Flow
```dart
// 1. Pick image
var picked = await ImagePicker().pickImage(source: ImageSource.gallery);
// 2. Generate unique filename
var nameimage = "${Random().nextInt(100000)}${basename(picked.path)}";
// 3. Upload bytes to Storage
await ref.putData(imageBytes, SettableMetadata(contentType: "image/jpeg"));
// 4. Get download URL
imageurl = await ref.getDownloadURL();
```

### Swipe-to-Delete (Dismissible)
```dart
Dismissible(
  key: UniqueKey(),
  onDismissed: (_) async {
    await notesref.doc(docId).delete();          // Delete from Firestore
    await FirebaseStorage.instance               // Delete image from Storage
        .refFromURL(imageurl).delete();
  },
)
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK
- Firebase project with Auth, Firestore & Storage enabled

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/ahmedhadi7/notes-app-flutter.git
cd notes-app-flutter
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Firebase**
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

**4. Run the app**
```bash
flutter run
```

---

## 📦 Dependencies

```yaml
dependencies:
  firebase_core:
  firebase_auth:
  cloud_firestore:
  firebase_storage:
  firebase_messaging:
  image_picker:
  path:
```

---

## 👨‍💻 Author

Ahmed Hadi
- GitHub: [@ahmedhadi7](https://github.com/ahmedhadi7)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).