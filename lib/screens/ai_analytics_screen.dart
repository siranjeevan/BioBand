import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/sensor_data.dart';

class AIAnalyticsScreen extends StatefulWidget {
  const AIAnalyticsScreen({super.key});

  @override
  State<AIAnalyticsScreen> createState() => _AIAnalyticsScreenState();
}

class _AIAnalyticsScreenState extends State<AIAnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _dataTimer;
  DateTime _lastSynced = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.repeat();
    _startDataUpdates();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dataTimer?.cancel();
    super.dispose();
  }

  void _startDataUpdates() {
    _dataTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        SensorData.heartRate = 65 + Random().nextInt(25);
        SensorData.spo2 = 95 + Random().nextInt(5);
        SensorData.steps += Random().nextInt(10);
        SensorData.calories = (SensorData.steps * 0.04).round();
        _lastSynced = DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vitals Tracking',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => setState(() => _lastSynced = DateTime.now()),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea( // ✅ Fix: wrap content with SafeArea
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSyncStatus(),
                const SizedBox(height: 24),
                _buildVitalCards(),
                const SizedBox(height: 24), // ✅ Extra spacing at bottom
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSyncStatus() {
    final timeDiff = DateTime.now().difference(_lastSynced);
    final syncText =
        timeDiff.inMinutes < 1 ? 'Just now' : '${timeDiff.inMinutes}m ago';

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Device Connected',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Last synced: $syncText',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.bluetooth_connected,
            color: AppColors.success,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildVitalCard(
          icon: Icons.favorite,
          title: 'Heart Rate',
          value: '${SensorData.heartRate}',
          unit: 'BPM',
          color: AppColors.error,
          animationType: 'pulse',
        ),
        _buildVitalCard(
          icon: Icons.air,
          title: 'Blood Oxygen',
          value: '${SensorData.spo2}',
          unit: '%',
          color: AppColors.secondary,
          animationType: 'wave',
        ),
        _buildVitalCard(
          icon: Icons.local_fire_department,
          title: 'Calories',
          value: '${SensorData.calories}',
          unit: 'kcal',
          color: AppColors.warning,
          animationType: 'flame',
        ),
        _buildVitalCard(
          icon: Icons.directions_walk,
          title: 'Steps',
          value: '${SensorData.steps}',
          unit: 'today',
          color: AppColors.success,
          animationType: 'bounce',
        ),
      ],
    );
  }

  Widget _buildVitalCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
    required String animationType,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimation(animationType, color),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimation(String type, Color color) {
    return SizedBox(
      height: 40,
      width: 40,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          switch (type) {
            case 'pulse':
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: 1.0 +
                        sin(_animationController.value * 2 * pi) * 0.2,
                    child: Icon(Icons.favorite, color: color, size: 40),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ],
              );
            case 'wave':
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(
                        0, sin(_animationController.value * 2 * pi) * 3),
                    child: Icon(Icons.air, color: color, size: 40),
                  ),
                  ...List.generate(
                    3,
                    (i) => Transform.scale(
                      scale: 0.5 +
                          (sin(_animationController.value * 2 * pi + i * 0.5) *
                              0.3),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            case 'flame':
              return Transform.rotate(
                angle: sin(_animationController.value * 2 * pi) * 0.1,
                child:
                    Icon(Icons.local_fire_department, color: color, size: 40),
              );
            case 'bounce':
              return Transform.translate(
                offset: Offset(
                    0, -sin(_animationController.value * 2 * pi).abs() * 3),
                child: Icon(Icons.directions_walk, color: color, size: 40),
              );
            default:
              return Icon(Icons.health_and_safety, color: color, size: 40);
          }
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.psychology), label: 'AI Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assessment), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/ai-analytics');
              break;
            case 2:
              Navigator.pushNamed(context, '/health');
              break;
            case 3:
              Navigator.pushNamed(context, '/reports');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
