# Blockradar Pulse

A minimal Flutter mobile app for monitoring Blockradar wallet infrastructure. This MVP developer tool allows Blockradar users to view wallet summaries, monitor real-time transactions, receive push notifications, and check API/webhook status.

## Features

- **Dashboard**: View wallet summaries with token balances and chain distribution
- **Transaction Feed**: Real-time transaction monitoring with filtering capabilities
- **Settings**: API key management, notification preferences, and status monitoring
- **Push Notifications**: Get notified about new transactions and failed sweeps
- **Modern UI**: Clean, professional design inspired by Stripe and Linear

## Architecture

- **State Management**: Riverpod for reactive state management
- **HTTP Client**: Dio with Retrofit for API communication
- **Secure Storage**: Flutter Secure Storage for API key management
- **Notifications**: Firebase Cloud Messaging + Local Notifications
- **UI**: Material Design 3 with custom theming

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # App-wide constants and colors
│   ├── navigation/
│   │   └── main_navigation.dart        # Bottom navigation wrapper
│   ├── services/
│   │   ├── http_service.dart           # HTTP client with interceptors
│   │   ├── notification_service.dart   # Push and local notifications
│   │   └── secure_storage_service.dart # Secure API key storage
│   └── theme/
│       └── app_theme.dart              # Material Design 3 theme
├── features/
│   ├── api_status/
│   │   ├── models/
│   │   │   ├── api_status_model.dart   # API status data models
│   │   │   └── api_status_model.g.dart # Generated JSON serialization
│   │   └── services/
│   │       └── api_status_service.dart # API status monitoring
│   ├── dashboard/
│   │   └── screens/
│   │       └── dashboard_screen.dart   # Wallet summary dashboard
│   ├── settings/
│   │   └── screens/
│   │       └── settings_screen.dart    # Settings and configuration
│   ├── transactions/
│   │   ├── models/
│   │   │   ├── transaction_model.dart  # Transaction data models
│   │   │   └── transaction_model.g.dart # Generated JSON serialization
│   │   ├── screens/
│   │   │   └── transaction_feed_screen.dart # Real-time transaction feed
│   │   └── services/
│   │       └── transaction_service.dart # Transaction API calls
│   └── wallet/
│       ├── models/
│       │   ├── wallet_model.dart       # Wallet data models
│       │   └── wallet_model.g.dart     # Generated JSON serialization
│       └── services/
│           └── wallet_service.dart     # Wallet API calls
└── main.dart                           # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (^3.8.1)
- Dart SDK
- iOS Simulator / Android Emulator or physical device

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Setup (Optional)

For production push notifications:

1. Create a Firebase project
2. Add your iOS/Android apps to the project
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the appropriate directories
5. Run `flutterfire configure` to generate `firebase_options.dart`

## Configuration

### API Key Setup

1. Open the app and navigate to Settings
2. Enter your Blockradar API key in the "API Configuration" section
3. Tap "Save API Key" to store it securely

### Mock Data

The app includes comprehensive mock data for development and testing:

- **Wallets**: Sample wallets across multiple blockchains
- **Transactions**: Real-time transaction feed simulation
- **API Status**: Mock service health monitoring
- **Webhooks**: Sample webhook event history

## API Integration

The app is designed to integrate with Blockradar APIs:

- **Base URL**: `https://api.blockradar.co/v1`
- **Authentication**: Bearer token in Authorization header
- **Endpoints**:
  - `GET /wallets` - List all wallets
  - `GET /wallets/summary` - Wallet summary statistics
  - `GET /transactions` - Transaction history
  - `GET /status` - API health status
  - `GET /webhooks/status` - Webhook monitoring

## Development

### Code Generation

When modifying models, regenerate code:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Adding New Features

1. Create feature folder under `lib/features/`
2. Add models with JSON serialization
3. Implement service classes with mock data
4. Create screens with proper error handling
5. Update navigation if needed

## Dependencies

### Core
- `flutter_riverpod`: State management
- `dio`: HTTP client
- `retrofit`: Type-safe API client
- `flutter_secure_storage`: Secure storage

### UI
- `google_fonts`: Typography
- `flutter_svg`: SVG support
- `intl`: Internationalization
- `timeago`: Relative time formatting

### Notifications
- `firebase_core`: Firebase initialization
- `firebase_messaging`: Push notifications
- `flutter_local_notifications`: Local notifications

### Development
- `build_runner`: Code generation
- `json_serializable`: JSON serialization
- `retrofit_generator`: API client generation
- `riverpod_generator`: Provider generation
