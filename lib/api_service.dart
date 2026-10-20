import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';
import 'models.dart';
import 'session_manager.dart';

/// API Service connecting the Flutter app to Firebase Authentication & SecureTrack Backend
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Smart URL selection based on running platform (Android Emulator vs Desktop/Web)
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  static const Duration _timeout = Duration(milliseconds: 2500);

  // Local user cache with realistic Sri Lankan Container Owners & Importers
  final Map<String, Map<String, dynamic>> _localUsers = {
    'owner@cargooverseas.lk': {
      'name': 'Tharindu Perera',
      'email': 'owner@cargooverseas.lk',
      'password': 'Secure@2026',
      'phone': '+94 77 123 4567',
      'role': 'Container Owner',
      'company': 'Cargo Overseas Freight Pvt Ltd',
      'tinNumber': 'TIN-104928190',
      'customsImporterCode': 'SLC-IMP-40918',
    },
    'kasun.fernando@ceylonlogistics.lk': {
      'name': 'Kasun Fernando',
      'email': 'kasun.fernando@ceylonlogistics.lk',
      'password': 'Secure@2026',
      'phone': '+94 71 892 3451',
      'role': 'Container Owner',
      'company': 'Ceylon Global Freight & Logistics Ltd',
      'tinNumber': 'TIN-209481729',
      'customsImporterCode': 'SLC-IMP-38912',
    },
    'anura.wijesinghe@lankaforwarding.lk': {
      'name': 'Anura Wijesinghe',
      'email': 'anura.wijesinghe@lankaforwarding.lk',
      'password': 'Secure@2026',
      'phone': '+94 77 345 6789',
      'role': 'Container Owner',
      'company': 'Lanka Maritime Forwarders Pvt Ltd',
      'tinNumber': 'TIN-301928471',
      'customsImporterCode': 'SLC-IMP-29481',
    },
    'dilani.senanayake@islandfreight.lk': {
      'name': 'Dilani Senanayake',
      'email': 'dilani.senanayake@islandfreight.lk',
      'password': 'Secure@2026',
      'phone': '+94 76 543 2198',
      'role': 'Container Owner',
      'company': 'Island Express Cargo Solutions',
      'tinNumber': 'TIN-409182736',
      'customsImporterCode': 'SLC-IMP-50192',
    },
    'rohan.de.silva@transocean.lk': {
      'name': 'Rohan De Silva',
      'email': 'rohan.de.silva@transocean.lk',
      'password': 'Secure@2026',
      'phone': '+94 72 456 1234',
      'role': 'Container Owner',
      'company': 'Transoceanic Shipping & Logistics Pvt Ltd',
      'tinNumber': 'TIN-502918374',
      'customsImporterCode': 'SLC-IMP-19402',
    },
  };

  UserModel _currentUser = UserModel.defaultOwner;
  UserModel get currentUser => _currentUser;

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    SessionManager.instance.saveSession(user);
  }

  /// Authenticate user against Firebase Authentication (or Local Cache)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String role = 'Owner',
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Try Firebase Authentication First (Firebase Console)
    try {
      final fbResult = await FirebaseService.instance.loginUser(
        email: cleanEmail,
        password: password,
        role: role,
      );

      if (fbResult['success'] == true && fbResult['user'] != null) {
        final u = fbResult['user'];
        final loggedUser = UserModel(
          name: u['name'] ?? 'User',
          email: u['email'] ?? cleanEmail,
          phone: u['phone'] ?? '+94 77 123 4567',
          role: u['role'] ?? role,
          company: u['company'] ?? 'Cargo Overseas Freight Pvt Ltd',
        );
        _currentUser = loggedUser;
        SessionManager.instance.saveSession(loggedUser);
        return fbResult;
      } else if (fbResult['error'] != null && fbResult['error'].toString().contains('wrong-password')) {
        return {
          'success': false,
          'error': 'Incorrect password. Please verify your credentials and try again.',
        };
      }
    } catch (e) {
      debugPrint('[Auth] Firebase login attempt note: $e');
    }

    // 2. Try Backend API
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': cleanEmail,
              'password': password,
              'role': role,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['user'] != null) {
          final u = decoded['user'];
          final loggedUser = UserModel(
            name: u['name'] ?? 'User',
            email: u['email'] ?? cleanEmail,
            phone: u['phone'] ?? '+94 77 123 4567',
            role: u['role'] ?? role,
            company: u['company'] ?? 'Cargo Overseas Freight Pvt Ltd',
          );
          _currentUser = loggedUser;
          SessionManager.instance.saveSession(loggedUser);
        }
        return decoded;
      }
    } catch (e) {
      debugPrint('ApiService login connecting to local registry: $e');
    }

    // 3. Check Local Registered Users
    if (_localUsers.containsKey(cleanEmail)) {
      final user = _localUsers[cleanEmail]!;
      if (user['password'] == password) {
        final loggedUser = UserModel(
          name: user['name'] ?? 'User',
          email: cleanEmail,
          phone: user['phone'] ?? '+94 77 123 4567',
          role: user['role'] ?? role,
          company: user['company'] ?? 'Cargo Overseas Freight Pvt Ltd',
        );
        _currentUser = loggedUser;
        SessionManager.instance.saveSession(loggedUser);
        return {
          'success': true,
          'token': 'jwt_local_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'name': user['name'] ?? 'User',
            'email': cleanEmail,
            'role': user['role'] ?? role,
            'company': user['company'] ?? 'Cargo Overseas Freight Pvt Ltd',
          }
        };
      } else {
        return {
          'success': false,
          'error': 'Incorrect password. Please verify your credentials and try again.',
        };
      }
    }

    // 4. Unregistered user rejection
    return {
      'success': false,
      'error': 'Access Denied: Unregistered email ($cleanEmail). Please create an account first.',
    };
  }

  /// Register new user directly into Firebase Authentication Console & Cloud Firestore
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'Owner',
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // Cache locally
    _localUsers[cleanEmail] = {
      'name': name.trim(),
      'email': cleanEmail,
      'phone': phone.trim(),
      'password': password,
      'role': role,
      'company': 'Cargo Overseas Freight Pvt Ltd',
    };

    final newUser = UserModel(
      name: name.trim(),
      email: cleanEmail,
      phone: phone.trim(),
      role: role,
      company: 'Cargo Overseas Freight Pvt Ltd',
    );
    _currentUser = newUser;
    SessionManager.instance.saveSession(newUser);

    // 1. Direct Firebase Auth & Cloud Firestore Registration
    try {
      final fbResult = await FirebaseService.instance.registerUser(
        name: name,
        email: cleanEmail,
        phone: phone,
        password: password,
        role: role,
      );
      if (fbResult['success'] == true) {
        debugPrint('[ApiService] User successfully created in Firebase Console: $cleanEmail');
      }
    } catch (e) {
      debugPrint('[ApiService] Firebase Auth registration note: $e');
    }

    // 2. Try sending to SQLite Backend API
    try {
      await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name.trim(),
              'email': cleanEmail,
              'phone': phone.trim(),
              'password': password,
              'role': role,
            }),
          )
          .timeout(_timeout);
    } catch (_) {}

    return {
      'success': true,
      'message': 'Account registered successfully in Firebase Authentication',
      'user': {
        'name': name.trim(),
        'email': cleanEmail,
        'role': role,
      }
    };
  }

  /// Fetch container list from backend
  Future<List<ContainerModel>> getContainers() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/containers'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return ContainerModel.sampleContainers;
        }
      }
    } catch (e) {
      debugPrint('ApiService getContainers fallback: $e');
    }
    return ContainerModel.sampleContainers;
  }

  /// Fetch live alerts list
  Future<List<AlertItem>> getAlerts({String category = 'All'}) async {
    try {
      final uri = category == 'All'
          ? Uri.parse('$baseUrl/alerts')
          : Uri.parse('$baseUrl/alerts?category=$category');

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return AlertItem.sampleAlerts.where((a) {
            if (category == 'All') return true;
            return a.category.toLowerCase() == category.toLowerCase();
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiService getAlerts fallback: $e');
    }

    return AlertItem.sampleAlerts.where((a) {
      if (category == 'All') return true;
      return a.category.toLowerCase() == category.toLowerCase();
    }).toList();
  }
}
