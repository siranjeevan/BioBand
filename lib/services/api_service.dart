import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../config/api_endpoints.dart';

class ApiService {
  static final String _baseUrl = Environment.apiBaseUrl;
  
  static String _buildUrl(String endpoint) => '$_baseUrl$endpoint';
  
  // GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse(_buildUrl(endpoint)),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(response.body);
  }
  
  // POST request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(_buildUrl(endpoint)),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return json.decode(response.body);
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
  static Future<Map<String, dynamic>> getDeviceHealthMetrics(String deviceId) => 
      get(ApiEndpoints.deviceHealthMetrics(deviceId));
}