import 'package:flutter/material.dart';
import 'package:nadi_pariksh/design_system/app_colors.dart';
import '../models/sensor_data.dart';
import '../widgets/chart_widget.dart';

class DetailScreen extends StatelessWidget {
  final String type;
  const DetailScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final data = _getSensorData();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: AppColors.transperant,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                data['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      data['color'].withOpacity(0.1),
                      AppColors.transperant,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          data['color'].withOpacity(0.1),
                          data['color'].withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: data['color'].withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(data['icon'], color: data['color'], size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data['current'],
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: data['color'],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['unit'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timeline, color: data['color'], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Recent Trends',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 120,
                          child: ChartWidget(
                            data: data['history'],
                            color: data['color'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: data['color'], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Statistics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow('Average', _getAverage(data['history']).toString(), data['color']),
                        _buildStatRow('Maximum', _getMax(data['history']).toString(), data['color']),
                        _buildStatRow('Minimum', _getMin(data['history']).toString(), data['color']),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _getAverage(List<int> data) => (data.reduce((a, b) => a + b) / data.length).round();
  int _getMax(List<int> data) => data.reduce((a, b) => a > b ? a : b);
  int _getMin(List<int> data) => data.reduce((a, b) => a < b ? a : b);

  Map<String, dynamic> _getSensorData() {
    switch (type) {
      case 'heart':
        return {
          'title': 'Heart Rate',
          'icon': Icons.favorite,
          'current': SensorData.heartRate.toString(),
          'unit': 'BPM',
          'color': AppColors.error,
          'history': SensorData.heartRateHistory,
        };
      case 'steps':
        return {
          'title': 'Steps',
          'icon': Icons.directions_walk,
          'current': SensorData.steps.toString(),
          'unit': 'Steps',
          'color': AppColors.success,
          'history': SensorData.stepsHistory,
        };
      case 'calories':
        return {
          'title': 'Calories',
          'icon': Icons.local_fire_department,
          'current': SensorData.calories.toString(),
          'unit': 'kcal',
          'color': AppColors.warning,
          'history': SensorData.caloriesHistory,
        };
      default:
        return {
          'title': 'Blood Oxygen',
          'icon': Icons.air,
          'current': '${SensorData.spo2}%',
          'unit': 'SpO₂',
          'color': AppColors.primaryLight,
          'history': SensorData.spo2History,
        };
    }
  }
}