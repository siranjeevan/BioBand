import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              backgroundColor: AppColors.transperant,
              flexibleSpace: const FlexibleSpaceBar(
                title: Text(
                  'Settings',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildPersonalizationSection(),
                  const SizedBox(height: 16),
                  _buildHealthAlertsSection(),
                  const SizedBox(height: 16),
                  _buildGeneralSection(),
                  const SizedBox(height: 16),
                  _buildAboutSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizationSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalization',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.favorite_border,
            title: 'Resting Heart Rate',
            subtitle: 'Your baseline heart rate',
            trailing: Text(
              '${UserSettings.restingHeartRate} BPM',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _showHeartRateDialog(),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildSettingTile(
            icon: Icons.directions_walk,
            title: 'Daily Steps Goal',
            subtitle: 'Target steps per day',
            trailing: Text(
              '${UserSettings.dailyStepsGoal}',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _showStepsGoalDialog(),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildSettingTile(
            icon: Icons.local_fire_department,
            title: 'Calories Goal',
            subtitle: 'Target calories to burn daily',
            trailing: Text(
              '${UserSettings.dailyCaloriesGoal} kcal',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _showCaloriesGoalDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAlertsSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Alerts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.notifications_active,
            title: 'Enable Alerts',
            subtitle: 'Get notified of health changes',
            trailing: Switch(
              value: UserSettings.enableHealthAlerts,
              onChanged: (value) => setState(() => UserSettings.enableHealthAlerts = value),
            ),
            onTap: () => setState(() => UserSettings.enableHealthAlerts = !UserSettings.enableHealthAlerts),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildSettingTile(
            icon: Icons.air,
            title: 'SpO₂ Thresholds',
            subtitle: 'Alert when oxygen levels drop',
            trailing: Text(
              '<${UserSettings.lowSpO2Threshold}%',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _showSpO2ThresholdDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.refresh,
            title: 'Real-time Updates',
            subtitle: 'Live sensor data updates',
            trailing: Switch(
              value: UserSettings.enableRealTimeUpdates,
              onChanged: (value) => setState(() => UserSettings.enableRealTimeUpdates = value),
            ),
            onTap: () => setState(() => UserSettings.enableRealTimeUpdates = !UserSettings.enableRealTimeUpdates),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildSettingTile(
            icon: Icons.straighten,
            title: 'Units',
            subtitle: 'Measurement system',
            trailing: Text(
              UserSettings.preferredUnits,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _showUnitsDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'App Information',
            subtitle: 'Version and details',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () => _showAboutDialog(),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildSettingTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get assistance',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showHeartRateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Resting Heart Rate', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [50, 55, 60, 65, 70, 75].map((rate) => InkWell(
            onTap: () {
              setState(() => UserSettings.updateRestingHeartRate(rate));
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    UserSettings.restingHeartRate == rate ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  Text('$rate BPM', style: const TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showStepsGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Daily Steps Goal', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [5000, 8000, 10000, 12000, 15000].map((steps) => InkWell(
            onTap: () {
              setState(() => UserSettings.updateStepsGoal(steps));
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    UserSettings.dailyStepsGoal == steps ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  Text('$steps steps', style: const TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showCaloriesGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Daily Calories Goal', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [300, 400, 500, 600, 800].map((calories) => InkWell(
            onTap: () {
              setState(() => UserSettings.updateCaloriesGoal(calories));
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    UserSettings.dailyCaloriesGoal == calories ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  Text('$calories kcal', style: const TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showSpO2ThresholdDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('SpO₂ Alert Threshold', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [92, 94, 95, 96].map((threshold) => InkWell(
            onTap: () {
              setState(() => UserSettings.updateSpO2Thresholds(threshold, threshold - 3));
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    UserSettings.lowSpO2Threshold == threshold ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  Text('Alert below $threshold%', style: const TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Units', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Metric', 'Imperial'].map((unit) => InkWell(
            onTap: () {
              setState(() => UserSettings.preferredUnits = unit);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    UserSettings.preferredUnits == unit ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  Text(unit, style: const TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Nadi Pariksh',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.health_and_safety,
          color: AppColors.primary,
          size: 32,
        ),
      ),
      children: [
        const Text('Professional health monitoring with AI-powered insights.'),
      ],
    );
  }
}