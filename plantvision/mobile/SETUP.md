# PLANTVISION Mobile - Setup Guide

## Quick Start

This guide will help you set up the PLANTVISION mobile application for development.

## Prerequisites

### Required Software
- **Flutter SDK**: 3.10.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **Git**: Latest version
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA

### For Android Development
- **Android Studio**: Arctic Fox or newer
- **Android SDK**: API 24 (Android 7.0) or higher
- **Java Development Kit (JDK)**: 11 or higher

### For iOS Development (macOS only)
- **Xcode**: 14.0 or higher
- **CocoaPods**: Latest version
- **iOS SDK**: 12.0 or higher

## Installation Steps

### 1. Install Flutter

#### macOS
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### Linux
```bash
# Download and extract Flutter
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.0-stable.tar.xz
tar xf flutter_linux_3.10.0-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### Windows
1. Download Flutter SDK from https://flutter.dev
2. Extract to `C:\src\flutter`
3. Add `C:\src\flutter\bin` to PATH
4. Run `flutter doctor` in command prompt

### 2. Clone the Repository

```bash
cd /workspace/plantvision
# The mobile directory should already exist with project structure
```

### 3. Install Dependencies

```bash
cd /workspace/plantvision/mobile
flutter pub get
```

### 4. Configure API Endpoint

Edit `lib/core/config/app_config.dart`:

```dart
// Development
static const String baseUrl = 'http://localhost:8000';

// Staging
// static const String baseUrl = 'https://staging-api.plantvision.com';

// Production
// static const String baseUrl = 'https://api.plantvision.com';
```

### 5. Generate Code (if using code generation)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. Run the Application

#### On Android Emulator
```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run
```

#### On iOS Simulator (macOS only)
```bash
# Start simulator
open -a Simulator

# Run app
flutter run
```

#### On Physical Device
1. Enable Developer Options and USB Debugging (Android)
2. Trust computer (iOS)
3. Connect device via USB
4. Run `flutter run`

## Development Environment Setup

### Android Studio Setup

1. **Install Android Studio**
   - Download from https://developer.android.com/studio
   - Install Android SDK, Android SDK Platform-Tools
   - Install Android Emulator

2. **Install Flutter Plugin**
   - Open Android Studio
   - Go to Preferences → Plugins
   - Search for "Flutter" and install
   - Restart Android Studio

3. **Create Android Emulator**
   - Open AVD Manager
   - Create Virtual Device
   - Select Pixel 4 or newer
   - Download system image (API 30+)
   - Finish setup

### VS Code Setup

1. **Install VS Code**
   - Download from https://code.visualstudio.com

2. **Install Extensions**
   - Flutter
   - Dart
   - Flutter Riverpod Snippets (optional)
   - Error Lens (optional)

3. **Configure Settings**
   ```json
   {
     "dart.flutterSdkPath": "/path/to/flutter",
     "dart.debugExternalPackageLibraries": true,
     "editor.formatOnSave": true
   }
   ```

## Project Configuration

### Android Configuration

#### Update Package Name (if needed)
1. Edit `android/app/build.gradle`:
   ```gradle
   defaultConfig {
       applicationId "com.yourcompany.plantvision"
   }
   ```

2. Update `AndroidManifest.xml` package attribute

#### Signing Configuration (for release builds)
1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore ~/plantvision-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias plantvision
   ```

2. Create `android/key.properties`:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=plantvision
   storeFile=/path/to/plantvision-key.jks
   ```

3. Update `android/app/build.gradle`:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

### iOS Configuration (macOS only)

#### Update Bundle Identifier
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner → General
3. Update Bundle Identifier: `com.yourcompany.plantvision`

#### Configure Signing
1. Select Runner → Signing & Capabilities
2. Enable Automatically manage signing
3. Select your Team

#### Install CocoaPods Dependencies
```bash
cd ios
pod install
cd ..
```

## Database Setup

The SQLite database will be automatically created on first run. Schema is defined in:
- `lib/core/database/database_helper.dart`

To reset the database during development:
```dart
await DatabaseHelper.instance.clearDatabase();
```

## Environment Variables

Create `.env` file for sensitive configuration (not committed to git):

```env
API_BASE_URL=https://api.plantvision.com
API_KEY=your_api_key_here
SENTRY_DSN=your_sentry_dsn
```

Use with `flutter_dotenv` package:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
await dotenv.load();
String apiUrl = dotenv.env['API_BASE_URL'] ?? '';
```

## Running Tests

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Test with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Building for Release

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Then open Xcode and archive for distribution
```

## Common Issues & Solutions

### Issue: Flutter Doctor Shows Errors
**Solution**: Run `flutter doctor -v` and follow the instructions for each issue.

### Issue: Android Licenses Not Accepted
**Solution**: Run `flutter doctor --android-licenses` and accept all.

### Issue: CocoaPods Not Found (iOS)
**Solution**: Install CocoaPods: `sudo gem install cocoapods`

### Issue: Gradle Build Fails
**Solution**: 
- Clear Gradle cache: `./android/gradlew clean` (from project root)
- Invalidate Android Studio caches
- Check internet connection for dependency downloads

### Issue: iOS Build Fails
**Solution**:
- Run `pod repo update` in ios directory
- Clean build: `flutter clean && flutter pub get`
- Update CocoaPods: `sudo gem install cocoapods`

### Issue: Hot Reload Not Working
**Solution**:
- Save all files
- Stop and restart the app
- Run `flutter clean`

## Development Workflow

### 1. Create Feature Branch
```bash
git checkout -b feature/camera-capture
```

### 2. Make Changes
- Write code
- Write tests
- Run linter: `flutter analyze`
- Format code: `flutter format .`

### 3. Test Changes
```bash
flutter test
flutter run
```

### 4. Commit & Push
```bash
git add .
git commit -m "feat: implement camera capture"
git push origin feature/camera-capture
```

### 5. Create Pull Request
- Open PR on GitHub/GitLab
- Wait for code review
- Address feedback
- Merge to main

## Useful Commands

```bash
# Clean build artifacts
flutter clean

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Analyze code
flutter analyze

# Format code
flutter format lib/

# Generate code
flutter pub run build_runner build

# Watch for changes (continuous code generation)
flutter pub run build_runner watch

# List connected devices
flutter devices

# Run in profile mode
flutter run --profile

# Build with obfuscation
flutter build apk --obfuscate --split-debug-info=build/debug-info
```

## Next Steps

1. ✅ Project structure created
2. ✅ Core configuration files set up
3. ✅ Database schema defined
4. ⏳ Implement data sources and repositories
5. ⏳ Create UI screens and widgets
6. ⏳ Implement authentication flow
7. ⏳ Implement camera capture
8. ⏳ Implement offline sync
9. ⏳ Write tests
10. ⏳ Deploy to staging

## Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Riverpod Documentation**: https://riverpod.dev
- **Material Design 3**: https://m3.material.io
- **Dart Style Guide**: https://dart.dev/guides/language/effective-dart/style
- **Project Issues**: https://github.com/yourorg/plantvision-mobile/issues

## Support

For setup issues or questions:
- **Email**: dev-support@plantvision.com
- **Slack**: #plantvision-mobile
- **Wiki**: https://wiki.plantvision.com/mobile

---

**Last Updated**: 2025-10-02  
**Version**: 1.0.0  
**Status**: Initial Setup Complete
