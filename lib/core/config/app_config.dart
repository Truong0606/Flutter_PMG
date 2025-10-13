class AppConfig {
  static const String environment = String.fromEnvironment(
    'FLUTTER_ENV',
    defaultValue: 'production',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://pesapp.orangeglacier-1e02abb7.southeastasia.azurecontainerapps.io/auth-api/api',
  );

  static const String appName = 'PES Mobile';
  static const String appVersion = '1.0.0';

  // Development configuration
  static const String devApiBaseUrl = 'https://pesapp.orangeglacier-1e02abb7.southeastasia.azurecontainerapps.io/auth-api/api';
  
  // Production configuration  
  static const String prodApiBaseUrl = 'https://pesapp.orangeglacier-1e02abb7.southeastasia.azurecontainerapps.io/auth-api/api';

  static String get currentApiBaseUrl {
    switch (environment) {
      case 'development':
        return devApiBaseUrl;
      case 'production':
        return prodApiBaseUrl;
      default:
        return apiBaseUrl;
    }
  }

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  // Cloudinary configuration (set via --dart-define)
  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'duy1h4uru',
  );
  static const String cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'pes_mobile_unsigned',
  );
}