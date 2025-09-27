import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/sensor_data.dart';
import '../models/user_settings.dart';
import '../models/health_analysis.dart';

class HealthOverviewScreen extends StatefulWidget {
  const HealthOverviewScreen({super.key});

  @override
  State<HealthOverviewScreen> createState() => _HealthOverviewScreenState();
}

class _HealthOverviewScreenState extends State<HealthOverviewScreen> with TickerProviderStateMixin {
  Timer? _realTimeTimer;
  bool _isDetailedView = false;
  int _selectedMetric = 0;
  String? _tappedValue;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _startRealTimeUpdates();
    _animationController.forward();
  }

  @override
  void dispose() {
    _realTimeTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startRealTimeUpdates() {
    _realTimeTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        SensorData.heartRate = 65 + Random().nextInt(25);
        SensorData.spo2 = 95 + Random().nextInt(5);
        SensorData.steps += Random().nextInt(5);
        SensorData.calories = (SensorData.steps * 0.04).round();
      });
    });
  }

  Color _getHealthColor(String metric, double value) {
    switch (metric) {
      case 'heartRate':
        if (value < 60 || value > 100) return AppColors.error;
        if (value < 65 || value > 90) return AppColors.warning;
        return AppColors.success;
      case 'spo2':
        if (value < 92) return AppColors.error;
        if (value < 95) return AppColors.warning;
        return AppColors.success;
      case 'steps':
        if (value < 5000) return AppColors.warning;
        if (value > 8000) return AppColors.success;
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
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
          'Health Overview',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDetailedView ? Icons.visibility_off : Icons.visibility,
              color: AppColors.primary,
            ),
            onPressed: () => setState(() => _isDetailedView = !_isDetailedView),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDailyHealthReport(),
              const SizedBox(height: 20),
              _buildKeyMetrics(),
              const SizedBox(height: 20),
              _buildHealthInsights(),
              const SizedBox(height: 20),
              _buildInteractiveChart(),
              const SizedBox(height: 20),
              if (_isDetailedView) ...[
                _buildDetailedAnalysis(),
                const SizedBox(height: 20),
              ],
              _buildDisclaimer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      children: [
        // TOP PRIORITY: Heart Rate & SpO2 - Largest, most prominent
        GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.monitor_heart, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Critical Vitals',
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: AppColors.success, size: 10),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildPrimaryVitalCard(
                      'Heart Rate',
                      '${SensorData.heartRate}',
                      'BPM',
                      Icons.favorite,
                      _getHealthColor('heartRate', SensorData.heartRate.toDouble()),
                      _getHealthStatus('heartRate', SensorData.heartRate.toDouble()),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildPrimaryVitalCard(
                      'Blood Oxygen',
                      '${SensorData.spo2}',
                      '%',
                      Icons.air,
                      _getHealthColor('spo2', SensorData.spo2.toDouble()),
                      _getHealthStatus('spo2', SensorData.spo2.toDouble()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // SECONDARY: Steps & Calories - Smaller, less prominent
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity Metrics',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSecondaryVitalCard(
                      'Steps',
                      '${SensorData.steps}',
                      'today',
                      Icons.directions_walk,
                      _getHealthColor('steps', SensorData.steps.toDouble()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSecondaryVitalCard(
                      'Calories',
                      '${SensorData.calories}',
                      'kcal',
                      Icons.local_fire_department,
                      AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryVitalCard(String title, String value, String unit, IconData icon, Color color, String status) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.12,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1.0,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: screenWidth * 0.025,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryVitalCard(String title, String value, String unit, IconData icon, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.065,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: screenWidth * 0.028,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getHealthStatus(String metric, double value) {
    switch (metric) {
      case 'heartRate':
        if (value < 60) return 'LOW';
        if (value > 100) return 'HIGH';
        if (value > 90) return 'ELEVATED';
        return 'NORMAL';
      case 'spo2':
        if (value < 92) return 'CRITICAL';
        if (value < 95) return 'LOW';
        if (value < 97) return 'FAIR';
        return 'EXCELLENT';
      default:
        return 'NORMAL';
    }
  }

  Widget _buildInteractiveChart() {
    final metrics = ['Heart Rate', 'Oxygen', 'Steps', 'Calories'];
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Interactive Trends',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tap chart points for exact values • Swipe to change metrics',
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: metrics.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedMetric == index;
                final colors = [AppColors.error, AppColors.secondary, AppColors.success, AppColors.warning];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMetric = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected 
                        ? LinearGradient(
                            colors: [colors[index], colors[index].withValues(alpha: 0.7)],
                          )
                        : null,
                      color: !isSelected ? AppColors.surface.withValues(alpha: 0.3) : null,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected ? colors[index] : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: colors[index].withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ] : null,
                    ),
                    child: Text(
                      metrics[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: screenWidth * 0.032,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onPanUpdate: (details) {
              if (details.delta.dx > 10) {
                setState(() {
                  _selectedMetric = (_selectedMetric - 1) % metrics.length;
                });
              } else if (details.delta.dx < -10) {
                setState(() {
                  _selectedMetric = (_selectedMetric + 1) % metrics.length;
                });
              }
            },
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
              ),
              child: _buildChart(_selectedMetric),
            ),
          ),
          if (_tappedValue != null)
            Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Exact Value: $_tappedValue ${_getUnit(_selectedMetric)}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildChart(int metricIndex) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (details) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition = renderBox.globalToLocal(details.globalPosition);
            _handleChartTap(localPosition, metricIndex);
          },
          child: CustomPaint(
            size: const Size(double.infinity, 180),
            painter: InteractiveChartPainter(
              metricIndex,
              _animationController.value,
            ),
          ),
        );
      },
    );
  }

  void _handleChartTap(Offset position, int metricIndex) {
    final data = [
      [72, 75, 68, 74, 71, 76, 73], // Heart Rate
      [97, 98, 96, 99, 97, 98, 97], // Oxygen
      [4500, 5200, 6800, 7200, 8100, 8900, 9200], // Steps
      [180, 208, 272, 288, 324, 356, 368], // Calories
    ];
    
    final values = data[metricIndex];
    final chartWidth = MediaQuery.of(context).size.width - 80; // Account for padding
    final pointSpacing = chartWidth / (values.length - 1);
    
    for (int i = 0; i < values.length; i++) {
      final pointX = i * pointSpacing;
      if ((position.dx - pointX).abs() < 30) { // 30px tap tolerance
        setState(() {
          _tappedValue = values[i].toString();
        });
        // Clear tapped value after 3 seconds
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _tappedValue = null;
            });
          }
        });
        break;
      }
    }
  }

  String _getUnit(int metricIndex) {
    switch (metricIndex) {
      case 0: return 'BPM';
      case 1: return '%';
      case 2: return 'steps';
      case 3: return 'kcal';
      default: return '';
    }
  }

  Widget _buildDetailedAnalysis() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Deep Dive Analysis',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Advanced metrics for health enthusiasts',
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          _buildAnalysisItem(
            'Resting Heart Rate', 
            '${UserSettings.restingHeartRate} BPM', 
            _getRestingHRStatus(),
            Icons.favorite_border,
          ),
          _buildAnalysisItem(
            'Heart Rate Variability', 
            '${35 + Random().nextInt(20)} ms', 
            'Recovery indicator',
            Icons.timeline,
          ),
          _buildAnalysisItem(
            'Oxygen Saturation Trend', 
            '${SensorData.spo2}% avg', 
            _getSpO2Trend(),
            Icons.air,
          ),
          _buildAnalysisItem(
            'Daily Activity Score', 
            '${(SensorData.steps / UserSettings.dailyStepsGoal * 100).toInt()}%', 
            _getActivityLevel(),
            Icons.directions_walk,
          ),
          _buildAnalysisItem(
            'Caloric Burn Rate', 
            '${(SensorData.calories / 8).toStringAsFixed(1)} kcal/hr', 
            'Based on current activity',
            Icons.local_fire_department,
          ),
        ],
      ),
    );
  }

  String _getRestingHRStatus() {
    final current = SensorData.heartRate;
    final resting = UserSettings.restingHeartRate;
    final diff = current - resting;
    if (diff > 20) return 'Elevated - Check stress levels';
    if (diff > 10) return 'Slightly elevated';
    if (diff < -5) return 'Below resting - Good recovery';
    return 'Within normal range';
  }

  String _getSpO2Trend() {
    if (SensorData.spo2 >= 98) return 'Excellent oxygenation';
    if (SensorData.spo2 >= 96) return 'Good oxygen levels';
    if (SensorData.spo2 >= 94) return 'Fair - monitor closely';
    return 'Low - seek medical advice';
  }

  String _getActivityLevel() {
    final percentage = (SensorData.steps / UserSettings.dailyStepsGoal * 100);
    if (percentage >= 100) return 'Goal achieved! 🎉';
    if (percentage >= 75) return 'Almost there!';
    if (percentage >= 50) return 'Good progress';
    if (percentage >= 25) return 'Keep moving';
    return 'Get active today';
  }

  Widget _buildAnalysisItem(String title, String value, String status, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: screenWidth * 0.028,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.medical_information, color: AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Medical Disclaimer',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ NOT FOR MEDICAL DIAGNOSIS',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: screenWidth * 0.032,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Consumer-grade sensors (±5% accuracy margin)\n• For fitness and wellness tracking only\n• Not a substitute for professional medical advice\n• Consult healthcare providers for medical concerns',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: screenWidth * 0.03,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.verified_user, color: AppColors.success, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Data encrypted and stored locally for your privacy',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: screenWidth * 0.028,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InteractiveChartPainter extends CustomPainter {
  final int metricIndex;
  final double animationValue;

  InteractiveChartPainter(this.metricIndex, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final colors = [AppColors.error, AppColors.secondary, AppColors.success, AppColors.warning];
    paint.color = colors[metricIndex];

    final path = Path();
    final points = _generateDataPoints(size);
    
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final animatedY = size.height - (point.dy * animationValue);
      
      if (i == 0) {
        path.moveTo(point.dx, animatedY);
      } else {
        path.lineTo(point.dx, animatedY);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = colors[metricIndex]
      ..style = PaintingStyle.fill;

    for (final point in points) {
      final animatedY = size.height - (point.dy * animationValue);
      canvas.drawCircle(Offset(point.dx, animatedY), 4, pointPaint);
    }
  }

  List<Offset> _generateDataPoints(Size size) {
    final data = [
      [72, 75, 68, 74, 71, 76, 73], // Heart Rate
      [97, 98, 96, 99, 97, 98, 97], // Oxygen
      [4500, 5200, 6800, 7200, 8100, 8900, 9200], // Steps
      [180, 208, 272, 288, 324, 356, 368], // Calories
    ];

    final values = data[metricIndex];
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();
    final minValue = values.reduce((a, b) => a < b ? a : b).toDouble();
    
    return values.asMap().entries.map((entry) {
      final x = (entry.key / (values.length - 1)) * size.width;
      final normalizedValue = (entry.value - minValue) / (maxValue - minValue);
      final y = normalizedValue * (size.height - 40) + 20;
      return Offset(x, y);
    }).toList();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
  Widget _buildDailyHealthReport() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.gradient1,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Health Report',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      DateTime.now().toString().split(' ')[0],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDailyMetricsGrid(),
        ],
      ),
    );
  }
  
  Widget _buildDailyMetricsGrid() {
    final metrics = HealthAnalysis.getDailyMetrics();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: metric.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: metric.color.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.name,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${metric.value} ${metric.unit}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: metric.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metric.description,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHealthInsights() {
    final insights = HealthAnalysis.getHealthInsights();
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
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: insight.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    insight.icon,
                    color: insight.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: insight.color,
                        ),
                      ),
                      Text(
                        insight.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
