import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/session_service.dart';

class DriverLoginPage extends StatefulWidget {
  const DriverLoginPage({super.key});

  @override
  State<DriverLoginPage> createState() => _DriverLoginPageState();
}

class _DriverLoginPageState extends State<DriverLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Save FCM Token to Firestore
  Future<void> _saveDriverFcmToken(String driverId) async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(driverId)
            .set({
          'fcmToken': fcmToken,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint("FCM Token successfully saved: $fcmToken");
      }
    } catch (e) {
      debugPrint("Error saving FCM Token: $e");
    }
  }

  Future<void> _loginDriver() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter both email and password!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        final String role = (data?['role'] ?? '').toString().toUpperCase();
        if (role == 'DRIVER') {
          await SessionService.recordLogin();
          _showMessage("Logged in successfully!", Colors.green);

          await _saveDriverFcmToken(uid);

          if (mounted) {
            try {
              Navigator.pushReplacementNamed(context, '/home_screen');
            } catch (_) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          }
          return;
        }
      }

      await FirebaseAuth.instance.signOut();
      _showMessage("This account is not registered as an authorized driver!", Colors.red);

    } on FirebaseAuthException catch (e) {
      String customErrorMessage;
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential':
          customErrorMessage = "Incorrect email or password. Please try again.";
          break;
        case 'wrong-password':
          customErrorMessage = "Incorrect password. Please try again.";
          break;
        case 'invalid-email':
          customErrorMessage = "The email address format is invalid.";
          break;
        case 'user-disabled':
          customErrorMessage = "This driver account has been disabled.";
          break;
        case 'too-many-requests':
          customErrorMessage = "Too many failed attempts. Please try again later.";
          break;
        default:
          customErrorMessage = e.message ?? "Login failed. Please try again.";
      }
      _showMessage(customErrorMessage, Colors.red);
    } catch (e) {
      _showMessage("An error occurred. Please check your connection.", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  
    const primaryNavy = Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Form(
            key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              
              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                  onPressed: () {
                    try {
                      Navigator.pop(context);
                    } catch (_) {}
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Logo Center Icon
              SizedBox(
                width: 150,
                height: 150,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'SecureTrack SL',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to your account',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              // Driver Portal Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryNavy,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_car,
                      size: 18,
                      color: primaryNavy,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Container Driver Portal',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Email Input Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.poppins(fontSize: 14),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!v.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                  },
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF64748B)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryNavy, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Input Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: GoogleFonts.poppins(fontSize: 14),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryNavy, width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF64748B),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginDriver,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),

              // Forgot Password
              TextButton(
                onPressed: () {
                  _showMessage("Password reset link sent to registered email", primaryNavy);
                },
                child: Text(
                  'Forgot Password ?',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: primaryNavy,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Create New Account Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      try {
                        Navigator.pushNamed(context, '/register');
                      } catch (_) {}
                    },
                    child: Text(
                      'Create New Account',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
       ),
      ),
    );
  }
}