import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

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
import 'package:securetrack_sl/driver/services/firebase_service.dart';
import 'package:securetrack_sl/driver/services/session_service.dart';

// Top-level Background Notification Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Background FCM Message Received: ${message.messageId}");
}

// Theme Mode Notifier: ALWAYS defaults to light theme unless explicitly enabled in settings
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load saved dark mode preference from SharedPreferences (Default is false / Light Mode)
  final prefs = await SharedPreferences.getInstance();
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Pre-seed Sri Lanka Customs dataset in Firestore if empty
  ShipmentService.seedInitialShipmentsIfEmpty();

  // Register Background Notification Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request Notification Permission
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
          title: 'Driver App',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // EasyLocalization Configuration
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          
          // Routes setup for seamless navigation
          routes: {
            '/login': (context) => const DriverLoginPage(),
            '/register': (context) => const DriverRegisterPage(),
            '/settings': (context) => const SettingsScreen(),
            '/home': (context) => const MainNavigationScreen(),
            '/home_screen': (context) => const MainNavigationScreen(),
            '/shipments': (context) => const ShipmentsScreen(),
          },

          // Light Theme (Default)
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            primaryColor: const Color(0xFF1E3A8A),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E3A8A),
              brightness: Brightness.light,
              primary: const Color(0xFF1E3A8A),
              surface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF8FAFC),
              foregroundColor: Color.fromARGB(255, 23, 53, 134),
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          
          // Dark Theme (Only active when toggled in Settings)
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            primaryColor: const Color(0xFF2563EB),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E293B),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E293B),
              surfaceTintColor: const Color.fromARGB(0, 14, 31, 108),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),

          // Login State Management
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const DriverLoginPage();
        }

        return FutureBuilder<bool>(
          future: _verifyDriverAccessAndSession(user.uid),
          builder: (context, checkSnapshot) {
            if (checkSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final bool isAuthorized = checkSnapshot.data ?? false;
            if (isAuthorized) {
              return const MainNavigationScreen();
            } else {
              FirebaseAuth.instance.signOut();
              return const DriverLoginPage();
            }
          },
        );
      },
    );
  }

  static Future<bool> _verifyDriverAccessAndSession(String uid) async {
    final bool sessionOk = await SessionService.isSessionValid();
    if (!sessionOk) {
      return false;
    }

    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        await FirebaseService.seedInitialDataIfEmpty();
        userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
      }
      if (!userDoc.exists) {
        return false;
      }
      final data = userDoc.data() as Map<String, dynamic>?;
      final role = (data?['role'] ?? '').toString().toUpperCase();
      return role == 'DRIVER';
    } catch (e) {
      debugPrint("Error checking driver access: $e");
      return false;
    }
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

    // Firestore Listener for Unread Alerts
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
      }, onError: (error) {
        debugPrint("Firestore Query Error: $error");
      });
    } catch (e) {
      debugPrint("Firestore Listener Setup Error: $e");
    }

    // Setup FCM Token and Listeners
    _setupFcmToken(user.uid);
  }

  // Setup FCM Token and Listeners
  Future<void> _setupFcmToken(String uid) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Token Refresh Listener
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'fcmToken': newToken}, SetOptions(merge: true));
      });

      // Foreground Notification Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("Foreground notification received: ${message.notification?.title}");
      });
    } catch (e) {
      debugPrint("FCM Token Error: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Reset unread count when clicking on Alerts tab
      if (index == 2) {
        _unreadAlertsCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic titles for each tab
    final List<String> titles = [
      'home'.tr(),
      'route'.tr(),
      'alerts'.tr(),
      'profile'.tr(),
    ];

    // Navigation Screens
    final List<Widget> screens = [
      HomeScreen(
        onNavigate: _onItemTapped,
      ),
      const RouteScreen(),
      const AlertsScreen(),
      const ProfileScreen(),
    ];

    return Listener(
      onPointerDown: (_) => SessionService.updateActivity(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        // Side Drawer
        drawer: Menu(
          onSelectTab: (index) {
            _onItemTapped(index);
          },
        ),

        appBar: AppBar(
          centerTitle: true,
          
          // Tab Name
          title: Text(
            titles[_selectedIndex],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          
          // Menu Bar Icon
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),

          // Top Notification Icon
          actions: [
            IconButton(
              icon: Badge(
                isLabelVisible: _unreadAlertsCount > 0,
                label: Text('$_unreadAlertsCount'),
                child: const Icon(Icons.notifications_none),
              ),
              onPressed: () {
                _onItemTapped(2);
              },
            ),
          ],
        ),

        body: screens[_selectedIndex],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color.fromARGB(255, 23, 53, 134),
          unselectedItemColor: const Color.fromARGB(255, 92, 125, 210),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map),
              label: 'route'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: _unreadAlertsCount > 0,
                label: Text('$_unreadAlertsCount'),
                child: const Icon(Icons.notifications),
              ),
              label: 'alerts'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'profile'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
