import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'session_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Driver Login
  Future<User?> loginDriver(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await SessionService.recordLogin();
      }

      return credential.user;
    } catch (e) {
      debugPrint("Login Error: $e");
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await SessionService.logout(null);
  }
}