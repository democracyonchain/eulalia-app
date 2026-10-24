class ApiConfig {
  // Override per environment:
  // flutter run --dart-define=API_BASE_URL=http://10.143.10.199:5219
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5219',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
