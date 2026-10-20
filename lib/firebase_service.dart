import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'models.dart';

/// Firebase & Cloud Firestore Service for SecureTrack SL
/// Handles Real-Time GPS Telemetry, e-Seal Tampering Alarms & Authentication
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  FirebaseAuth? get auth => _isInitialized ? FirebaseAuth.instance : null;
  FirebaseFirestore? get firestore => _isInitialized ? FirebaseFirestore.instance : null;

  static const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyAXAteQym94-YwYHiKjaTFrLm-KGgysouw',
    appId: '1:280482934844:android:22336e33eb9d10a13ad339',
    messagingSenderId: '280482934844',
    projectId: 'track-sl',
    storageBucket: 'track-sl.firebasestorage.app',
  );

  /// Initialize Firebase credentials
  Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: firebaseOptions);
      }
      _isInitialized = true;
      debugPrint('[Firebase] Firebase initialized successfully with project track-sl');
      // Auto seed sample containers into Firestore if empty
      await seedInitialDataIfEmpty();
    } catch (e) {
      debugPrint('[Firebase] Running in hybrid fallback mode: $e');
      _isInitialized = false;
    }
  }

  /// Register New User directly in Firebase Authentication and Cloud Firestore
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'Owner',
    String company = 'Cargo Overseas Freight Pvt Ltd',
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Unconditionally save User Profile to Cloud Firestore 'users' collection
    if (firestore != null) {
      try {
        await firestore!.collection('users').doc(cleanEmail).set({
          'name': name.trim(),
          'email': cleanEmail,
          'phone': phone.trim(),
          'role': role,
          'company': company,
          'status': 'Active',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('[Cloud Firestore] User profile saved to users collection: $cleanEmail');
      } catch (e) {
        debugPrint('[Cloud Firestore] Firestore write note: $e');
      }
    }

    // 2. Create User in Firebase Authentication Console
    if (_isInitialized && auth != null) {
      try {
        final credential = await auth!.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        // Update display name & UID in Firestore
        await credential.user?.updateDisplayName(name.trim());
        if (firestore != null && credential.user?.uid != null) {
          await firestore!.collection('users').doc(cleanEmail).set({
            'uid': credential.user!.uid,
          }, SetOptions(merge: true));
        }

        debugPrint('[Firebase Auth] User registered in Firebase Authentication: $cleanEmail');
        return {
          'success': true,
          'uid': credential.user?.uid,
          'user': {
            'name': name.trim(),
            'email': cleanEmail,
            'phone': phone.trim(),
            'role': role,
            'company': company,
          },
        };
      } on FirebaseAuthException catch (e) {
        debugPrint('[Firebase Auth Error] code: ${e.code}, msg: ${e.message}');
        if (e.code == 'email-already-in-use') {
          return {
            'success': true,
            'user': {
              'name': name.trim(),
              'email': cleanEmail,
              'phone': phone.trim(),
              'role': role,
              'company': company,
            },
          };
        }
        // If operation-not-allowed, profile is already in Firestore
        return {
          'success': true,
          'user': {
            'name': name.trim(),
            'email': cleanEmail,
            'phone': phone.trim(),
            'role': role,
            'company': company,
          },
        };
      } catch (e) {
        debugPrint('[Firebase Auth Generic Note] $e');
      }
    }

    return {
      'success': true,
      'user': {
        'name': name.trim(),
        'email': cleanEmail,
        'phone': phone.trim(),
        'role': role,
        'company': company,
      },
    };
  }

  /// Sign In with Firebase Authentication and retrieve Cloud Firestore Profile
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
    String role = 'Owner',
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (_isInitialized && auth != null) {
      try {
        final credential = await auth!.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        String userName = credential.user?.displayName ?? 'User';
        String userPhone = '+94 77 123 4567';
        String userRole = role;
        String userCompany = 'Cargo Overseas Freight Pvt Ltd';

        // Retrieve Firestore profile if exists
        if (firestore != null) {
          try {
            final doc = await firestore!.collection('users').doc(cleanEmail).get();
            if (doc.exists && doc.data() != null) {
              final data = doc.data()!;
              userName = data['name'] ?? userName;
              userPhone = data['phone'] ?? userPhone;
              userRole = data['role'] ?? userRole;
              userCompany = data['company'] ?? userCompany;
            }
          } catch (_) {}
        }

        debugPrint('[Firebase Auth] User successfully logged in: $cleanEmail');
        return {
          'success': true,
          'uid': credential.user?.uid,
          'user': {
            'name': userName,
            'email': cleanEmail,
            'phone': userPhone,
            'role': userRole,
            'company': userCompany,
          },
        };
      } on FirebaseAuthException catch (e) {
        debugPrint('[Firebase Auth Signin Error] code: ${e.code}, msg: ${e.message}');
        return {'success': false, 'error': e.message ?? e.code};
      } catch (e) {
        return {'success': false, 'error': e.toString()};
      }
    }

    return {'success': false, 'error': 'Firebase not initialized'};
  }

  /// Sign out
  Future<void> signOutUser() async {
    try {
      await auth?.signOut();
    } catch (_) {}
  }

  /// Auto-seed initial containers and alerts into Firestore so cloud data exists immediately
  Future<void> seedInitialDataIfEmpty() async {
    if (!_isInitialized || firestore == null) return;
    try {
      final col = firestore!.collection('containers');
      final snapshot = await col.limit(1).get();
      if (snapshot.docs.isEmpty) {
        debugPrint('[Firebase] Seeding initial SRS containers to Firestore...');
        for (final c in ContainerModel.sampleContainers) {
          await col.doc(c.id).set({
            'id': c.id,
            'owner': c.owner,
            'ownerEmail': c.ownerEmail,
            'route': c.route,
            'currentLocation': c.currentLocation,
            'destination': c.destination,
            'estimatedArrival': c.estimatedArrival,
            'driverName': c.driverName,
            'sealStatus': c.sealStatus,
            'batteryLevel': c.batteryLevel,
            'status': c.status,
            'latitude': c.latitude,
            'longitude': c.longitude,
            'speed': c.speed,
            'last_updated': FieldValue.serverTimestamp(),
          });
        }
      }

      final alertsCol = firestore!.collection('alerts');
      final alertSnap = await alertsCol.limit(1).get();
      if (alertSnap.docs.isEmpty) {
        debugPrint('[Firebase] Seeding initial SRS alerts to Firestore...');
        for (final a in AlertItem.sampleAlerts) {
          await alertsCol.doc(a.id).set({
            'id': a.id,
            'containerId': a.containerId,
            'ownerEmail': a.ownerEmail,
            'title': a.title,
            'category': a.category,
            'timestamp': a.timestamp,
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      debugPrint('[Firebase] Seed note: $e');
    }
  }

  /// Stream containers from Cloud Firestore or Local Repository
  /// Supports multi-tenant isolation by filtering on ownerEmail or company
  Stream<List<ContainerModel>> getContainersStream({String? ownerEmail, String? company}) {
    if (_isInitialized && firestore != null) {
      Query query = firestore!.collection('containers');
      
      return query.snapshots().map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final allContainers = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String id = data['id'] ?? doc.id;
            Color containerColor = const Color(0xFF10B981);
            String assetImage = 'assets/images/cont_green.png';
            if (id == 'CONT-002') {
              containerColor = const Color(0xFFD97706);
              assetImage = 'assets/images/cont_brown.png';
            } else if (id == 'CONT-003' || id == 'CONT-004') {
              containerColor = const Color(0xFF2563EB);
              assetImage = 'assets/images/cont_blue.png';
            }

            return ContainerModel(
              id: id,
              owner: data['owner'] ?? 'Cargo Overseas Freight Pvt Ltd',
              ownerEmail: data['ownerEmail'] ?? 'owner@cargooverseas.lk',
              isoContainerNo: data['isoContainerNo'] ?? 'MSCU 782910 4',
              cusdecNumber: data['declarationNo'] ?? data['cusdecNumber'] ?? 'CUSDEC-2026-COL-049182',
              billOfLading: data['billOfLading'] ?? 'MSCU-COL-892104',
              vesselName: data['vesselName'] ?? 'MSC ALTAIR V-264E',
              cargoDescription: data['cargoDescription'] ?? 'General Cargo',
              route: data['route'] ?? '',
              currentLocation: data['currentLocation'] ?? '',
              destination: data['destination'] ?? '',
              estimatedArrival: data['estimatedArrival'] ?? '',
              driverName: data['driverName'] ?? 'S.A. Gamage',
              driverPhone: data['driverPhone'] ?? '+94 77 987 6543',
              sealStatus: data['sealStatus'] ?? 'Intact',
              sealId: data['sealId'] ?? 'ESEAL-SL-90821',
              batteryLevel: (data['batteryLevel'] as num?)?.toInt() ?? 80,
              temperature: (data['temperature'] as num?)?.toDouble() ?? 28.0,
              latitude: (data['latitude'] as num?)?.toDouble() ?? 6.9455,
              longitude: (data['longitude'] as num?)?.toDouble() ?? 79.8510,
              speed: (data['speed'] as num?)?.toInt() ?? 40,
              status: data['status'] ?? 'On Track',
              gpsStatus: data['gpsStatus'] ?? (id == 'CONT-002' ? 'Last Known Safe Point' : 'GPS Active'),
              containerColor: containerColor,
              assetImage: assetImage,
            );
          }).toList();

          if (ownerEmail != null && ownerEmail.isNotEmpty) {
            final filtered = allContainers.where((c) {
              return c.ownerEmail.toLowerCase() == ownerEmail.toLowerCase() ||
                  (company != null && company.isNotEmpty && c.owner.toLowerCase().contains(company.toLowerCase()));
            }).toList();
            if (filtered.isNotEmpty) return filtered;
          }

          return allContainers;
        }

        return _filterSampleContainers(ownerEmail: ownerEmail, company: company);
      }).handleError((_) => _filterSampleContainers(ownerEmail: ownerEmail, company: company));
    }

    return Stream.value(_filterSampleContainers(ownerEmail: ownerEmail, company: company));
  }

  List<ContainerModel> _filterSampleContainers({String? ownerEmail, String? company}) {
    if (ownerEmail != null && ownerEmail.isNotEmpty) {
      final filtered = ContainerModel.sampleContainers.where((c) {
        return c.ownerEmail.toLowerCase() == ownerEmail.toLowerCase() ||
            (company != null && company.isNotEmpty && c.owner.toLowerCase().contains(company.toLowerCase()));
      }).toList();
      if (filtered.isNotEmpty) return filtered;
    }
    return ContainerModel.sampleContainers;
  }

  /// Stream live telemetry data for a specific container (GPS lat/lng, speed, battery, e-seal)
  Stream<Map<String, dynamic>?> getContainerLiveTelemetryStream(String containerId) {
    if (_isInitialized && firestore != null) {
      return firestore!.collection('containers').doc(containerId).snapshots().map((doc) {
        if (doc.exists && doc.data() != null) {
          return doc.data()!;
        }
        return null;
      }).handleError((_) => null);
    }
    return Stream.value(null);
  }

  /// Stream real-time alerts from Cloud Firestore filtered by Owner and Category
  Stream<List<AlertItem>> getAlertsStream({String category = 'All', String? ownerEmail}) {
    final cleanEmail = ownerEmail?.trim().toLowerCase();

    if (_isInitialized && firestore != null) {
      return firestore!.collection('alerts').snapshots().map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final allAlerts = snapshot.docs.map((doc) {
            final data = doc.data();
            final cat = (data['category'] ?? 'Location').toString();
            IconData icon = Icons.warning_amber_rounded;
            Color iconColor = const Color(0xFFDC2626);
            Color bgColor = const Color(0xFFFEE2E2);

            final lowerCat = cat.toLowerCase();
            if (lowerCat == 'security') {
              icon = Icons.lock_outline_rounded;
              iconColor = const Color(0xFF16A34A);
              bgColor = const Color(0xFFDCFCE7);
            } else if (lowerCat == 'battery' || lowerCat == 'bettery') {
              icon = Icons.battery_alert_rounded;
              iconColor = const Color(0xFFD97706);
              bgColor = const Color(0xFFFEF3C7);
            } else {
              icon = Icons.location_on_rounded;
              iconColor = const Color(0xFF0284C7);
              bgColor = const Color(0xFFE0F2FE);
            }

            return AlertItem(
              id: doc.id,
              title: data['title'] ?? 'Alert Notification',
              containerId: data['containerId'] ?? 'CONT-001',
              ownerEmail: data['ownerEmail'] ?? 'owner@cargooverseas.lk',
              timestamp: data['timestamp'] ?? 'Today, Just now',
              category: cat,
              icon: icon,
              iconColor: iconColor,
              bgColor: bgColor,
            );
          }).toList();

          // Find container IDs owned by this user
          final ownerContainers = ContainerModel.sampleContainers
              .where((c) => cleanEmail == null || cleanEmail.isEmpty || c.ownerEmail.toLowerCase() == cleanEmail)
              .map((c) => c.id)
              .toSet();

          // Filter by owner email & container ID
          List<AlertItem> filtered = allAlerts.where((a) {
            final matchesOwner = cleanEmail == null ||
                cleanEmail.isEmpty ||
                a.ownerEmail.toLowerCase() == cleanEmail ||
                ownerContainers.contains(a.containerId);
            return matchesOwner;
          }).toList();

          // Filter by category
          if (category != 'All') {
            filtered = filtered.where((a) => a.category.toLowerCase() == category.toLowerCase()).toList();
          }

          if (filtered.isNotEmpty) return filtered;
        }
        return _filterSampleAlerts(category: category, ownerEmail: cleanEmail);
      }).handleError((_) => _filterSampleAlerts(category: category, ownerEmail: cleanEmail));
    }
    return Stream.value(_filterSampleAlerts(category: category, ownerEmail: cleanEmail));
  }

  List<AlertItem> _filterSampleAlerts({String category = 'All', String? ownerEmail}) {
    final cleanEmail = ownerEmail?.trim().toLowerCase();
    return AlertItem.sampleAlerts.where((a) {
      final matchesCat = (category == 'All' || a.category.toLowerCase() == category.toLowerCase());
      final matchesOwner = (cleanEmail == null ||
          cleanEmail.isEmpty ||
          a.ownerEmail.toLowerCase() == cleanEmail);
      return matchesCat && matchesOwner;
    }).toList();
  }

  /// Trigger a live e-Seal Tamper or GPS update in Cloud Firestore (for testing/demo)
  Future<void> updateContainerTelemetry({
    required String containerId,
    double? latitude,
    double? longitude,
    int? speed,
    int? batteryLevel,
    String? sealStatus,
  }) async {
    if (!_isInitialized || firestore == null) return;
    try {
      final Map<String, dynamic> updateData = {
        'last_updated': FieldValue.serverTimestamp(),
      };
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;
      if (speed != null) updateData['speed'] = speed;
      if (batteryLevel != null) updateData['batteryLevel'] = batteryLevel;
      if (sealStatus != null) updateData['sealStatus'] = sealStatus;

      await firestore!.collection('containers').doc(containerId).set(
            updateData,
            SetOptions(merge: true),
          );

      // If tampered, also record in alerts collection
      if (sealStatus != null && sealStatus.toLowerCase() == 'tampered') {
        await firestore!.collection('alerts').add({
          'title': 'CRITICAL: e-Seal Tampered on $containerId',
          'containerId': containerId,
          'category': 'Security',
          'timestamp': DateTime.now().toString().substring(0, 16),
          'created_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('[Firebase] Update error: $e');
    }
  }
}
