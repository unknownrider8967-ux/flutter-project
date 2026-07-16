import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncsphere/core/theme/theme_provider.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/presentation/auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        child: Column(
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: DesignTokens.spacingL),
            _buildSettingsSection(context),
            const SizedBox(height: DesignTokens.spacingL),
            // 🔴 ADD APP LOGO AT BOTTOM
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 40,
                width: 40,
                color: DesignTokens.textHint.withOpacity(0.3),
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.event_note,
                    size: 40,
                    color: DesignTokens.textHint.withOpacity(0.3),
                  );
                },
              ),
            ),
            const SizedBox(height: DesignTokens.spacingM),
            Text(
              'SyncSphere v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: DesignTokens.textHint,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingL),
            SyncSphereButton(
              label: 'Log Out',
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              backgroundColor: DesignTokens.error,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: DesignTokens.radiusL,
        boxShadow: DesignTokens.shadowMedium,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: DesignTokens.primaryColor.withOpacity(0.1),
            // 🔴 USE LOGO AS DEFAULT AVATAR
            child: user?.photoURL != null
                ? ClipOval(
                    child: Image.network(
                      user!.photoURL!,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: DesignTokens.primaryColor,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                : Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.primaryColor,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Text(
            user?.displayName ?? 'User',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            user?.email ?? 'No email',
            style: TextStyle(
              color: DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: DesignTokens.radiusL,
        boxShadow: DesignTokens.shadowSmall,
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.person_outline,
            label: 'Account Settings',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            trailing: Switch(
              value: true,
              onChanged: (_) {},
              activeColor: DesignTokens.primaryColor,
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.color_lens_outlined,
            label: 'Theme',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  themeProvider.themeMode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  size: 20,
                  color: DesignTokens.textSecondary,
                ),
                const SizedBox(width: DesignTokens.spacingS),
                Text(
                  themeProvider.themeMode == ThemeMode.light ? 'Light' : 'Dark',
                  style: const TextStyle(color: DesignTokens.textSecondary),
                ),
              ],
            ),
            onTap: () {
              themeProvider.toggleTheme();
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.info_outline,
            label: 'About SyncSphere',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.help_outline,
            label: 'Help & Support',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String label,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: DesignTokens.primaryColor),
      title: Text(label),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: DesignTokens.surfaceVariant,
    );
  }
}