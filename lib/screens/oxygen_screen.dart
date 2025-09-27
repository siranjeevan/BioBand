import 'package:flutter/material.dart';
import 'package:nadi_pariksh/design_system/app_colors.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      home: const OxygenScreen(),
    );
  }
}

class SensorData {
  static int spo2 = 98;
}



class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const GlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

class OxygenScreen extends StatefulWidget {
  const OxygenScreen({super.key});

  @override
  State<OxygenScreen> createState() => _OxygenScreenState();
}

class _OxygenScreenState extends State<OxygenScreen>
    with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  List<Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    // Initialize bubbles after a slight delay to ensure proper rendering context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _bubbles = List.generate(15, (index) => Bubble());
      });
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
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
          'Blood Oxygen',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildOxygenCard(),
            const SizedBox(height: 20),
            _buildBubbleAnimation(),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 20),
            _buildInfoText(),
          ],
        ),
      ),
    );
  }

  Widget _buildOxygenCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  AppColors.secondary,
                  AppColors.success,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.air,
              color:AppColors.textSecondary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${SensorData.spo2}%',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const Text(
            'SpO₂',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleAnimation() {
    return GlassContainer(
      height: 200,
      child: AnimatedBuilder(
        animation: _bubbleController,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(double.infinity, 200),
            painter: BubblePainter(_bubbles, _bubbleController.value),
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
                  'Normal Range',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '95-100%',
                  style: TextStyle(
                    color: AppColors.secondary,
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
                  'Status',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Excellent',
                  style: TextStyle(
                    color: AppColors.success,
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

  Widget _buildInfoText() {
    return const GlassContainer(
      padding: EdgeInsets.all(16),
      child: Text(
        "Maintain healthy oxygen levels by practicing deep breathing exercises, staying hydrated, and maintaining good posture.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}

class Bubble {
  double x;
  double y;
  double size;
  double speed;
  Color color;

  Bubble()
      : x = Random().nextDouble(),
        y = 1.0 + Random().nextDouble() * 0.5,
        size = 5 + Random().nextDouble() * 15,
        speed = 0.3 + Random().nextDouble() * 0.7,
        color = AppColors.secondary.withOpacity(0.3 + Random().nextDouble() * 0.4);

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
    // Draw background gradient
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0A0E21).withOpacity(0.8),
          const Color(0xFF0A0E21).withOpacity(0.4),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), backgroundPaint);

    // Draw each bubble
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
      
      // Add shine effect
      final shinePaint = Paint()
        ..color =AppColors.textSecondary.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        center + Offset(-bubble.size * 0.3, -bubble.size * 0.3),
        bubble.size * 0.3,
        shinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}