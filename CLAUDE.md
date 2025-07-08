# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Build & Run
- `flutter run` - Run the app on connected device/emulator
- `flutter run --debug` - Run in debug mode (default)
- `flutter run --release` - Run in release mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app (requires macOS)

### Development Tools
- `flutter analyze` - Run static analysis on the code
- `flutter test` - Run unit tests
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies
- `flutter doctor` - Check Flutter environment setup

### Code Quality
- `flutter analyze` - Static analysis with rules from analysis_options.yaml
- Code follows Flutter linting rules from `package:flutter_lints/flutter.yaml`

## Architecture Overview

### State Management
- **Primary**: Flutter Riverpod for state management
- **Auth State**: Managed by `AuthNotifier` in `lib/provider/auth_provider.dart`
- **Navigation**: Go Router with authentication-aware routing

### Authentication Flow
- Firebase Auth integration with Google Sign-In support
- Email/password authentication
- User data stored in both Firestore and local storage
- Backend API sync via Dio HTTP client
- Authentication state managed through Riverpod providers

### Routing Architecture
- **Router**: `go_router` with `lib/core/router/app_router.dart`
- **Route Guards**: Authentication-based redirects
- **Navigation Flow**: Splash → Onboarding (first-time) → Auth screens → Home
- **Protected Routes**: Home, Profile, Deals, Stores, Settings
- **Public Routes**: Auth screens, Onboarding, Splash

### Key Services
- **AuthService**: Firebase Auth operations, user management
- **StorageService**: Local storage with shared_preferences
- **DioClient**: HTTP client for backend API communication

### Project Structure
```
lib/
├── core/
│   ├── router/        # Go Router configuration
│   └── theme/         # App theming
├── models/            # Data models (UserModel, AuthState)
├── provider/          # Riverpod providers
├── services/          # Business logic services
└── ui/
    └── Auths/         # Authentication screens
```

### Authentication States
- **Initial**: App startup, checking auth status
- **Loading**: Auth operations in progress
- **Authenticated**: User logged in with UserModel
- **Unauthenticated**: User logged out, redirect to login/onboarding
- **Error**: Auth error with error message

### UI Screens Structure
- **SplashScreen**: Initial loading screen
- **OnboardingScreen**: First-time user introduction
- **LoginScreen**: Main login with Google/email options
- **EmailLoginScreen**: Email/password login form
- **RegisterScreen**: User registration form
- **ForgotPasswordScreen**: Password reset
- **HomeScreen**: Main app screen (authenticated)

### Database Integration
- **Firestore**: User profile storage
- **Local Storage**: User preferences, auth tokens
- **Backend API**: User data synchronization

### Environment Configuration
- Uses `flutter_dotenv` for environment variables
- Environment file: `.env` (configure API endpoints, keys)
- Firebase configuration in `firebase_options.dart`

## Development Notes

### Firebase Setup
- Firebase Core initialized in `main.dart`
- Auth, Firestore, and Google Services configured
- Platform-specific Google Services files included

### Theme System
- Custom theme in `lib/core/theme/app_theme.dart`
- Material 3 design system
- Support for light/dark themes
- Custom colors: Primary (#6C63FF), Secondary (#4CAF50), Accent (#FF6B35)

### Error Handling
- Comprehensive Firebase Auth error handling
- User-friendly error messages
- Graceful fallbacks for service failures

### Code Patterns
- Riverpod for state management
- Async/await pattern for Firebase operations
- Proper error handling with try-catch blocks
- Singleton pattern for services
- Extension methods for context utilities

### Testing
- Unit tests in `test/` directory
- Widget tests configured
- Use `flutter test` to run all tests