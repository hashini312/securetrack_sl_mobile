import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:securetrack_sl/owner/app_settings.dart';
import 'package:securetrack_sl/owner/components.dart';
import 'package:securetrack_sl/owner/firebase_service.dart' as owner_fs;
import 'package:securetrack_sl/owner/models.dart';
import 'package:securetrack_sl/owner/screens.dart' as owner_screens;
import 'package:securetrack_sl/owner/session_manager.dart' as owner_sm;
import 'package:securetrack_sl/owner/settings_screen.dart' as owner_settings;
import 'package:securetrack_sl/owner/main.dart' as owner_main;

import 'package:securetrack_sl/driver/firebase_options.dart';
import 'package:securetrack_sl/driver/driver_login_page.dart';
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
      child: const SecureTrackApp(),
    ),
  );
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
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          themeMode: settings.themeMode,
          // Exact Light Theme from original Owner App
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
          // Exact Dark Theme from original Owner App
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
                return MaterialPageRoute(builder: (_) => const owner_screens.SplashScreen());
              case '/role-selection':
                return MaterialPageRoute(builder: (_) => const owner_screens.RoleSelectionScreen());
              case '/login':
                final roleArg = routeSettings.arguments as String? ?? 'Owner';
                if (roleArg.toLowerCase() == 'driver') {
                  return MaterialPageRoute(builder: (_) => const DriverLoginPage());
                }
                return MaterialPageRoute(builder: (_) => const owner_screens.LoginScreen());
              case '/driver-login':
                return MaterialPageRoute(builder: (_) => const DriverLoginPage());
              case '/home_screen':
              case '/driver-home':
                return MaterialPageRoute(builder: (_) => const driver_app.MainNavigationScreen());
              case '/register':
                return MaterialPageRoute(builder: (_) => const owner_screens.RegisterScreen());
              case '/home':
                return MaterialPageRoute(builder: (_) => const owner_main.MainShell());
              case '/container-details':
                final container = routeSettings.arguments as ContainerModel? ?? ContainerModel.sampleContainers.first;
                return MaterialPageRoute(builder: (_) => owner_screens.ContainerDetailsScreen(container: container));
              case '/live-tracking':
                final container = routeSettings.arguments as ContainerModel?;
                return MaterialPageRoute(builder: (_) => owner_screens.LiveTrackingScreen(container: container));
              case '/settings':
                return MaterialPageRoute(builder: (_) => const owner_settings.SettingsScreen());
              default:
                return MaterialPageRoute(builder: (_) => const owner_screens.SplashScreen());
            }
          },
        );
      },
    );
  }
}
