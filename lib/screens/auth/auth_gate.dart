import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/auth_model.dart';
import '../home/home_screen.dart';
import '../onboarding/splash_screen.dart';
import 'login_screen.dart';

/// AuthGate displays the splash animation for a minimum duration,
/// then reacts to the auth stream to show either [HomeScreen] or [LoginScreen].
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _minSplashPassed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _minSplashPassed = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authModel = context.watch<AuthModel>();

    return StreamBuilder<User?>(
      stream: authModel.authStateChanges,
      initialData: authModel.currentUser,
      builder: (context, snapshot) {
        if (!_minSplashPassed || snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = snapshot.data;
        if (user != null) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
