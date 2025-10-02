class DeviceState {
  static bool _isConnected = true;
  static String _deviceName = 'Health Band Pro';
  
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