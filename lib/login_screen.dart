import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anotherrunner/l10n/app_localizations.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isRegistering = false;

  void _toggleLoading() {
    if (mounted) {
      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _confirmPasswordController.clear();
    });
  }

  Future<void> _signInWithEmail() async {
    final l10n = AppLocalizations.of(context)!;

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fillAllFields)));
      return;
    }
    _toggleLoading();
    await _auth.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    _toggleLoading();
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fillEmailToReset)));
      return;
    }

    _toggleLoading();
    final success = await _auth.resetPassword(email);
    _toggleLoading();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordResetSent)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorSendingOtp)));
    }
  }

  Future<void> _startRegistration() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fillAllFields)));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordsNotMatch)));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordTooShort)));
      return;
    }

    _toggleLoading();

    final String otp = (Random().nextInt(900000) + 100000).toString();
    final bool emailSent = await _auth.sendOtpEmail(email, otp);

    _toggleLoading();

    if (!mounted) return;

    if (emailSent) {
      _showOtpDialog(email, password, otp);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorSendingOtp)));
    }
  }

  void _showOtpDialog(String email, String password, String correctOtp) {
    final l10n = AppLocalizations.of(context)!;
    _otpController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmEmailTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.otpSentMessage(email)),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: l10n.otpCodeLabel,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancelBtn),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_otpController.text.trim() == correctOtp) {
                Navigator.pop(dialogContext);
                _toggleLoading();
                try {
                  await _auth.registerWithEmail(email, password);
                } on FirebaseAuthException catch (e) {
                  if (!mounted) return;
                  if (e.code == 'email-already-in-use') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.emailInUsePassword)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Registration Error')));
                  }
                }
                _toggleLoading();
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invalidOtp)));
              }
            },
            child: Text(l10n.confirmBtn),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    _toggleLoading();
    await _auth.signInWithGoogle();
    _toggleLoading();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.welcomeTo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                isDarkMode
                    ? 'lib/assets/Graphic resource (White).png'
                    : 'lib/assets/Graphic resource.png',
                height: 48,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.chooseLoginMethod,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.emailLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.passwordLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_isRegistering) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPasswordLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                ElevatedButton(
                  onPressed: _isRegistering ? _startRegistration : _signInWithEmail,
                  child: Text(_isRegistering ? l10n.createAccountBtn : l10n.signInBtn),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _toggleMode,
                  child: Text(_isRegistering
                      ? l10n.alreadyHaveAccount
                      : l10n.dontHaveAccount),
                ),
                const Divider(height: 48),
                OutlinedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: SvgPicture.asset(
                    'lib/assets/Google.svg',
                    width: 24,
                    height: 24,
                  ),
                  label: Text(l10n.signInWithGoogleBtn),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _resetPassword,
                  child: Text(
                    l10n.forgotPasswordBtn,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}