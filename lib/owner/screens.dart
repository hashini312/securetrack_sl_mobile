import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'api_service.dart';
import 'app_settings.dart';
import 'components.dart';
import 'firebase_service.dart';
import 'models.dart';
import 'session_manager.dart';
import 'enhanced_container_card.dart';
import 'package:securetrack_sl/driver/services/session_service.dart';

//Splash screen with modern real animation (no letters/text)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Continuous subtle breathing/pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Initial entrance scale & fade animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeIn,
    );

    _scaleController.forward();

    _timer = Timer(const Duration(milliseconds: 4000), () {
      _checkSessionAndNavigate();
    });
  }

  Future<void> _checkSessionAndNavigate() async {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    // Check if user has an active session within the 15-minute window
    final sessionUser = await SessionManager.instance.getValidSession();
    if (!mounted) return;

    if (sessionUser != null) {
      // Valid session found! Restore user profile and go straight to Dashboard
      ApiService.instance.setCurrentUser(sessionUser);
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // No active session or expired (> 15 min), navigate to Role Selection / Login
      Navigator.of(context).pushReplacementNamed('/role-selection');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashNavy,
      body: GestureDetector(
        onTap: _checkSessionAndNavigate,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleController, _pulseController]),
            builder: (context, child) {
              final pulseValue = _pulseController.value;
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Radar Ripple / Glow Ring 1
                      Container(
                        width: 200 + (pulseValue * 30),
                        height: 200 + (pulseValue * 30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2563EB).withValues(alpha: 0.08 * (1 - pulseValue)),
                          border: Border.all(
                            color: const Color(0xFF60A5FA).withValues(alpha: 0.25 * (1 - pulseValue)),
                            width: 1.5,
                          ),
                        ),
                      ),
                      // Middle Glowing Ring 2
                      Container(
                        width: 170 + (pulseValue * 15),
                        height: 170 + (pulseValue * 15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E4E8C).withValues(alpha: 0.15),
                          border: Border.all(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                              blurRadius: 25,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      // Center Logo Hero (Increased size & subtle breathing)
                      Transform.scale(
                        scale: 1.0 + (pulseValue * 0.05),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const AppLogo(
                            size: 135,
                            isDarkBackground: true,
                            isBw: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

//role selection
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashNavy,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Top Logo and Title
            Center(
              child: Column(
                children: [
                  const AppLogo(size: 150, isDarkBackground: true, isBw: true),
                  const SizedBox(height: 14),
                  Text(
                    'SecureTrack SL',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select your role to continue',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // White Bottom Sheet containing Role Cards
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Container Owner Card
                  InkWell(
                    onTap: () async {
                      // Check if already logged in within 15 minutes
                      final sessionUser = await SessionManager.instance.getValidSession();
                      if (!context.mounted) return;
                      if (sessionUser != null) {
                        ApiService.instance.setCurrentUser(sessionUser);
                        Navigator.of(context).pushReplacementNamed('/home');
                      } else {
                        Navigator.of(context).pushNamed('/login', arguments: 'Owner');
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.ownerCardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6495ED),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Container Owner',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Track your containers\nwith status and alerts',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textMedium,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.primaryBlue,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Driver Card
                  InkWell(
                    onTap: () async {
                      final isDriverValid = await SessionService.isSessionValid();
                      if (!context.mounted) return;
                      if (isDriverValid) {
                        Navigator.of(context).pushNamed('/driver-home');
                      } else {
                        Navigator.of(context).pushNamed('/driver-login');
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.driverCardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              color: Color(0xFF48BB78),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.directions_car_filled,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Driver',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Update lock screen view\nassigned trips and alerts',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textMedium,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF166534),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String _userRole = 'Owner';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _checkActiveSession();
  }

  Future<void> _checkActiveSession() async {
    final sessionUser = await SessionManager.instance.getValidSession();
    if (mounted && sessionUser != null) {
      ApiService.instance.setCurrentUser(sessionUser);
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && (args == 'Driver' || args == 'Owner')) {
      _userRole = args;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (email.isEmpty) {
      _emailError = 'Please enter your email';
      isValid = false;
    } else if (!emailRegex.hasMatch(email)) {
      _emailError = 'Please enter a valid email address (e.g. name@domain.com)';
      isValid = false;
    } else {
      _emailError = null;
    }

    if (password.isEmpty) {
      _passwordError = 'Please enter your password';
      isValid = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isValid = false;
    } else {
      _passwordError = null;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleLogin() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await ApiService.instance.login(
      email: email,
      password: password,
      role: _userRole,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      final userName = result['user']?['name'] ?? 'User';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, $userName! Logged in successfully.'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      final errorMsg = result['error'] ?? 'Access Denied: Unregistered email or invalid password';
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.gpp_bad_rounded, color: AppColors.dangerRed, size: 26),
              SizedBox(width: 8),
              Text(
                'Access Denied',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.dangerRed),
              ),
            ],
          ),
          content: Text(
            errorMsg,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushNamed('/register', arguments: _userRole);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDriver = _userRole == 'Driver';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Back to role selection button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed('/role-selection');
                    }
                  },
                ),
              ),

              // Brand Header with enhanced Logo size
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const AppLogo(size: 150),
              ),
              const SizedBox(height: 16),
              Text(
                'SecureTrack SL',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to your account',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDriver ? AppColors.driverCardBg : AppColors.ownerCardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDriver ? const Color(0xFF10B981) : AppColors.primaryBlue,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDriver ? Icons.directions_car : Icons.person,
                      size: 16,
                      color: isDriver ? const Color(0xFF166534) : AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isDriver ? 'Driver Portal' : 'Container Owner Portal',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDriver ? const Color(0xFF166534) : AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Inputs with Real-time Email Validation
              CustomInputField(
                hintText: 'Email Address',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                errorText: _emailError,
                onChanged: (val) {
                  if (_emailError != null) {
                    setState(() {
                      _emailError = null;
                    });
                  }
                },
              ),
              CustomInputField(
                hintText: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                onTogglePassword: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                controller: _passwordController,
                errorText: _passwordError,
                onChanged: (val) {
                  if (_passwordError != null) {
                    setState(() {
                      _passwordError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),

              // Login Button
              PrimaryButton(
                text: _isLoading ? 'Authenticating...' : 'Login',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : () => _handleLogin(),
              ),
              const SizedBox(height: 14),

              // Forgot Password
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent to registered email'),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  );
                },
                child: Text(
                  'Forgot Password ?',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Create New Account link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/register', arguments: _userRole);
                    },
                    child: Text(
                      'Create New Account',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//reg screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _selectedRole = 'Owner';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && (args == 'Driver' || args == 'Owner')) {
      _selectedRole = args;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateRegistration() {
    bool isValid = true;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (name.isEmpty) {
      _nameError = 'Full name is required';
      isValid = false;
    } else {
      _nameError = null;
    }

    if (email.isEmpty) {
      _emailError = 'Email address is required';
      isValid = false;
    } else if (!emailRegex.hasMatch(email)) {
      _emailError = 'Please enter a valid email address';
      isValid = false;
    } else {
      _emailError = null;
    }

    if (phone.isEmpty) {
      _phoneError = 'Phone number is required';
      isValid = false;
    } else if (phone.replaceAll(RegExp(r'[^0-9]'), '').length < 9) {
      _phoneError = 'Please enter a valid phone number (min 9 digits)';
      isValid = false;
    } else {
      _phoneError = null;
    }

    if (password.isEmpty) {
      _passwordError = 'Password is required';
      isValid = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isValid = false;
    } else {
      _passwordError = null;
    }

    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
      isValid = false;
    } else if (confirmPassword != password) {
      _confirmPasswordError = 'Passwords do not match';
      isValid = false;
    } else {
      _confirmPasswordError = null;
    }

    setState(() {});
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create New Account',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Inputs with validation errors
              CustomInputField(
                hintText: 'Full Name',
                prefixIcon: Icons.person_outline,
                controller: _nameController,
                errorText: _nameError,
                onChanged: (val) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              CustomInputField(
                hintText: 'Email Address',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                errorText: _emailError,
                onChanged: (val) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              CustomInputField(
                hintText: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                errorText: _phoneError,
                onChanged: (val) {
                  if (_phoneError != null) setState(() => _phoneError = null);
                },
              ),
              CustomInputField(
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                controller: _passwordController,
                errorText: _passwordError,
                onChanged: (val) {
                  if (_passwordError != null) setState(() => _passwordError = null);
                },
              ),
              CustomInputField(
                hintText: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: _isConfirmPasswordVisible,
                onTogglePassword: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                controller: _confirmPasswordController,
                errorText: _confirmPasswordError,
                onChanged: (val) {
                  if (_confirmPasswordError != null) setState(() => _confirmPasswordError = null);
                },
              ),
              const SizedBox(height: 8),

              // Register Button
              PrimaryButton(
                text: 'Register',
                onPressed: () async {
                  if (_validateRegistration()) {
                    final res = await ApiService.instance.register(
                      name: _nameController.text.trim(),
                      email: _emailController.text.trim(),
                      phone: _phoneController.text.trim(),
                      password: _passwordController.text,
                      role: _selectedRole,
                    );

                    if (!context.mounted) return;

                    if (res['success'] == true) {
                      final name = _nameController.text.trim();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Account created for $name! Welcome to SecureTrack SL.'),
                          backgroundColor: AppColors.successGreen,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      Navigator.of(context).pushReplacementNamed('/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res['error'] ?? 'Registration failed'),
                          backgroundColor: AppColors.dangerRed,
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 20),

              // Link to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

//dashboard screen
class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final textMuted = isDark ? const Color(0xFF94A3B8) : AppColors.textMuted;
        final borderColor = isDark ? const Color(0xFF334155) : AppColors.borderLight;

        final currentUser = ApiService.instance.currentUser;
        return StreamBuilder<List<ContainerModel>>(
          stream: FirebaseService.instance.getContainersStream(
            ownerEmail: currentUser.email,
            company: currentUser.company,
          ),
          initialData: ContainerModel.sampleContainers.where((c) => c.ownerEmail.toLowerCase() == currentUser.email.toLowerCase()).toList().isNotEmpty
              ? ContainerModel.sampleContainers.where((c) => c.ownerEmail.toLowerCase() == currentUser.email.toLowerCase()).toList()
              : ContainerModel.sampleContainers,
          builder: (context, snapshot) {
            final containers = snapshot.data ?? ContainerModel.sampleContainers;
            final int totalCount = containers.length;
            final int onTrackCount = containers.where((c) => c.status.trim().toLowerCase() == 'on track').length;
            final int arrivedCount = containers.where((c) => c.status.trim().toLowerCase() == 'arrived').length;
            final int alertsCount = containers.where((c) => c.sealStatus.trim().toLowerCase() == 'tampered' || c.batteryLevel < 50).length;

            return Scaffold(
              backgroundColor: bgColor,
              drawer: _buildDashboardDrawer(context),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Header
                      Builder(
                        builder: (context) {
                          final currentUser = ApiService.instance.currentUser;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Builder(
                                builder: (scaffoldContext) => GestureDetector(
                                  onTap: () => Scaffold.of(scaffoldContext).openDrawer(),
                                  child: Icon(Icons.menu, color: textColor, size: 26),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${settings.tr('hello')},',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: textMuted,
                                      ),
                                    ),
                                    Text(
                                      currentUser.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Quick Language Badge / Selector
                              GestureDetector(
                                onTap: () => Navigator.of(context).pushNamed('/settings'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE0EDFB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF475569) : AppColors.primaryBlue.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(settings.language.flag, style: const TextStyle(fontSize: 12)),
                                      const SizedBox(width: 4),
                                      Text(
                                        settings.language.label,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFF93C5FD) : AppColors.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Role Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  currentUser.role,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),

                      // Total Containers Banner Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Row(
                          children: [
                            // Container Graphic Stack
                            Image.asset(
                              'assets/images/container_banner.png',
                              width: 90,
                              height: 50,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.inventory_2, color: Colors.white),
                                );
                              },
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${settings.tr('total_containers')} ($totalCount)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '$totalCount',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.circle, color: AppColors.successGreen, size: 8),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${settings.tr('arrived')} ($arrivedCount)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.successGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3 Metric Cards: [On Track] [Alerts] [Arrived]
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              value: '$onTrackCount',
                              label: settings.tr('on_track'),
                              backgroundColor: const Color(0xFFD4EEDF),
                              textColor: const Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              value: '$alertsCount',
                              label: settings.tr('alerts'),
                              backgroundColor: alertsCount > 0 ? const Color(0xFFFEE2E2) : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              textColor: alertsCount > 0 ? const Color(0xFF991B1B) : textMuted,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              value: '$arrivedCount',
                              label: settings.tr('arrived'),
                              backgroundColor: const Color(0xFFD6E6F9),
                              textColor: const Color(0xFF1E40AF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Section Header: Recent Containers | View All
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            settings.tr('recent_containers'),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showAllContainersModal(context, containers),
                            child: Text(
                              settings.tr('view_all'),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Recent Containers List
                      ...containers.map(
                        (container) => EnhancedOwnerContainerCard(
                          container: container,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/container-details',
                              arguments: container,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDashboardDrawer(BuildContext context) {
    final settings = AppSettingsController.instance;
    final isDark = settings.isDarkMode;
    final drawerBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textDark;

    return Drawer(
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              color: AppColors.primaryBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: AppColors.primaryBlue, size: 28),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Builder(
                    builder: (context) {
                      final currentUser = ApiService.instance.currentUser;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.name,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${currentUser.role} • ${currentUser.email}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: AppColors.primaryBlue),
              title: Text(settings.tr('dashboard'), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textCol)),
              onTap: () {
                Navigator.pop(context);
                onNavigateTab(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined, color: AppColors.primaryBlue),
              title: Text(settings.tr('live_tracking'), style: GoogleFonts.poppins(fontSize: 13, color: textCol)),
              onTap: () {
                Navigator.pop(context);
                onNavigateTab(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined, color: AppColors.primaryBlue),
              title: Text(settings.tr('alerts'), style: GoogleFonts.poppins(fontSize: 13, color: textCol)),
              onTap: () {
                Navigator.pop(context);
                onNavigateTab(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_outlined, color: AppColors.primaryBlue),
              title: Text(settings.tr('profile'), style: GoogleFonts.poppins(fontSize: 13, color: textCol)),
              onTap: () {
                Navigator.pop(context);
                onNavigateTab(3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.primaryBlue),
              title: Text(settings.tr('settings'), style: GoogleFonts.poppins(fontSize: 13, color: textCol)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE0EDFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${settings.language.flag} ${settings.language.code.toUpperCase()}',
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/settings');
              },
            ),
            const Spacer(),
            Divider(color: isDark ? const Color(0xFF334155) : AppColors.borderLight),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.dangerRed),
              title: Text(
                settings.tr('sign_out'),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dangerRed,
                ),
              ),
              onTap: () async {
                await SessionManager.instance.clearSession();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/role-selection', (route) => false);
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showAllContainersModal(BuildContext context, List<ContainerModel> containers) {
    final settings = AppSettingsController.instance;
    final isDark = settings.isDarkMode;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.72,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${settings.tr('total_containers')} (${containers.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textCol,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: textCol),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: containers.length,
                itemBuilder: (c, idx) => ContainerItemCard(
                  container: containers[idx],
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).pushNamed(
                      '/container-details',
                      arguments: containers[idx],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//container details screen
class ContainerDetailsScreen extends StatelessWidget {
  final ContainerModel container;

  const ContainerDetailsScreen({super.key, required this.container});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final mutedText = isDark ? const Color(0xFF94A3B8) : AppColors.textMedium;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: cardColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              settings.tr('view_details'),
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
              ),
            ),
            centerTitle: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Container 3D Graphic + On Track Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 3D Shipping Container graphic
                      Image.asset(
                        'assets/images/container_details.png',
                        height: 90,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const ContainerBoxArt(width: 140, height: 90);
                        },
                      ),
                      // Status badge
                      StatusBadge(status: container.status),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Container ID & Owner
                  Text(
                    container.id,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Owner : ${container.owner}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF93C5FD) : AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Detail Item 1: ISO Container Number & Type
                  _buildDetailRow(
                    icon: Icons.tag,
                    iconColor: AppColors.primaryBlue,
                    title: 'ISO Container No / Type',
                    value: '${container.isoContainerNo} (${container.id})',
                    textColor: textColor,
                    mutedColor: mutedText,
                  ),

                  // Detail Item 2: CUSDEC Customs Declaration No
                  _buildDetailRow(
                    icon: Icons.assignment_outlined,
                    iconColor: AppColors.primaryBlue,
                    title: 'Sri Lanka Customs CUSDEC No',
                    value: container.cusdecNumber,
                    textColor: textColor,
                    mutedColor: mutedText,
                  ),

                  // Detail Item 3: Bill of Lading (BL) & Vessel
                  _buildDetailRow(
                    icon: Icons.directions_boat_outlined,
                    iconColor: AppColors.primaryBlue,
                    title: 'Bill of Lading / Vessel',
                    value: '${container.billOfLading} • ${container.vesselName}',
                    textColor: textColor,
                    mutedColor: mutedText,
                  ),

                  // Detail Item 4: Cargo Description
                  _buildDetailRow(
                    icon: Icons.inventory_2_outlined,
                    iconColor: AppColors.primaryBlue,
                    title: 'Cargo Description',
                    value: container.cargoDescription,
                    textColor: textColor,
                    mutedColor: mutedText,
                  ),

                  // Detail Item 5: Current Location
                  _buildDetailRow(
                    icon: Icons.my_location,
                    iconColor: AppColors.primaryBlue,
                    title: 'Current Location',
                    value: container.currentLocation,
                    textColor: textColor,
                    mutedColor: mutedText,
                  ),

                  // Detail Item 6: Destination Yard
                  _buildDetailRow(
                    icon: Icons.location_on,
                    iconColor: AppColors.primaryBlue,
                    title: 'Destination (Examination Yard)',
                    value: container.destination,
                    textColor: textColor,
                    mutedColor: mutedText,
                  ),

                  // Detail Item 7: Estimated Arrival
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    iconColor: AppColors.primaryBlue,
                    title: 'Estimated Arrival (ETA)',
                    value: container.estimatedArrival,
                    textColor: textColor,
                    mutedColor: mutedText,
                  ),

                  // Detail Item 8: Assigned Driver & Emergency Call
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.person_outline, color: AppColors.primaryBlue, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assigned Driver & Emergency Contact',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: mutedText,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${container.driverName} (${container.driverPhone})',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling Driver ${container.driverName} at ${container.driverPhone}...'),
                                backgroundColor: AppColors.primaryBlue,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone, size: 14, color: AppColors.successGreen),
                                const SizedBox(width: 4),
                                Text(
                                  'Call',
                                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Detail Item 9: IoT e-Seal Status
                  _buildDetailRow(
                    icon: Icons.lock_outline,
                    iconColor: container.sealStatus.toLowerCase() == 'tampered' ? AppColors.dangerRed : AppColors.successGreen,
                    title: '${settings.tr('seal_status')} (${container.sealId})',
                    value: container.sealStatus,
                    valueColor: container.sealStatus.toLowerCase() == 'tampered' ? AppColors.dangerRed : AppColors.successGreen,
                    textColor: textColor,
                    mutedColor: mutedText,
                  ),

                  // Detail Item 10: Battery Level & Telemetry Temp (SRS < 50% Threshold)
                  _buildDetailRow(
                    icon: Icons.battery_charging_full,
                    iconColor: container.batteryLevel < 50 ? AppColors.warningOrange : AppColors.successGreen,
                    title: '${settings.tr('battery')} & Sensor Telemetry (SRS <50% Alert)',
                    value: '${container.batteryLevel}% ${container.batteryLevel < 50 ? "(Low Battery Warning)" : "(Optimal)"} • Temp: ${container.temperature}°C • Speed: ${container.speed} km/h',
                    valueColor: container.batteryLevel < 50 ? AppColors.warningOrange : AppColors.successGreen,
                    textColor: textColor,
                    mutedColor: mutedText,
                  ),

                  // Detail Item 11: Fail-Safe Signal & GPS Mode (SRS REQ-3)
                  _buildDetailRow(
                    icon: container.gpsStatus == 'GPS Active' ? Icons.gps_fixed : Icons.warning_amber_rounded,
                    iconColor: container.gpsStatus == 'GPS Active' ? AppColors.infoBlue : AppColors.warningOrange,
                    title: 'GPS Signal Integrity (SRS REQ-3)',
                    value: container.gpsStatus,
                    valueColor: container.gpsStatus == 'GPS Active' ? AppColors.infoBlue : AppColors.warningOrange,
                    textColor: textColor,
                    mutedColor: mutedText,
                  ),
                  const SizedBox(height: 28),

                  // Bottom Button: View on Map
                  PrimaryButton(
                    text: settings.tr('track_on_map'),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/live-tracking',
                        arguments: container,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Color? valueColor,
    Color textColor = AppColors.textDark,
    Color mutedColor = AppColors.textMedium,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 1),
                ],
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//live tracking screen
class LiveTrackingScreen extends StatefulWidget {
  final ContainerModel? container;

  const LiveTrackingScreen({super.key, this.container});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  late ContainerModel _selectedContainer;
  final TransformationController _transformController = TransformationController();
  final MapController _mapController = MapController();

  // Mode: Real OpenStreetMap vs Mockup Vector Art
  bool _useRealMap = true;

  // Transit state metrics
  final double _routeProgress = 0.35;
  final int _currentSpeed = 42;
  final double _remainingKm = 8.7;
  final int _remainingMinutes = 21;

  // 1. Orugodawatta Customs Examination Yard Route (CONT-001)
  static const List<LatLng> _orugodawattaRoute = [
    LatLng(6.9455, 79.8510), // Colombo Port Gate 04
    LatLng(6.9410, 79.8525), // Fort / Main Street
    LatLng(6.9385, 79.8610), // Ingurukade Junction
    LatLng(6.9470, 79.8710), // Prince of Wales Ave
    LatLng(6.9560, 79.8810), // Kelani Bridge Corridor
    LatLng(6.9450, 79.8815), // Baseline Road
    LatLng(6.9380, 79.8820), // Orugodawatta Customs Yard (RCT)
  ];

  // 2. Grayline 1 (GL1) Examination Yard Route (CONT-002)
  static const List<LatLng> _grayline1Route = [
    LatLng(6.9480, 79.8530), // Colombo Port Gate 02
    LatLng(6.9460, 79.8580), // Kochchikade Terminal
    LatLng(6.9470, 79.8670), // Sugathadasa / Prince of Wales Ave
    LatLng(6.9500, 79.8690), // Bloemendhal Road Corridor
    LatLng(6.9525, 79.8730), // Grayline 1 (GL1) Examination Yard Grandpass
  ];

  // 3. Grayline 2 (GL2) Examination Yard Route (CONT-003)
  static const List<LatLng> _grayline2Route = [
    LatLng(6.9510, 79.8550), // Colombo Port Gate 05
    LatLng(6.9580, 79.8650), // Aluthmawatha Customs Corridor
    LatLng(6.9610, 79.8820), // Peliyagoda New Kelani Bridge
    LatLng(6.9620, 79.8850), // Kandy Road / Baseline Junction
    LatLng(6.9635, 79.8885), // Grayline 2 (GL2) Examination Yard Peliyagoda
  ];

  List<LatLng> get _currentRoute {
    final dest = _selectedContainer.destination.toLowerCase();
    final routeStr = _selectedContainer.route.toLowerCase();
    if (_selectedContainer.id == 'CONT-002' ||
        _selectedContainer.id == 'CONT-005' ||
        dest.contains('grayline 1') ||
        dest.contains('gl1') ||
        routeStr.contains('grayline 1')) {
      return _grayline1Route;
    } else if (_selectedContainer.id == 'CONT-003' ||
        dest.contains('grayline 2') ||
        dest.contains('gl2') ||
        routeStr.contains('grayline 2')) {
      return _grayline2Route;
    }
    return _orugodawattaRoute;
  }

  LatLng get _currentVehicleLocation {
    final route = _currentRoute;
    final int totalSegments = route.length - 1;
    final double exactPos = (_routeProgress * totalSegments).clamp(0.0, totalSegments.toDouble());
    final int index = exactPos.floor();
    final double fraction = exactPos - index;

    if (index >= totalSegments) return route.last;

    final start = route[index];
    final end = route[index + 1];

    return LatLng(
      start.latitude + (end.latitude - start.latitude) * fraction,
      start.longitude + (end.longitude - start.longitude) * fraction,
    );
  }

  @override
  void initState() {
    super.initState();
    final currentUser = ApiService.instance.currentUser;
    final ownerContainers = ContainerModel.sampleContainers.where((c) => c.ownerEmail.toLowerCase() == currentUser.email.toLowerCase()).toList();
    _selectedContainer = widget.container ?? (ownerContainers.isNotEmpty ? ownerContainers.first : ContainerModel.sampleContainers.first);
  }

  @override
  void didUpdateWidget(covariant LiveTrackingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.container != null && widget.container != oldWidget.container) {
      _selectedContainer = widget.container!;
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _showCheckpointsSheet() {
    final settings = AppSettingsController.instance;
    final isDark = settings.isDarkMode;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textDark;

    final dest = _selectedContainer.destination.toLowerCase();
    final String yardName = (dest.contains('grayline 1') || dest.contains('gl1'))
        ? 'Grayline 1 (GL1) Yard'
        : ((dest.contains('grayline 2') || dest.contains('gl2'))
            ? 'Grayline 2 (GL2) Yard'
            : 'Orugodawatta Yard (RCT)');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.alt_route_rounded, color: AppColors.primaryBlue, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Checkpoints ➔ $yardName',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedContainer.id == 'CONT-002') ...[
              _buildCheckpointItem(
                title: 'Colombo Port Gate 02',
                time: '08:00 AM - Customs Clearance Out',
                status: 'Passed',
                isPassed: true,
                isFirst: true,
                isDark: isDark,
              ),
              _buildCheckpointItem(
                title: 'Kochchikade Terminal Corridor',
                time: '08:20 AM - e-Seal RFID Check',
                status: 'Passed',
                isPassed: true,
                isDark: isDark,
              ),
              _buildCheckpointItem(
                title: 'Prince of Wales Avenue',
                time: '08:45 AM - GPS Geofence In Transit',
                status: 'Active',
                isPassed: false,
                isActive: true,
                isDark: isDark,
              ),
              _buildCheckpointItem(
                title: 'Grayline 1 (GL1) Examination Depot',
                time: 'ETA: ${_selectedContainer.estimatedArrival} - Final Physical Exam',
                status: 'Scheduled',
                isPassed: false,
                isLast: true,
                isDark: isDark,
              ),
            ] else if (_selectedContainer.id == 'CONT-003') ...[
              _buildCheckpointItem(
                title: 'Colombo Port Gate 05',
                time: '01:15 PM - Customs Release',
                status: 'Passed',
                isPassed: true,
                isFirst: true,
                isDark: isDark,
              ),
              _buildCheckpointItem(
                title: 'Aluthmawatha Corridor',
                time: '01:35 PM - RFID Scanned',
                status: 'Passed',
                isPassed: true,
                isDark: isDark,
              ),
              _buildCheckpointItem(
                title: 'Peliyagoda Kelani Bridge Gate',
                time: '01:50 PM - Transit Verified',
                status: 'Passed',
                isPassed: true,
                isDark: isDark,
              ),
              _buildCheckpointItem(
                title: 'Grayline 2 (GL2) Yard Peliyagoda',
                time: 'Arrived at ${_selectedContainer.estimatedArrival} - Cargo Unloaded',
                status: 'Arrived',
                isPassed: true,
                isLast: true,
                isDark: isDark,
              ),
            ] else ...[
              _buildCheckpointItem(
                title: 'Colombo Port Gate 04',
                time: '07:15 AM - Customs Release',
                status: 'Passed',
                isPassed: true,
                isFirst: true,
                isDark: isDark,
              ),
              _buildCheckpointItem(
                title: 'Ingurukade Junction Terminal',
                time: '07:38 AM - RFID e-Seal Verified',
                status: 'Passed',
                isPassed: true,
                isDark: isDark,
              ),
              _buildCheckpointItem(
                title: 'Peliyagoda / Baseline Corridor',
                time: '08:02 AM - GPS Corridor In Transit',
                status: 'Active',
                isPassed: false,
                isActive: true,
                isDark: isDark,
              ),
              _buildCheckpointItem(
                title: 'Orugodawatta Examination Yard (RCT)',
                time: 'ETA: ${_selectedContainer.estimatedArrival} - Final Clearance',
                status: 'Scheduled',
                isPassed: false,
                isLast: true,
                isDark: isDark,
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckpointItem({
    required String title,
    required String time,
    required String status,
    required bool isPassed,
    bool isActive = false,
    bool isFirst = false,
    bool isLast = false,
    bool isDark = false,
  }) {
    final Color badgeBg = isPassed
        ? AppColors.successLight
        : (isActive ? AppColors.warningLight : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)));
    final Color badgeText = isPassed
        ? AppColors.successGreen
        : (isActive ? AppColors.warningOrange : (isDark ? const Color(0xFF94A3B8) : AppColors.textMuted));
    final Color dotColor = isPassed
        ? AppColors.successGreen
        : (isActive ? AppColors.primaryBlue : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 2),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: isPassed ? AppColors.successGreen : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: badgeText,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final borderColor = isDark ? const Color(0xFF334155) : AppColors.borderLight;

        final currentUser = ApiService.instance.currentUser;
        return StreamBuilder<List<ContainerModel>>(
          stream: FirebaseService.instance.getContainersStream(
            ownerEmail: currentUser.email,
            company: currentUser.company,
          ),
          initialData: ContainerModel.sampleContainers.where((c) => c.ownerEmail.toLowerCase() == currentUser.email.toLowerCase()).toList().isNotEmpty
              ? ContainerModel.sampleContainers.where((c) => c.ownerEmail.toLowerCase() == currentUser.email.toLowerCase()).toList()
              : ContainerModel.sampleContainers,
          builder: (context, snapshot) {
            final containers = (snapshot.data != null && snapshot.data!.isNotEmpty)
                ? snapshot.data!
                : ContainerModel.sampleContainers;

            if (!containers.any((c) => c.id == _selectedContainer.id)) {
              _selectedContainer = containers.first;
            }

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
            backgroundColor: cardColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: Text(
              settings.tr('live_tracking'),
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
              ),
            ),
            actions: [
              // Toggle Real Map / Mockup Map
              IconButton(
                icon: Icon(
                  _useRealMap ? Icons.map_outlined : Icons.layers_outlined,
                  color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                ),
                tooltip: _useRealMap ? 'Switch to Mockup Map' : 'Switch to Real Map',
                onPressed: () {
                  setState(() {
                    _useRealMap = !_useRealMap;
                  });
                },
              ),
              // Waypoints list action
              IconButton(
                icon: Icon(Icons.alt_route, color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue),
                tooltip: 'View Checkpoints',
                onPressed: _showCheckpointsSheet,
              ),
              // Recenter view
              IconButton(
                icon: Icon(Icons.my_location, color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue),
                tooltip: 'Recenter Map',
                onPressed: () {
                  if (_useRealMap) {
                    try {
                      _mapController.move(_currentVehicleLocation, 14.0);
                    } catch (_) {}
                  } else {
                    _transformController.value = Matrix4.identity();
                  }
                },
              ),
            ],
            centerTitle: false,
          ),
          body: Stack(
            children: [
              // 1. Map View (Real OpenStreetMap or Mockup Image)
              Positioned.fill(
                child: _useRealMap
                    ? FlutterMap(
                        mapController: _mapController,
                        options: const MapOptions(
                          initialCenter: LatLng(6.9450, 79.8650),
                          initialZoom: 13.5,
                          minZoom: 10.0,
                          maxZoom: 18.0,
                        ),
                        children: [
                          // Vector tiles (OpenStreetMap with Dark Matrix shader for Night Radar Theme)
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.securetrack.sl',
                            tileBuilder: (context, tileWidget, tile) {
                              if (isDark) {
                                return ColorFiltered(
                                  colorFilter: const ColorFilter.matrix(<double>[
                                    -0.85, 0, 0, 0, 215,
                                    0, -0.85, 0, 0, 220,
                                    0, 0, -0.75, 0, 240,
                                    0, 0, 0, 1, 0,
                                  ]),
                                  child: tileWidget,
                                );
                              }
                              return tileWidget;
                            },
                          ),
                          // Transit Corridor Route Polyline
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _currentRoute,
                                strokeWidth: 3.5,
                                color: isDark
                                    ? const Color(0xFF60A5FA)
                                    : const Color(0xFF2563EB).withValues(alpha: 0.85),
                              ),
                            ],
                          ),
                          // Real Markers Layer
                          MarkerLayer(
                            markers: [
                              // 1. Start Port Marker
                              Marker(
                                point: _currentRoute.first,
                                width: 44,
                                height: 44,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: const Icon(Icons.directions_boat, color: Colors.white, size: 22),
                                ),
                              ),
                              // 2. Destination Marker (Customs Examination Yard)
                              Marker(
                                point: _currentRoute.last,
                                width: 44,
                                height: 44,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.dangerRed,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                                ),
                              ),
                              // 3. Live Animated Vehicle Marker
                              Marker(
                                point: _currentVehicleLocation,
                                width: 52,
                                height: 52,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.successGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.successGreen.withValues(alpha: 0.5),
                                        blurRadius: 12,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.local_shipping, color: Colors.white, size: 26),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 0.8,
                        maxScale: 3.5,
                        boundaryMargin: const EdgeInsets.all(80),
                        child: Image.asset(
                          'assets/images/colombo_map.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return ColomboMapArt(
                              progress: _routeProgress,
                              durationText: '$_remainingMinutes min',
                              distanceText: '${_remainingKm.toStringAsFixed(1)} km',
                            );
                          },
                        ),
                      ),
              ),

              // Top Floating Bar: Container Chips & Live Telemetry
              Positioned(
                top: 10,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    // Container Selector Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: containers.map((c) {
                          final isSelected = c.id == _selectedContainer.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedContainer = c;
                                });
                                if (_useRealMap) {
                                  try {
                                    _mapController.move(_currentVehicleLocation, 13.5);
                                  } catch (_) {}
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryBlue : cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryBlue : borderColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.inventory_2,
                                      size: 14,
                                      color: isSelected ? Colors.white : (isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      c.id,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? Colors.white : textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Telemetry Strip Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTelemetryItem(
                            Icons.speed,
                            settings.tr('speed'),
                            '$_currentSpeed km/h',
                            isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                            isDark,
                          ),
                          _buildTelemetryItem(
                            Icons.lock,
                            settings.tr('seal_status'),
                            _selectedContainer.sealStatus,
                            _selectedContainer.sealStatus.toLowerCase() == 'tampered' ? AppColors.dangerRed : AppColors.successGreen,
                            isDark,
                          ),
                          _buildTelemetryItem(
                            Icons.battery_charging_full,
                            settings.tr('battery'),
                            '${_selectedContainer.batteryLevel}%',
                            _selectedContainer.batteryLevel < 50 ? AppColors.warningOrange : AppColors.successGreen,
                            isDark,
                          ),
                          _buildTelemetryItem(
                            Icons.cell_tower,
                            'Signal',
                            '4G LTE',
                            AppColors.infoBlue,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Recenter GPS Button (Floating above bottom card)
              Positioned(
                right: 20,
                bottom: 140,
                child: FloatingActionButton.small(
                  heroTag: 'recenter_btn',
                  backgroundColor: cardColor,
                  foregroundColor: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                  elevation: 4,
                  onPressed: () {
                    if (_useRealMap) {
                      try {
                        _mapController.move(_currentVehicleLocation, 14.0);
                      } catch (_) {}
                    } else {
                      _transformController.value = Matrix4.identity();
                    }
                  },
                  child: const Icon(Icons.my_location, size: 20),
                ),
              ),

              // Bottom Floating Container Tracking Card
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.successGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedContainer.id,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          StatusBadge(status: _selectedContainer.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _selectedContainer.gpsStatus == 'GPS Active'
                                  ? AppColors.infoLight
                                  : AppColors.warningLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _selectedContainer.gpsStatus == 'GPS Active'
                                    ? AppColors.infoBlue.withValues(alpha: 0.3)
                                    : AppColors.warningOrange.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _selectedContainer.gpsStatus == 'GPS Active'
                                      ? Icons.satellite_alt_rounded
                                      : Icons.warning_amber_rounded,
                                  size: 12,
                                  color: _selectedContainer.gpsStatus == 'GPS Active'
                                      ? AppColors.infoBlue
                                      : AppColors.warningOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedContainer.gpsStatus,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedContainer.gpsStatus == 'GPS Active'
                                        ? AppColors.infoBlue
                                        : AppColors.warningOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_selectedContainer.batteryLevel < 50)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Low Battery (<50%)',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warningOrange,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Route: ${_selectedContainer.route}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ETA: $_remainingMinutes mins (${_remainingKm.toStringAsFixed(1)} km left)',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF93C5FD) : AppColors.primaryBlue,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/container-details',
                                arguments: _selectedContainer,
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  settings.tr('view_details'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                                  ),
                                ),
                                Icon(Icons.chevron_right, size: 16, color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
      },
    );
  }

  Widget _buildTelemetryItem(IconData icon, String label, String value, Color color, [bool isDark = false]) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

//alert screen
class AlertsScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const AlertsScreen({super.key, this.onNavigateTab});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Security', 'Location', 'Battery'];

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
        final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Title with Bell Icon & Export Report Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                            size: 26,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            settings.tr('alerts'),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                              title: Row(
                                children: [
                                  const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primaryBlue, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Security Audit Report',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sri Lanka Customs Compliance Audit Log',
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '• Export Format: Official Security Incident Log (PDF)\n• Importer: ${ApiService.instance.currentUser.company}\n• Verified By: Electronic Cargo Tracking System (ECTS)\n• Date Range: Active Transit Corridor Trips',
                                    style: GoogleFonts.poppins(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppColors.textMedium, height: 1.4),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Close'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Security Incident Audit Report (PDF) downloaded successfully!'),
                                        backgroundColor: AppColors.successGreen,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.download, size: 16, color: Colors.white),
                                  label: const Text('Download PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE0EDFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? const Color(0xFF475569) : AppColors.primaryBlue.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.description_outlined, size: 14, color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue),
                              const SizedBox(width: 4),
                              Text(
                                'Audit Report',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Filter Category Chips: All, Security, Location, Battery
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final bool isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE0EDFB)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : (isDark ? const Color(0xFF334155) : Colors.transparent),
                                ),
                              ),
                              child: Text(
                                category,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? const Color(0xFF94A3B8) : AppColors.primaryBlue),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Alerts List
                  Expanded(
                    child: StreamBuilder<List<AlertItem>>(
                      stream: FirebaseService.instance.getAlertsStream(
                        category: _selectedCategory,
                        ownerEmail: ApiService.instance.currentUser.email,
                      ),
                      initialData: AlertItem.sampleAlerts.where((alert) {
                        final matchesCat = (_selectedCategory == 'All' || alert.category.toLowerCase() == _selectedCategory.toLowerCase());
                        final matchesOwner = alert.ownerEmail.toLowerCase() == ApiService.instance.currentUser.email.toLowerCase();
                        return matchesCat && matchesOwner;
                      }).toList(),
                      builder: (context, snapshot) {
                        final currentUserEmail = ApiService.instance.currentUser.email.trim().toLowerCase();
                        
                        // 1. Get from stream if available and non-empty
                        List<AlertItem> alerts = [];
                        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                          alerts = snapshot.data!;
                        } else {
                          // 2. Fallback to sampleAlerts
                          alerts = AlertItem.sampleAlerts.where((alert) {
                            final matchesCat = (_selectedCategory == 'All' || alert.category.toLowerCase() == _selectedCategory.toLowerCase());
                            final matchesOwner = currentUserEmail.isEmpty || 
                                                 alert.ownerEmail.toLowerCase() == currentUserEmail ||
                                                 alert.ownerEmail.toLowerCase() == 'owner@cargooverseas.lk';
                            return matchesCat && matchesOwner;
                          }).toList();
                        }

                        // 3. Guaranteed safety fallback: If still empty, show all alerts for this owner
                        if (alerts.isEmpty) {
                          alerts = AlertItem.sampleAlerts.where((alert) {
                            return alert.ownerEmail.toLowerCase() == currentUserEmail ||
                                   alert.ownerEmail.toLowerCase() == 'owner@cargooverseas.lk';
                          }).toList();
                        }

                        if (alerts.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.notifications_off_outlined, size: 48, color: isDark ? const Color(0xFF64748B) : AppColors.textLight),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No alerts in $_selectedCategory',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: alerts.length,
                          separatorBuilder: (context, index) => Divider(
                            color: borderColor,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            return AlertItemCard(
                              alert: alert,
                              onTap: () {
                                final matchedContainer = ContainerModel.sampleContainers.firstWhere(
                                  (c) => c.id == alert.containerId,
                                  orElse: () => ContainerModel.sampleContainers.first,
                                );
                                _showAlertDetails(context, alert, matchedContainer, isDark);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAlertDetails(BuildContext context, AlertItem alert, ContainerModel container, [bool isDark = false]) {
    final settings = AppSettingsController.instance;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : AppColors.textDark;
    final mutedCol = isDark ? const Color(0xFF94A3B8) : AppColors.textMuted;
    final innerBg = isDark ? const Color(0xFF0F172A) : AppColors.background;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? alert.bgColor.withValues(alpha: 0.25) : alert.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(alert.icon, color: alert.iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textCol,
                        ),
                      ),
                      Text(
                        'Container ${alert.containerId} • ${alert.timestamp}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: mutedCol,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: innerBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.transparent),
              ),
              child: Text(
                'High-priority security telemetry verified by Sri Lanka Customs gateway. Container is actively being tracked.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? const Color(0xFFE2E8F0) : AppColors.textMedium,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).pushNamed(
                        '/live-tracking',
                        arguments: container,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      settings.tr('track_on_map'),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).pushNamed(
                        '/container-details',
                        arguments: container,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      settings.tr('view_details'),
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

//profile screen
class ProfileScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const ProfileScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final currentUser = ApiService.instance.currentUser;
    final settings = AppSettingsController.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? const Color(0xFF0F172A) : AppColors.background;
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textDark;
        final textMuted = isDark ? const Color(0xFF94A3B8) : AppColors.textMuted;
        final borderColor = isDark ? const Color(0xFF334155) : AppColors.borderLight;

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top User Header Banner (Blue card with profile icon)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.person, size: 38, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentUser.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currentUser.role} • ${currentUser.company}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // User Account Information Section
                  Text(
                    settings.tr('company_info'),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _buildCompanyRow(Icons.person_outline, 'Full Name', currentUser.name, isDark),
                        Divider(height: 20, color: borderColor),
                        _buildCompanyRow(Icons.email_outlined, 'Email Address', currentUser.email, isDark),
                        Divider(height: 20, color: borderColor),
                        _buildCompanyRow(Icons.phone_outlined, 'Phone Number', currentUser.phone, isDark),
                        Divider(height: 20, color: borderColor),
                        _buildCompanyRow(Icons.badge_outlined, 'Registered Role', currentUser.role, isDark),
                        Divider(height: 20, color: borderColor),
                        _buildCompanyRow(Icons.business_outlined, 'Affiliated Company', currentUser.company, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // App Preferences & Settings Section
                  Text(
                    settings.tr('settings'),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Theme switch row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                  color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  settings.tr('theme_mode'),
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: isDark,
                              activeColor: AppColors.accentBlue,
                              onChanged: (_) => settings.toggleTheme(),
                            ),
                          ],
                        ),
                        Divider(height: 16, color: borderColor),
                        // Language selector
                        Text(
                          settings.tr('select_language'),
                          style: GoogleFonts.poppins(fontSize: 12, color: textMuted, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: AppLanguage.values.map((lang) {
                            final isSel = settings.language == lang;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => settings.setLanguage(lang),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? AppColors.primaryBlue
                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSel ? AppColors.primaryBlue : borderColor,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(lang.flag, style: const TextStyle(fontSize: 16)),
                                      const SizedBox(height: 2),
                                      Text(
                                        lang.label,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                          color: isSel ? Colors.white : textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        // More Settings Button
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/settings');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE0EDFB),
                            foregroundColor: isDark ? Colors.white : AppColors.primaryBlue,
                            elevation: 0,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.tune_rounded, size: 18),
                          label: Text(
                            'All Settings (Alarms, Hotline & Security)',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Out Button
                  OutlinedButton.icon(
                    onPressed: () async {
                      await SessionManager.instance.clearSession();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/role-selection', (route) => false);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: AppColors.dangerRed),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout, color: AppColors.dangerRed),
                    label: Text(
                      settings.tr('sign_out'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dangerRed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompanyRow(IconData icon, String label, String value, [bool isDark = false]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


