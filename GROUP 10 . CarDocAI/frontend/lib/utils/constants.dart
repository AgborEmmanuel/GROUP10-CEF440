class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String apiVersion = '/api/v1';
  
  // API Endpoints
  static const String dashboardDiagnosisEndpoint = '/diagnosis/diagnose/dashboard';
  static const String engineSoundDiagnosisEndpoint = '/diagnosis/diagnose/engine-sound';
  static const String diagnosisHistoryEndpoint = '/diagnosis/history';
  
  // Network Configuration
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 60000; // 60 seconds
  
  // File Upload Configuration
  static const int maxImageSizeMB = 10;
  static const int maxAudioSizeMB = 25;
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png'];
  static const List<String> supportedAudioFormats = ['mp3', 'wav', 'm4a', 'aac'];
  
  // Error Messages
  static const String networkErrorMessage = 'Network connection failed. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  static const String authErrorMessage = 'Authentication failed. Please log in again.';
  static const String fileUploadErrorMessage = 'File upload failed. Please try again.';
  
  // App Configuration
  static const String appName = 'CarDocAI';
  static const String appVersion = '1.0.0';
  
  // Diagnosis Configuration
  static const double minConfidenceThreshold = 0.5;
  static const int maxRecommendations = 5;
  
  // Audio Recording Configuration
  static const int minRecordingDurationSeconds = 3;
  static const int maxRecordingDurationSeconds = 60;
  static const int audioSampleRate = 44100;
  
  // Image Capture Configuration
  static const int imageQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
}
