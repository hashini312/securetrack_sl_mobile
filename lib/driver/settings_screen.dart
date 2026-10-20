import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Push Notifications enabled' : 'Push Notifications silenced',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        final bool isDarkMode = currentThemeMode == ThemeMode.dark;

        return Scaffold(
          //App Bar
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'settings'.tr().toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
          ),
          centerTitle: true,
        ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [

                // Dark Mode Toggle Switch
                _buildToggleItem(
                  context: context,
                  icon: Icons.nightlight_round,
                  title: 'dark_mode'.tr(),
                  subtitle: isDarkMode
                      ? 'dark_mode_enabled'.tr()
                      : 'light_mode_active'.tr(),
                  value: isDarkMode,
                  onChanged: (bool value) async {
                    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isDarkMode', value);
                  },
                ),

                // Push Notifications Switch
                _buildToggleItem(
                  context: context,
                  icon: Icons.notifications_active_outlined,
                  title: 'push_notifications'.tr(),
                  subtitle: _notificationsEnabled ? 'Active for critical alerts' : 'Disabled',
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                ),

                // Change Password Option
                _buildSettingsItem(
                  context: context,
                  icon: Icons.lock_outline,
                  title: 'change_password'.tr(),
                  subtitle: 'Update driver login credentials',
                  onTap: () => _showChangePasswordDialog(context),
                ),

                // Help & Support
                _buildSettingsItem(
                  context: context,
                  icon: Icons.help_outline,
                  title: 'help_support'.tr(),
                  subtitle: '24/7 Operations Hotline & Technical Support',
                  onTap: () => _showHelpSupportDialog(context),
                ),

                // About App
                _buildSettingsItem(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'about_app'.tr(),
                  subtitle: 'v1.0.0 (Sri Lanka Customs ECTS)',
                  onTap: () => _showAboutAppDialog(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Change Password
  void _showChangePasswordDialog(BuildContext parentContext) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscure = true;

    showDialog(
      context: parentContext,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.lock_reset, color: Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              Text('change_password'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscure,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscure,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscure,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.check_circle_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: !obscure,
                      onChanged: (val) => setDialogState(() => obscure = !val!),
                    ),
                    const Text('Show Passwords', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(parentContext);
                final newPass = newPasswordController.text.trim();
                final confirmPass = confirmPasswordController.text.trim();

                if (newPass.isEmpty || newPass.length < 6) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('New password must be at least 6 characters.')),
                  );
                  return;
                }
                if (newPass != confirmPass) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Passwords do not match.')),
                  );
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.updatePassword(newPass);
                    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Password updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Please log in first.')),
                    );
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error updating password: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: Text('save_changes'.tr(), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Help & Support
  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.support_agent, color: Color(0xFF1E3A8A)),
            const SizedBox(width: 8),
            Text('help_support'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sri Lanka Customs 24/7 Operations Desk', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('📞 Customs Hotline: 1933 / +94 11 222 1300'),
            SizedBox(height: 4),
            Text('🚨 Emergency Control Room: +94 11 247 8888'),
            SizedBox(height: 4),
            Text('✉️ IT Support: support@customs.gov.lk'),
            SizedBox(height: 10),
            Divider(),
            Text(
              'If your container reports a false seal tamper alarm or route blockage, stay inside your vehicle and call the Control Room immediately.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  // About App
  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info, color: Color(0xFF1E3A8A)),
            const SizedBox(width: 8),
            Text('about_app'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SecureTrack SL - Driver Application', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Version 1.0.0 (Release Build)', style: TextStyle(color: Colors.grey, fontSize: 13)),
            SizedBox(height: 10),
            Text(
              'An IoT-Based Real-Time Container Monitoring and Anti-Theft Framework for Sri Lanka Customs.\n\n'
              'Features ESP32 telemetry, dual-sensor intrusion detection, dynamic geofencing, and automated route verification.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  // Common Settings Item Widget
  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? theme.iconTheme.color),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: titleColor ?? theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              )
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // Toggle Item Widget (Dark Mode / Notifications)
  Widget _buildToggleItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.iconTheme.color),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}