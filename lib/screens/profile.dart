// profile.dart
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../main.dart' show authModel, cartModel, favoritesModel, ordersModel;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    authModel.addListener(_rebuild);
  }

  @override
  void dispose() {
    authModel.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  Future<void> _signOut() async {
    await authModel.signOut();
    cartModel.clear();
    favoritesModel.clear();
    ordersModel.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _editName() {
    final ctrl = TextEditingController(
      text: authModel.currentUser?.displayName ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Name', style: TextStyle(color: AppColors.textPrimary)),
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
  }

  @override
  Widget build(BuildContext context) {
    final user = authModel.currentUser;
    final text = Theme.of(context).textTheme;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 72, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('You are not signed in', style: text.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: text.titleLarge),
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
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(user.email ?? '', style: text.bodyMedium),
                    if (user.metadata.creationTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Member since ${_fmtDate(user.metadata.creationTime!)}',
                        style: text.labelSmall,
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
            onTap: _editName,
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
              onPressed: _signOut,
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.danger),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size(double.infinity, 48),
                shape: const StadiumBorder(),
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

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}
