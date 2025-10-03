import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/sensor_data.dart';
import '../models/device_state.dart';
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
    _bubbles = List.generate(8, (index) => Bubble());
    _flames = List.generate(12, (index) => FlameParticle());
    _animationController.repeat();
    _startDataUpdates();
  }



  void _checkDeviceAndShowDialog() {
    if (!DeviceState.isConnected && mounted) {
      showNoDeviceDialog();
    }
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
        automaticallyImplyLeading: false,
        title: const Text(
          'Vitals Tracking',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
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
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimation(animationType, color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
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
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            'Overall Health Score',
            '85/100',
            'Excellent health metrics detected',
            Icons.health_and_safety,
            AppColors.success,
          ),
          _buildInsightItem(
            'Activity Level',
            'High',
            'You\'re meeting daily activity goals',
            Icons.trending_up,
            AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String value, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Today\'s Goal',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${((SensorData.steps / 10000) * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                const Text(
                  'Steps Goal',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Weekly Avg',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${SensorData.heartRate - 5}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const Text(
                  'Heart Rate',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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