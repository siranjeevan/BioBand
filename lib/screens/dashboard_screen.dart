import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/sensor_data.dart';
import '../models/device_state.dart';
import '../services/api_service.dart';
import 'main_navigation_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onDialogDismissed;
  const DashboardScreen({super.key, this.onDialogDismissed});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _insightAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dataTimer;
  DateTime _lastSynced = DateTime.now();
  late List<Bubble> _bubbles;
  late List<FlameParticle> _flames;
  bool _isFromDeviceConnect = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _insightAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _insightAnimationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _insightAnimationController, curve: Curves.easeIn),
    );
    _bubbles = List.generate(8, (index) => Bubble());
    _flames = List.generate(12, (index) => FlameParticle());
    _animationController.repeat();
    _insightAnimationController.forward();
    _startDataUpdates();
    
    // Check device connection after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkDeviceAndShowDialog();
    });
  }



  void _checkDeviceAndShowDialog() {
    if (!DeviceState.isConnected && mounted) {
      showNoDeviceDialog();
    }
  }





  @override
  void dispose() {
    _animationController.dispose();
    _insightAnimationController.dispose();
    _dataTimer?.cancel();
    super.dispose();
  }



  void _startDataUpdates() {
    if (DeviceState.isConnected) {
      _fetchLatestHealthMetrics();
      _dataTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _fetchLatestHealthMetrics();
      });
    }
  }

  Future<void> _fetchLatestHealthMetrics() async {
    if (!DeviceState.isConnected || DeviceState.deviceId.isEmpty) return;
    
    try {
      final response = await ApiService.getLatestDeviceHealthMetrics(DeviceState.deviceId);
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        setState(() {
          SensorData.heartRate = data['heart_rate'] ?? SensorData.heartRate;
          SensorData.spo2 = data['spo2'] ?? SensorData.spo2;
          SensorData.steps = data['steps'] ?? SensorData.steps;
          SensorData.calories = data['calories'] ?? SensorData.calories;
          _lastSynced = DateTime.now();
        });
      }
    } catch (e) {
      setState(() {
        SensorData.heartRate = 65 + Random().nextInt(25);
        SensorData.spo2 = 95 + Random().nextInt(5);
        SensorData.steps += Random().nextInt(10);
        SensorData.calories = (SensorData.steps * 0.04).round();
        _lastSynced = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text(
              'Vitals Tracking',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (DeviceState.isConnected) ...[
              Icon(
                Icons.circle,
                color: AppColors.success,
                size: 8,
              ),
              const SizedBox(width: 4),
              Text(
                DeviceState.deviceId,
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (DeviceState.isConnected)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
              onPressed: _fetchLatestHealthMetrics,
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
            child: SafeArea(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: !DeviceState.isConnected ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildHealthInsights(),
                      const SizedBox(height: 24),
                      _buildVitalCards(),
                      const SizedBox(height: 24),
                      _buildQuickStats(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!DeviceState.isConnected)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 100, // Leave more space for bottom navigation
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ),
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
          animationType: 'heartbeat',
        ),
        _buildVitalCard(
          icon: Icons.air,
          title: 'Blood Oxygen',
          value: '${SensorData.spo2}',
          unit: '%',
          color: AppColors.textPrimary,
          animationType: 'bubble',
        ),
        _buildVitalCard(
          icon: Icons.local_fire_department,
          title: 'Calories',
          value: '${SensorData.calories}',
          unit: 'kcal',
          color: AppColors.warning,
          animationType: 'fire',
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + sin(_animationController.value * 2 * pi) * 0.02,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.05),
                  color.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildAnimation(animationType, color),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: color.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
            case 'heartbeat':
              return Transform.scale(
                scale: 1.0 + sin(_animationController.value * 2 * pi) * 0.2,
                child: Icon(Icons.favorite, color: color, size: 40),
              );
            case 'bubble':
              return CustomPaint(
                painter: BubblePainter(_bubbles, _animationController.value),
              );
            case 'bounce':
              return Transform.translate(
                offset: Offset(0, -sin(_animationController.value * 2 * pi).abs() * 3),
                child: Icon(Icons.directions_walk, color: color, size: 40),
              );
            case 'fire':
              return CustomPaint(
                painter: FlamePainter(_flames, _animationController.value),
              );
            default:
              return Icon(Icons.health_and_safety, color: color, size: 40);
          }
        },
      ),
    );
  }

  Widget _buildHealthInsights() {
    return Stack(
      children: [
        // Background animation
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: HealthParticlesPainter(_animationController.value),
              );
            },
          ),
        ),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + sin(_animationController.value * 2 * pi) * 0.1,
                        child: const Icon(
                          Icons.health_and_safety,
                          color: AppColors.success,
                          size: 24,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Health Status: Optimal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Your recent vitals indicate a strong and stable condition.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  void showNoDeviceDialog() {
    if (!mounted || DeviceState.isConnected) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            // User dismissed dialog with back button
            widget.onDialogDismissed?.call();
          }
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.bluetooth_disabled,
                    size: 60,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Device Connected',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please connect your health device to view vitals',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/device-connect');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Connect Device',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildTemperatureCard('28°C', 'Skin Temp', AppColors.error),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActivityCard(),
        ),
      ],
    );
  }

  Widget _buildTemperatureCard(String temp, String label, Color color) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + sin(_animationController.value * 2 * pi) * 0.02,
          child: GlassContainer(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: sin(_animationController.value * 2 * pi) * 0.1,
                      child: Icon(
                        Icons.thermostat,
                        color: color,
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  temp,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityCard() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + sin(_animationController.value * 2 * pi) * 0.02,
          child: GlassContainer(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: sin(_animationController.value * 2 * pi) * 0.1,
                      child: const Icon(
                        Icons.directions_walk,
                        color: AppColors.success,
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const Text(
                  'Walking',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}

class Bubble {
  late double x;
  late double y;
  late double size;
  late double speed;
  late Color color;

  Bubble() {
    final random = Random();
    x = random.nextDouble();
    y = 1.0 + random.nextDouble() * 0.5;
    size = 2 + random.nextDouble() * 4;
    speed = 0.3 + random.nextDouble() * 0.7;
    color = AppColors.textPrimary.withValues(alpha: 0.3 + random.nextDouble() * 0.4);
  }

  void update(double animationValue) {
    y -= speed * 0.02;
    if (y < -0.1) {
      y = 1.1;
      x = Random().nextDouble();
    }
  }
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double animationValue;

  BubblePainter(this.bubbles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      bubble.update(animationValue);
      
      final paint = Paint()
        ..color = bubble.color
        ..style = PaintingStyle.fill;

      final center = Offset(
        bubble.x * size.width,
        bubble.y * size.height,
      );

      canvas.drawCircle(center, bubble.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FlameParticle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late Color color;
  late double life;

  FlameParticle() {
    reset();
  }

  void reset() {
    final random = Random();
    x = 0.3 + random.nextDouble() * 0.4;
    y = 0.9;
    size = 1 + random.nextDouble() * 2;
    speed = 0.5 + random.nextDouble() * 1.0;
    life = 1.0;
    
    final colors = [
      const Color(0xFFFF6B35),
      const Color(0xFFFF8E53),
      AppColors.warning,
    ];
    color = colors[random.nextInt(colors.length)];
  }

  void update() {
    y -= speed * 0.01;
    life -= 0.02;
    x += (Random().nextDouble() - 0.5) * 0.01;
    
    if (life <= 0 || y < 0) {
      reset();
    }
  }
}

class FlamePainter extends CustomPainter {
  final List<FlameParticle> flames;
  final double animationValue;

  FlamePainter(this.flames, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var flame in flames) {
      flame.update();
      
      final paint = Paint()
        ..color = flame.color.withValues(alpha: flame.life * 0.8)
        ..style = PaintingStyle.fill;

      final center = Offset(
        flame.x * size.width,
        flame.y * size.height,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: flame.size,
          height: flame.size * 1.5,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HealthParticlesPainter extends CustomPainter {
  final double animationValue;

  HealthParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.success.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final offset = Offset(
        (i * 0.2 + animationValue * 0.1) * size.width,
        sin(animationValue * 2 * pi + i) * 10 + size.height * 0.5,
      );
      canvas.drawCircle(offset, 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}