import 'package:flutter/material.dart';
import '../models/sensor_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: Colors.transparent,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  child: Column(
                    children: [
                      _buildSettingTile(
                        icon: Icons.refresh,
                        title: 'Refresh Rate',
                        subtitle: 'How often sensors update',
                        trailing: Text(
                          '${SensorData.refreshRate}s',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: _showRefreshRateDialog,
                      ),
                      const Divider(height: 1),
                      _buildSettingTile(
                        icon: Icons.vibration,
                        title: 'Vibration Alerts',
                        subtitle: 'Haptic feedback for notifications',
                        trailing: Switch(
                          value: SensorData.vibrationAlert,
                          onChanged: (value) => setState(() => SensorData.vibrationAlert = value),
                        ),
                        onTap: () => setState(() => SensorData.vibrationAlert = !SensorData.vibrationAlert),
                      ),
                      const Divider(height: 1),
                      _buildSettingTile(
                        icon: Icons.straighten,
                        title: 'Units',
                        subtitle: 'Measurement system',
                        trailing: Text(
                          SensorData.units,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: _showUnitsDialog,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      _buildSettingTile(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'App version and information',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showAboutDialog(),
                      ),
                      const Divider(height: 1),
                      _buildSettingTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help using the app',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ]),
            ),
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
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[400]),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showRefreshRateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refresh Rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2, 5].map((rate) => RadioListTile<int>(
            title: Text('${rate} second${rate > 1 ? 's' : ''}'),
            value: rate,
            groupValue: SensorData.refreshRate,
            onChanged: (value) {
              setState(() => SensorData.refreshRate = value!);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Metric', 'Imperial'].map((unit) => RadioListTile<String>(
            title: Text(unit),
            value: unit,
            groupValue: SensorData.units,
            onChanged: (value) {
              setState(() => SensorData.units = value!);
              Navigator.pop(context);
            },
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
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.health_and_safety,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
      ),
      children: [
        const Text('Professional health monitoring for smartwatches.'),
      ],
    );
  }
}