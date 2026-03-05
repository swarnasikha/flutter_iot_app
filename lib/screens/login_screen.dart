import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'dart:math' as math;
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _rotateController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;
      final role = await _firestoreService.getUserRole(uid);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => DashboardScreen(role: role),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(_parseError(e.toString()));
    }
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) return 'No account found with this email';
    if (error.contains('wrong-password')) return 'Incorrect password';
    if (error.contains('invalid-email')) return 'Invalid email address';
    if (error.contains('network-request-failed')) return 'Network error. Check connection';
    return 'Authentication failed. Try again.';
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B35), size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontFamily: 'monospace'))),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFFFF6B35), width: 1),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF555570),
        letterSpacing: 2.5,
        fontFamily: 'monospace',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // ── Animated background grid ──────────────────────

          // ── Main content ──────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Logo & Title ──────────────────
                        Center(
                          child: AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (_, _) => Transform.scale(
                              scale: _pulseAnim.value,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF12121F),
                                  border: Border.all(
                                    color: const Color(0xFFFF6B35),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.whatshot_rounded,
                                  color: Color(0xFFFF6B35),
                                  size: 38,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Center(
                          child: Column(
                            children: [
                              const Text(
                                "STEAM PRO",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 8,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 30, height: 1, color: const Color(0xFFFF6B35)),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "CONTROL SYSTEM",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF666680),
                                      letterSpacing: 4,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(width: 30, height: 1, color: const Color(0xFFFF6B35)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // ── Section label ─────────────────
                        const Text(
                          "OPERATOR ACCESS",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFFF6B35),
                            letterSpacing: 3,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Email Field ───────────────────
                        _buildLabel("EMAIL ADDRESS"),
                        const SizedBox(height: 6),
                        Focus(
                          onFocusChange: (v) => setState(() => _emailFocused = v),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12121F),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _emailFocused
                                    ? const Color(0xFFFF6B35)
                                    : const Color(0xFF2A2A3E),
                                width: _emailFocused ? 1.5 : 1,
                              ),
                              boxShadow: _emailFocused
                                  ? [BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.1), blurRadius: 12)]
                                  : [],
                            ),
                            child: TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: "operator@steamco.com",
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.2),
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.alternate_email,
                                  color: _emailFocused
                                      ? const Color(0xFFFF6B35)
                                      : const Color(0xFF444460),
                                  size: 18,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Password Field ────────────────
                        _buildLabel("ACCESS CODE"),
                        const SizedBox(height: 6),
                        Focus(
                          onFocusChange: (v) => setState(() => _passwordFocused = v),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12121F),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _passwordFocused
                                    ? const Color(0xFFFF6B35)
                                    : const Color(0xFF2A2A3E),
                                width: _passwordFocused ? 1.5 : 1,
                              ),
                              boxShadow: _passwordFocused
                                  ? [BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.1), blurRadius: 12)]
                                  : [],
                            ),
                            child: TextField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 14,
                                letterSpacing: 2,
                              ),
                              decoration: InputDecoration(
                                hintText: "••••••••••",
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.2),
                                  letterSpacing: 2,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: _passwordFocused
                                      ? const Color(0xFFFF6B35)
                                      : const Color(0xFF444460),
                                  size: 18,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF444460),
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Login Button ──────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: _isLoading
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF12121F),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFFF6B35)),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Color(0xFFFF6B35)),
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: login,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B35),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF6B35).withOpacity(0.35),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.power_settings_new, color: Colors.white, size: 18),
                                        SizedBox(width: 10),
                                        Text(
                                          "INITIALIZE SESSION",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 2.5,
                                            fontSize: 13,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 16),

                        // ── Sign Up Link ──────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "NO CREDENTIALS?",
                              style: TextStyle(
                                color: Color(0xFF444460),
                                fontSize: 10,
                                letterSpacing: 2,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, _, _) => const SignupScreen(),
                                  transitionsBuilder: (_, animation, _, child) =>
                                      FadeTransition(opacity: animation, child: child),
                                  transitionDuration: const Duration(milliseconds: 400),
                                ),
                              ),
                              child: const Text(
                                "REGISTER →",
                                style: TextStyle(
                                  color: Color(0xFFFF6B35),
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Status bar ────────────────────
                        
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

