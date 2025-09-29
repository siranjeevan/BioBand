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
        automaticallyImplyLeading: false,
        title: const Text(
          'Health Reports',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
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
          child: ScrollConfiguration(
  behavior: const ScrollBehavior().copyWith(overscroll: false),
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
)

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
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
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
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
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
                color: AppColors.textPrimary,
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
            height: 250,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 250),
                  painter: DetailedChartPainter(
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
            AppColors.textPrimary,
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
                color: AppColors.textPrimary,
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

class DetailedChartPainter extends CustomPainter {
  final int metricIndex;
  final int filterIndex;
  final double animationValue;

  DetailedChartPainter(this.metricIndex, this.filterIndex, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [AppColors.error, AppColors.textPrimary, AppColors.success, AppColors.warning];
    final primaryColor = colors[metricIndex];
    
    // Draw grid lines
    _drawGrid(canvas, size);
    
    // Draw axes
    _drawAxes(canvas, size);
    
    // Draw data area fill
    _drawAreaFill(canvas, size, primaryColor);
    
    // Draw main line
    _drawMainLine(canvas, size, primaryColor);
    
    // Draw data points
    _drawDataPoints(canvas, size, primaryColor);
    
    // Draw labels
    _drawLabels(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = (i / 5) * (size.height - 40) + 20;
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width - 20, y),
        gridPaint,
      );
    }

    // Vertical grid lines
    final data = _generateData();
    for (int i = 0; i < data.length; i++) {
      final x = 40 + (i / (data.length - 1)) * (size.width - 60);
      canvas.drawLine(
        Offset(x, 20),
        Offset(x, size.height - 20),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.3)
      ..strokeWidth = 2;

    // Y-axis
    canvas.drawLine(
      Offset(40, 20),
      Offset(40, size.height - 20),
      axisPaint,
    );

    // X-axis
    canvas.drawLine(
      Offset(40, size.height - 20),
      Offset(size.width - 20, size.height - 20),
      axisPaint,
    );
  }

  void _drawAreaFill(Canvas canvas, Size size, Color color) {
    final data = _generateData();
    final path = Path();
    
    path.moveTo(40, size.height - 20);
    
    for (int i = 0; i < data.length; i++) {
      final x = 40 + (i / (data.length - 1)) * (size.width - 60);
      final y = size.height - 20 - (data[i] * (size.height - 40) * animationValue);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width - 20, size.height - 20);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, fillPaint);
  }

  void _drawMainLine(Canvas canvas, Size size, Color color) {
    final data = _generateData();
    final path = Path();
    
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < data.length; i++) {
      final x = 40 + (i / (data.length - 1)) * (size.width - 60);
      final y = size.height - 20 - (data[i] * (size.height - 40) * animationValue);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Create smooth curves
        final prevX = 40 + ((i - 1) / (data.length - 1)) * (size.width - 60);
        final prevY = size.height - 20 - (data[i - 1] * (size.height - 40) * animationValue);
        final cpX = (prevX + x) / 2;
        
        path.quadraticBezierTo(cpX, prevY, x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  void _drawDataPoints(Canvas canvas, Size size, Color color) {
    final data = _generateData();
    
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final ringPaint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = 40 + (i / (data.length - 1)) * (size.width - 60);
      final y = size.height - 20 - (data[i] * (size.height - 40) * animationValue);
      
      // Animated point size
      final pointSize = 6 * animationValue;
      
      // Draw outer ring
      canvas.drawCircle(Offset(x, y), pointSize + 2, ringPaint);
      // Draw inner point
      canvas.drawCircle(Offset(x, y), pointSize, pointPaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Y-axis labels
    final maxValue = _getMaxValue();
    for (int i = 0; i <= 5; i++) {
      final value = (maxValue * i / 5).toInt();
      final y = size.height - 20 - (i / 5) * (size.height - 40);
      
      textPainter.text = TextSpan(
        text: value.toString(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }

    // X-axis labels
    final labels = _getTimeLabels();
    for (int i = 0; i < labels.length; i++) {
      final x = 40 + (i / (labels.length - 1)) * (size.width - 60);
      
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 15));
    }
  }

  List<double> _generateData() {
    // Generate realistic data based on metric type
    switch (metricIndex) {
      case 0: // Heart Rate
        return [0.6, 0.7, 0.65, 0.8, 0.75, 0.9, 0.85];
      case 1: // SpO2
        return [0.95, 0.97, 0.96, 0.98, 0.97, 0.99, 0.98];
      case 2: // Steps
        return [0.3, 0.5, 0.4, 0.7, 0.6, 0.9, 0.8];
      case 3: // Calories
        return [0.4, 0.6, 0.5, 0.8, 0.7, 0.9, 0.85];
      default:
        return [0.5, 0.6, 0.7, 0.8, 0.6, 0.9, 0.7];
    }
  }

  int _getMaxValue() {
    switch (metricIndex) {
      case 0: return 100; // Heart Rate
      case 1: return 100; // SpO2
      case 2: return 15000; // Steps
      case 3: return 500; // Calories
      default: return 100;
    }
  }

  List<String> _getTimeLabels() {
    switch (filterIndex) {
      case 0: // Day
        return ['6AM', '9AM', '12PM', '3PM', '6PM', '9PM', '12AM'];
      case 1: // Week
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 2: // Month
        return ['W1', 'W2', 'W3', 'W4'];
      default:
        return ['1', '2', '3', '4', '5', '6', '7'];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}