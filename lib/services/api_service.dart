import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../config/api_endpoints.dart';

class ApiService {
  static final String _baseUrl = Environment.apiBaseUrl;
  
  static String _buildUrl(String endpoint) => '$_baseUrl$endpoint';
  
  // GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse(_buildUrl(endpoint)),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } else {
        return {'error': 'HTTP ${response.statusCode}', 'message': response.body};
      }
    } catch (e) {
      return {'error': 'Network error', 'message': e.toString()};
    }
  }
  
  // POST request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(_buildUrl(endpoint)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } else {
        return {'error': 'HTTP ${response.statusCode}', 'message': response.body};
      }
    } catch (e) {
      return {'error': 'Network error', 'message': e.toString()};
    }
  }
  
  // User methods
  static Future<Map<String, dynamic>> getUsers() => get(ApiEndpoints.users);
  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) => 
      post(ApiEndpoints.createUser, userData);
  
  // Device methods
  static Future<Map<String, dynamic>> getDevices() => get(ApiEndpoints.devices);
  static Future<Map<String, dynamic>> registerDevice(Map<String, dynamic> deviceData) => 
      post(ApiEndpoints.registerDevice, deviceData);
  
  // Health metrics methods
  static Future<Map<String, dynamic>> getHealthMetrics() => get(ApiEndpoints.healthMetrics);
  static Future<Map<String, dynamic>> addHealthMetrics(Map<String, dynamic> healthData) => 
      post(ApiEndpoints.addHealthMetrics, healthData);
  static Future<Map<String, dynamic>> getDeviceHealthMetrics(String deviceId) async {
    final result = await get(ApiEndpoints.deviceHealthMetrics(deviceId));
    
    // Handle different response formats
    if (result.containsKey('error')) {
      return result;
    }
    
    // Normalize response format
    if (result.containsKey('health_metrics')) {
      return result;
    } else if (result is List) {
      return {'health_metrics': result};
    } else {
      return {'health_metrics': [result]};
    }
  }
}