import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/device_state.dart';
import '../services/api_service.dart';

class HealthReportScreen extends StatefulWidget {
  const HealthReportScreen({super.key});

  @override
  State<HealthReportScreen> createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends State<HealthReportScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _healthData = [];
  DateTime _lastUpdated = DateTime.now();
  String _selectedPeriod = 'Today';
  
  final List<String> _periods = ['Today', 'This Week', 'This Month', 'All Time'];

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
      if (response['success'] == true && response['health_metrics'] != null) {
        final List<dynamic> metrics = response['health_metrics'];
        setState(() {
          _healthData = metrics.cast<Map<String, dynamic>>();
          _lastUpdated = DateTime.now();
          _isLoading = false;
        });
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

  List<Map<String, dynamic>> _getFilteredData() {
    if (_healthData.isEmpty) return [];
    
    final now = DateTime.now();
    DateTime cutoffDate;
    
    switch (_selectedPeriod) {
      case 'Today':
        cutoffDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case 'This Month':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case 'All Time':
        return _healthData;
      default:
        cutoffDate = DateTime(now.year, now.month, now.day);
    }
    
    return _healthData.where((data) {
      try {
        final timestamp = DateTime.parse(data['timestamp'] ?? data['created_at'] ?? '');
        return timestamp.isAfter(cutoffDate);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Health Report',
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
            icon: const Icon(Icons.share, color: AppColors.primary),
            onPressed: _shareReport,
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
              : ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildReportHeader(),
                        const SizedBox(height: 16),
                        _buildPeriodSelector(),
                        const SizedBox(height: 24),
                        _buildVitalsSummary(),
                        const SizedBox(height: 24),
                        _buildDetailedMetrics(),
                        const SizedBox(height: 24),
                        _buildHealthTrends(),
                        const SizedBox(height: 24),
                        _buildRecommendations(),
                        const SizedBox(height: 24),
                        _buildDataTable(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildReportHeader() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Health Report',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Generated: ${DateFormat('MMM dd, yyyy HH:mm').format(_lastUpdated)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.devices,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Device: ${DeviceState.isConnected ? DeviceState.deviceId : 'Not Connected'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVitalsSummary() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text(
            'No data available for selected period',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vitals Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildSummaryCard('Heart Rate', 'heart_rate', 'BPM', AppColors.error, Icons.favorite),
            _buildSummaryCard('Blood Oxygen', 'spo2', '%', AppColors.primary, Icons.air),
            _buildSummaryCard('Steps', 'steps', 'steps', AppColors.success, Icons.directions_walk),
            _buildSummaryCard('Calories', 'calories', 'kcal', AppColors.warning, Icons.local_fire_department),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String field, String unit, Color color, IconData icon) {
    final filteredData = _getFilteredData();
    final values = filteredData
        .map((d) => double.tryParse(d[field]?.toString() ?? '0') ?? 0)
        .where((v) => v > 0)
        .toList();

    if (values.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color.withValues(alpha: 0.5), size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'No data',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final average = values.reduce((a, b) => a + b) / values.length;
    final highest = values.reduce((a, b) => a > b ? a : b);
    final lowest = values.reduce((a, b) => a < b ? a : b);

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${average.toInt()} $unit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Avg (${lowest.toInt()}-${highest.toInt()})',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildMetricRow('Total Readings', '${filteredData.length}', Icons.analytics),
              const Divider(color: AppColors.border),
              _buildMetricRow('Data Quality', _getDataQuality(), Icons.verified),
              const Divider(color: AppColors.border),
              _buildMetricRow('Health Score', '${_calculateHealthScore()}/100', Icons.health_and_safety),
              const Divider(color: AppColors.border),
              _buildMetricRow('Monitoring Period', _getMonitoringPeriod(), Icons.schedule),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTrends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Trends',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTrendItem('Heart Rate Trend', _getTrendForMetric('heart_rate'), AppColors.error),
              const SizedBox(height: 16),
              _buildTrendItem('SpO2 Trend', _getTrendForMetric('spo2'), AppColors.primary),
              const SizedBox(height: 16),
              _buildTrendItem('Activity Trend', _getTrendForMetric('steps'), AppColors.success),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendItem(String title, Map<String, dynamic> trend, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(trend['icon'], color: color, size: 20),
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
                trend['description'],
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          trend['change'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: trend['isPositive'] ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Recommendations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: _getRecommendations().map((rec) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(rec['icon'], color: rec['color'], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rec['text'],
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return const SizedBox.shrink();

    // Sort by timestamp (most recent first)
    final sortedData = List<Map<String, dynamic>>.from(filteredData);
    sortedData.sort((a, b) {
      try {
        final aTime = DateTime.parse(a['timestamp'] ?? a['created_at'] ?? '');
        final bTime = DateTime.parse(b['timestamp'] ?? b['created_at'] ?? '');
        return bTime.compareTo(aTime);
      } catch (e) {
        return 0;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Raw Data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.surface.withValues(alpha: 0.1)),
              columns: const [
                DataColumn(label: Text('Time', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('HR', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('SpO2', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Steps', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Calories', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold))),
              ],
              rows: sortedData.take(10).map((data) {
                DateTime? timestamp;
                try {
                  timestamp = DateTime.parse(data['timestamp'] ?? data['created_at'] ?? '');
                } catch (e) {
                  timestamp = null;
                }

                return DataRow(
                  cells: [
                    DataCell(Text(
                      timestamp != null ? DateFormat('HH:mm').format(timestamp) : 'N/A',
                      style: const TextStyle(color: AppColors.textSecondary),
                    )),
                    DataCell(Text(
                      data['heart_rate']?.toString() ?? '-',
                      style: const TextStyle(color: AppColors.textPrimary),
                    )),
                    DataCell(Text(
                      data['spo2']?.toString() ?? '-',
                      style: const TextStyle(color: AppColors.textPrimary),
                    )),
                    DataCell(Text(
                      data['steps']?.toString() ?? '-',
                      style: const TextStyle(color: AppColors.textPrimary),
                    )),
                    DataCell(Text(
                      data['calories']?.toString() ?? '-',
                      style: const TextStyle(color: AppColors.textPrimary),
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _getDataQuality() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return 'No Data';
    
    int validReadings = 0;
    for (var data in filteredData) {
      if ((data['heart_rate'] != null && int.tryParse(data['heart_rate'].toString()) != null) ||
          (data['spo2'] != null && int.tryParse(data['spo2'].toString()) != null) ||
          (data['steps'] != null && int.tryParse(data['steps'].toString()) != null) ||
          (data['calories'] != null && int.tryParse(data['calories'].toString()) != null)) {
        validReadings++;
      }
    }
    
    final quality = (validReadings / filteredData.length * 100).round();
    if (quality >= 90) return 'Excellent';
    if (quality >= 70) return 'Good';
    if (quality >= 50) return 'Fair';
    return 'Poor';
  }

  int _calculateHealthScore() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return 0;
    
    int score = 0;
    int factors = 0;
    
    // Heart rate score
    final hrData = filteredData.where((d) => d['heart_rate'] != null).toList();
    if (hrData.isNotEmpty) {
      final avgHR = hrData.map((d) => double.tryParse(d['heart_rate'].toString()) ?? 0)
          .reduce((a, b) => a + b) / hrData.length;
      if (avgHR >= 60 && avgHR <= 100) score += 25;
      else if (avgHR >= 50 && avgHR <= 110) score += 15;
      else score += 5;
      factors++;
    }
    
    // SpO2 score
    final spo2Data = filteredData.where((d) => d['spo2'] != null).toList();
    if (spo2Data.isNotEmpty) {
      final avgSpO2 = spo2Data.map((d) => double.tryParse(d['spo2'].toString()) ?? 0)
          .reduce((a, b) => a + b) / spo2Data.length;
      if (avgSpO2 >= 95) score += 25;
      else if (avgSpO2 >= 90) score += 15;
      else score += 5;
      factors++;
    }
    
    // Activity score
    final stepsData = filteredData.where((d) => d['steps'] != null).toList();
    if (stepsData.isNotEmpty) {
      final avgSteps = stepsData.map((d) => double.tryParse(d['steps'].toString()) ?? 0)
          .reduce((a, b) => a + b) / stepsData.length;
      if (avgSteps >= 8000) score += 25;
      else if (avgSteps >= 5000) score += 15;
      else score += 5;
      factors++;
    }
    
    return factors > 0 ? (score / factors).round() : 0;
  }

  String _getMonitoringPeriod() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return 'No data';
    
    try {
      final timestamps = filteredData
          .map((d) => DateTime.parse(d['timestamp'] ?? d['created_at'] ?? ''))
          .toList();
      timestamps.sort();
      
      final duration = timestamps.last.difference(timestamps.first);
      if (duration.inDays > 0) {
        return '${duration.inDays} days';
      } else if (duration.inHours > 0) {
        return '${duration.inHours} hours';
      } else {
        return '${duration.inMinutes} minutes';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Map<String, dynamic> _getTrendForMetric(String metric) {
    final filteredData = _getFilteredData();
    if (filteredData.length < 2) {
      return {
        'icon': Icons.trending_flat,
        'description': 'Insufficient data for trend analysis',
        'change': 'N/A',
        'isPositive': true,
      };
    }
    
    final values = filteredData
        .map((d) => double.tryParse(d[metric]?.toString() ?? '0') ?? 0)
        .where((v) => v > 0)
        .toList();
    
    if (values.length < 2) {
      return {
        'icon': Icons.trending_flat,
        'description': 'No trend data available',
        'change': 'N/A',
        'isPositive': true,
      };
    }
    
    final recent = values.take(values.length ~/ 2).toList();
    final older = values.skip(values.length ~/ 2).toList();
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;
    
    final changePercent = ((recentAvg - olderAvg) / olderAvg * 100);
    final isIncreasing = changePercent > 5;
    final isDecreasing = changePercent < -5;
    
    IconData icon;
    String description;
    bool isPositive;
    
    if (isIncreasing) {
      icon = Icons.trending_up;
      description = 'Increasing trend detected';
      isPositive = metric != 'heart_rate'; // HR increase might be concerning
    } else if (isDecreasing) {
      icon = Icons.trending_down;
      description = 'Decreasing trend observed';
      isPositive = metric == 'heart_rate'; // HR decrease might be good
    } else {
      icon = Icons.trending_flat;
      description = 'Stable readings';
      isPositive = true;
    }
    
    return {
      'icon': icon,
      'description': description,
      'change': '${changePercent.abs().toStringAsFixed(1)}%',
      'isPositive': isPositive,
    };
  }

  List<Map<String, dynamic>> _getRecommendations() {
    final score = _calculateHealthScore();
    final filteredData = _getFilteredData();
    
    List<Map<String, dynamic>> recommendations = [];
    
    if (filteredData.isEmpty) {
      recommendations.add({
        'icon': Icons.bluetooth,
        'color': AppColors.primary,
        'text': 'Connect your device to start monitoring your health metrics',
      });
      return recommendations;
    }
    
    if (score >= 80) {
      recommendations.add({
        'icon': Icons.check_circle,
        'color': AppColors.success,
        'text': 'Excellent health metrics! Continue your current lifestyle',
      });
    } else if (score >= 60) {
      recommendations.add({
        'icon': Icons.trending_up,
        'color': AppColors.warning,
        'text': 'Good progress. Consider increasing daily physical activity',
      });
    } else {
      recommendations.add({
        'icon': Icons.health_and_safety,
        'color': AppColors.error,
        'text': 'Consider consulting with a healthcare provider for guidance',
      });
    }
    
    // Add specific recommendations based on data
    final hrData = filteredData.where((d) => d['heart_rate'] != null).toList();
    if (hrData.isNotEmpty) {
      final avgHR = hrData.map((d) => double.tryParse(d['heart_rate'].toString()) ?? 0)
          .reduce((a, b) => a + b) / hrData.length;
      if (avgHR > 100) {
        recommendations.add({
          'icon': Icons.self_improvement,
          'color': AppColors.warning,
          'text': 'Consider stress management techniques to lower resting heart rate',
        });
      }
    }
    
    final stepsData = filteredData.where((d) => d['steps'] != null).toList();
    if (stepsData.isNotEmpty) {
      final avgSteps = stepsData.map((d) => double.tryParse(d['steps'].toString()) ?? 0)
          .reduce((a, b) => a + b) / stepsData.length;
      if (avgSteps < 5000) {
        recommendations.add({
          'icon': Icons.directions_walk,
          'color': AppColors.primary,
          'text': 'Aim for at least 8,000 steps daily for optimal health benefits',
        });
      }
    }
    
    return recommendations;
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report sharing feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}