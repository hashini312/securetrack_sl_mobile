import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:securetrack_sl/owner/app_settings.dart';
import 'package:securetrack_sl/owner/firebase_service.dart' as owner_fs;
import 'package:securetrack_sl/owner/session_manager.dart' as owner_sm;
import 'package:securetrack_sl/owner/screens.dart' as owner_screens;
import 'package:securetrack_sl/owner/main.dart' as owner_main;

import 'package:securetrack_sl/driver/firebase_options.dart';
import 'package:securetrack_sl/driver/driver_login_page.dart';
import 'package:securetrack_sl/driver/services/session_service.dart';
import 'package:securetrack_sl/driver/services/shipment_service.dart';
import 'package:securetrack_sl/driver/main.dart' as driver_app;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Owner services
  await owner_sm.SessionManager.instance.init();
  await owner_fs.FirebaseService.instance.init();

  // Initialize Driver services
  final prefs = await SharedPreferences.getInstance();
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  driver_app.themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  ShipmentService.seedInitialShipmentsIfEmpty();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('si'),
        Locale('ta'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const SecureTrackUnifiedApp(),
    ),
  );
}

class SecureTrackUnifiedApp extends StatelessWidget {
  const SecureTrackUnifiedApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'SecureTrack SL',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          themeMode: settings.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            primaryColor: const Color(0xFF1E3A8A),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E3A8A),
              primary: const Color(0xFF1E3A8A),
              secondary: const Color(0xFF0284C7),
              surface: Colors.white,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF0F172A),
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            primaryColor: const Color(0xFF3B82F6),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3B82F6),
              primary: const Color(0xFF3B82F6),
              secondary: const Color(0xFF38BDF8),
              surface: const Color(0xFF1E293B),
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E293B),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          home: const UnifiedRoleSelectorScreen(),
        );
      },
    );
  }
}

/// Unified Role Selector Landing Page
class UnifiedRoleSelectorScreen extends StatelessWidget {
  const UnifiedRoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Emblem / Logo
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Icon(
                    Icons.security_rounded,
                    size: 64,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'SecureTrack SL',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sri Lanka Customs Container Transit Monitoring',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 40),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Portal to Continue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Portal Card 1: Container Owner
              _buildPortalCard(
                context: context,
                title: 'Container Owner Portal',
                subtitle: 'Track live containers, view analytics & security status',
                icon: Icons.corporate_fare_rounded,
                accentColor: const Color(0xFF1E3A8A),
                onTap: () {
                  final sm = owner_sm.SessionManager.instance;
                  final cachedSession = sm.getCachedValidSession();
                  if (cachedSession != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const owner_main.MainShell(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const owner_screens.LoginScreen(),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              // Portal Card 2: Truck Driver
              _buildPortalCard(
                context: context,
                title: 'Truck Driver Portal',
                subtitle: 'View assigned shipments, GPS corridor routes & alerts',
                icon: Icons.local_shipping_rounded,
                accentColor: const Color(0xFF0284C7),
                onTap: () async {
                  final isValid = await SessionService.isSessionValid();
                  if (context.mounted) {
                    if (isValid) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const driver_app.MainNavigationScreen(),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DriverLoginPage(),
                        ),
                      );
                    }
                  }
                },
              ),

              const SizedBox(height: 48),

              Text(
                'Sri Lanka Customs • Secure Transit Command',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortalCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
