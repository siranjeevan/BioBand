# API Documentation

## Overview
Bio-Band uses RESTful APIs for backend communication and Firebase for authentication and real-time data sync.

## Base Configuration

### Environment Setup
```dart
// config/environment.dart
class Environment {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
}
```

### API Endpoints
```dart
// config/api_endpoints.dart
class ApiEndpoints {
  static const String users = '/users';
  static const String createUser = '/users/create';
  static const String devices = '/devices';
  static const String registerDevice = '/devices/register';
  static const String healthMetrics = '/health-metrics';
  static const String addHealthMetrics = '/health-metrics/add';
  
  static String deviceHealthMetrics(String deviceId) => 
    '/health-metrics/device/$deviceId';
}
```

## API Service

### Core Methods

#### GET Request
```dart
static Future<Map<String, dynamic>> get(String endpoint) async {
  final response = await http.get(
    Uri.parse(_buildUrl(endpoint)),
    headers: {'Content-Type': 'application/json'},
  ).timeout(const Duration(seconds: 10));
  
  return _handleResponse(response);
}
```

#### POST Request
```dart
static Future<Map<String, dynamic>> post(
  String endpoint, 
  Map<String, dynamic> data
) async {
  final response = await http.post(
    Uri.parse(_buildUrl(endpoint)),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  ).timeout(const Duration(seconds: 10));
  
  return _handleResponse(response);
}
```

### Error Handling
- Network timeout (10 seconds)
- HTTP status code validation
- JSON parsing error handling
- Standardized error response format

## Endpoints

### User Management

#### Get Users
- **Endpoint**: `GET /users`
- **Response**: List of users
- **Usage**: `ApiService.getUsers()`

#### Create User
- **Endpoint**: `POST /users/create`
- **Body**: User data object
- **Response**: Created user details
- **Usage**: `ApiService.createUser(userData)`

### Device Management

#### Get Devices
- **Endpoint**: `GET /devices`
- **Response**: List of registered devices
- **Usage**: `ApiService.getDevices()`

#### Register Device
- **Endpoint**: `POST /devices/register`
- **Body**: Device registration data
- **Response**: Device registration confirmation
- **Usage**: `ApiService.registerDevice(deviceData)`

### Health Metrics

#### Get All Health Metrics
- **Endpoint**: `GET /health-metrics`
- **Response**: All health metrics data
- **Usage**: `ApiService.getHealthMetrics()`

#### Add Health Metrics
- **Endpoint**: `POST /health-metrics/add`
- **Body**: Health data object
- **Response**: Confirmation of data addition
- **Usage**: `ApiService.addHealthMetrics(healthData)`

#### Get Device Health Metrics
- **Endpoint**: `GET /health-metrics/device/{deviceId}`
- **Parameters**: Device ID
- **Response**: Device-specific health metrics
- **Usage**: `ApiService.getDeviceHealthMetrics(deviceId)`

## Data Models

### Health Metrics Response
```json
{
  "success": true,
  "health_metrics": [
    {
      "id": "1",
      "heart_rate": "72",
      "spo2": "97",
      "steps": "5423",
      "calories": "210",
      "timestamp": "2024-01-01T12:00:00Z",
      "device_id": "DEVICE_001"
    }
  ]
}
```

### Error Response
```json
{
  "error": "Network error",
  "message": "Connection timeout"
}
```

## Firebase Integration

### Authentication
```dart
// services/google_auth.dart
class GoogleAuthService {
  static Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = 
      await googleUser?.authentication;
    
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    
    final UserCredential userCredential = 
      await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential.user;
  }
}
```

### Real-time Database
- User profiles
- Device states
- Health metrics sync
- Notification preferences

## Request/Response Flow

### Health Data Sync
1. Device connects via Bluetooth
2. App fetches latest metrics from API
3. Data normalized and stored locally
4. UI updates with new values
5. Background sync every 10 seconds

### Error Recovery
1. Network error detection
2. Retry mechanism with exponential backoff
3. Offline mode with local storage
4. User notification of connection issues

## Security

### Authentication
- Firebase Auth tokens
- Google OAuth 2.0
- Secure token storage

### Data Protection
- HTTPS encryption
- Request validation
- Rate limiting
- Input sanitization

## Performance Optimization

### Caching Strategy
- Local data caching
- Image caching
- API response caching
- Offline data access

### Request Optimization
- Request batching
- Compression
- Minimal payload size
- Connection pooling

## Testing

### Unit Tests
```dart
test('API service returns health metrics', () async {
  final result = await ApiService.getHealthMetrics();
  expect(result['success'], true);
  expect(result['health_metrics'], isA<List>());
});
```

### Integration Tests
- End-to-end API flows
- Authentication testing
- Error scenario validation
- Performance benchmarking