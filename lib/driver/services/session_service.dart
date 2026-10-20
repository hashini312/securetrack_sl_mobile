import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const int sessionTimeoutMinutes = 15;
  static const String keyLoginTime = 'login_time';
  static const String keyLastActive = 'last_active_time';

  static Timer? _sessionTimer;

  /// Call upon successful driver login
  static Future<void> recordLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final int now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(keyLoginTime, now);
    await prefs.setInt(keyLastActive, now);
  }

  /// Update last active timestamp on user interaction
  static Future<void> updateActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLastActive, DateTime.now().millisecondsSinceEpoch);
  }

  /// Check whether the current session is valid (< 15 minutes)
  static Future<bool> isSessionValid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final int? lastActive = prefs.getInt(keyLastActive) ?? prefs.getInt(keyLoginTime);

    if (lastActive == null) {
      await recordLogin();
      return true;
    }

    final DateTime lastActiveTime = DateTime.fromMillisecondsSinceEpoch(lastActive);
    final Duration difference = DateTime.now().difference(lastActiveTime);

    if (difference.inMinutes >= sessionTimeoutMinutes) {
      return false;
    }

    return true;
  }

  /// Clear session timestamps and log out
  static Future<void> logout(BuildContext? context) async {
    _sessionTimer?.cancel();
    _sessionTimer = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyLoginTime);
    await prefs.remove(keyLastActive);

    await FirebaseAuth.instance.signOut();

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please log in again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/role-selection',
        (route) => false,
      );
    }
  }

  /// Start periodic monitoring of session validity
  static void startMonitoring(BuildContext context) {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 15), (timer) async {
      final valid = await isSessionValid();
      if (!valid) {
        timer.cancel();
        _sessionTimer = null;
        if (context.mounted) {
          await logout(context);
        }
      }
    });
  }

  /// Stop periodic monitoring
  static void stopMonitoring() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }
}

