// screens/profile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/auth_model.dart';
import '../../core/state/cart_model.dart';
import '../../core/state/favorites_model.dart';
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
    final authModel = context.read<AuthModel>();
    final user = authModel.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? _buildNotSignedIn(context)
          : _buildSignedIn(context, user, authModel),
    );
  }

  Widget _buildNotSignedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 72, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('You are not signed in', style: Theme.of(context).textTheme.titleMedium),
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
                    Text(user.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
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
              final ctrl = TextEditingController(
                text: user.displayName ?? '',
              );
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Edit Name',
                      style: TextStyle(color: AppColors.textPrimary)),
                  content: TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(hintText: 'Full name'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final name = ctrl.text.trim();
                        Navigator.pop(ctx);
                        if (name.isEmpty) return;
                        await authModel.updateProfile(fullName: name);
                      },
                      child: const Text('Save'),
                    ),
                  ],
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
              final messenger = ScaffoldMessenger.of(context);
              await authModel.sendPasswordResetEmail(user.email!);
              messenger.showSnackBar(
                const SnackBar(content: Text('Password reset email sent.')),
              );
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await authModel.signOut();
                
                context.read<CartModel>().clear();
                context.read<FavoritesModel>().clear();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
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
