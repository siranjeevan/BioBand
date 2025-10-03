# Business Logic Documentation

## Overview
Bio-Band's business logic handles health data processing, device management, user authentication, and real-time monitoring workflows.

## Core Models

### SensorData
Central data model for health metrics.

```dart
class SensorData {
  static int heartRate = 72;
  static int steps = 5423;
  static int calories = 210;
  static int spo2 = 97;
  static List<int> heartRateHistory = [70, 72, 75, 73, 71, 74, 72];
  static List<int> stepsHistory = [5400, 5410, 5415, 5420, 5423];
  static List<int> caloriesHistory = [200, 205, 207, 209, 210];
  static List<int> spo2History = [96, 97, 98, 97, 97];
  static int refreshRate = 2;
  static bool vibrationAlert = true;
  static String units = 'Metric';
}
```

### DeviceState
Manages device connection and identification.

```dart
class DeviceState {
  static bool isConnected = false;
  static String deviceId = '';
  static String deviceName = '';
  static DateTime? lastSync;
  static ConnectionStatus status = ConnectionStatus.disconnected;
}
```

### HealthAnalysis
Processes and analyzes health data trends.

```dart
class HealthAnalysis {
  static HealthStatus analyzeVitals(SensorData data);
  static List<HealthInsight> generateInsights(List<SensorData> history);
  static RiskLevel assessRisk(SensorData current, SensorData baseline);
}
```

### UserSettings
Manages user preferences and configuration.

```dart
class UserSettings {
  String userId;
  String displayName;
  String email;
  NotificationPreferences notifications;
  MeasurementUnits units;
  PrivacySettings privacy;
}
```

## State Management

### Theme Provider
Manages app-wide theme and appearance settings.

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  
  ThemeMode get themeMode => _themeMode;
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark 
      ? ThemeMode.light 
      : ThemeMode.dark;
    notifyListeners();
  }
}
```

## Business Rules

### Health Monitoring Logic

#### Vital Signs Validation
```dart
class VitalSignsValidator {
  static bool isHeartRateNormal(int bpm) {
    return bpm >= 60 && bpm <= 100;
  }
  
  static bool isSpO2Normal(int percentage) {
    return percentage >= 95 && percentage <= 100;
  }
  
  static HealthAlert? checkForAlerts(SensorData data) {
    if (!isHeartRateNormal(data.heartRate)) {
      return HealthAlert.abnormalHeartRate(data.heartRate);
    }
    if (!isSpO2Normal(data.spo2)) {
      return HealthAlert.lowOxygen(data.spo2);
    }
    return null;
  }
}
```

#### Data Synchronization
```dart
class DataSyncManager {
  static Timer? _syncTimer;
  
  static void startAutoSync() {
    _syncTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (DeviceState.isConnected) {
        _fetchLatestData();
      }
    });
  }
  
  static Future<void> _fetchLatestData() async {
    final response = await ApiService.getDeviceHealthMetrics(
      DeviceState.deviceId
    );
    
    if (response['success'] == true) {
      _updateSensorData(response['health_metrics']);
    }
  }
}
```

### Device Connection Logic

#### Connection Workflow
1. **Discovery Phase**
   - Scan for available devices
   - Filter by device type
   - Display connection options

2. **Pairing Phase**
   - Establish Bluetooth connection
   - Authenticate device
   - Exchange encryption keys

3. **Validation Phase**
   - Verify device capabilities
   - Test data transmission
   - Confirm connection stability

```dart
class DeviceConnectionManager {
  static Future<ConnectionResult> connectDevice(String deviceId) async {
    try {
      // Establish connection
      final connection = await BluetoothManager.connect(deviceId);
      
      // Validate device
      final isValid = await _validateDevice(connection);
      if (!isValid) {
        return ConnectionResult.invalidDevice();
      }
      
      // Update state
      DeviceState.isConnected = true;
      DeviceState.deviceId = deviceId;
      DeviceState.lastSync = DateTime.now();
      
      return ConnectionResult.success();
    } catch (e) {
      return ConnectionResult.error(e.toString());
    }
  }
}
```

### Authentication Logic

#### Google Sign-In Flow
```dart
class AuthenticationManager {
  static Future<AuthResult> signInWithGoogle() async {
    try {
      final user = await GoogleAuthService.signInWithGoogle();
      if (user != null) {
        await _createUserProfile(user);
        return AuthResult.success(user);
      }
      return AuthResult.cancelled();
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }
  
  static Future<void> _createUserProfile(User user) async {
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    await ApiService.createUser(userData);
  }
}
```

## Data Processing

### Health Metrics Processing
```dart
class HealthMetricsProcessor {
  static ProcessedMetrics processRawData(Map<String, dynamic> rawData) {
    return ProcessedMetrics(
      heartRate: _parseHeartRate(rawData['heart_rate']),
      spo2: _parseSpO2(rawData['spo2']),
      steps: _parseSteps(rawData['steps']),
      calories: _parseCalories(rawData['calories']),
      timestamp: DateTime.parse(rawData['timestamp']),
    );
  }
  
  static List<HealthTrend> analyzeTrends(List<ProcessedMetrics> history) {
    final trends = <HealthTrend>[];
    
    // Heart rate trend analysis
    final hrTrend = _analyzeHeartRateTrend(history);
    if (hrTrend != null) trends.add(hrTrend);
    
    // Activity trend analysis
    final activityTrend = _analyzeActivityTrend(history);
    if (activityTrend != null) trends.add(activityTrend);
    
    return trends;
  }
}
```

### AI Analytics Logic
```dart
class AIAnalyticsEngine {
  static Future<HealthInsights> generateInsights(
    List<SensorData> history
  ) async {
    final patterns = _detectPatterns(history);
    final predictions = await _generatePredictions(patterns);
    final recommendations = _generateRecommendations(patterns, predictions);
    
    return HealthInsights(
      patterns: patterns,
      predictions: predictions,
      recommendations: recommendations,
      confidence: _calculateConfidence(patterns),
    );
  }
  
  static List<HealthPattern> _detectPatterns(List<SensorData> data) {
    // Pattern detection algorithms
    // - Circadian rhythm analysis
    // - Activity pattern recognition
    // - Anomaly detection
  }
}
```

## Workflow Management

### App Initialization Flow
1. **Splash Screen**
   - Initialize Firebase
   - Load environment variables
   - Check authentication state

2. **Authentication Check**
   - Verify existing session
   - Route to login or main app
   - Handle authentication errors

3. **Device Connection Check**
   - Scan for previously connected devices
   - Attempt auto-reconnection
   - Show connection dialog if needed

4. **Data Synchronization**
   - Fetch latest health data
   - Update local cache
   - Start background sync

### Health Monitoring Workflow
1. **Data Collection**
   - Receive data from connected device
   - Validate data integrity
   - Store in local database

2. **Real-time Processing**
   - Update UI with new values
   - Check for health alerts
   - Trigger notifications if needed

3. **Background Analysis**
   - Process historical trends
   - Generate health insights
   - Update AI recommendations

## Error Handling

### Connection Errors
```dart
class ConnectionErrorHandler {
  static void handleConnectionLoss() {
    DeviceState.isConnected = false;
    _showConnectionLostDialog();
    _attemptReconnection();
  }
  
  static Future<void> _attemptReconnection() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(Duration(seconds: 5 * (i + 1)));
      
      final result = await DeviceConnectionManager.reconnect();
      if (result.isSuccess) {
        _showReconnectionSuccess();
        return;
      }
    }
    
    _showManualReconnectionRequired();
  }
}
```

### Data Validation
```dart
class DataValidator {
  static ValidationResult validateHealthData(Map<String, dynamic> data) {
    final errors = <String>[];
    
    if (!_isValidHeartRate(data['heart_rate'])) {
      errors.add('Invalid heart rate value');
    }
    
    if (!_isValidSpO2(data['spo2'])) {
      errors.add('Invalid SpO2 value');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
```

## Performance Optimization

### Memory Management
- Proper disposal of timers and controllers
- Efficient data structure usage
- Garbage collection optimization

### Battery Optimization
- Intelligent sync intervals
- Background task management
- Power-efficient Bluetooth usage

### Data Efficiency
- Compression algorithms
- Selective data synchronization
- Local caching strategies