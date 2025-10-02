class DeviceState {
  static bool _isConnected = false;
  static String _deviceName = '';
  
  static bool get isConnected => _isConnected;
  static String get deviceName => _deviceName;
  
  static void connect(String name) {
    _isConnected = true;
    _deviceName = name;
  }
  
  static void disconnect() {
    _isConnected = false;
    _deviceName = '';
  }
}