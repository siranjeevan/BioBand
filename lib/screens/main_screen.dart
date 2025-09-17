import 'package:flutter/material.dart';
import 'dart:math' as math;
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
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
              color: Colors.white,
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
          Navigator.pushReplacementNamed(context, '/');
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
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      decoration: _backgroundDecoration,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHealthAnalysis(),
              SizedBox(height: screenHeight * 0.025),
              Expanded(child: _buildHealthMetrics()),
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
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: GlassContainer(
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
            ),
          ),
        );
      },
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
        Expanded(
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: screenWidth * 0.04,
            crossAxisSpacing: screenWidth * 0.04,
            childAspectRatio: aspectRatio,
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
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_animationController.value * 0.1),
          child: GlassContainer(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedIcon(icon, color, animationType, screenWidth),
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
          ),
        );
      },
    );
  }

  Widget _buildAnimatedIcon(IconData icon, Color color, String animationType, double screenWidth) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        Widget animatedIcon = Icon(
          icon,
          color: color,
          size: screenWidth * 0.07,
        );

        switch (animationType) {
          case 'heartbeat':
            final heartbeatScale = 1.0 + (0.2 * (1 + math.sin(_animationController.value * 2 * math.pi * 2)));
            animatedIcon = Transform.scale(
              scale: heartbeatScale,
              child: animatedIcon,
            );
            break;
          case 'bubble':
            final bubbleOffset = 5 * math.sin(_animationController.value * 2 * math.pi);
            animatedIcon = Transform.translate(
              offset: Offset(0, bubbleOffset),
              child: animatedIcon,
            );
            break;
          case 'bounce':
            final bounceOffset = 8 * (1 - (2 * _animationController.value - 1).abs());
            animatedIcon = Transform.translate(
              offset: Offset(0, -bounceOffset),
              child: animatedIcon,
            );
            break;
          case 'fire':
            final fireRotation = 0.1 * math.sin(_animationController.value * 2 * math.pi * 3);
            animatedIcon = Transform.rotate(
              angle: fireRotation,
              child: animatedIcon,
            );
            break;
        }

        return Container(
          padding: EdgeInsets.all(screenWidth * 0.03),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: animatedIcon,
        );
      },
    );
  }
}