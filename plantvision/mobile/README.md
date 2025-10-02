# PLANTVISION Mobile App

Industrial Photo Repository Mobile Application for equipment inspection and documentation.

## Overview

PLANTVISION is a production-ready mobile application designed for industrial environments to capture, manage, and sync photos of equipment with comprehensive metadata. The app supports offline-first operation, secure authentication, and seamless cloud synchronization.

## Features

### Core Features
- **Camera Capture**: High-quality photo capture with real-time preview
- **Metadata Collection**: Equipment ID, location, timestamp, severity, notes, tags
- **QR/Barcode Scanner**: Quick equipment identification
- **GPS Location**: Automatic location tagging with geocoding
- **Offline Mode**: Full functionality without network connectivity
- **Background Sync**: Automatic upload when connectivity is restored
- **Secure Authentication**: JWT-based auth with biometric support
- **Multi-factor Authentication**: Enhanced security options
- **Role-based Access Control**: Uploader, Viewer, Admin roles
- **Photo Gallery**: Browse, search, and filter photos
- **Audit Trail**: Complete activity logging

### Technical Features
- **Offline-First Architecture**: SQLite local database with encrypted storage
- **Background Services**: WorkManager for reliable background sync
- **Retry Logic**: Exponential backoff for failed uploads
- **Conflict Resolution**: Server-wins strategy for metadata conflicts
- **Push Notifications**: Upload status and sync alerts
- **Material Design 3**: Modern, responsive UI
- **State Management**: Riverpod for predictable state handling

## Architecture

### Clean Architecture Layers
```
lib/
├── core/                  # Shared utilities and configuration
│   ├── config/           # App configuration constants
│   ├── database/         # SQLite database helper
│   ├── services/         # Background services, notifications
│   ├── theme/            # Material Design 3 theme
│   └── utils/            # Utility functions
├── features/             # Feature modules
│   ├── auth/             # Authentication
│   ├── camera/           # Photo capture
│   ├── home/             # Home dashboard
│   ├── photos/           # Photo gallery & management
│   ├── sync/             # Offline sync
│   ├── settings/         # App settings
│   └── splash/           # Splash screen
```

### Feature Module Structure (Clean Architecture)
```
feature/
├── data/
│   ├── datasources/      # Local & remote data sources
│   ├── models/           # Data models & JSON serialization
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business logic
└── presentation/
    ├── providers/        # Riverpod state providers
    ├── screens/          # UI screens
    └── widgets/          # Reusable UI components
```

## Technology Stack

### Core Framework
- **Flutter**: 3.10+
- **Dart**: 3.0+

### State Management
- **Riverpod**: 2.4+ (Provider pattern)
- **Riverpod Annotation**: Code generation for providers

### Local Storage
- **SQLite (sqflite)**: 2.3+ (Relational database)
- **Flutter Secure Storage**: 9.0+ (Encrypted key-value storage)
- **Path Provider**: File system access

### Networking
- **Dio**: 5.3+ (HTTP client)
- **Retrofit**: 4.0+ (Type-safe REST client)
- **Connectivity Plus**: Network status monitoring

### Media & Camera
- **Camera**: 0.10+ (Camera access)
- **Image Picker**: 1.0+ (Gallery access)
- **Image**: 4.1+ (Image processing)

### Location Services
- **Geolocator**: 10.1+ (GPS location)
- **Geocoding**: 2.1+ (Address lookup)

### Authentication
- **Local Auth**: 2.1+ (Biometric authentication)
- **JWT Decoder**: 2.0+ (Token parsing)

### Background Processing
- **WorkManager**: 0.5+ (Background tasks)
- **Flutter Local Notifications**: 16.1+ (Push notifications)

### Utilities
- **Mobile Scanner**: 3.5+ (QR/Barcode scanning)
- **Permission Handler**: 11.0+ (Runtime permissions)
- **UUID**: 4.1+ (Unique ID generation)
- **Logger**: 2.0+ (Logging)
- **Intl**: 0.18+ (Internationalization)

## Getting Started

### Prerequisites
- Flutter SDK 3.10 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode
- Android SDK (API 24+) / iOS 12+
- Physical device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourorg/plantvision-mobile.git
   cd plantvision-mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure API endpoint**
   Edit `lib/core/config/app_config.dart`:
   ```dart
   static const String baseUrl = 'https://your-api.com';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Build Release

#### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Configuration

### API Configuration
Edit `lib/core/config/app_config.dart`:
- `baseUrl`: Backend API URL
- `apiTimeout`: Request timeout (seconds)
- `syncInterval`: Background sync frequency
- `maxPhotoSizeMB`: Maximum photo file size
- Feature flags for optional functionality

### Android Permissions
Required permissions in `AndroidManifest.xml`:
- Camera access
- Location (fine & coarse)
- Storage (read & write)
- Network state
- Biometric authentication

### iOS Permissions
Required keys in `Info.plist`:
- NSCameraUsageDescription
- NSLocationWhenInUseUsageDescription
- NSPhotoLibraryUsageDescription
- NSFaceIDUsageDescription

## Database Schema

### Tables
- **users**: User accounts and roles
- **photos**: Photo metadata and sync status
- **equipment**: Equipment master data
- **sync_queue**: Upload queue with retry logic
- **app_settings**: App configuration

## Security

### Data Protection
- AES-256 encryption for local storage
- TLS 1.2+ for all network communication
- JWT tokens for API authentication
- Biometric authentication (fingerprint/face)
- Secure session management

### Best Practices
- No plaintext credentials stored
- Token refresh on expiry
- Auto-logout on inactivity
- Encrypted database
- Certificate pinning (production)

## Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widgets/
```

## Performance Optimization

- **Image Compression**: Photos compressed before upload
- **Thumbnail Generation**: 256x256 previews for gallery
- **Lazy Loading**: Paginated photo list
- **Cache Strategy**: Network images cached locally
- **Background Upload**: Batch processing with retry logic
- **Database Indexing**: Optimized queries

## Offline Functionality

### Offline Features
- Full camera capture with metadata
- Local photo gallery
- Equipment lookup from cached data
- Settings management
- Upload queue management

### Sync Behavior
- Auto-sync on network restore
- Manual sync trigger
- Conflict resolution (server wins)
- Retry with exponential backoff
- Progress notifications

## Deployment

### Android
1. Generate keystore
2. Configure `key.properties`
3. Build release APK/Bundle
4. Upload to Play Store

### iOS
1. Configure provisioning profiles
2. Build release archive
3. Upload to App Store Connect
4. Submit for review

## Monitoring & Logging

### Logging Levels
- **DEBUG**: Development logging
- **INFO**: General information
- **WARNING**: Potential issues
- **ERROR**: Error events
- **FATAL**: Critical failures

### Crash Reporting
- Integrate Firebase Crashlytics (recommended)
- Sentry for error tracking
- Custom error logging to backend

## Roadmap

### Upcoming Features
- [ ] AI-powered image diagnostics
- [ ] Offline map view
- [ ] Voice notes
- [ ] Photo annotations
- [ ] PDF report generation
- [ ] Multi-language support
- [ ] Dark mode toggle
- [ ] Advanced filtering
- [ ] Photo comparison tool
- [ ] Equipment history timeline

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

Proprietary - All rights reserved

## Support

For issues, questions, or feature requests:
- Email: support@plantvision.com
- Issue Tracker: https://github.com/yourorg/plantvision-mobile/issues
- Documentation: https://docs.plantvision.com

## Team

- **Project Owner**: Industrial Operations Team
- **Development**: Mobile Development Team
- **Backend**: API Development Team
- **QA**: Quality Assurance Team

---

**Version**: 1.0.0  
**Last Updated**: 2025-10-02  
**Status**: Production Ready
