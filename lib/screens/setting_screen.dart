import 'package:flutter/material.dart';

enum AppThemeMode { system, light, dark }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State variables for settings
  AppThemeMode _currentThemeMode = AppThemeMode.system;
  String _selectedLanguage = 'English';
  bool _enableAppointmentReminders = true;
  bool _enableCriticalAlerts = true;
  bool _enableBiometricAuth = false;
  bool _enableDataSharing = false;
  final List<String> _languages = ['English', 'Spanish', 'Hindi', 'French'];

  String _getThemeModeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System Default';
      case AppThemeMode.light:
        return 'Light Mode';
      case AppThemeMode.dark:
        return 'Dark Mode';
    }
  }

  void _showActionSnackbar(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action successful (simulated).'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSwitchSetting(String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.indigo,
      ),
      onTap: () => onChanged(!value),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed, {Color color = Colors.indigo}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: OutlinedButton.icon(
        icon: Icon(icon, color: color),
        label: Text(title, style: TextStyle(color: color)),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(color: color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Application Settings'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: <Widget>[
          // 1. Account & Profile Settings
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ExpansionTile(
              initiallyExpanded: true,
              leading: const Icon(Icons.person, color: Colors.indigo),
              title: const Text('Account & Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              children: <Widget>[
                const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.medical_services)),
                  title: Text('Dr. Marcus Welby'),
                  subtitle: Text('marcus.welby@clinic.com'),
                ),
                _buildActionButton(
                  'Change Password',
                  Icons.lock_reset,
                      () => _showActionSnackbar('Password reset link sent'),
                ),
                _buildActionButton(
                  'Update Profile Information',
                  Icons.edit_note,
                      () => _showActionSnackbar('Profile update form opened'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // 2. App Preferences
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ExpansionTile(
              leading: const Icon(Icons.palette, color: Colors.teal),
              title: const Text('App Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
              children: <Widget>[
                // Theme Mode Selector
                ListTile(
                  title: const Text('Theme Mode'),
                  trailing: DropdownButton<AppThemeMode>(
                    value: _currentThemeMode,
                    items: AppThemeMode.values.map((AppThemeMode mode) {
                      return DropdownMenuItem<AppThemeMode>(
                        value: mode,
                        child: Text(_getThemeModeLabel(mode)),
                      );
                    }).toList(),
                    onChanged: (AppThemeMode? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _currentThemeMode = newValue;
                        });
                        _showActionSnackbar('Theme changed to ${_getThemeModeLabel(newValue)}');
                      }
                    },
                  ),
                ),
                // Language Selector
                ListTile(
                  title: const Text('Language'),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    items: _languages.map((String lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(lang),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedLanguage = newValue;
                        });
                        _showActionSnackbar('Language set to $newValue');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // 3. Notification Settings
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ExpansionTile(
              leading: const Icon(Icons.notifications, color: Colors.orange),
              title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
              children: <Widget>[
                _buildSwitchSetting(
                  'Appointment Reminders',
                  _enableAppointmentReminders,
                      (value) {
                    setState(() {
                      _enableAppointmentReminders = value;
                    });
                    _showActionSnackbar('Reminders ${value ? 'enabled' : 'disabled'}');
                  },
                ),
                _buildSwitchSetting(
                  'Critical Lab Result Alerts',
                  _enableCriticalAlerts,
                      (value) {
                    setState(() {
                      _enableCriticalAlerts = value;
                    });
                    _showActionSnackbar('Critical alerts ${value ? 'enabled' : 'disabled'}');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // 4. Security & Privacy
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ExpansionTile(
              leading: const Icon(Icons.security, color: Colors.blueGrey),
              title: const Text('Security & Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
              children: <Widget>[
                _buildSwitchSetting(
                  'Enable Biometric Login (Fingerprint/Face ID)',
                  _enableBiometricAuth,
                      (value) {
                    setState(() {
                      _enableBiometricAuth = value;
                    });
                    _showActionSnackbar('Biometric authentication ${value ? 'enabled' : 'disabled'}');
                  },
                ),
                _buildSwitchSetting(
                  'Anonymous Data Sharing (for research)',
                  _enableDataSharing,
                      (value) {
                    setState(() {
                      _enableDataSharing = value;
                    });
                    _showActionSnackbar('Data sharing ${value ? 'enabled' : 'disabled'}');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // 5. Data & Storage
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ExpansionTile(
              leading: const Icon(Icons.storage, color: Colors.lightGreen),
              title: const Text('Data & Storage', style: TextStyle(fontWeight: FontWeight.bold)),
              children: <Widget>[
                ListTile(
                  title: const Text('Last Sync Time'),
                  subtitle: Text('2 minutes ago (${DateTime.now().hour}:${DateTime.now().minute})'),
                  trailing: IconButton(
                    icon: const Icon(Icons.sync, color: Colors.indigo),
                    onPressed: () => _showActionSnackbar('Data sync initiated'),
                  ),
                ),
                _buildActionButton(
                  'Export EMR Data (PDF)',
                  Icons.archive,
                      () => _showActionSnackbar('EMR data export started'),
                ),
                _buildActionButton(
                  'Clear Local Cache (250 MB)',
                  Icons.delete_sweep,
                      () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Cache Clear'),
                      content: const Text('Are you sure you want to clear the local application cache? This action is reversible upon next sync.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            _showActionSnackbar('Cache cleared');
                            Navigator.pop(context);
                          },
                          child: const Text('Clear', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.red.shade600,
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // 6. About & Logout
          const Center(
            child: Text(
              'App Version 1.2.0 (Build 456)',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'LOG OUT',
            Icons.logout,
                () => _showActionSnackbar('User logged out'),
            color: Colors.pink.shade700,
          ),
        ],
      ),
    );
  }
}