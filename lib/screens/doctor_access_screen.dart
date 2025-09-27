import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';

class DoctorAccessScreen extends StatefulWidget {
  const DoctorAccessScreen({super.key});

  @override
  State<DoctorAccessScreen> createState() => _DoctorAccessScreenState();
}

class _DoctorAccessScreenState extends State<DoctorAccessScreen> {
  final List<Doctor> _connectedDoctors = [
    Doctor(
      id: '1',
      name: 'Dr. Sarah Johnson',
      specialty: 'Cardiologist',
      hospital: 'City Medical Center',
      isDataSharingEnabled: true,
      lastAccessed: DateTime.now().subtract(const Duration(days: 2)),
      profileImage: null,
    ),
    Doctor(
      id: '2',
      name: 'Dr. Michael Chen',
      specialty: 'General Physician',
      hospital: 'Health Plus Clinic',
      isDataSharingEnabled: false,
      lastAccessed: DateTime.now().subtract(const Duration(days: 7)),
      profileImage: null,
    ),
    Doctor(
      id: '3',
      name: 'Dr. Emily Rodriguez',
      specialty: 'Pulmonologist',
      hospital: 'Respiratory Care Center',
      isDataSharingEnabled: true,
      lastAccessed: DateTime.now().subtract(const Duration(hours: 12)),
      profileImage: null,
    ),
  ];

  final List<DoctorFeedback> _feedbacks = [
    DoctorFeedback(
      doctorId: '1',
      doctorName: 'Dr. Sarah Johnson',
      message: 'Your heart rate patterns look good. Continue with regular exercise.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: FeedbackType.positive,
    ),
    DoctorFeedback(
      doctorId: '3',
      doctorName: 'Dr. Emily Rodriguez',
      message: 'SpO₂ levels are within normal range. Keep monitoring.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: FeedbackType.neutral,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Doctor Access',
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
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: _addNewDoctor,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataSharingOverview(),
                const SizedBox(height: 24),
                _buildConnectedDoctors(),
                const SizedBox(height: 24),
                _buildDoctorFeedback(),
                const SizedBox(height: 24),
                _buildPrivacySettings(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataSharingOverview() {
    final enabledCount = _connectedDoctors.where((d) => d.isDataSharingEnabled).length;
    
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
                  Icons.share,
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
                      'Data Sharing Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$enabledCount of ${_connectedDoctors.length} doctors have access',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'Active Shares',
                  enabledCount.toString(),
                  AppColors.success,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  'Total Doctors',
                  _connectedDoctors.length.toString(),
                  AppColors.primary,
                  Icons.medical_services,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
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
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedDoctors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connected Doctors',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_connectedDoctors.length, (index) {
          final doctor = _connectedDoctors[index];
          return _buildDoctorCard(doctor);
        }),
      ],
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  doctor.name.split(' ').map((n) => n[0]).join(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      doctor.hospital,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: doctor.isDataSharingEnabled,
                onChanged: (value) {
                  setState(() {
                    doctor.isDataSharingEnabled = value;
                  });
                },
                activeColor: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Last accessed: ${_getTimeAgo(doctor.lastAccessed)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showDoctorDetails(doctor),
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorFeedback() {
    if (_feedbacks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Feedback',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_feedbacks.length, (index) {
          final feedback = _feedbacks[index];
          return _buildFeedbackCard(feedback);
        }),
      ],
    );
  }

  Widget _buildFeedbackCard(DoctorFeedback feedback) {
    final color = _getFeedbackColor(feedback.type);
    
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFeedbackIcon(feedback.type),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.doctorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _getTimeAgo(feedback.timestamp),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback.message,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Privacy & Security',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPrivacyItem(
            'Data Encryption',
            'All shared data is encrypted end-to-end',
            Icons.lock,
            true,
          ),
          _buildPrivacyItem(
            'Access Logs',
            'Track when doctors access your data',
            Icons.history,
            true,
          ),
          _buildPrivacyItem(
            'Auto-Revoke Access',
            'Automatically revoke access after 30 days',
            Icons.timer,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyItem(String title, String description, IconData icon, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
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
          Switch(
            value: enabled,
            onChanged: (value) {},
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Color _getFeedbackColor(FeedbackType type) {
    switch (type) {
      case FeedbackType.positive:
        return AppColors.success;
      case FeedbackType.neutral:
        return AppColors.primary;
      case FeedbackType.negative:
        return AppColors.warning;
    }
  }

  IconData _getFeedbackIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.positive:
        return Icons.thumb_up;
      case FeedbackType.neutral:
        return Icons.info;
      case FeedbackType.negative:
        return Icons.warning;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _addNewDoctor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add New Doctor',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'To add a new doctor, please provide them with your patient ID: NP-2024-001',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Copy patient ID to clipboard
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Copy ID', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDoctorDetails(Doctor doctor) {
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
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                doctor.name.split(' ').map((n) => n[0]).join(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              doctor.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              doctor.specialty,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
            Text(
              doctor.hospital,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Remove Access',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Contact',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  bool isDataSharingEnabled;
  final DateTime lastAccessed;
  final String? profileImage;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.isDataSharingEnabled,
    required this.lastAccessed,
    this.profileImage,
  });
}

class DoctorFeedback {
  final String doctorId;
  final String doctorName;
  final String message;
  final DateTime timestamp;
  final FeedbackType type;

  DoctorFeedback({
    required this.doctorId,
    required this.doctorName,
    required this.message,
    required this.timestamp,
    required this.type,
  });
}

enum FeedbackType { positive, neutral, negative }