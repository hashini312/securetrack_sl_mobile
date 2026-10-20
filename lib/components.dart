import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models.dart';

/// App color palette matching the UI designs
class AppColors {
  AppColors._();

  static const Color splashNavy = Color(0xFF0E1E38);
  static const Color cardNavy = Color(0xFF132A4D);
  static const Color primaryBlue = Color(0xFF1E4E8C);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color skyBlue = Color(0xFFE0EDFB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0);

  static const Color textDark = Color(0xFF0F172A);
  static const Color textMedium = Color(0xFF334155);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  static const Color successGreen = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color infoBlue = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);

  static const Color ownerCardBg = Color(0xFFD6E6F9);
  static const Color driverCardBg = Color(0xFFD4EEDF);
  static const Color inspectorCardBg = Color(0xFFFEF3C7);
}

/// App circular logo widget supporting both Black & White and Full Color variants
class AppLogo extends StatelessWidget {
  final double size;
  final bool isDarkBackground;
  final bool isBw;

  const AppLogo({
    super.key,
    this.size = 50,
    this.isDarkBackground = false,
    this.isBw = false,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = isBw ? 'assets/images/logo_bw.png' : 'assets/images/logo.png';

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/logo_color.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // High fidelity fallback circular logo
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkBackground ? Colors.white70 : AppColors.primaryBlue,
                  width: 2,
                ),
                color: isDarkBackground ? Colors.white.withValues(alpha: 0.1) : AppColors.skyBlue,
              ),
              child: Center(
                child: Icon(
                  Icons.shield_outlined,
                  size: size * 0.55,
                  color: isDarkBackground ? Colors.white : AppColors.primaryBlue,
                ),
              ),
            );
          },
        );
      },
    );
  }
}



/// 3D Container visual representation
class ContainerGraphic extends StatelessWidget {
  final double height;
  final String? assetPath;

  const ContainerGraphic({
    super.key,
    this.height = 100,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = assetPath ?? 'assets/images/container_details.png';
    return Image.asset(
      imagePath,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: height * 1.6,
          decoration: BoxDecoration(
            color: const Color(0xFF1E4E8C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
          ),
          child: const Center(
            child: Icon(
              Icons.inventory_2_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

/// Metric card on the dashboard (e.g., 2 On Track, 0 Alerts, 1 Active)
class MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status Pill Badge ('On Track', 'Arrived', etc.)
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isOnTrack = status.toLowerCase().contains('track');
    final Color bgColor = isOnTrack ? AppColors.successLight : AppColors.infoLight;
    final Color textColor = isOnTrack ? AppColors.successGreen : AppColors.infoBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// Dashboard Recent Container Item Card
class ContainerItemCard extends StatelessWidget {
  final ContainerModel container;
  final VoidCallback onTap;

  const ContainerItemCard({
    super.key,
    required this.container,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Container thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                container.assetImage,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: container.containerColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    container.id,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    container.route,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status badge
            StatusBadge(status: container.status),
          ],
        ),
      ),
    );
  }
}

/// Alert Notification Card
class AlertItemCard extends StatelessWidget {
  final AlertItem alert;
  final VoidCallback? onTap;

  const AlertItemCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Circle Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? alert.bgColor.withValues(alpha: 0.25) : alert.bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  alert.icon,
                  color: alert.iconColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Text details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.containerId,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    alert.timestamp,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron arrow
            Icon(
              Icons.chevron_right,
              color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Rounded Input Field
class CustomInputField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final TextEditingController? controller;

  const CustomInputField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.controller,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError ? AppColors.dangerRed : AppColors.borderLight,
                width: hasError ? 1.5 : 1.2,
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: onChanged,
              obscureText: isPassword && !isPasswordVisible,
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
                prefixIcon: Icon(
                  prefixIcon,
                  color: hasError ? AppColors.dangerRed : AppColors.primaryBlue,
                  size: 20,
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: onTogglePassword,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.dangerRed, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      errorText!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.dangerRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom Primary Action Button
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          disabledBackgroundColor: AppColors.primaryBlue.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// 3D Isometric Shipping Container widget
class ContainerBoxArt extends StatelessWidget {
  final double width;
  final double height;
  final Color primaryColor;

  const ContainerBoxArt({
    super.key,
    this.width = 160,
    this.height = 95,
    this.primaryColor = const Color(0xFF1E5BB3),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ContainerIsometricPainter(primaryColor: primaryColor),
      ),
    );
  }
}

class _ContainerIsometricPainter extends CustomPainter {
  final Color primaryColor;

  _ContainerIsometricPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pFrontTopLeft = Offset(w * 0.40, h * 0.22);
    final pFrontTopRight = Offset(w * 0.72, h * 0.28);
    final pFrontBottomLeft = Offset(w * 0.40, h * 0.88);
    final pFrontBottomRight = Offset(w * 0.72, h * 0.94);

    final pLeftTopLeft = Offset(w * 0.04, h * 0.40);
    final pLeftBottomLeft = Offset(w * 0.04, h * 0.78);
    final pTopBack = Offset(w * 0.36, h * 0.08);

    final sidePaint = Paint()..color = primaryColor..style = PaintingStyle.fill;
    final sideFrontPaint = Paint()..color = HSLColor.fromColor(primaryColor).withLightness(0.42).toColor()..style = PaintingStyle.fill;
    final topPaint = Paint()..color = HSLColor.fromColor(primaryColor).withLightness(0.50).toColor()..style = PaintingStyle.fill;
    final linePaint = Paint()..color = const Color(0xFF0F3266)..strokeWidth = 1.5..style = PaintingStyle.stroke;

    // 1. Long Side
    final leftPath = Path()
      ..moveTo(pLeftTopLeft.dx, pLeftTopLeft.dy)
      ..lineTo(pFrontTopLeft.dx, pFrontTopLeft.dy)
      ..lineTo(pFrontBottomLeft.dx, pFrontBottomLeft.dy)
      ..lineTo(pLeftBottomLeft.dx, pLeftBottomLeft.dy)
      ..close();
    canvas.drawPath(leftPath, sidePaint);
    canvas.drawPath(leftPath, linePaint);

    // Corrugations
    const ribs = 9;
    for (int i = 1; i < ribs; i++) {
      final t = i / ribs;
      final top = Offset.lerp(pLeftTopLeft, pFrontTopLeft, t)!;
      final bot = Offset.lerp(pLeftBottomLeft, pFrontBottomLeft, t)!;
      final ribPaint = Paint()
        ..color = (i % 2 == 0)
            ? HSLColor.fromColor(primaryColor).withLightness(0.55).toColor()
            : HSLColor.fromColor(primaryColor).withLightness(0.36).toColor()
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.square;
      canvas.drawLine(top, bot, ribPaint);
    }

    // 2. Top Roof
    final topPath = Path()
      ..moveTo(pLeftTopLeft.dx, pLeftTopLeft.dy)
      ..lineTo(pTopBack.dx, pTopBack.dy)
      ..lineTo(pFrontTopRight.dx, pFrontTopRight.dy)
      ..lineTo(pFrontTopLeft.dx, pFrontTopLeft.dy)
      ..close();
    canvas.drawPath(topPath, topPaint);
    canvas.drawPath(topPath, linePaint);

    // 3. Front Face (Doors)
    final frontPath = Path()
      ..moveTo(pFrontTopLeft.dx, pFrontTopLeft.dy)
      ..lineTo(pFrontTopRight.dx, pFrontTopRight.dy)
      ..lineTo(pFrontBottomRight.dx, pFrontBottomRight.dy)
      ..lineTo(pFrontBottomLeft.dx, pFrontBottomLeft.dy)
      ..close();
    canvas.drawPath(frontPath, sideFrontPaint);
    canvas.drawPath(frontPath, linePaint);

    // Door vertical divider
    final doorMidTop = Offset.lerp(pFrontTopLeft, pFrontTopRight, 0.5)!;
    final doorMidBot = Offset.lerp(pFrontBottomLeft, pFrontBottomRight, 0.5)!;
    canvas.drawLine(doorMidTop, doorMidBot, linePaint);

    // Locking rods
    final rod1Top = Offset.lerp(pFrontTopLeft, pFrontTopRight, 0.25)!;
    final rod1Bot = Offset.lerp(pFrontBottomLeft, pFrontBottomRight, 0.25)!;
    final rod2Top = Offset.lerp(pFrontTopLeft, pFrontTopRight, 0.75)!;
    final rod2Bot = Offset.lerp(pFrontBottomLeft, pFrontBottomRight, 0.75)!;
    final rodPaint = Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 2.0;
    canvas.drawLine(rod1Top, rod1Bot, rodPaint);
    canvas.drawLine(rod2Top, rod2Bot, rodPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Colombo Map Simulation Canvas Widget
class ColomboMapArt extends StatelessWidget {
  final String durationText;
  final String distanceText;
  final double progress; // 0.0 to 1.0

  const ColomboMapArt({
    super.key,
    this.durationText = '21 min',
    this.distanceText = '8.7 km',
    this.progress = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _ColomboMapArtPainter(
            progress: progress,
            durationText: durationText,
            distanceText: distanceText,
          ),
        ),

        // Watermark
        Positioned(
          bottom: 110,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
            ),
            child: const Text(
              'SecureTrack SL GPS Telemetry',
              style: TextStyle(fontSize: 10, color: Color(0xFF475569), fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColomboMapArtPainter extends CustomPainter {
  final double progress;
  final String durationText;
  final String distanceText;

  _ColomboMapArtPainter({
    required this.progress,
    required this.durationText,
    required this.distanceText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Land
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFF8FAFC));

    // Sea / Harbour Coastline (Left)
    final waterPaint = Paint()..color = const Color(0xFFBAE6FD);
    final coastPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.28, 0)
      ..quadraticBezierTo(w * 0.32, h * 0.25, w * 0.22, h * 0.40)
      ..quadraticBezierTo(w * 0.15, h * 0.55, w * 0.18, h * 0.70)
      ..quadraticBezierTo(w * 0.22, h * 0.85, w * 0.14, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(coastPath, waterPaint);

    // Harbour Pier
    final pierPath = Path()
      ..moveTo(w * 0.12, h * 0.28)
      ..lineTo(w * 0.26, h * 0.28)
      ..lineTo(w * 0.24, h * 0.34)
      ..lineTo(w * 0.16, h * 0.34)
      ..close();
    canvas.drawPath(pierPath, Paint()..color = const Color(0xFFCBD5E1));

    // Parks / Lakes (Beira Lake representation)
    final greenPaint = Paint()..color = const Color(0xFFDCFCE7);
    canvas.drawCircle(Offset(w * 0.45, h * 0.65), 28, greenPaint);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.38, h * 0.52), width: 50, height: 26),
      waterPaint,
    );

    // Roads Grid
    final secRoadPaint = Paint()..color = Colors.white..strokeWidth = 3.5..style = PaintingStyle.stroke;
    final roadBorderPaint = Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 5.5..style = PaintingStyle.stroke;

    final roads = [
      Path()..moveTo(w * 0.62, 0)..lineTo(w * 0.60, h),
      Path()..moveTo(w * 0.25, h * 0.35)..lineTo(w * 0.22, h),
      Path()..moveTo(w * 0.24, h * 0.48)..quadraticBezierTo(w * 0.50, h * 0.45, w, h * 0.42),
      Path()..moveTo(w * 0.30, h * 0.18)..quadraticBezierTo(w * 0.65, h * 0.15, w, h * 0.22),
      Path()..moveTo(w * 0.32, h * 0.32)..quadraticBezierTo(w * 0.75, h * 0.30, w * 0.88, h * 0.36),
    ];

    for (final p in roads) {
      canvas.drawPath(p, roadBorderPaint);
      canvas.drawPath(p, secRoadPaint);
    }

    // Main Route (Deep Blue Polyline)
    final routePath = Path()
      ..moveTo(w * 0.22, h * 0.32)
      ..lineTo(w * 0.20, h * 0.38)
      ..lineTo(w * 0.25, h * 0.46)
      ..quadraticBezierTo(w * 0.34, h * 0.46, w * 0.38, h * 0.38)
      ..lineTo(w * 0.42, h * 0.24)
      ..lineTo(w * 0.52, h * 0.22)
      ..lineTo(w * 0.60, h * 0.25)
      ..lineTo(w * 0.70, h * 0.32)
      ..lineTo(w * 0.70, h * 0.37)
      ..lineTo(w * 0.75, h * 0.37);

    final routeBorder = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final routeCore = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(routePath, routeBorder);
    canvas.drawPath(routePath, routeCore);

    // Compute dynamic vehicle position along path metrics
    final pathMetrics = routePath.computeMetrics().toList();
    Offset carOffset = Offset(w * 0.42, h * 0.24);
    double carAngle = 0.0;

    if (pathMetrics.isNotEmpty) {
      final metric = pathMetrics.first;
      final clampedP = progress.clamp(0.01, 0.99);
      final distance = metric.length * clampedP;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        carOffset = tangent.position;
        carAngle = tangent.angle;
      }
    }

    // Start Pin (Colombo Harbour Gate 4)
    final startPin = Offset(w * 0.22, h * 0.32);
    canvas.drawCircle(startPin, 7, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(startPin, 3.5, Paint()..color = Colors.white);

    // Checkpoint Markers along Route
    final cp1 = Offset(w * 0.25, h * 0.46); // Ingurukade
    final cp2 = Offset(w * 0.52, h * 0.22); // Kelaniya Bridge
    _drawCheckpointDot(canvas, cp1, 'Ingurukade', isPassed: progress > 0.3);
    _drawCheckpointDot(canvas, cp2, 'Kelani Link', isPassed: progress > 0.6);

    // Destination Pin (Red Pin at Orugodawatta Yard)
    final destPinOffset = Offset(w * 0.75, h * 0.37);
    canvas.drawOval(
      Rect.fromCenter(center: destPinOffset + const Offset(0, 14), width: 14, height: 6),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );

    final pinPath = Path()
      ..moveTo(destPinOffset.dx, destPinOffset.dy + 12)
      ..quadraticBezierTo(destPinOffset.dx - 9, destPinOffset.dy - 2, destPinOffset.dx - 9, destPinOffset.dy - 8)
      ..arcToPoint(Offset(destPinOffset.dx + 9, destPinOffset.dy - 8), radius: const Radius.circular(9), clockwise: true)
      ..quadraticBezierTo(destPinOffset.dx + 9, destPinOffset.dy - 2, destPinOffset.dx, destPinOffset.dy + 12)
      ..close();
    canvas.drawPath(pinPath, Paint()..color = const Color(0xFFDC2626));
    canvas.drawCircle(destPinOffset - const Offset(0, 8), 3.5, Paint()..color = Colors.white);

    // Vehicle Marker with Pulse Halo and Arrow
    canvas.drawCircle(carOffset, 20, Paint()..color = const Color(0xFF3B82F6).withValues(alpha: 0.25));
    canvas.drawCircle(carOffset, 14, Paint()..color = const Color(0xFF1D4ED8));
    canvas.drawCircle(carOffset, 14, Paint()..color = Colors.white..strokeWidth = 2.5..style = PaintingStyle.stroke);

    // Rotated navigation arrow inside car marker
    canvas.save();
    canvas.translate(carOffset.dx, carOffset.dy);
    canvas.rotate(carAngle);
    final arrowPath = Path()
      ..moveTo(7, 0)
      ..lineTo(-5, -5)
      ..lineTo(-2, 0)
      ..lineTo(-5, 5)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = Colors.white);
    canvas.restore();

    // Place labels
    _drawText(canvas, 'Colombo Harbour', Offset(w * 0.10, h * 0.24));
    _drawText(canvas, 'Fort Station', Offset(w * 0.18, h * 0.50));
    _drawText(canvas, 'Kelaniya', Offset(w * 0.68, h * 0.18));
    _drawText(canvas, 'Dematagoda', Offset(w * 0.55, h * 0.44));
    _drawText(canvas, 'Colombo', Offset(w * 0.45, h * 0.58), fontSize: 15, isBold: true);
    _drawText(canvas, 'Orugodawatta Depot', Offset(w * 0.64, h * 0.32));

    // Dynamic Live ETA / Distance Tooltip directly above vehicle
    _drawVehicleTooltip(canvas, carOffset);
  }

  void _drawCheckpointDot(Canvas canvas, Offset pos, String label, {required bool isPassed}) {
    final dotColor = isPassed ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    canvas.drawCircle(pos, 5, Paint()..color = dotColor);
    canvas.drawCircle(pos, 2, Paint()..color = Colors.white);
    _drawText(canvas, label, pos + const Offset(-18, 7), fontSize: 9);
  }

  void _drawVehicleTooltip(Canvas canvas, Offset carOffset) {
    final tooltipOffset = carOffset + const Offset(-45, -42);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tooltipOffset.dx, tooltipOffset.dy, 90, 26),
      const Radius.circular(13),
    );
    canvas.drawRRect(rrect, Paint()..color = Colors.black.withValues(alpha: 0.15));
    canvas.drawRRect(
      rrect.deflate(1),
      Paint()..color = const Color(0xFF0F172A),
    );

    final span = TextSpan(
      text: '$durationText ($distanceText)',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    final painter = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, tooltipOffset + Offset((90 - painter.width) / 2, (26 - painter.height) / 2));
  }

  void _drawText(Canvas canvas, String text, Offset position, {double fontSize = 10, bool isBold = false}) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        color: const Color(0xFF334155),
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
        backgroundColor: Colors.white.withValues(alpha: 0.75),
      ),
    );
    final painter = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant _ColomboMapArtPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.durationText != durationText ||
        oldDelegate.distanceText != distanceText;
  }
}

