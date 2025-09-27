import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<HealthAlert> _alerts = [
    HealthAlert(
      id: '1',
      type: AlertType.critical,
      title: 'High Heart Rate Detected',
      message: 'Heart rate exceeded 120 BPM for 5 minutes',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      value: '125 BPM',
      icon: Icons.favorite,
    ),
    HealthAlert(
      id: '2',
      type: AlertType.warning,
      title: 'Low Blood Oxygen',
      message: 'SpO₂ levels dropped below 94%',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      value: '93%',
      icon: Icons.air,
    ),
    HealthAlert(
      id: '3',
      type: AlertType.info,
      title: 'Daily Step Goal Achieved',
      message: 'Congratulations! You reached 10,000 steps',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      value: '10,247 steps',
      icon: Icons.directions_walk,
    ),
    HealthAlert(
      id: '4',
      type: AlertType.warning,
      title: 'Irregular Heart Rhythm',
      message: 'Unusual heart rate pattern detected',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      value: 'Arrhythmia',
      icon: Icons.monitor_heart,
    ),
    HealthAlert(
      id: '5',
      type: AlertType.info,
      title: 'Hydration Reminder',
      message: 'Time to drink water for better health',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      value: '2.1L today',
      icon: Icons.water_drop,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Health Alerts',
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
            icon: const Icon(Icons.settings, color: AppColors.primary),
            onPressed: _showAlertSettings,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAlertSummary(),
              Expanded(child: _buildAlertsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertSummary() {
    final criticalCount = _alerts.where((a) => a.type == AlertType.critical).length;
    final warningCount = _alerts.where((a) => a.type == AlertType.warning).length;
    final infoCount = _alerts.where((a) => a.type == AlertType.info).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Critical',
              criticalCount.toString(),
              AppColors.error,
              Icons.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Warning',
              warningCount.toString(),
              AppColors.warning,
              Icons.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Info',
              infoCount.toString(),
              AppColors.primary,
              Icons.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildAlertCard(HealthAlert alert) {
    final color = _getAlertColor(alert.type);
    final timeAgo = _getTimeAgo(alert.timestamp);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            ),
            child: Icon(alert.icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alert.value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (alert.type == AlertType.critical)
                      TextButton(
                        onPressed: () => _showAlertDetails(alert),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.critical:
        return AppColors.error;
      case AlertType.warning:
        return AppColors.warning;
      case AlertType.info:
        return AppColors.primary;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showAlertDetails(HealthAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(alert.icon, color: _getAlertColor(alert.type)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                alert.title,
                style: TextStyle(
                  color: _getAlertColor(alert.type),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.message,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '⚠️ If symptoms persist, consult a healthcare professional immediately.',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to emergency contacts or call emergency services
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Emergency', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAlertSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Alert Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingItem('Critical Alerts', true),
            _buildSettingItem('Warning Alerts', true),
            _buildSettingItem('Info Alerts', false),
            _buildSettingItem('Sound Notifications', true),
            _buildSettingItem('Vibration', true),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, bool value) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {},
        activeColor: AppColors.primary,
      ),
    );
  }
}

enum AlertType { critical, warning, info }

class HealthAlert {
  final String id;
  final AlertType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final String value;
  final IconData icon;

  HealthAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.value,
    required this.icon,
  });
}