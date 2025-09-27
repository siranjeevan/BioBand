import 'package:flutter/material.dart';
import 'dart:math';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/sensor_data.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedFilter = 0; // 0: Day, 1: Week, 2: Month
  int _selectedMetric = 0; // 0: HR, 1: SpO2, 2: Steps, 3: Calories

  final List<String> _filters = ['Day', 'Week', 'Month'];
  final List<String> _metrics = ['Heart Rate', 'SpO₂', 'Steps', 'Calories'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Health Reports',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: AppColors.primary),
            onPressed: _exportReport,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFilterTabs(),
                const SizedBox(height: 24),
                _buildMetricSelector(),
                const SizedBox(height: 24),
                _buildChart(),
                const SizedBox(height: 24),
                _buildSummaryCards(),
                const SizedBox(height: 24),
                _buildTrendAnalysis(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilter == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _filters[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _metrics.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedMetric == index;
          final colors = [AppColors.error, AppColors.secondary, AppColors.success, AppColors.warning];
          
          return GestureDetector(
            onTap: () => setState(() => _selectedMetric = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? colors[index] : AppColors.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? colors[index] : AppColors.border,
                  width: 2,
                ),
              ),
              child: Text(
                _metrics[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${_metrics[_selectedMetric]} Trend',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: ChartPainter(
                    _selectedMetric,
                    _selectedFilter,
                    _animationController.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final data = _getSummaryData();
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Average',
            data['average']!,
            _getUnit(_selectedMetric),
            AppColors.primary,
            Icons.analytics,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Highest',
            data['highest']!,
            _getUnit(_selectedMetric),
            AppColors.success,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Lowest',
            data['lowest']!,
            _getUnit(_selectedMetric),
            AppColors.warning,
            Icons.trending_down,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, String unit, Color color, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Trend Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTrendItem(
            'Overall Trend',
            _getTrendDescription(),
            _getTrendIcon(),
            _getTrendColor(),
          ),
          const SizedBox(height: 12),
          _buildTrendItem(
            'Health Score',
            '${_getHealthScore()}/100',
            Icons.health_and_safety,
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildTrendItem(
            'Recommendation',
            _getRecommendation(),
            Icons.lightbulb,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String title, String description, IconData icon, Color color) {
    return Row(
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
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
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
    );
  }

  Map<String, String> _getSummaryData() {
    switch (_selectedMetric) {
      case 0: // Heart Rate
        return {'average': '72', 'highest': '89', 'lowest': '58'};
      case 1: // SpO2
        return {'average': '97', 'highest': '99', 'lowest': '95'};
      case 2: // Steps
        return {'average': '7.2K', 'highest': '12.5K', 'lowest': '3.1K'};
      case 3: // Calories
        return {'average': '288', 'highest': '450', 'lowest': '124'};
      default:
        return {'average': '0', 'highest': '0', 'lowest': '0'};
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

  String _getTrendDescription() {
    return 'Improving trend with consistent readings';
  }

  IconData _getTrendIcon() {
    return Icons.trending_up;
  }

  Color _getTrendColor() {
    return AppColors.success;
  }

  int _getHealthScore() {
    return 85;
  }

  String _getRecommendation() {
    return 'Maintain current activity levels for optimal health';
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report exported successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final int metricIndex;
  final int filterIndex;
  final double animationValue;

  ChartPainter(this.metricIndex, this.filterIndex, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final colors = [AppColors.error, AppColors.secondary, AppColors.success, AppColors.warning];
    paint.color = colors[metricIndex];

    final data = _generateData();
    final path = Path();
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i] * size.height * animationValue);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = colors[metricIndex]
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i] * size.height * animationValue);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  List<double> _generateData() {
    final random = Random();
    return List.generate(7, (index) => 0.3 + random.nextDouble() * 0.4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}