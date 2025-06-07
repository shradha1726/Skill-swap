// lib/screens/email_verification_screen.dart

// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/loading_indicator.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer;
  bool _isEmailVerified = false;
  bool _isSending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkEmailVerified();

    // Periodically check email verification status every 3 seconds
    _timer = Timer.periodic(
        const Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  Future<void> _checkEmailVerified() async {
    await _auth.currentUser?.reload();
    final user = _auth.currentUser;
    if (user != null && user.emailVerified) {
      setState(() {
        _isEmailVerified = true;
      });
      _timer?.cancel();

      // Navigate to home screen after verification
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isSending = true;
      _errorMessage = null;
    });
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send verification email. Please try again.';
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: _isEmailVerified
              ? const Text('Email verified! Redirecting...')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'A verification email has been sent to your email address. Please check your inbox and click the verification link.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 16),
                    _isSending
                        ? const LoadingIndicator()
                        : ElevatedButton(
                            onPressed: _resendVerificationEmail,
                            child: const Text('Resend Verification Email'),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _logout,
                      child: const Text('Cancel and Logout'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
