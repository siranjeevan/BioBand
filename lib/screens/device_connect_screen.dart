import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/device_state.dart';

class DeviceConnectScreen extends StatefulWidget {
  const DeviceConnectScreen({super.key});

  @override
  State<DeviceConnectScreen> createState() => _DeviceConnectScreenState();
}

class _DeviceConnectScreenState extends State<DeviceConnectScreen> with TickerProviderStateMixin {
  late AnimationController _scanController;
  bool _isScanning = false;
  bool _isConnected = false;
  String? _connectedDevice;
  
  final List<BluetoothDevice> _devices = [
    BluetoothDevice('Health Band Pro', 'HB-001', -45),
    BluetoothDevice('Fitness Tracker X', 'FT-002', -52),
    BluetoothDevice('Smart Watch Plus', 'SW-003', -38),
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() => _isScanning = true);
    _scanController.repeat();
    
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isScanning = false);
        _scanController.stop();
      }
    });
  }

  void _connectDevice(BluetoothDevice device) {
    setState(() {
      _isConnected = true;
      _connectedDevice = device.name;
    });
    
    DeviceState.connect(device.name);
    
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pushReplacementNamed(context, '/reports'),
        ),
        title: const Text(
          'Connect Your Device',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildScanAnimation(),
                const SizedBox(height: 24),
                _buildScanButton(),
                const SizedBox(height: 16),
                _buildDeviceList(),
                const SizedBox(height: 24),
                _buildLoginWithDeviceIdButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildScanAnimation() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isScanning)
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(200, 200),
                  painter: ScanAnimationPainter(_scanController.value),
                );
              },
            ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradient1,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.bluetooth_searching,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isScanning ? null : _startScanning,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          _isScanning ? 'Scanning...' : 'Start Scanning',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Available Devices',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _devices.length,
          itemBuilder: (context, index) {
            final device = _devices[index];
            return GlassContainer(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textPrimary.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.watch,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
                title: Text(
                  device.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${device.id} • Signal: ${device.rssi} dBm',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () => _connectDevice(device),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(60, 32),
                  ),
                  child: const Text(
                    'Connect',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoginWithDeviceIdButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, '/device-login'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.textPrimary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Login with Device ID',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class BluetoothDevice {
  final String name;
  final String id;
  final int rssi;

  BluetoothDevice(this.name, this.id, this.rssi);
}

class ScanAnimationPainter extends CustomPainter {
  final double animationValue;

  ScanAnimationPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      final radius = (size.width / 2) * (animationValue + i * 0.3) % 1;
      final opacity = 1.0 - ((animationValue + i * 0.3) % 1);
      
      paint.color = AppColors.textPrimary.withValues(alpha: opacity * 0.6);
      canvas.drawCircle(center, radius * size.width / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}