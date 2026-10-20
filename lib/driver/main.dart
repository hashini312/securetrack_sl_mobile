import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:securetrack_sl/owner/components.dart';
import 'package:securetrack_sl/driver/firebase_options.dart';
import 'package:securetrack_sl/driver/menu.dart';
import 'package:securetrack_sl/driver/driver_register_page.dart';
import 'package:securetrack_sl/driver/settings_screen.dart';
import 'package:securetrack_sl/driver/driver_login_page.dart';
import 'package:securetrack_sl/driver/screens/home_screen.dart';
import 'package:securetrack_sl/driver/screens/route_screen.dart';
import 'package:securetrack_sl/driver/screens/alerts_screen.dart';
import 'package:securetrack_sl/driver/screens/profile_screen.dart';
import 'package:securetrack_sl/driver/screens/shipments_screen.dart';
import 'package:securetrack_sl/driver/services/shipment_service.dart';
import 'package:securetrack_sl/driver/services/session_service.dart';
import 'package:securetrack_sl/driver/driver_sos_dialog.dart';

// Top-level Background Notification Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Background FCM Message Received: ${message.messageId}");
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ShipmentService.seedInitialShipmentsIfEmpty();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('si'),
        Locale('ta'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'SecureTrack Driver',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routes: {
            '/login': (context) => const DriverLoginPage(),
            '/register': (context) => const DriverRegisterPage(),
            '/settings': (context) => const SettingsScreen(),
            '/home': (context) => const MainNavigationScreen(),
            '/home_screen': (context) => const MainNavigationScreen(),
            '/shipments': (context) => const ShipmentsScreen(),
          },
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
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  int _unreadAlertsCount = 0;

  @override
  void initState() {
    super.initState();
    SessionService.startMonitoring(context);
    _setupFcmTokenAndListeners();
  }

  @override
  void dispose() {
    SessionService.stopMonitoring();
    super.dispose();
  }

  Future<void> _setupFcmTokenAndListeners() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      FirebaseFirestore.instance
          .collection('alerts')
          .where('driverId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            _unreadAlertsCount = snapshot.docs.length;
          });
        }
      });
    } catch (e) {
      debugPrint("Firestore Listener Error: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _unreadAlertsCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<String> titles = [
      'Driver Dashboard',
      'Corridor Navigation',
      'Customs Alerts',
      'Driver Profile',
    ];

    final List<Widget> screens = [
      HomeScreen(onNavigate: _onItemTapped),
      const RouteScreen(),
      const AlertsScreen(),
      const ProfileScreen(),
    ];

    return Listener(
      onPointerDown: (_) => SessionService.updateActivity(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        drawer: Menu(onSelectTab: _onItemTapped),
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text(
            titles[_selectedIndex],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          actions: [
            // Quick SOS button in AppBar
            IconButton(
              tooltip: 'Emergency SOS',
              icon: const Icon(Icons.emergency_rounded, color: AppColors.dangerRed),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const DriverSosDialog(
                    containerId: 'Active Container',
                    vehicleNo: 'Active Truck',
                  ),
                );
              },
            ),
            // Unread Alert Notification badge
            IconButton(
              icon: Badge(
                isLabelVisible: _unreadAlertsCount > 0,
                label: Text('$_unreadAlertsCount'),
                child: const Icon(Icons.notifications_outlined, color: AppColors.textDark),
              ),
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
        body: screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: AppColors.textLight,
            selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_rounded),
                label: 'home'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.navigation_rounded),
                label: 'route'.tr(),
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: _unreadAlertsCount > 0,
                  label: Text('$_unreadAlertsCount'),
                  child: const Icon(Icons.notifications_rounded),
                ),
                label: 'alerts'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_rounded),
                label: 'profile'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
