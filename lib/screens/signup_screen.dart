import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool _nameFocused = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;
  bool _confirmFocused = false;

  // Password strength
  double _passwordStrength = 0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.transparent;

  late AnimationController _slideController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    passwordController.addListener(_evaluatePasswordStrength);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _evaluatePasswordStrength() {
    final p = passwordController.text;
    double strength = 0;
    if (p.isEmpty) {
      setState(() { _passwordStrength = 0; _strengthLabel = ''; _strengthColor = Colors.transparent; });
      return;
    }
    if (p.length >= 6) strength += 0.25;
    if (p.length >= 10) strength += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (p.contains(RegExp(r'[0-9!@#\$%^&*]'))) strength += 0.25;

    String label;
    Color color;
    if (strength <= 0.25) { label = 'WEAK'; color = const Color(0xFFFF3B30); }
    else if (strength <= 0.5) { label = 'FAIR'; color = const Color(0xFFFF9500); }
    else if (strength <= 0.75) { label = 'GOOD'; color = const Color(0xFFFFCC00); }
    else { label = 'STRONG'; color = const Color(0xFF00FF88); }

    setState(() {
      _passwordStrength = strength;
      _strengthLabel = label;
      _strengthColor = color;
    });
  }

  void signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError("All fields are required");
      return;
    }
    if (password != confirm) {
      _showError("Access codes do not match");
      return;
    }
    if (password.length < 6) {
      _showError("Access code must be at least 6 characters");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(name);

      // Save user to Firestore with default role
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'role': 'user',
      });

      if (mounted) {
        _showSuccess("Account registered. Awaiting authorization.");
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(_parseError(e.toString()));
    }
  }

  String _parseError(String error) {
    if (error.contains('email-already-in-use')) return 'This email is already registered';
    if (error.contains('invalid-email')) return 'Invalid email address';
    if (error.contains('weak-password')) return 'Access code is too weak';
    if (error.contains('network-request-failed')) return 'Network error. Check connection';
    return 'Registration failed. Try again.';
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B35), size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12))),
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

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF00FF88), size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12))),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF00FF88), width: 1),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // ── Background grid ───────────────────────────────

          // ── Back button ───────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121F),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF2A2A3E)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios, color: Color(0xFF666680), size: 12),
                      SizedBox(width: 4),
                      Text(
                        "BACK",
                        style: TextStyle(
                          color: Color(0xFF666680),
                          fontSize: 10,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 60, 28, 28),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ────────────────────────
                        Center(
                          child: AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (_, _) => Transform.scale(
                              scale: _pulseAnim.value,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF12121F),
                                  border: Border.all(color: const Color(0xFFFF6B35), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6B35).withOpacity(0.25),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.person_add_outlined, color: Color(0xFFFF6B35), size: 32),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: Column(
                            children: [
                              const Text(
                                "REGISTER OPERATOR",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 24, height: 1, color: const Color(0xFFFF6B35)),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "NEW ACCESS CREDENTIALS",
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFF555570),
                                      letterSpacing: 3,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(width: 24, height: 1, color: const Color(0xFFFF6B35)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Step indicator ────────────────
                        _buildSectionDivider("IDENTITY"),
                        const SizedBox(height: 14),

                        // ── Name Field ────────────────────
                        _buildLabel("OPERATOR NAME"),
                        const SizedBox(height: 6),
                        _buildInputField(
                          controller: nameController,
                          hint: "John Engineer",
                          icon: Icons.badge_outlined,
                          isFocused: _nameFocused,
                          onFocusChange: (v) => setState(() => _nameFocused = v),
                        ),

                        const SizedBox(height: 16),

                        // ── Email Field ───────────────────
                        _buildLabel("EMAIL ADDRESS"),
                        const SizedBox(height: 6),
                        _buildInputField(
                          controller: emailController,
                          hint: "operator@steamco.com",
                          icon: Icons.alternate_email,
                          isFocused: _emailFocused,
                          onFocusChange: (v) => setState(() => _emailFocused = v),
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 24),
                        _buildSectionDivider("SECURITY"),
                        const SizedBox(height: 14),

                        // ── Password Field ────────────────
                        _buildLabel("ACCESS CODE"),
                        const SizedBox(height: 6),
                        _buildInputField(
                          controller: passwordController,
                          hint: "Min. 6 characters",
                          icon: Icons.lock_outline,
                          isFocused: _passwordFocused,
                          onFocusChange: (v) => setState(() => _passwordFocused = v),
                          obscure: _obscurePassword,
                          onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),

                        // Password strength bar
                        if (_passwordStrength > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: _passwordStrength,
                                    backgroundColor: const Color(0xFF1E1E30),
                                    valueColor: AlwaysStoppedAnimation(_strengthColor),
                                    minHeight: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _strengthLabel,
                                style: TextStyle(
                                  color: _strengthColor,
                                  fontSize: 9,
                                  letterSpacing: 2,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        // ── Confirm Password Field ────────
                        _buildLabel("CONFIRM ACCESS CODE"),
                        const SizedBox(height: 6),
                        _buildInputField(
                          controller: confirmPasswordController,
                          hint: "Re-enter access code",
                          icon: Icons.lock_reset_outlined,
                          isFocused: _confirmFocused,
                          onFocusChange: (v) => setState(() => _confirmFocused = v),
                          obscure: _obscureConfirm,
                          onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          // Show match indicator
                          suffixWidget: confirmPasswordController.text.isNotEmpty
                              ? Icon(
                                  confirmPasswordController.text == passwordController.text
                                      ? Icons.check_circle_outline
                                      : Icons.cancel_outlined,
                                  color: confirmPasswordController.text == passwordController.text
                                      ? const Color(0xFF00FF88)
                                      : const Color(0xFFFF3B30),
                                  size: 16,
                                )
                              : null,
                        ),

                        const SizedBox(height: 32),

                        // ── Register Button ───────────────
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
                                  onTap: signup,
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
                                        Icon(Icons.how_to_reg_outlined, color: Colors.white, size: 18),
                                        SizedBox(width: 10),
                                        Text(
                                          "REGISTER CREDENTIALS",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 2.5,
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 20),

                        // ── Footer note ───────────────────
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.info_outline, color: Color(0xFF333350), size: 12),
                              const SizedBox(width: 6),
                              Text(
                                "Role assigned by system admin after registration",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.2),
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Status bar ────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D0D1A),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF1E1E30)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF00FF88),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "REGISTRATION PORTAL: OPEN",
                                style: TextStyle(
                                  color: Color(0xFF444460),
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                "v2.4.1",
                                style: TextStyle(
                                  color: Color(0xFF333350),
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        Container(width: 16, height: 1, color: const Color(0xFF2A2A3E)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFFFF6B35),
            letterSpacing: 3,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: const Color(0xFF2A2A3E))),
      ],
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isFocused,
    required Function(bool) onFocusChange,
    TextInputType keyboardType = TextInputType.text,
    bool? obscure,
    VoidCallback? onToggleObscure,
    Widget? suffixWidget,
  }) {
    return Focus(
      onFocusChange: onFocusChange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFF12121F),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isFocused ? const Color(0xFFFF6B35) : const Color(0xFF2A2A3E),
            width: isFocused ? 1.5 : 1,
          ),
          boxShadow: isFocused
              ? [BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.1), blurRadius: 12)]
              : [],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure ?? false,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontSize: 14,
          ),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontFamily: 'monospace',
              fontSize: 13,
            ),
            prefixIcon: Icon(
              icon,
              color: isFocused ? const Color(0xFFFF6B35) : const Color(0xFF444460),
              size: 18,
            ),
            suffixIcon: onToggleObscure != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (suffixWidget != null) ...[suffixWidget, const SizedBox(width: 4)],
                      IconButton(
                        icon: Icon(
                          (obscure ?? false) ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF444460),
                          size: 18,
                        ),
                        onPressed: onToggleObscure,
                      ),
                    ],
                  )
                : suffixWidget != null
                    ? Padding(padding: const EdgeInsets.only(right: 12), child: suffixWidget)
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}

