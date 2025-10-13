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
  static const String devParentApiBaseUrl = 'https://pesapp.orangeglacier-1e02abb7.southeastasia.azurecontainerapps.io/parent-api/api';
  
  // Production configuration  
  static const String prodApiBaseUrl = 'https://pesapp.orangeglacier-1e02abb7.southeastasia.azurecontainerapps.io/auth-api/api';
  static const String prodParentApiBaseUrl = 'https://pesapp.orangeglacier-1e02abb7.southeastasia.azurecontainerapps.io/parent-api/api';

  // Class service configuration
  static const String devClassApiBaseUrl = 'https://pesapp.orangeglacier-1e02abb7.southeastasia.azurecontainerapps.io/class-api/api';
  static const String prodClassApiBaseUrl = 'https://pesapp.orangeglacier-1e02abb7.southeastasia.azurecontainerapps.io/class-api/api';

  // Override via --dart-define
  static const String parentApiBaseUrl = String.fromEnvironment(
    'PARENT_API_BASE_URL',
    defaultValue: 'https://pesapp.orangeglacier-1e02abb7.southeastasia.azurecontainerapps.io/parent-api/api',
  );
  static const String classApiBaseUrl = String.fromEnvironment(
    'CLASS_API_BASE_URL',
    defaultValue: 'https://pesapp.orangeglacier-1e02abb7.southeastasia.azurecontainerapps.io/class-api/api',
  );

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

  static String get currentParentApiBaseUrl {
    // Allow explicit override first
    if (parentApiBaseUrl.isNotEmpty) return parentApiBaseUrl;
    switch (environment) {
      case 'development':
        return devParentApiBaseUrl;
      case 'production':
        return prodParentApiBaseUrl;
      default:
        return devParentApiBaseUrl;
    }
  }

  static String get currentClassApiBaseUrl {
    // Allow explicit override first
    if (classApiBaseUrl.isNotEmpty) return classApiBaseUrl;
    switch (environment) {
      case 'development':
        return devClassApiBaseUrl;
      case 'production':
        return prodClassApiBaseUrl;
      default:
        return devClassApiBaseUrl;
    }
  }

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