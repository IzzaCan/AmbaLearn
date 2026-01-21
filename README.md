# AmbaLearn Mobile 📱

AmbaLearn Mobile is a comprehensive learning platform built with Flutter. It provides an interactive learning experience with features like AI-powered chat assistants, course management, and a robust examination system.

## ✨ Key Features

- **🔐 Authentication**: Secure login and registration system with Google Sign-in support.
- **📚 Course Management**: Browse and enroll in various courses with detailed lessons.
- **💬 AI Chat Assistant**: Interactive AI chatbot to help students with their learning queries.
- **📝 Examination System**: Integrated exam module with real-time scoring and result tracking.
- **⚙️ User Settings**: Personalized user profiles and application settings.
- **🎥 Video Integration**: Seamless YouTube video player integration for video-based lessons.

## 🚀 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Networking**: [Dio](https://pub.dev/packages/dio) & [Socket.IO](https://pub.dev/packages/socket_io_client)
- **Local Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Media**: YouTube Player, Camera, Image picker
- **Authentication**: Google Sign-In support

## 🛠️ Installation & Setup

### Prerequisites
- Flutter SDK (latest version recommended)
- Android Studio / VS Code
- Dart SDK

### Steps
1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/ambalearn-mobile.git
   cd ambalearn-mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── config/      # Application configurations
├── l10n/        # Localization files
├── models/      # Data models
├── pages/       # UI Screens (Login, Home, Courses, Chat, etc.)
├── providers/   # State management logic
├── services/    # API and external service integrations
└── widgets/     # Reusable UI components
```

---

*Developed with ❤️ as part of Capstone Project.*
