class AppConstants {
  static const String appName = 'Blockradar Pulse';
  static const String apiBaseUrl = 'https://api.blockradar.co';
  static const String secureStorageApiKeyKey = 'blockradar_api_key';
  
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration notificationCheckInterval = Duration(minutes: 1);
  
  static const int maxTransactionHistory = 100;
  static const int refreshInterval = 30;
}

class AppColors {
  // Official Blockradar Brand Colors
  static const primary = 0xFFa3ff50; // Official Blockradar green
  static const primaryDark = 0xFF7dd83f; // Darker shade of Blockradar green
  static const secondary = 0xFF5cb85c; // Complementary green
  static const accent = 0xFF7dd83f; // Darker shade of Blockradar green
  static const success = 0xFFa3ff50; // Blockradar green for success
  static const warning = 0xFFFBBF24;
  static const error = 0xFFEF4444;
  
  // Dark theme (primary theme like Blockradar)
  static const background = 0xFF000000; // Pure black
  static const surface = 0xFF0a0a0a; // Very dark gray
  static const surfaceVariant = 0xFF1a1a1a; // Dark gray
  static const cardSurface = 0xFF1a1a1a;
  static const onSurface = 0xFFFFFFFF; // Pure white
  static const onSurfaceVariant = 0xFFcccccc; // Light gray
  static const onSurfaceMuted = 0xFF666666;
  static const border = 0xFF2a2a2a; // Darker border
  static const borderLight = 0xFF333333; // Dark gray outline
  static const shadow = 0xFF000000; // Pure black shadow
  
  // Light theme (secondary)
  static const backgroundLight = 0xFFFAFAFA;
  static const surfaceLight = 0xFFFFFFFF;
  static const onSurfaceLight = 0xFF1F2937;
  static const onSurfaceVariantLight = 0xFF6B7280;
  static const borderLightTheme = 0xFFE5E7EB;
  static const shadowLight = 0x1A000000;
  
  // Gradient colors
  static const gradientStart = 0xFFa3ff50; // Official Blockradar green
  static const gradientEnd = 0xFF7dd83f; // Darker shade of Blockradar green
  
  // Status colors
  static const positive = 0xFFa3ff50; // Official Blockradar green
  static const negative = 0xFFEF4444;
  static const neutral = 0xFF666666;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double extraLarge = 24.0;
  
  // Legacy aliases
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}