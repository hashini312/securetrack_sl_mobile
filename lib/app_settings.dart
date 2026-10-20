import 'package:flutter/material.dart';

/// Supported Languages in Sri Lanka Customs ecosystem
enum AppLanguage {
  english('en', 'English', '🇬🇧'),
  sinhala('si', 'සිංහල', '🇱🇰'),
  tamil('ta', 'தமிழ்', '🇱🇰');

  final String code;
  final String label;
  final String flag;

  const AppLanguage(this.code, this.label, this.flag);
}

/// Central Localization Translations Dictionary
class AppTranslations {
  AppTranslations._();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'SecureTrack SL',
      'dashboard': 'Dashboard',
      'live_tracking': 'Live Tracking',
      'alerts': 'Alerts',
      'profile': 'Profile',
      'settings': 'Settings',
      'hello': 'Hello',
      'on_track': 'On Track',
      'arrived': 'Arrived',
      'delayed': 'Delayed',
      'recent_containers': 'Recent Containers',
      'view_all': 'View All',
      'seal_status': 'Seal Status',
      'secure': 'Secure',
      'tampered': 'Tampered',
      'speed': 'Speed',
      'battery': 'Battery',
      'location': 'Location',
      'route': 'Route',
      'eta': 'ETA',
      'track_on_map': 'Track on Map',
      'view_details': 'View Details',
      'active_containers': 'Active',
      'delivered_containers': 'Delivered',
      'total_containers': 'Total',
      'sign_out': 'Sign Out',
      'appearance': 'Appearance',
      'theme_mode': 'App Theme',
      'light_mode': 'Light Mode',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'select_language': 'Select Language',
      'notifications_alarms': 'Notifications & Alarms',
      'seal_tamper_siren': 'Seal Tamper Siren Alarm',
      'seal_tamper_siren_sub': 'Play high-priority audible siren when e-seal is breached',
      'route_deviation_alert': 'Geofence Deviation Alerts',
      'route_deviation_alert_sub': 'Notify if container departs designated Customs route',
      'low_battery_alert': 'Low Battery Alerts (<25%)',
      'low_battery_alert_sub': 'Notify when IoT tracking device needs battery recharge',
      'security': 'Security & Access',
      'biometric_unlock': 'Biometric / Fingerprint Lock',
      'biometric_unlock_sub': 'Require fingerprint verification on app launch',
      'customs_support': 'Sri Lanka Customs & Support',
      'emergency_hotline': 'Customs Emergency Hotline (1937)',
      'emergency_hotline_sub': '24/7 Direct line to Sri Lanka Customs ICT & Control Room',
      'call_now': 'Call Hotline',
      'help_docs': 'Project Info & SRS Documentation',
      'app_version': 'Version 1.0.0 (ITUM Project)',
      'save_changes': 'Saved',
      'all_alerts': 'All Alerts',
      'security_alerts': 'Security',
      'location_alerts': 'Location',
      'battery_alerts': 'Battery',
      'company_info': 'Company Profile',
      'contact_info': 'Contact Info',
      'status': 'Status',
      'last_updated': 'Last Updated',
    },
    'si': {
      'app_title': 'සිකියුර්ට්‍රැක් ශ්‍රී ලංකා',
      'dashboard': 'ප්‍රධාන පුවරුව',
      'live_tracking': 'සජීවී සිතියම',
      'alerts': 'ඇඟවීම්',
      'profile': 'පැතිකඩ',
      'settings': 'සැකසුම්',
      'hello': 'ආයුබෝවන්',
      'on_track': 'ගමනේ යෙදෙන',
      'arrived': 'ළඟා වූ',
      'delayed': 'ප්‍රමාද වූ',
      'recent_containers': 'මෑත බහාලුම්',
      'view_all': 'සියල්ල බලන්න',
      'seal_status': 'මුද්‍රාවේ තත්ත්වය',
      'secure': 'ආරක්ෂිතයි',
      'tampered': 'හානි වී ඇත',
      'speed': 'වේගය',
      'battery': 'බැටරිය',
      'location': 'ස්ථානය',
      'route': 'ගමන් මාර්ගය',
      'eta': 'ළඟාවන වේලාව',
      'track_on_map': 'සිතියමේ බලන්න',
      'view_details': 'විස්තර බලන්න',
      'active_containers': 'ක්‍රියාකාරී',
      'delivered_containers': 'භාරදුන්',
      'total_containers': 'මුළු එකතුව',
      'sign_out': 'ඉවත් වන්න (Sign Out)',
      'appearance': 'පෙනුම (Appearance)',
      'theme_mode': 'යෙදුමේ තේමාව (Theme)',
      'light_mode': 'ලා පැහැති තේමාව (Light)',
      'dark_mode': 'අඳුරු තේමාව (Dark)',
      'language': 'භාෂාව (Language)',
      'select_language': 'භාෂාව තෝරන්න',
      'notifications_alarms': 'දැනුම්දීම් සහ අනතුරු ඇඟවීම්',
      'seal_tamper_siren': 'මුද්‍රා අනතුරු ඇඟවීමේ හඬ (Siren)',
      'seal_tamper_siren_sub': 'මුද්‍රාව කැඩූ විගස ශබ්ද අනතුරු ඇඟවීමක් නිකුත් කිරීම',
      'route_deviation_alert': 'මාර්ගයෙන් පිටවීමේ අනතුරු ඇඟවීම්',
      'route_deviation_alert_sub': 'නියමිත රේගු මාර්ගයෙන් පිට පැන්න විට දැනුම් දීම',
      'low_battery_alert': 'අඩු බැටරි අනතුරු ඇඟවීම (<25%)',
      'low_battery_alert_sub': 'IoT උපාංගයේ බැටරිය අඩු වූ විට දැනුම් දීම',
      'security': 'ආරක්ෂාව (Security)',
      'biometric_unlock': 'ඇඟිලි සලකුණු අගුල (Fingerprint)',
      'biometric_unlock_sub': 'යෙදුම විවෘත කිරීමට ඇඟිලි සලකුණු භාවිතා කිරීම',
      'customs_support': 'ශ්‍රී ලංකා රේගු සහය',
      'emergency_hotline': 'හදිසි රේගු දුරකථන අංකය (1937)',
      'emergency_hotline_sub': 'පැය 24 පුරා රේගු පාලන මැදිරිය හා සම්බන්ධ වීමට',
      'call_now': 'ඇමතුමක් ගන්න',
      'help_docs': 'ව්‍යාපෘති විස්තර සහ SRS ලේඛන',
      'app_version': 'අනුවාදය 1.0.0 (ITUM Project)',
      'save_changes': 'සුරැකිණි',
      'all_alerts': 'සියලු ඇඟවීම්',
      'security_alerts': 'ආරක්ෂක',
      'location_alerts': 'ස්ථානීය',
      'battery_alerts': 'බැටරි',
      'company_info': 'සමාගමේ තොරතුරු',
      'contact_info': 'සම්බන්ධතා තොරතුරු',
      'status': 'තත්ත්වය',
      'last_updated': 'යාවත්කාලීන වේලාව',
    },
    'ta': {
      'app_title': 'செக்யூர்டிராக் இலங்கை',
      'dashboard': 'முகப்பு',
      'live_tracking': 'நேரலை கண்காணிப்பு',
      'alerts': 'எச்சரிக்கைகள்',
      'profile': 'சுயவிவரம்',
      'settings': 'அமைப்புகள்',
      'hello': 'வணக்கம்',
      'on_track': 'பயணத்தில்',
      'arrived': 'வந்து சேர்ந்தவை',
      'delayed': 'தாமதமானது',
      'recent_containers': 'சமீபத்திய கொள்கலன்கள்',
      'view_all': 'அனைத்தையும் பார்',
      'seal_status': 'சீல் நிலை',
      'secure': 'பாதுகாப்பானது',
      'tampered': 'சேதமடைந்துள்ளது',
      'speed': 'வேகம்',
      'battery': 'மின்கலன்',
      'location': 'இடம்',
      'route': 'பாதை',
      'eta': 'எதிர்பார்க்கப்படும் நேரம்',
      'track_on_map': 'வரைபடத்தில் காண்க',
      'view_details': 'விவரங்களை காண்க',
      'active_containers': 'செயலில் உள்ளவை',
      'delivered_containers': 'ஒப்படைக்கப்பட்டவை',
      'total_containers': 'மொத்தம்',
      'sign_out': 'வெளியேறு (Sign Out)',
      'appearance': 'தோற்றம்',
      'theme_mode': 'பயன்பாட்டு வடிவம்',
      'light_mode': 'வெளிச்ச முறை (Light)',
      'dark_mode': 'இருண்ட முறை (Dark)',
      'language': 'மொழி (Language)',
      'select_language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'notifications_alarms': 'அறிவிப்புகள் & எச்சரிக்கைகள்',
      'seal_tamper_siren': 'சீல் சேத ஒலி எச்சரிக்கை',
      'seal_tamper_siren_sub': 'சீல் சேதமடைந்தவுடன் உரத்த எச்சரிக்கை ஒலித்தல்',
      'route_deviation_alert': 'பாதை விலகல் எச்சரிக்கைகள்',
      'route_deviation_alert_sub': 'சுங்கப் பாதையை விட்டு வெளியேறினால் அறிவிக்கும்',
      'low_battery_alert': 'குறைந்த மின்கல எச்சரிக்கை (<25%)',
      'low_battery_alert_sub': 'IoT சாதன மின்கலன் குறையும் போது அறிவித்தல்',
      'security': 'பாதுகாப்பு',
      'biometric_unlock': 'கைரேகை பூட்டு (Fingerprint)',
      'biometric_unlock_sub': 'பயன்பாட்டைத் திறக்க கைரேகையைப் பயன்படுத்தவும்',
      'customs_support': 'இலங்கை சுங்க ஆதரவு',
      'emergency_hotline': 'சுங்க அவசர உதவி எண் (1937)',
      'emergency_hotline_sub': '24/7 இலங்கை சுங்க கட்டுப்பாட்டு அறை தொடர்பு',
      'call_now': 'அழைக்கவும்',
      'help_docs': 'திட்ட விவரங்கள் மற்றும் SRS ஆவணங்கள்',
      'app_version': 'பதிப்பு 1.0.0 (ITUM Project)',
      'save_changes': 'சேமிக்கப்பட்டது',
      'all_alerts': 'அனைத்து எச்சரிக்கைகள்',
      'security_alerts': 'பாதுகாப்பு',
      'location_alerts': 'இடம்',
      'battery_alerts': 'மின்கலன்',
      'company_info': 'நிறுவன சுயவிவரம்',
      'contact_info': 'தொடர்பு தகவல்',
      'status': 'நிலை',
      'last_updated': 'கடைசியாக புதுப்பிக்கப்பட்டது',
    }
  };

  static String get(String key, AppLanguage language) {
    final langCode = language.code;
    return _localizedValues[langCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

/// Global Application Settings & Theme State Controller
class AppSettingsController extends ChangeNotifier {
  AppSettingsController._();
  static final AppSettingsController instance = AppSettingsController._();

  ThemeMode _themeMode = ThemeMode.light;
  AppLanguage _language = AppLanguage.english;

  bool _sealTamperSiren = true;
  bool _geofenceAlerts = true;
  bool _batteryAlerts = true;
  bool _biometricLogin = false;
  final String _customsHotline = '1937';

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  AppLanguage get language => _language;
  bool get sealTamperSiren => _sealTamperSiren;
  bool get geofenceAlerts => _geofenceAlerts;
  bool get batteryAlerts => _batteryAlerts;
  bool get biometricLogin => _biometricLogin;
  String get customsHotline => _customsHotline;

  /// Quick translation helper
  String tr(String key) => AppTranslations.get(key, _language);

  // Setters
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    if (_language != lang) {
      _language = lang;
      notifyListeners();
    }
  }

  void setSealTamperSiren(bool value) {
    _sealTamperSiren = value;
    notifyListeners();
  }

  void setGeofenceAlerts(bool value) {
    _geofenceAlerts = value;
    notifyListeners();
  }

  void setBatteryAlerts(bool value) {
    _batteryAlerts = value;
    notifyListeners();
  }

  void setBiometricLogin(bool value) {
    _biometricLogin = value;
    notifyListeners();
  }
}
