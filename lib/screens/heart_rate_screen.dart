import 'package:flutter/material.dart';
import 'dart:math';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/sensor_data.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transperant,
      appBar: AppBar(
        backgroundColor: AppColors.transperant,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Heart Rate',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeartRateCard(),
            const SizedBox(height: 20),
            _buildWaveVisualization(),
            const SizedBox(height: 20),
            _buildStatsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error,
                        AppColors.error.withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: AppColors.textPrimary,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            '${SensorData.heartRate}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const Text(
            'BPM',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveVisualization() {
    return GlassContainer(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(double.infinity, 150),
            painter: HeartWavePainter(_waveController.value),
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
                  'Avg',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '75',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 24,
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
                  'Max',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '95',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 24,
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

class HeartWavePainter extends CustomPainter {
  final double animationValue;

  HeartWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.error
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = size.height / 2;
    
    for (double x = 0; x <= size.width; x += 2) {
      final normalizedX = (x / size.width) * 4 * pi;
      final offset = animationValue * 2 * pi;
      
      // Create heartbeat-like wave
      double y = centerY;
      if ((normalizedX + offset) % (2 * pi) < pi / 4) {
        y += sin((normalizedX + offset) * 8) * 30;
      } else {
        y += sin((normalizedX + offset) * 2) * 10;
      }
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}