// screens/profile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/auth_model.dart';
import '../../core/state/cart_model.dart';
import '../../core/state/favorites_model.dart';
import '../../core/state/orders_model.dart';
import '../../core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authModel = context.watch<AuthModel>();
    final user = authModel.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body:
          user == null
              ? _buildNotSignedIn(context)
              : _buildSignedIn(context, user, authModel),
    );
  }

  Widget _buildNotSignedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person_outline,
            size: 72,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'You are not signed in',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignedIn(BuildContext context, User user, AuthModel authModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          // Avatar + name + email row
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.accent,
                child: Text(
                  _initials(user.displayName ?? user.email ?? '?'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surfaceDark,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'No name set',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (user.metadata.creationTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Member since ${_fmtDate(user.metadata.creationTime!)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _sectionTitle('Account', context),
          _tile(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (_) => _EditNameDialog(
                      initialName: user.displayName ?? '',
                    ),
              );
            },
          ),
          _tile(
            icon: Icons.shopping_bag_outlined,
            label: 'My Orders',
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),
          _tile(
            icon: Icons.favorite_border,
            label: 'My Favorites',
            onTap: () => Navigator.pushNamed(context, '/favorites'),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Security', context),
          _tile(
            icon: Icons.lock_reset_outlined,
            label: 'Reset Password',
            onTap: () async {
              final email = user.email;
              final messenger = ScaffoldMessenger.of(context);
              if (email == null || email.trim().isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('No email associated with this account.'),
                  ),
                );
                return;
              }
              try {
                await authModel.sendPasswordResetEmail(email);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Password reset email sent.')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to send password reset email: $e'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final cart = context.read<CartModel>();
                final favorites = context.read<FavoritesModel>();
                final orders = context.read<OrdersModel>();
                final navigator = Navigator.of(context);

                await authModel.signOut();

                cart.clear();
                favorites.clear();
                orders.clear();
                navigator.pushNamedAndRemoveUntil('/login', (route) => false);
              },
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.danger),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size(double.infinity, 48),
                shape: StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.2,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20),
      ),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _EditNameDialog extends StatefulWidget {
  final String initialName;

  const _EditNameDialog({required this.initialName});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;

    final authModel = context.read<AuthModel>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _saving = true);
    try {
      await authModel.updateProfile(fullName: name);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        'Edit Name',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: TextField(
        controller: _ctrl,
        enabled: !_saving,
        decoration: const InputDecoration(
          hintText: 'Full name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child:
              _saving
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.surfaceDark,
                    ),
                  )
                  : const Text('Save'),
        ),
      ],
    );
  }
}

