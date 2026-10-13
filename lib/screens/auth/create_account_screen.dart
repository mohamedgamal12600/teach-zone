// screens/auth/create_account_screen.dart
// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/auth_model.dart';
import '../../core/theme/app_colors.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_loading) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await context.read<AuthModel>().createUserWithEmailAndPassword(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        _nameCtrl.text.trim(),
      );
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = _mapError(e.code, e.message));
    } on TimeoutException catch (e) {
      if (!mounted) return;
      setState(
        () =>
            _error = e.message ?? 'Operation timed out. Check your connection.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to create account: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapError(String code, String? message) => switch (code) {
    'email-already-in-use' => 'An account already exists for that email.',
    'invalid-email' => 'Invalid email address format.',
    'weak-password' => 'Password is too weak (minimum 6 characters).',
    'operation-not-allowed' =>
      'Email/Password sign-in is not enabled in Firebase Console. Please enable it under Authentication -> Sign-in method.',
    'network-request-failed' =>
      'Network error. Please check your internet connection.',
    _ => message ?? 'Authentication error: $code',
  };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create account', style: text.headlineMedium),
                const SizedBox(height: 6),
                Text('Join TechZone today', style: text.bodyMedium),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  enabled: !_loading,
                  decoration: const InputDecoration(
                    hintText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Full name is required.';
                    if (v.trim().length < 2) return 'Name is too short.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_loading,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Email is required.';
                    if (!v.contains('@')) return 'Enter a valid email.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  enabled: !_loading,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed:
                          () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required.';
                    if (v.length < 6) return 'Minimum 6 characters.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  enabled: !_loading,
                  decoration: InputDecoration(
                    hintText: 'Confirm password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed:
                          () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Please confirm your password.';
                    if (v != _passCtrl.text) return 'Passwords do not match.';
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.field),
                      border: Border.all(color: AppColors.danger),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 18,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child:
                        _loading
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.surfaceDark,
                              ),
                            )
                            : const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: text.bodyMedium),
                    TextButton(
                      onPressed:
                          _loading
                              ? null
                              : () => Navigator.pushReplacementNamed(
                                context,
                                '/login',
                              ),
                      child: const Text('Sign In'),
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
