import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/sensor_data.dart';
import '../widgets/sensor_card.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _startSensorUpdates();
    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startSensorUpdates() {
    _timer = Timer.periodic(Duration(seconds: SensorData.refreshRate), (timer) {
      setState(() {
        SensorData.heartRate = 65 + Random().nextInt(30);
        SensorData.steps += Random().nextInt(3);
        SensorData.calories = (SensorData.steps * 0.04).round();
        SensorData.spo2 = 95 + Random().nextInt(5);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: ShaderMask(
                  shaderCallback: (bounds) => AppColors.gradient1.createShader(bounds),
                  child: const Text(
                    'Health Monitor',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                centerTitle: true,
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.settings_outlined, color: AppColors.primary),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: 20,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),
                    Text(
                      'Health Metrics',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMetricsGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      opacity: 0.05,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.gradient1,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.waving_hand,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your health data is being monitored',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;
    final aspectRatio = screenWidth > 600 ? 1.2 : 0.9;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: aspectRatio,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            )),
            child: SensorCard(
              icon: Icons.favorite_rounded,
              value: SensorData.heartRate.toString(),
              label: 'Heart Rate',
              unit: 'BPM',
              color: AppColors.error,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DetailScreen(type: 'heart')),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
            )),
            child: SensorCard(
              icon: Icons.directions_walk_rounded,
              value: SensorData.steps.toString(),
              label: 'Steps',
              unit: 'today',
              color: AppColors.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DetailScreen(type: 'steps')),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
            )),
            child: SensorCard(
              icon: Icons.local_fire_department_rounded,
              value: SensorData.calories.toString(),
              label: 'Calories',
              unit: 'kcal',
              color: AppColors.warning,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DetailScreen(type: 'calories')),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
            )),
            child: SensorCard(
              icon: Icons.air_rounded,
              value: SensorData.spo2.toString(),
              label: 'Blood O₂',
              unit: '%',
              color: AppColors.secondary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DetailScreen(type: 'spo2')),
              ),
            ),
          ),
        ),
      ],
    );
  }
}