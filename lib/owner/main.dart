import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_settings.dart';
import 'components.dart';
import 'firebase_service.dart';
import 'models.dart';
import 'screens.dart';
import 'session_manager.dart';
import 'settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Session Manager & Firebase Cloud Backend
  await SessionManager.instance.init();
  await FirebaseService.instance.init();

  runApp(const SecureTrackApp());
}

class SecureTrackApp extends StatelessWidget {
  const SecureTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'SecureTrack SL',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          // Light Theme
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.background,
            primaryColor: AppColors.primaryBlue,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryBlue,
              primary: AppColors.primaryBlue,
              secondary: AppColors.accentBlue,
              surface: Colors.white,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textDark,
              elevation: 0,
            ),
          ),
          // Dark Theme for night port operations & custom logistics
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            primaryColor: AppColors.accentBlue,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryBlue,
              primary: AppColors.accentBlue,
              secondary: const Color(0xFF60A5FA),
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
          initialRoute: '/',
          onGenerateRoute: (routeSettings) {
            switch (routeSettings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => const SplashScreen());
              case '/role-selection':
                return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
              case '/login':
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              case '/register':
                return MaterialPageRoute(builder: (_) => const RegisterScreen());
              case '/home':
                return MaterialPageRoute(builder: (_) => const MainShell());
              case '/container-details':
                final container = routeSettings.arguments as ContainerModel? ?? ContainerModel.sampleContainers.first;
                return MaterialPageRoute(builder: (_) => ContainerDetailsScreen(container: container));
              case '/live-tracking':
                final container = routeSettings.arguments as ContainerModel?;
                return MaterialPageRoute(builder: (_) => LiveTrackingScreen(container: container));
              case '/settings':
                return MaterialPageRoute(builder: (_) => const SettingsScreen());
              default:
                return MaterialPageRoute(builder: (_) => const SplashScreen());
            }
          },
        );
      },
    );
  }
}

/// Main Shell hosting the 4 Bottom Navigation Bar tabs: Home, Map, Alerts, Profile
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  StreamSubscription<List<ContainerModel>>? _containerAlertSub;
  final Set<String> _notifiedTamperedContainers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _startTamperListener();
  }

  void _startTamperListener() {
    _containerAlertSub = FirebaseService.instance.getContainersStream().listen((containers) {
      for (final c in containers) {
        final isTampered = c.sealStatus.trim().toLowerCase() == 'tampered';
        if (isTampered && !_notifiedTamperedContainers.contains(c.id)) {
          _notifiedTamperedContainers.add(c.id);
          if (mounted && AppSettingsController.instance.sealTamperSiren) {
            _showCriticalTamperDialog(c);
          }
        } else if (!isTampered && _notifiedTamperedContainers.contains(c.id)) {
          _notifiedTamperedContainers.remove(c.id);
        }
      }
    });
  }

  void _showCriticalTamperDialog(ContainerModel container) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppSettingsController.instance.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Color(0xFFDC2626),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'SECURITY ALERT',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unauthorized Container Breach Detected!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppSettingsController.instance.isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppSettingsController.instance.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppSettingsController.instance.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Container ID: ${container.id}',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentBlue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: Electronic Seal (e-Seal) Compromised',
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFDC2626), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Driver: ${container.driverName}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppSettingsController.instance.isDarkMode ? const Color(0xFF94A3B8) : AppColors.textMuted,
                    ),
                  ),
                  Text(
                    'Route: ${container.route}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppSettingsController.instance.isDarkMode ? const Color(0xFF94A3B8) : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Customs enforcement & owner audit stream notified immediately.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppSettingsController.instance.isDarkMode ? const Color(0xFF94A3B8) : AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Dismiss',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.location_on, size: 16),
            label: Text(
              'Track on Live Map',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _onTabTapped(1); // Switch to Map tab
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _containerAlertSub?.cancel();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;
    final isDark = settings.isDarkMode;

    final List<Widget> pages = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const LiveTrackingScreen(),
      AlertsScreen(onNavigateTab: _onTabTapped),
      ProfileScreen(onNavigateTab: _onTabTapped),
    ];

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Listener(
          onPointerDown: (_) => SessionManager.instance.updateActivity(),
          behavior: HitTestBehavior.translucent,
          child: PopScope(
            canPop: _currentIndex == 0,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (_currentIndex != 0) {
                // If user is on Map, Alerts, or Profile, back button takes them to Dashboard (Home) tab!
                setState(() {
                  _currentIndex = 0;
                });
              }
            },
            child: Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF334155) : AppColors.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              selectedItemColor: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
              unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF6BA2D4),
              selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.normal),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: settings.tr('dashboard'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.location_on_outlined),
                  activeIcon: const Icon(Icons.location_on),
                  label: settings.tr('live_tracking'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.notifications_outlined),
                  activeIcon: const Icon(Icons.notifications),
                  label: settings.tr('alerts'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: settings.tr('profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
  }
}
