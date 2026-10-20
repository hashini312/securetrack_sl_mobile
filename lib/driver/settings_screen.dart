import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:securetrack_sl/owner/app_settings.dart';
import 'package:securetrack_sl/owner/components.dart';
import 'main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _appSettings = AppSettingsController.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appSettings,
      builder: (context, _) {
        final bool isDarkMode = _appSettings.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF0F172A) : AppColors.background,
          appBar: AppBar(
            backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDarkMode ? Colors.white : AppColors.textDark,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Driver Settings',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION: APPEARANCE
                _buildSectionHeader('APPEARANCE & DISPLAY', isDarkMode),
                const SizedBox(height: 8),

                // Dark Mode Switch
                _buildSettingsTile(
                  isDarkMode: isDarkMode,
                  icon: isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  iconColor: AppColors.primaryBlue,
                  title: 'Dark Mode',
                  subtitle: isDarkMode ? 'Dark theme enabled for night transits' : 'Light theme active',
                  trailing: Switch.adaptive(
                    value: isDarkMode,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (bool value) {
                      _appSettings.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                      themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // SECTION: NOTIFICATIONS & CORRIDORS
                _buildSectionHeader('ALERTS & SAFETY', isDarkMode),
                const SizedBox(height: 8),

                _buildSettingsTile(
                  isDarkMode: isDarkMode,
                  icon: Icons.notifications_active_rounded,
                  iconColor: AppColors.warningOrange,
                  title: 'Corridor Breach Alarms',
                  subtitle: 'Immediate audio siren when vehicle leaves corridor',
                  trailing: Switch.adaptive(
                    value: _appSettings.geofenceAlerts,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (bool val) {
                      setState(() {});
                    },
                  ),
                ),

                const SizedBox(height: 8),

                _buildSettingsTile(
                  isDarkMode: isDarkMode,
                  icon: Icons.battery_charging_full_rounded,
                  iconColor: AppColors.successGreen,
                  title: 'IoT Low Battery Warning',
                  subtitle: 'Alert when ESP32 smart seal drops below 25%',
                  trailing: Switch.adaptive(
                    value: _appSettings.batteryAlerts,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (bool val) {
                      setState(() {});
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // SECTION: SECURITY
                _buildSectionHeader('SECURITY & CREDENTIALS', isDarkMode),
                const SizedBox(height: 8),

                _buildSettingsTile(
                  isDarkMode: isDarkMode,
                  icon: Icons.lock_reset_rounded,
                  iconColor: AppColors.primaryBlue,
                  title: 'Change Password',
                  subtitle: 'Update your driver portal password',
                  onTap: () => _showChangePasswordDialog(context, isDarkMode),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
                ),

                const SizedBox(height: 20),

                // SECTION: SUPPORT & ABOUT
                _buildSectionHeader('SYSTEM & SUPPORT', isDarkMode),
                const SizedBox(height: 8),

                _buildSettingsTile(
                  isDarkMode: isDarkMode,
                  icon: Icons.support_agent_rounded,
                  iconColor: AppColors.infoBlue,
                  title: 'Customs Emergency Hotline (1937)',
                  subtitle: '24/7 Sri Lanka Customs Control Center',
                  onTap: () => _showHelpSupportDialog(context, isDarkMode),
                  trailing: const Icon(Icons.phone_in_talk_rounded, size: 18, color: AppColors.infoBlue),
                ),

                const SizedBox(height: 8),

                _buildSettingsTile(
                  isDarkMode: isDarkMode,
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.textMuted,
                  title: 'About SecureTrack SL',
                  subtitle: 'v1.0.0 (Customs Container Tracking System)',
                  onTap: () => _showAboutAppDialog(context, isDarkMode),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
                ),

                const SizedBox(height: 32),

                // Log Out Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout_rounded, color: AppColors.dangerRed),
                    label: Text(
                      'Sign Out from Driver Portal',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.dangerRed,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.dangerRed),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: isDarkMode ? Colors.white60 : AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required bool isDarkMode,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: isDarkMode ? Colors.white60 : AppColors.textMuted,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext parentContext, bool isDarkMode) {
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Change Password',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: GoogleFonts.poppins(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPassCtrl,
              obscureText: true,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: GoogleFonts.poppins(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (newPassCtrl.text.trim().isEmpty || newPassCtrl.text != confirmPassCtrl.text) {
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match or empty!')),
                  );
                }
                return;
              }
              try {
                final user = FirebaseAuth.instance.currentUser;
                await user?.updatePassword(newPassCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Password updated successfully!'), backgroundColor: AppColors.successGreen),
                  );
                }
              } catch (e) {
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.dangerRed),
                  );
                }
              }
            },
            child: Text('Update', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sri Lanka Customs Support', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(
          'Hotline: 1937\nOperations Room: +94 11 222 1937\nEmail: ects-support@customs.gov.lk\nHours: 24/7 Round-the-clock Monitoring',
          style: GoogleFonts.poppins(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK', style: GoogleFonts.poppins())),
        ],
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('SecureTrack SL', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(
          'Version: 1.0.0+1\nIoT Container Transit Corridor Monitoring\nDivision of Information Technology, ITUM / Sri Lanka Customs\n\nAll rights reserved © 2026',
          style: GoogleFonts.poppins(fontSize: 12, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: GoogleFonts.poppins())),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out from the Driver Portal?', style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/role-selection', (route) => false);
              }
            },
            child: Text('Sign Out', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
