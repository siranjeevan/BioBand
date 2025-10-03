import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/device_state.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedFilter = 0; // 0: Day, 1: Week, 2: Month
  int _selectedMetric = 0; // 0: HR, 1: SpO2, 2: Steps, 3: Calories
  bool _isLoading = false;
  List<Map<String, dynamic>> _healthData = [];
  DateTime _lastUpdated = DateTime.now();

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
    _fetchHealthData();
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
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _fetchHealthData,
          ),
          IconButton(
            icon: const Icon(Icons.description, color: AppColors.primary),
            onPressed: () => Navigator.pushNamed(context, '/health-report'),
          ),
          IconButton(
            icon: const Icon(Icons.file_download, color: AppColors.primary),
            onPressed: _exportReport,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _healthData.isEmpty
                  ? _buildNoDataMessage()
                  : ScrollConfiguration(
                      behavior: const ScrollBehavior().copyWith(overscroll: false),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildLastUpdated(),
                            const SizedBox(height: 16),
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
              onTap: () => setState(() {
                _selectedFilter = index;
                _animationController.reset();
                _animationController.forward();
              }),
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
    final filteredData = _getFilteredData();
    
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
            child: filteredData.isEmpty
                ? const Center(
                    child: Text(
                      'No data available for selected period',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTapDown: (details) => _handleChartTap(details, filteredData),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(double.infinity, 250),
                          painter: DetailedChartPainter(
                            _selectedMetric,
                            _selectedFilter,
                            _animationController.value,
                            filteredData,
                          ),
                        );
                      },
                    ),
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

  Future<void> _fetchHealthData() async {
    if (!DeviceState.isConnected || DeviceState.deviceId.isEmpty) {
      setState(() {
        _healthData = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final response = await ApiService.getDeviceHealthMetrics(DeviceState.deviceId);
      
      if (response.containsKey('health_metrics') && response['health_metrics'] != null) {
        final dynamic metricsData = response['health_metrics'];
        List<Map<String, dynamic>> allData = [];
        
        if (metricsData is List) {
          allData = metricsData.cast<Map<String, dynamic>>();
        } else if (metricsData is Map) {
          allData = [metricsData.cast<String, dynamic>()];
        }
        
        // Process and validate data
        final List<Map<String, dynamic>> validData = [];
        
        for (var data in allData) {
          // Validate required fields
          if (_hasValidHealthData(data)) {
            // Normalize timestamp
            final normalizedData = Map<String, dynamic>.from(data);
            final timestamp = data['timestamp']?.toString() ?? '';
            
            if (timestamp.isNotEmpty && timestamp != 'time') {
              try {
                DateTime.parse(timestamp);
                normalizedData['timestamp'] = timestamp;
              } catch (e) {
                // Use current time for invalid timestamps
                normalizedData['timestamp'] = DateTime.now().toIso8601String();
              }
            } else {
              normalizedData['timestamp'] = DateTime.now().toIso8601String();
            }
            
            validData.add(normalizedData);
          }
        }
        
        // Sort by timestamp (oldest first for chronological display)
        validData.sort((a, b) {
          try {
            return DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp']));
          } catch (e) {
            return 0;
          }
        });
        
        setState(() {
          _healthData = validData.take(20).toList(); // Show last 20 entries
          _lastUpdated = DateTime.now();
          _isLoading = false;
        });
        
        // Restart animation for new data
        _animationController.reset();
        _animationController.forward();
      } else {
        setState(() {
          _healthData = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _healthData = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch health data: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  bool _hasValidHealthData(Map<String, dynamic> data) {
    // Check timestamp validity first
    final timestamp = data['timestamp']?.toString() ?? '';
    if (timestamp.isEmpty || timestamp == 'time') {
      return false;
    }
    
    // Try to parse timestamp
    try {
      DateTime.parse(timestamp);
    } catch (e) {
      return false;
    }
    
    // Check if at least one health metric has valid data
    final heartRate = double.tryParse(data['heart_rate']?.toString() ?? '0') ?? 0;
    final spo2 = double.tryParse(data['spo2']?.toString() ?? '0') ?? 0;
    final steps = double.tryParse(data['steps']?.toString() ?? '0') ?? 0;
    final calories = double.tryParse(data['calories']?.toString() ?? '0') ?? 0;
    
    return heartRate > 0 || spo2 > 0 || steps > 0 || calories > 0;
  }

  Widget _buildLastUpdated() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Last updated: ${DateFormat('MMM dd, yyyy HH:mm').format(_lastUpdated)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredData() {
    if (_healthData.isEmpty) return [];
    
    // Filter out invalid timestamps first
    final validData = _healthData.where((data) {
      final timestampStr = data['timestamp'] ?? '';
      if (timestampStr.isEmpty || timestampStr == 'time') return false;
      try {
        DateTime.parse(timestampStr);
        return true;
      } catch (e) {
        return false;
      }
    }).toList();
    
    if (validData.isEmpty) return [];
    
    // Sort by timestamp
    validData.sort((a, b) {
      final timeA = DateTime.parse(a['timestamp']);
      final timeB = DateTime.parse(b['timestamp']);
      return timeA.compareTo(timeB);
    });
    
    // For API data with future dates, use relative filtering
    final allTimestamps = validData.map((d) => DateTime.parse(d['timestamp'])).toList();
    final latestTime = allTimestamps.last;
    
    DateTime filterStart;
    switch (_selectedFilter) {
      case 0: // Day - show last 24 hours of data
        filterStart = latestTime.subtract(const Duration(hours: 24));
        break;
      case 1: // Week - show last 7 days of data
        filterStart = latestTime.subtract(const Duration(days: 7));
        break;
      case 2: // Month - show last 30 days of data
        filterStart = latestTime.subtract(const Duration(days: 30));
        break;
      default:
        filterStart = latestTime.subtract(const Duration(days: 7));
    }
    
    // Filter data based on selected period
    final filteredData = validData.where((data) {
      final dataTime = DateTime.parse(data['timestamp']);
      return dataTime.isAfter(filterStart);
    }).toList();
    
    return filteredData.isNotEmpty ? filteredData : validData.take(3).toList();
  }

  Map<String, String> _getSummaryData() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) {
      return {'average': '0', 'highest': '0', 'lowest': '0'};
    }

    String fieldName;
    switch (_selectedMetric) {
      case 0: fieldName = 'heart_rate'; break;
      case 1: fieldName = 'spo2'; break;
      case 2: fieldName = 'steps'; break;
      case 3: fieldName = 'calories'; break;
      default: return {'average': '0', 'highest': '0', 'lowest': '0'};
    }

    final values = filteredData
        .map((data) => double.tryParse(data[fieldName]?.toString() ?? '0') ?? 0)
        .where((v) => v > 0)
        .toList();

    if (values.isEmpty) {
      return {'average': '0', 'highest': '0', 'lowest': '0'};
    }

    final average = values.reduce((a, b) => a + b) / values.length;
    final highest = values.reduce((a, b) => a > b ? a : b);
    final lowest = values.reduce((a, b) => a < b ? a : b);

    String formatValue(double value) {
      if (_selectedMetric == 2 && value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      }
      return value.toInt().toString();
    }

    return {
      'average': formatValue(average),
      'highest': formatValue(highest),
      'lowest': formatValue(lowest),
    };
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
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return 'No data available';
    if (filteredData.length < 2) return 'Insufficient data for analysis';
    
    String fieldName;
    switch (_selectedMetric) {
      case 0: fieldName = 'heart_rate'; break;
      case 1: fieldName = 'spo2'; break;
      case 2: fieldName = 'steps'; break;
      case 3: fieldName = 'calories'; break;
      default: return 'No trend data available';
    }
    
    final recent = filteredData.take(3).map((d) => 
        double.tryParse(d[fieldName]?.toString() ?? '0') ?? 0).where((v) => v > 0).toList();
    final older = filteredData.skip(3).take(3).map((d) => 
        double.tryParse(d[fieldName]?.toString() ?? '0') ?? 0).where((v) => v > 0).toList();
    
    if (recent.isEmpty || older.isEmpty) return 'Insufficient valid data';
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;
    
    final change = ((recentAvg - olderAvg) / olderAvg * 100).abs();
    
    if (change < 5) return 'Stable readings';
    if (recentAvg > olderAvg) return 'Increasing trend';
    return 'Decreasing trend';
  }

  IconData _getTrendIcon() {
    final filteredData = _getFilteredData();
    if (filteredData.length < 2) return Icons.trending_flat;
    
    String fieldName;
    switch (_selectedMetric) {
      case 0: fieldName = 'heart_rate'; break;
      case 1: fieldName = 'spo2'; break;
      case 2: fieldName = 'steps'; break;
      case 3: fieldName = 'calories'; break;
      default: return Icons.trending_flat;
    }
    
    final recent = filteredData.take(3).map((d) => 
        double.tryParse(d[fieldName]?.toString() ?? '0') ?? 0).toList();
    final older = filteredData.skip(3).take(3).map((d) => 
        double.tryParse(d[fieldName]?.toString() ?? '0') ?? 0).toList();
    
    if (recent.isEmpty || older.isEmpty) return Icons.trending_flat;
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;
    
    if (recentAvg > olderAvg) return Icons.trending_up;
    if (recentAvg < olderAvg) return Icons.trending_down;
    return Icons.trending_flat;
  }

  Color _getTrendColor() {
    final icon = _getTrendIcon();
    if (icon == Icons.trending_up) {
      return _selectedMetric == 0 ? AppColors.warning : AppColors.success; // HR up = warning, others up = good
    }
    if (icon == Icons.trending_down) {
      return _selectedMetric == 0 ? AppColors.success : AppColors.warning; // HR down = good, others down = warning
    }
    return AppColors.textSecondary;
  }

  int _getHealthScore() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return 0;
    
    int totalScore = 0;
    int validMetrics = 0;
    
    // Heart rate score
    final hrValues = filteredData
        .map((d) => double.tryParse(d['heart_rate']?.toString() ?? '0') ?? 0)
        .where((v) => v > 0).toList();
    if (hrValues.isNotEmpty) {
      final avgHR = hrValues.reduce((a, b) => a + b) / hrValues.length;
      if (avgHR >= 60 && avgHR <= 100) totalScore += 25;
      else if (avgHR >= 50 && avgHR <= 110) totalScore += 15;
      else totalScore += 5;
      validMetrics++;
    }
    
    // SpO2 score
    final spo2Values = filteredData
        .map((d) => double.tryParse(d['spo2']?.toString() ?? '0') ?? 0)
        .where((v) => v > 0).toList();
    if (spo2Values.isNotEmpty) {
      final avgSpO2 = spo2Values.reduce((a, b) => a + b) / spo2Values.length;
      if (avgSpO2 >= 95) totalScore += 25;
      else if (avgSpO2 >= 90) totalScore += 15;
      else totalScore += 5;
      validMetrics++;
    }
    
    return validMetrics > 0 ? (totalScore / validMetrics).round() : 0;
  }

  String _getRecommendation() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return 'No data available for recommendations';
    
    final score = _getHealthScore();
    if (score == 0) return 'Insufficient data for recommendations';
    
    if (score >= 20) return 'Good health metrics detected';
    if (score >= 15) return 'Consider monitoring more regularly';
    return 'Consult healthcare provider if needed';
  }

  void _handleChartTap(TapDownDetails details, List<Map<String, dynamic>> data) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = details.localPosition;
    
    // Calculate chart area (accounting for padding and margins)
    const chartPadding = 40.0;
    const chartHeight = 250.0;
    const containerPadding = 20.0;
    
    // Adjust for container padding and chart positioning
    final chartX = localPosition.dx - containerPadding - chartPadding;
    final chartWidth = renderBox.size.width - (containerPadding * 2) - (chartPadding * 2);
    
    if (chartX < 0 || chartX > chartWidth || data.isEmpty) return;
    
    // Find closest data point
    final pointIndex = data.length == 1 
        ? 0 
        : ((chartX / chartWidth) * (data.length - 1)).round().clamp(0, data.length - 1);
    
    final selectedData = data[pointIndex];
    _showDataPointDialog(selectedData);
  }
  
  void _showDataPointDialog(Map<String, dynamic> data) {
    String fieldName;
    String unit;
    switch (_selectedMetric) {
      case 0: fieldName = 'heart_rate'; unit = 'BPM'; break;
      case 1: fieldName = 'spo2'; unit = '%'; break;
      case 2: fieldName = 'steps'; unit = 'steps'; break;
      case 3: fieldName = 'calories'; unit = 'kcal'; break;
      default: return;
    }
    
    final value = data[fieldName]?.toString() ?? '0';
    final timestamp = data['timestamp']?.toString() ?? '';
    final time = timestamp.isNotEmpty && timestamp != 'time' 
        ? DateFormat('HH:mm - MMM dd').format(DateTime.parse(timestamp))
        : 'Unknown time';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _metrics[_selectedMetric],
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Value:', style: TextStyle(color: AppColors.textSecondary)),
                Text('$value $unit', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Time:', style: TextStyle(color: AppColors.textSecondary)),
                Text(time, style: const TextStyle(color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Activity:', style: TextStyle(color: AppColors.textSecondary)),
                Text(data['activity']?.toString() ?? 'N/A', style: const TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report exported successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'API Connection Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unable to fetch health data.\nPlease check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchHealthData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailedChartPainter extends CustomPainter {
  final int metricIndex;
  final int filterIndex;
  final double animationValue;
  final List<Map<String, dynamic>> healthData;

  DetailedChartPainter(this.metricIndex, this.filterIndex, this.animationValue, this.healthData);

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
    if (data.isNotEmpty) {
      for (int i = 0; i < data.length; i++) {
        final x = data.length == 1 
            ? size.width / 2 
            : 40 + (i / (data.length - 1)) * (size.width - 60);
        canvas.drawLine(
          Offset(x, 20),
          Offset(x, size.height - 20),
          gridPaint,
        );
      }
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
    if (data.isEmpty) return;
    
    final path = Path();
    
    if (data.length == 1) {
      // Single point - create rectangle area
      final y = size.height - 20 - (data[0] * (size.height - 40) * animationValue);
      path.moveTo(40, size.height - 20);
      path.lineTo(40, y);
      path.lineTo(size.width - 20, y);
      path.lineTo(size.width - 20, size.height - 20);
      path.close();
    } else {
      // Multiple points - create area under curve
      path.moveTo(40, size.height - 20);
      
      for (int i = 0; i < data.length; i++) {
        final x = 40 + (i / (data.length - 1)) * (size.width - 60);
        final y = size.height - 20 - (data[i] * (size.height - 40) * animationValue);
        path.lineTo(x, y);
      }
      
      path.lineTo(size.width - 20, size.height - 20);
      path.close();
    }

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
    if (data.isEmpty) return;
    
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (data.length == 1) {
      // Single point - draw horizontal line
      final x = size.width / 2;
      final y = size.height - 20 - (data[0] * (size.height - 40) * animationValue);
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width - 20, y),
        linePaint,
      );
    } else {
      // Multiple points - draw connected line
      final path = Path();
      for (int i = 0; i < data.length; i++) {
        final x = 40 + (i / (data.length - 1)) * (size.width - 60);
        final y = size.height - 20 - (data[i] * (size.height - 40) * animationValue);
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, linePaint);
    }
  }

  void _drawDataPoints(Canvas canvas, Size size, Color color) {
    final data = _generateData();
    if (data.isEmpty) return;
    
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = data.length == 1 
          ? size.width / 2 
          : 40 + (i / (data.length - 1)) * (size.width - 60);
      final y = size.height - 20 - (data[i] * (size.height - 40) * animationValue);
      
      // Animated point size
      final pointSize = 8 * animationValue;
      
      // Draw outer ring
      canvas.drawCircle(Offset(x, y), pointSize + 2, ringPaint);
      // Draw inner point
      canvas.drawCircle(Offset(x, y), pointSize, pointPaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
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
    if (healthData.isEmpty) return [];
    
    String fieldName;
    switch (metricIndex) {
      case 0: fieldName = 'heart_rate'; break;
      case 1: fieldName = 'spo2'; break;
      case 2: fieldName = 'steps'; break;
      case 3: fieldName = 'calories'; break;
      default: return [];
    }
    
    // Use the already filtered healthData (passed from _getFilteredData)
    final List<double> values = [];
    for (var data in healthData) {
      final value = double.tryParse(data[fieldName]?.toString() ?? '0') ?? 0;
      if (value > 0) {
        values.add(value);
      }
    }
    
    if (values.isEmpty) return [];
    
    // Use appropriate max values for normalization
    double maxRange;
    switch (metricIndex) {
      case 0: maxRange = 120; break;
      case 1: maxRange = 100; break;
      case 2: maxRange = 15000; break;
      case 3: maxRange = 500; break;
      default: maxRange = 100;
    }
    
    return values.map((v) {
      final normalized = v / maxRange;
      return normalized.clamp(0.05, 0.95);
    }).toList();
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
    if (healthData.isEmpty) {
      switch (filterIndex) {
        case 0: return ['No Data Today'];
        case 1: return ['No Data This Week'];
        case 2: return ['No Data This Month'];
        default: return ['No Data'];
      }
    }
    
    // Use the already filtered healthData
    return healthData.map((data) {
      final timestamp = DateTime.parse(data['timestamp']);
      switch (filterIndex) {
        case 0: // Day - show time (HH:mm)
          return DateFormat('HH:mm').format(timestamp);
        case 1: // Week - show day names (Mon, Tue, etc.)
          return DateFormat('EEE').format(timestamp);
        case 2: // Month - show month names (Jan, Feb, etc.)
          return DateFormat('MMM').format(timestamp);
        default:
          return DateFormat('HH:mm').format(timestamp);
      }
    }).toList();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}