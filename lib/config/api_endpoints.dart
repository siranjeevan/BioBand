class ApiEndpoints {
  // User endpoints
  static const String users = '/users/';
  static const String createUser = '/users/';
  
  // Device endpoints
  static const String devices = '/devices/';
  static const String registerDevice = '/devices/';
  
  // Health metrics endpoints
  static const String healthMetrics = '/health-metrics/';
  static const String addHealthMetrics = '/health-metrics/';
  static String deviceHealthMetrics(String deviceId) => '/health-metrics/device/$deviceId';
  
  // System endpoints
  static const String health = '/health';
  static const String apiStatus = '/';
}