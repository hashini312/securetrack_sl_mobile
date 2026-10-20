import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Handles session persistence and automatic 15-minute inactivity timeout
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  static const String _keyUser = 'securetrack_session_user';
  static const String _keyLastActive = 'securetrack_session_last_active';
  static const int sessionTimeoutMinutes = 15;

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('[SessionManager] Init error: $e');
    }
  }

  /// Record user login and store session timestamp
  Future<void> saveSession(UserModel user) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'role': user.role,
        'company': user.company,
        'companyId': user.companyId,
      });

      await _prefs!.setString(_keyUser, userData);
      await updateActivity();
      debugPrint('[SessionManager] Session saved for: ${user.email}');
    } catch (e) {
      debugPrint('[SessionManager] saveSession error: $e');
    }
  }

  /// Update the last active timestamp (call when user interacts with app)
  Future<void> updateActivity() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await _prefs!.setInt(_keyLastActive, now);
    } catch (e) {
      debugPrint('[SessionManager] updateActivity error: $e');
    }
  }

  /// Synchronously check if session is still valid (since SharedPreferences is preloaded in main())
  UserModel? getCachedValidSession() {
    if (_prefs == null) return null;
    final userJson = _prefs!.getString(_keyUser);
    final lastActive = _prefs!.getInt(_keyLastActive);

    if (userJson == null || lastActive == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final diffMinutes = (now - lastActive) / (1000 * 60);

    if (diffMinutes <= sessionTimeoutMinutes) {
      updateActivity();
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel(
        name: map['name'] ?? 'User',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        role: map['role'] ?? 'Owner',
        company: map['company'] ?? 'Cargo Overseas Freight Pvt Ltd',
        companyId: map['companyId'] ?? 'COMP-COF-2024',
      );
    } else {
      clearSession();
      return null;
    }
  }

  /// Check whether the current session is still valid (within 15 minutes)
  Future<UserModel?> getValidSession() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final userJson = _prefs!.getString(_keyUser);
      final lastActive = _prefs!.getInt(_keyLastActive);

      if (userJson == null || lastActive == null) {
        return null;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final diffMinutes = (now - lastActive) / (1000 * 60);

      debugPrint('[SessionManager] Time elapsed since last activity: ${diffMinutes.toStringAsFixed(1)} min');

      if (diffMinutes <= sessionTimeoutMinutes) {
        // Session is still active! Refresh activity timer
        await updateActivity();
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel(
          name: map['name'] ?? 'User',
          email: map['email'] ?? '',
          phone: map['phone'] ?? '',
          role: map['role'] ?? 'Owner',
          company: map['company'] ?? 'Cargo Overseas Freight Pvt Ltd',
          companyId: map['companyId'] ?? 'COMP-COF-2024',
        );
      } else {
        // Expired after 15 minutes
        debugPrint('[SessionManager] Session expired (> 15 minutes). Clearing session.');
        await clearSession();
        return null;
      }
    } catch (e) {
      debugPrint('[SessionManager] getValidSession error: $e');
      return null;
    }
  }

  /// Clear session when user explicitly logs out or session times out
  Future<void> clearSession() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.remove(_keyUser);
      await _prefs!.remove(_keyLastActive);
      debugPrint('[SessionManager] Session cleared successfully');
    } catch (e) {
      debugPrint('[SessionManager] clearSession error: $e');
    }
  }
}
