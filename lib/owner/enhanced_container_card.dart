import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components.dart';
import 'models.dart';

/// Enhanced Premium Container Card for Owner Dashboard
class EnhancedOwnerContainerCard extends StatelessWidget {
  final ContainerModel container;
  final VoidCallback onTap;

  const EnhancedOwnerContainerCard({
    super.key,
    required this.container,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTampered = container.sealStatus.trim().toLowerCase() == 'tampered';
    final isOnTrack = container.status.trim().toLowerCase() == 'on track';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isTampered
              ? AppColors.dangerRed
              : (isDark ? const Color(0xFF334155) : AppColors.borderLight),
          width: isTampered ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Container Box Icon + ID + Seal Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: container.containerColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: container.containerColor.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.all_inbox_rounded,
                          color: container.containerColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                container.id,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '• ${container.isoContainerNo}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: isDark ? Colors.white60 : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            container.cargoDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isTampered
                            ? AppColors.dangerLight
                            : (isOnTrack ? AppColors.successLight : AppColors.infoLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isTampered ? Icons.warning_rounded : (isOnTrack ? Icons.check_circle : Icons.done_all),
                            size: 13,
                            color: isTampered
                                ? AppColors.dangerRed
                                : (isOnTrack ? AppColors.successGreen : AppColors.infoBlue),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isTampered ? 'Tampered' : container.status,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isTampered
                                  ? AppColors.dangerRed
                                  : (isOnTrack ? AppColors.successGreen : AppColors.infoBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Corridor Route Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.route, size: 16, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          container.route,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // IoT Telemetry Row: Speed, Temp, Battery & Seal ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Speed
                    Row(
                      children: [
                        const Icon(Icons.speed, size: 14, color: AppColors.infoBlue),
                        const SizedBox(width: 4),
                        Text(
                          '${container.speed} km/h',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                    // Temp
                    Row(
                      children: [
                        const Icon(Icons.thermostat, size: 14, color: AppColors.warningOrange),
                        const SizedBox(width: 4),
                        Text(
                          '${container.temperature}°C',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                    // Battery
                    Row(
                      children: [
                        Icon(
                          container.batteryLevel < 30 ? Icons.battery_alert : Icons.battery_std,
                          size: 14,
                          color: container.batteryLevel < 30 ? AppColors.dangerRed : AppColors.successGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${container.batteryLevel}%',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                    // Next Action Arrow
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
