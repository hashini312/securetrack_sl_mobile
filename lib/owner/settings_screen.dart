import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_settings.dart';
import 'components.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final settings = AppSettingsController.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final mutedTextColor = isDark ? const Color(0xFF94A3B8) : AppColors.textMuted;
        final borderColor = isDark ? const Color(0xFF334155) : AppColors.borderLight;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              settings.tr('settings'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: APPEARANCE ---
                  _buildSectionHeader(settings.tr('appearance'), Icons.palette_outlined, textColor),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        // Theme Toggle
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF3B82F6).withValues(alpha: 0.2) : const Color(0xFFE0EDFB),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            settings.tr('theme_mode'),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            isDark ? settings.tr('dark_mode') : settings.tr('light_mode'),
                            style: GoogleFonts.poppins(fontSize: 12, color: mutedTextColor),
                          ),
                          trailing: Switch.adaptive(
                            value: isDark,
                            activeColor: AppColors.accentBlue,
                            onChanged: (_) => settings.toggleTheme(),
                          ),
                        ),
                        Divider(height: 1, color: borderColor),
                        // Language Selector Tile
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF10B981).withValues(alpha: 0.2) : const Color(0xFFD1FAE5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.language_rounded,
                              color: AppColors.successGreen,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            settings.tr('language'),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            '${settings.language.flag} ${settings.language.label}',
                            style: GoogleFonts.poppins(fontSize: 12, color: mutedTextColor),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
                          onTap: () => _showLanguageSelector(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION 2: NOTIFICATIONS & ALARMS ---
                  _buildSectionHeader(settings.tr('notifications_alarms'), Icons.notifications_active_outlined, textColor),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        // Siren Alarm
                        SwitchListTile.adaptive(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFFEF4444).withValues(alpha: 0.2) : const Color(0xFFFEE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.volume_up_rounded, color: AppColors.dangerRed, size: 22),
                          ),
                          title: Text(
                            settings.tr('seal_tamper_siren'),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            settings.tr('seal_tamper_siren_sub'),
                            style: GoogleFonts.poppins(fontSize: 11, color: mutedTextColor),
                          ),
                          activeColor: AppColors.dangerRed,
                          value: settings.sealTamperSiren,
                          onChanged: (val) => settings.setSealTamperSiren(val),
                        ),
                        Divider(height: 1, color: borderColor),
                        // Geofence / Route Deviation
                        SwitchListTile.adaptive(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFFF59E0B).withValues(alpha: 0.2) : const Color(0xFFFEF3C7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.alt_route_rounded, color: AppColors.warningOrange, size: 22),
                          ),
                          title: Text(
                            settings.tr('route_deviation_alert'),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            settings.tr('route_deviation_alert_sub'),
                            style: GoogleFonts.poppins(fontSize: 11, color: mutedTextColor),
                          ),
                          activeColor: AppColors.accentBlue,
                          value: settings.geofenceAlerts,
                          onChanged: (val) => settings.setGeofenceAlerts(val),
                        ),
                        Divider(height: 1, color: borderColor),
                        // Battery warning
                        SwitchListTile.adaptive(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0284C7).withValues(alpha: 0.2) : const Color(0xFFE0F2FE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.battery_alert_rounded, color: AppColors.infoBlue, size: 22),
                          ),
                          title: Text(
                            settings.tr('low_battery_alert'),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            settings.tr('low_battery_alert_sub'),
                            style: GoogleFonts.poppins(fontSize: 11, color: mutedTextColor),
                          ),
                          activeColor: AppColors.accentBlue,
                          value: settings.batteryAlerts,
                          onChanged: (val) => settings.setBatteryAlerts(val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION 3: SECURITY ---
                  _buildSectionHeader(settings.tr('security'), Icons.security_rounded, textColor),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.lock_reset_rounded, color: mutedTextColor, size: 22),
                          ),
                          title: Text(
                            'Change Password',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
                          onTap: () => _showChangePasswordDialog(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION 4: SRI LANKA CUSTOMS HOTLINE & SUPPORT ---
                  _buildSectionHeader(settings.tr('customs_support'), Icons.support_agent_rounded, textColor),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E3A8A), const Color(0xFF1E293B)]
                            : [const Color(0xFF1E4E8C), const Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    settings.tr('emergency_hotline'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    settings.tr('emergency_hotline_sub'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.phone, color: Colors.white),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Connecting to Sri Lanka Customs: 1937',
                                            style: GoogleFonts.poppins(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.primaryBlue,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                icon: const Icon(Icons.call, size: 18, color: AppColors.primaryBlue),
                                label: Text(
                                  settings.tr('call_now'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // App Version Info
                  Center(
                    child: Column(
                      children: [
                        Text(
                          settings.tr('app_version'),
                          style: GoogleFonts.poppins(fontSize: 11, color: mutedTextColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'SecureTrack SL • ITUM Final Year Project',
                          style: GoogleFonts.poppins(fontSize: 10, color: mutedTextColor.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = settings.isDarkMode;
        final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textCol = isDark ? Colors.white : AppColors.textDark;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                settings.tr('select_language'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 12),
              ...AppLanguage.values.map(
                (lang) {
                  final isSelected = settings.language == lang;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF2563EB).withValues(alpha: 0.3) : const Color(0xFFE0EDFB))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.accentBlue : (isDark ? const Color(0xFF334155) : AppColors.borderLight),
                      ),
                    ),
                    child: ListTile(
                      leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
                      title: Text(
                        lang.label,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: textCol,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.accentBlue)
                          : null,
                      onTap: () {
                        settings.setLanguage(lang);
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final isDark = settings.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Change Password',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : null),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : null),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password updated successfully!'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text('Update', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
