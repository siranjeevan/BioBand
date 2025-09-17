import 'package:flutter/material.dart';
import 'dart:math';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/sensor_data.dart';

class CaloriesScreen extends StatefulWidget {
  const CaloriesScreen({super.key});

  @override
  State<CaloriesScreen> createState() => _CaloriesScreenState();
}

class _CaloriesScreenState extends State<CaloriesScreen>
    with TickerProviderStateMixin {
  late AnimationController _flameController;
  late List<FlameParticle> _flames;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _flames = List.generate(20, (index) => FlameParticle());
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calories',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCaloriesCard(),
            const SizedBox(height: 20),
            _buildFlameAnimation(),
            const SizedBox(height: 20),
            _buildStatsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.warning,
                  AppColors.warning.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${SensorData.calories}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
          const Text(
            'Calories Burned',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlameAnimation() {
    return GlassContainer(
      height: 200,
      child: AnimatedBuilder(
        animation: _flameController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(double.infinity, 200),
            painter: FlamePainter(_flames, _flameController.value),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Goal',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '500 kcal',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Rate',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(SensorData.calories / 60).toStringAsFixed(1)}/min',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
    size = 3 + random.nextDouble() * 8;
    speed = 0.5 + random.nextDouble() * 1.0;
    life = 1.0;
    
    final colors = [
      const Color(0xFFFF6B35),
      const Color(0xFFFF8E53),
      const Color(0xFFFF4500),
      const Color(0xFFFFD700),
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

      // Draw flame particle as oval
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