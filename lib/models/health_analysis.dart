import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import 'sensor_data.dart';

class HealthAnalysis {
  static String getHealthStatus() {
    final hr = SensorData.heartRate;
    final spo2 = SensorData.spo2;
    final steps = SensorData.steps;
    final calories = SensorData.calories;
    
    if (hr > 100 || spo2 < 95) return 'Needs Attention';
    if (hr > 85 || steps < 5000 || calories < 200) return 'Good';
    return 'Excellent';
  }
  
  static Color getHealthStatusColor() {
    switch (getHealthStatus()) {
      case 'Needs Attention': return AppColors.error;
      case 'Good': return AppColors.warning;
      default: return AppColors.success;
    }
  }
  
  static String getHealthAnalysis() {
    final status = getHealthStatus();
    switch (status) {
      case 'Needs Attention':
        return 'Some vitals need monitoring. Consider consulting a healthcare professional.';
      case 'Good':
        return 'Your health is good, but there\'s room for improvement with regular exercise.';
      default:
        return 'Your vitals are within optimal range. Keep up the great work!';
    }
  }
  
  static List<DailyMetric> getDailyMetrics() {
    return [
      DailyMetric('Heart Rate', SensorData.heartRate, 'BPM', AppColors.error, 'Resting HR: 72 BPM'),
      DailyMetric('Blood Oxygen', SensorData.spo2, '%', AppColors.secondary, 'Normal: 95-100%'),
      DailyMetric('Steps', SensorData.steps, 'steps', AppColors.success, 'Goal: 10,000 steps'),
      DailyMetric('Calories', SensorData.calories, 'kcal', AppColors.warning, 'Goal: 500 kcal'),
    ];
  }
  
  static List<HealthInsight> getHealthInsights() {
    final insights = <HealthInsight>[];
    final hr = SensorData.heartRate;
    final spo2 = SensorData.spo2;
    final steps = SensorData.steps;
    final calories = SensorData.calories;
    
    if (hr > 100) {
      insights.add(HealthInsight(
        'Elevated Heart Rate',
        'Your heart rate is above normal. Consider rest and hydration.',
        Icons.favorite,
        AppColors.error,
      ));
    }
    
    if (spo2 < 95) {
      insights.add(HealthInsight(
        'Low Blood Oxygen',
        'Blood oxygen levels are below optimal. Ensure proper breathing.',
        Icons.air,
        AppColors.error,
      ));
    }
    
    if (steps < 5000) {
      insights.add(HealthInsight(
        'Increase Activity',
        'Try to reach 10,000 steps daily for better cardiovascular health.',
        Icons.directions_walk,
        AppColors.warning,
      ));
    }
    
    if (calories < 200) {
      insights.add(HealthInsight(
        'Low Calorie Burn',
        'Consider increasing physical activity to burn more calories.',
        Icons.local_fire_department,
        AppColors.warning,
      ));
    }
    
    if (insights.isEmpty) {
      insights.add(HealthInsight(
        'Great Health Status',
        'All your vitals are within healthy ranges. Keep it up!',
        Icons.check_circle,
        AppColors.success,
      ));
    }
    
    return insights;
  }
}

class DailyMetric {
  final String name;
  final int value;
  final String unit;
  final Color color;
  final String description;
  
  DailyMetric(this.name, this.value, this.unit, this.color, this.description);
}

class HealthInsight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  
  HealthInsight(this.title, this.description, this.icon, this.color);
}