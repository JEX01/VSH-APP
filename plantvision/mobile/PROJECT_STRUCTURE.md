# PLANTVISION Mobile - Project Structure

## Directory Overview

```
plantvision/mobile/
├── android/                           # Android-specific configuration
│   ├── app/
│   │   ├── src/main/
│   │   │   └── AndroidManifest.xml   # Permissions & app configuration
│   │   └── build.gradle              # Android build configuration
│   └── build.gradle                  # Project-level Gradle config
├── ios/                              # iOS-specific configuration
│   └── Runner/
│       └── Info.plist                # iOS permissions & settings
├── lib/                              # Main application code
│   ├── main.dart                     # Application entry point
│   ├── core/                         # Shared code across features
│   │   ├── config/
│   │   │   └── app_config.dart       # Configuration constants
│   │   ├── database/
│   │   │   └── database_helper.dart  # SQLite database setup
│   │   ├── services/
│   │   │   ├── notification_service.dart     # Push notifications
│   │   │   └── background_sync_service.dart  # Background upload
│   │   ├── theme/
│   │   │   └── app_theme.dart        # Material Design 3 theme
│   │   └── utils/
│   │       ├── logger.dart           # Logging utility
│   │       ├── image_utils.dart      # Image compression/thumbnail
│   │       └── validators.dart       # Input validation
│   └── features/                     # Feature modules (Clean Architecture)
│       ├── auth/                     # Authentication module
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── auth_local_datasource.dart
│       │   │   │   └── auth_remote_datasource.dart
│       │   │   ├── models/
│       │   │   │   ├── login_request.dart
│       │   │   │   ├── login_response.dart
│       │   │   │   └── user_model.dart
│       │   │   └── repositories/
│       │   │       └── auth_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── user.dart     # User entity
│       │   │   ├── repositories/
│       │   │   │   └── auth_repository.dart
│       │   │   └── usecases/
│       │   │       ├── login_usecase.dart
│       │   │       ├── logout_usecase.dart
│       │   │       └── get_current_user_usecase.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── auth_provider.dart
│       │       ├── screens/
│       │       │   ├── login_screen.dart
│       │       │   └── biometric_auth_screen.dart
│       │       └── widgets/
│       │           ├── login_form.dart
│       │           └── auth_button.dart
│       ├── camera/                   # Photo capture module
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── camera_datasource.dart
│       │   │   │   └── location_datasource.dart
│       │   │   ├── models/
│       │   │   │   └── photo_model.dart
│       │   │   └── repositories/
│       │   │       └── camera_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── photo.dart    # Photo entity with metadata
│       │   │   ├── repositories/
│       │   │   │   └── camera_repository.dart
│       │   │   └── usecases/
│       │   │       ├── capture_photo_usecase.dart
│       │   │       ├── save_photo_usecase.dart
│       │   │       └── scan_qr_code_usecase.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── camera_provider.dart
│       │       ├── screens/
│       │       │   ├── camera_screen.dart
│       │       │   ├── photo_preview_screen.dart
│       │       │   └── qr_scanner_screen.dart
│       │       └── widgets/
│       │           ├── camera_preview.dart
│       │           ├── metadata_form.dart
│       │           └── equipment_selector.dart
│       ├── home/                     # Home dashboard
│       │   └── presentation/
│       │       ├── screens/
│       │       │   └── home_screen.dart
│       │       └── widgets/
│       │           ├── stats_card.dart
│       │           ├── quick_actions.dart
│       │           └── sync_status_indicator.dart
│       ├── photos/                   # Photo gallery & management
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── photo_local_datasource.dart
│       │   │   │   └── photo_remote_datasource.dart
│       │   │   ├── models/
│       │   │   │   └── photo_list_model.dart
│       │   │   └── repositories/
│       │   │       └── photo_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── repositories/
│       │   │   │   └── photo_repository.dart
│       │   │   └── usecases/
│       │   │       ├── get_photos_usecase.dart
│       │   │       ├── search_photos_usecase.dart
│       │   │       └── delete_photo_usecase.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── photos_provider.dart
│       │       ├── screens/
│       │       │   ├── photo_list_screen.dart
│       │       │   ├── photo_detail_screen.dart
│       │       │   └── photo_filter_screen.dart
│       │       └── widgets/
│       │           ├── photo_grid.dart
│       │           ├── photo_card.dart
│       │           └── filter_chip_bar.dart
│       ├── sync/                     # Offline sync module
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   └── sync_local_datasource.dart
│       │   │   ├── models/
│       │   │   │   └── sync_queue_model.dart
│       │   │   └── repositories/
│       │   │       └── sync_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── sync_item.dart
│       │   │   ├── repositories/
│       │   │   │   └── sync_repository.dart
│       │   │   └── usecases/
│       │   │       ├── sync_photos_usecase.dart
│       │   │       ├── retry_failed_uploads_usecase.dart
│       │   │       └── get_sync_status_usecase.dart
│       │   └── presentation/
│       │       └── providers/
│       │           └── sync_provider.dart
│       ├── settings/                 # App settings
│       │   └── presentation/
│       │       ├── screens/
│       │       │   └── settings_screen.dart
│       │       └── widgets/
│       │           └── setting_tile.dart
│       └── splash/                   # Splash screen
│           └── presentation/
│               └── screens/
│                   └── splash_screen.dart
├── test/                             # Unit & widget tests
│   ├── core/
│   ├── features/
│   └── helpers/
├── integration_test/                 # Integration tests
│   ├── app_test.dart
│   └── camera_flow_test.dart
├── assets/                           # Static assets
│   ├── images/
│   │   └── logo.png
│   └── fonts/
│       ├── Roboto-Regular.ttf
│       └── Roboto-Bold.ttf
├── pubspec.yaml                      # Flutter dependencies
├── analysis_options.yaml             # Dart linting rules
├── .gitignore                        # Git ignore rules
├── README.md                         # Project documentation
└── PROJECT_STRUCTURE.md              # This file

```

## Key Files

### Entry Point
- **lib/main.dart**: Application initialization and root widget

### Core Configuration
- **lib/core/config/app_config.dart**: All app constants and feature flags
- **lib/core/database/database_helper.dart**: SQLite schema and migrations
- **lib/core/theme/app_theme.dart**: Material Design 3 theme configuration

### Core Services
- **lib/core/services/notification_service.dart**: Push notification handling
- **lib/core/services/background_sync_service.dart**: Background upload worker

### Domain Entities
- **lib/features/auth/domain/entities/user.dart**: User model
- **lib/features/camera/domain/entities/photo.dart**: Photo with metadata

### Android Configuration
- **android/app/src/main/AndroidManifest.xml**: Permissions and app config
- **android/app/build.gradle**: Build settings, SDK versions, ProGuard

### iOS Configuration
- **ios/Runner/Info.plist**: Permissions and app settings

## Architecture Patterns

### Clean Architecture
Each feature follows a 3-layer architecture:

1. **Data Layer**: Data sources (local SQLite, remote API), models, repositories
2. **Domain Layer**: Business entities, repository interfaces, use cases
3. **Presentation Layer**: UI screens, widgets, state providers (Riverpod)

### State Management
- **Riverpod**: Provider-based state management
- **Providers**: Located in `presentation/providers/` of each feature
- **State**: Immutable state objects with copyWith methods

### Dependency Injection
- Providers handle dependency injection
- Services use singleton pattern
- Repositories injected via Riverpod

## Data Flow

### Photo Capture Flow
1. User opens camera → `CameraScreen`
2. Captures photo → `CameraProvider`
3. Fill metadata → `MetadataForm`
4. Save locally → `CameraDatasource` → SQLite
5. Queue for sync → `SyncQueueDatasource`
6. Background worker uploads → `BackgroundSyncService`
7. Update status → `PhotoRepository`

### Authentication Flow
1. User enters credentials → `LoginScreen`
2. Submit → `AuthProvider` → `LoginUsecase`
3. API call → `AuthRemoteDatasource`
4. Store token → `AuthLocalDatasource` → SecureStorage
5. Update state → `AuthProvider`
6. Navigate to home → `HomeScreen`

### Offline Sync Flow
1. Network restored → `ConnectivityService`
2. Trigger sync → `BackgroundSyncService`
3. Fetch queue → `SyncLocalDatasource`
4. Upload photos → `PhotoRemoteDatasource`
5. Update status → `PhotoRepository`
6. Notify user → `NotificationService`

## Testing Strategy

### Unit Tests (`test/`)
- Use cases
- Repositories
- Utilities
- Providers (state logic)

### Widget Tests (`test/`)
- Individual widgets
- Screen layouts
- User interactions

### Integration Tests (`integration_test/`)
- Complete user flows
- Camera capture end-to-end
- Login to photo upload
- Offline mode testing

## Build Variants

### Debug
- Debug logging enabled
- API mocking available
- Source maps included

### Release
- ProGuard enabled (Android)
- Code obfuscation
- Optimized assets
- Crashlytics enabled

## Next Steps for Development

1. **Complete Use Cases**: Implement business logic in domain layer
2. **API Integration**: Implement remote data sources with Retrofit
3. **Offline Queue**: Complete sync logic with retry mechanism
4. **UI Polish**: Implement all screens and widgets
5. **Testing**: Write comprehensive tests
6. **Performance**: Optimize image compression and upload
7. **Security**: Implement certificate pinning
8. **CI/CD**: Set up automated builds and tests

## Conventions

### Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `camelCase` with `const`
- Private members: `_leadingUnderscore`

### Imports
1. Dart SDK imports
2. Flutter imports
3. Package imports
4. Relative imports

### Code Organization
- One class per file
- Group related files in folders
- Use barrel files (`index.dart`) for exports

---

**Last Updated**: 2025-10-02  
**Architecture**: Clean Architecture + Riverpod  
**Target Platforms**: Android (API 24+), iOS (12+)
