import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/sensor_data.dart';

import '../screens/settings_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentIndex = 0;
  late List<Bubble> _bubbles;
  late List<FlameParticle> _flames;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }



  BoxDecoration get _backgroundDecoration => const BoxDecoration(
    gradient: AppColors.backgroundGradient,
  );

  Color get _surfaceColor => AppColors.surface;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      endDrawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.gradient1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.health_and_safety,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Health Dashboard',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: _surfaceColor,
      child: Container(
        decoration: _backgroundDecoration,
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(child: _buildDrawerItems()),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradient1,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.textSecondary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'John Doe',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'john.doe@email.com',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bluetooth_connected,
                color: AppColors.success,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Health Band Pro',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Premium Member',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItems() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildDrawerItem(Icons.dashboard, 'Dashboard', () => Navigator.pop(context)),
        _buildDrawerItem(Icons.person, 'Profile', () {}),
        _buildDrawerItem(Icons.settings, 'Settings', () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        }),
        _buildDrawerItem(Icons.history, 'Health History', () {}),
        _buildDrawerItem(Icons.notifications, 'Notifications', () {}),
        const Divider(color: AppColors.border),
        _buildDrawerItem(Icons.help, 'Help & Support', () {}),
        _buildDrawerItem(Icons.info, 'About', () {}),
        const Divider(color: AppColors.border),
        _buildDrawerItem(Icons.logout, 'Logout', () {
          Navigator.pushReplacementNamed(context, '/login');
        }, isLogout: true),
      ],
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? AppColors.error : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D1E2F), Color(0xFF4E2A4F)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E2A4F).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor:AppColors.textSecondary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite, size: 28),
                label: 'Health',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person, size: 28),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      decoration: _backgroundDecoration,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHealthAnalysis(),
              const SizedBox(height: 20),
              _buildHealthMetrics(),
            ],
          ),
        ),
      ),
    );
  }





  Widget _buildHealthAnalysis() {
    final screenWidth = MediaQuery.of(context).size.width;
    final heartRate = SensorData.heartRate;
    final spo2 = SensorData.spo2;
    final calories = SensorData.calories;
    
    String healthStatus = 'Excellent';
    String analysis = 'Your vitals are within optimal range. Keep up the great work!';
    Color statusColor = AppColors.success;
    IconData statusIcon = Icons.favorite;
    
    if (heartRate > 100 || spo2 < 95) {
      healthStatus = 'Needs Attention';
      analysis = 'Some vitals need monitoring. Consider consulting a healthcare professional.';
      statusColor = AppColors.error;
      statusIcon = Icons.warning;
    } else if (heartRate > 85 || calories < 150) {
      healthStatus = 'Good';
      analysis = 'Your health is good, but there\'s room for improvement with regular exercise.';
      statusColor = AppColors.warning;
      statusIcon = Icons.trending_up;
    }
    
    return GlassContainer(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics,
                  color: statusColor,
                  size: screenWidth * 0.05,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  'AI Health Analysis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.04),
          Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: screenWidth * 0.04,
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withValues(alpha: 0.2),
                      statusColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  healthStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: screenWidth * 0.032,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          Text(
            analysis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: screenWidth * 0.035,
              height: 1.4,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          Row(
            children: [
              _buildQuickStat('HR', '$heartRate', 'bpm', AppColors.error),
              SizedBox(width: screenWidth * 0.04),
              _buildQuickStat('SpO₂', '$spo2', '%', AppColors.secondary),
              SizedBox(width: screenWidth * 0.04),
              _buildQuickStat('Cal', '$calories', 'kcal', AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, String unit, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.02,
          horizontal: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenWidth * 0.025,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: screenWidth * 0.022,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetrics() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;
    final aspectRatio = screenWidth > 600 ? 1.2 : 1.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.dashboard,
              color: AppColors.primary,
              size: screenWidth * 0.06,
            ),
            SizedBox(width: 8),
            Text(
              'Health Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.055,
              ),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.04),
        GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: screenWidth * 0.04,
          crossAxisSpacing: screenWidth * 0.04,
          childAspectRatio: aspectRatio,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            _buildAnimatedMetricCard(
              icon: Icons.favorite,
              title: 'Heart Rate',
              value: '${SensorData.heartRate}',
              unit: 'BPM',
              color: AppColors.error,
              animationType: 'heartbeat',
            ),
            _buildAnimatedMetricCard(
              icon: Icons.air,
              title: 'Oxygen',
              value: '${SensorData.spo2}',
              unit: '%',
              color: AppColors.secondary,
              animationType: 'bubble',
            ),
            _buildAnimatedMetricCard(
              icon: Icons.directions_walk,
              title: 'Steps',
              value: '${SensorData.steps}',
              unit: 'today',
              color: AppColors.success,
              animationType: 'bounce',
            ),
            _buildAnimatedMetricCard(
              icon: Icons.local_fire_department,
              title: 'Calories',
              value: '${SensorData.calories}',
              unit: 'kcal',
              color: AppColors.warning,
              animationType: 'fire',
            ),
            ],
        ),
      ],
    );
  }

  Widget _buildAnimatedMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
    required String animationType,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GlassContainer(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEnhancedAnimation(animationType, color, screenWidth),
          SizedBox(height: screenWidth * 0.03),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            unit,
            style: TextStyle(
              fontSize: screenWidth * 0.025,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          FittedBox(
            child: Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.032,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAnimation(String animationType, Color color, double screenWidth) {
    return SizedBox(
      height: screenWidth * 0.15,
      width: screenWidth * 0.25,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          switch (animationType) {
            case 'heartbeat':
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: 1.0 + math.sin(_animationController.value * 2 * math.pi) * 0.15,
                    child: Icon(
                      Icons.favorite,
                      color: color,
                      size: screenWidth * 0.06,
                    ),
                  ),
                  CustomPaint(
                    painter: HeartWavePainter(_animationController.value),
                  ),
                ],
              );
            case 'bubble':
              return CustomPaint(
                painter: BubblePainter(_bubbles, _animationController.value),
              );
            case 'bounce':
              return Transform.translate(
                offset: Offset(0, math.sin(_animationController.value * 2 * math.pi) * 3),
                child: Icon(
                  Icons.directions_walk,
                  color: color,
                  size: screenWidth * 0.08,
                ),
              );
            case 'fire':
              return CustomPaint(
                painter: FlamePainter(_flames, _animationController.value),
              );
            default:
              return Container();
          }
        },
      ),
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
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = size.height / 2;
    
    for (double x = 0; x <= size.width; x += 2) {
      final normalizedX = (x / size.width) * 4 * math.pi;
      final offset = animationValue * 2 * math.pi;
      
      double y = centerY;
      if ((normalizedX + offset) % (2 * math.pi) < math.pi / 4) {
        y += math.sin((normalizedX + offset) * 8) * 15;
      } else {
        y += math.sin((normalizedX + offset) * 2) * 5;
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

class Bubble {
  late double x;
  late double y;
  late double size;
  late double speed;
  late Color color;

  Bubble() {
    final random = math.Random();
    x = random.nextDouble();
    y = 1.0 + random.nextDouble() * 0.5;
    size = 3 + random.nextDouble() * 8;
    speed = 0.3 + random.nextDouble() * 0.7;
    color = AppColors.secondary.withValues(alpha: 0.3 + random.nextDouble() * 0.4);
  }

  void update(double animationValue) {
    y -= speed * 0.02;
    if (y < -0.1) {
      y = 1.1;
      x = math.Random().nextDouble();
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
    final random = math.Random();
    x = 0.3 + random.nextDouble() * 0.4;
    y = 0.9;
    size = 2 + random.nextDouble() * 4;
    speed = 0.5 + random.nextDouble() * 1.0;
    life = 1.0;
    
    final colors = [
      const Color(0xFFFF6B35),
      const Color(0xFFFF8E53),
      const Color(0xFFFF4500),
      AppColors.warning,
    ];
    color = colors[random.nextInt(colors.length)];
  }

  void update() {
    y -= speed * 0.01;
    life -= 0.02;
    x += (math.Random().nextDouble() - 0.5) * 0.01;
    
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