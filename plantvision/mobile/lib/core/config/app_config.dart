class AppConfig {
  // App Info
  static const String appName = 'NTPC Photo Inspection';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // API Configuration
  static const String baseUrl = 'https://api.ntpc-photo-inspection.com';
  static const String apiVersion = 'v1';
  static const String apiTimeout = '30';
  
  // Authentication
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const int tokenExpiryMinutes = 60;
  
  // Database
  static const String databaseName = 'ntpc_photo_inspection.db';
  static const int databaseVersion = 1;
  
  // Storage
  static const String photosDirectory = 'photos';
  static const String thumbnailsDirectory = 'thumbnails';
  static const int maxPhotoSizeMB = 10;
  static const int thumbnailMaxWidth = 256;
  static const int thumbnailMaxHeight = 256;
  static const int thumbnailQuality = 80;
  
  // Sync Configuration
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxRetryAttempts = 3;
  static const Duration retryBackoffBase = Duration(seconds: 2);
  static const int batchUploadSize = 5;
  
  // Location
  static const double locationAccuracy = 10.0; // meters
  static const Duration locationTimeout = Duration(seconds: 30);
  
  // Camera
  static const int photoQuality = 90;
  static const bool enableFlash = true;
  
  // Offline Mode
  static const int maxOfflinePhotos = 1000;
  static const Duration offlineCacheDuration = Duration(days: 30);
  
  // Security
  static const bool enableBiometrics = true;
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const int maxLoginAttempts = 5;
  
  // Pagination
  static const int photosPerPage = 20;
  static const int preloadThreshold = 5;
  
  // Background Services
  static const String backgroundSyncTask = 'photo_sync_task';
  static const Duration backgroundSyncFrequency = Duration(hours: 1);
  
  // Notifications
  static const String notificationChannelId = 'ntpc_photo_inspection_channel';
  static const String notificationChannelName = 'NTPC Photo Inspection';
  static const String notificationChannelDescription = 'Task assignments, photo upload status, and sync notifications';
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableBackgroundSync = true;
  static const bool enableLocationTracking = true;
  static const bool enableQRScanner = true;
  static const bool enableBiometricAuth = true;
}
