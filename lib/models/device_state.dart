class DeviceState {
  static bool _isConnected = false;
  static String _deviceName = '';
  static String _deviceId = '';
  
  static bool get isConnected => _isConnected;
  static String get deviceName => _deviceName;
  static String get deviceId => _deviceId;
  
  static void connect(String name, String id) {
    _isConnected = true;
    _deviceName = name;
    _deviceId = id;
  }
  
  static void disconnect() {
    _isConnected = false;
    _deviceName = '';
    _deviceId = '';
  }
}