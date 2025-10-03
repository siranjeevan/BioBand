import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../models/device_state.dart';
import '../services/google_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  bool _isEditing = false;
  
  late Map<String, String> _userInfo;
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _emergencyController;
  
  @override
  void initState() {
    super.initState();
    _initializeUserInfo();
    _setupControllers();
  }
  
  void _initializeUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    _userInfo = {
      'name': user?.displayName ?? 'User',
      'email': user?.email ?? 'user@email.com',
      'age': '28',
      'gender': 'Male',
      'weight': '75 kg',
      'height': '175 cm',
      'bloodType': 'O+',
      'emergencyContact': '+1 234 567 8900',
    };
  }
  
  void _setupControllers() {
    _nameController = TextEditingController(text: _userInfo['name']);
    _ageController = TextEditingController(text: _userInfo['age']);
    _weightController = TextEditingController(text: _userInfo['weight']?.replaceAll(' kg', ''));
    _heightController = TextEditingController(text: _userInfo['height']?.replaceAll(' cm', ''));
    _emergencyController = TextEditingController(text: _userInfo['emergencyContact']);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  Map<String, String> get _deviceInfo => {
    'deviceName': DeviceState.isConnected ? DeviceState.deviceName : 'No Device',
    'deviceId': DeviceState.isConnected ? 'HB-001' : '--',
    'batteryLevel': DeviceState.isConnected ? '85%' : '--',
    'firmwareVersion': DeviceState.isConnected ? '2.1.4' : '--',
    'lastSync': DeviceState.isConnected ? '2 minutes ago' : '--',
    'connectionStatus': DeviceState.isConnected ? 'Connected' : 'Disconnected',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: _isEditing ? AppColors.success : AppColors.textSecondary,
            ),
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.error),
              onPressed: _cancelEdit,
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
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildUserInfo(),
                const SizedBox(height: 24),
                _buildDeviceInfo(),
                const SizedBox(height: 24),
                _buildSettings(),
                const SizedBox(height: 24),
                _buildActions(),
              ],
            ),
          ),)
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  _userInfo['name']!.isNotEmpty 
                      ? _userInfo['name']!.split(' ').where((n) => n.isNotEmpty).map((n) => n[0]).join()
                      : 'U',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color:AppColors.textPrimary, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.textPrimary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isEditing
              ? SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textPrimary),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textPrimary),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textPrimary, width: 2),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                )
              : Text(
                  _userInfo['name']!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            _userInfo['email']!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEditableStatItem('Age', _ageController, ''),
              _buildEditableStatItem('Weight', _weightController, 'kg'),
              _buildEditableStatItem('Height', _heightController, 'cm'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableStatItem(String label, TextEditingController controller, String unit) {
    return Column(
      children: [
        _isEditing
            ? SizedBox(
                width: 60,
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textPrimary),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textPrimary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textPrimary, width: 2),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              )
            : Text(
                '${controller.text}${unit.isNotEmpty ? ' $unit' : ''}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableInfoRow(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: controller,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textPrimary),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textPrimary),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textPrimary, width: 2),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    controller.text,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildInfoRow('Gender', _userInfo['gender']!, Icons.person),
              _buildInfoRow('Blood Type', _userInfo['bloodType']!, Icons.bloodtype),
              _buildEditableInfoRow('Emergency Contact', _emergencyController, Icons.phone),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connected Device',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradient1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.watch,
                      color: AppColors.textPrimary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _deviceInfo['deviceName']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _deviceInfo['deviceId']!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DeviceState.isConnected 
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _deviceInfo['connectionStatus']!,
                      style: TextStyle(
                        color: DeviceState.isConnected ? AppColors.success : AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Battery Level', _deviceInfo['batteryLevel']!, Icons.battery_full),
              _buildInfoRow('Firmware', _deviceInfo['firmwareVersion']!, Icons.system_update),
              _buildInfoRow('Last Sync', _deviceInfo['lastSync']!, Icons.sync),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: DeviceState.isConnected
                    ? OutlinedButton(
                        onPressed: _logoutDevice,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Logout Device',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/device-connect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Connect Device',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSettingItem(
                'Dark Mode',
                'Switch between light and dark themes',
                Icons.dark_mode,
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (value) => setState(() => _isDarkMode = value),
                  activeColor: AppColors.textPrimary,
                ),
              ),
              _buildSettingItem(
                'Notifications',
                'Manage alert preferences',
                Icons.notifications,
                onTap: () {},
              ),
              _buildSettingItem(
                'Privacy',
                'Data sharing and privacy settings',
                Icons.privacy_tip,
                onTap: () {},
              ),
              _buildSettingItem(
                'Backup & Sync',
                'Cloud backup and synchronization',
                Icons.cloud_sync,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
  

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _exportData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Export Health Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _showLogoutDialog,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  void _saveProfile() {
    setState(() {
      _userInfo['name'] = _nameController.text;
      _userInfo['age'] = _ageController.text;
      _userInfo['weight'] = '${_weightController.text} kg';
      _userInfo['height'] = '${_heightController.text} cm';
      _userInfo['emergencyContact'] = _emergencyController.text;
      _isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _cancelEdit() {
    setState(() {
      _nameController.text = _userInfo['name']!;
      _ageController.text = _userInfo['age']!;
      _weightController.text = _userInfo['weight']!.replaceAll(' kg', '');
      _heightController.text = _userInfo['height']!.replaceAll(' cm', '');
      _emergencyController.text = _userInfo['emergencyContact']!;
      _isEditing = false;
    });
  }

  void _editProfile() {
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
              'Edit Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _userInfo['name']),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _userInfo['weight']?.replaceAll(' kg', '')),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _userInfo['height']?.replaceAll(' cm', '')),
            ),
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
                  'Save Changes',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Export Health Data',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Your health data will be exported as a PDF file. This may take a few moments.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Health data exported successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Export', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  void _logoutDevice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout Device',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to logout the current device?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              DeviceState.disconnect();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device disconnected successfully'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout Device', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to logout? You will need to reconnect your device.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await GoogleAuthService().signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
