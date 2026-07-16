import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/theme/theme_provider.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/user_model.dart';
import 'package:syncsphere/presentation/auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final AppUser? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        child: Column(
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: DesignTokens.spacingL),
            _buildSettingsSection(context),
            const SizedBox(height: DesignTokens.spacingL),
            const Icon(
              Icons.event_note,
              size: 40,
              color: DesignTokens.textHint,
            ),
            const SizedBox(height: DesignTokens.spacingXS),
            const Text(
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

  Widget _buildProfileHeader(BuildContext context, AppUser? user) {
    final initials = user?.name.isNotEmpty == true
        ? user!.name[0].toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: DesignTokens.radiusL,
        boxShadow: DesignTokens.shadowMedium,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: DesignTokens.primaryColor.withOpacity(0.1),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: DesignTokens.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Text(
            user?.name ?? 'Guest User',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: DesignTokens.spacingXS),
          Text(
            user?.email ?? 'No email',
            style: const TextStyle(color: DesignTokens.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            icon: themeProvider.themeMode == ThemeMode.light
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            label: 'Theme',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  themeProvider.themeMode == ThemeMode.light
                      ? 'Light'
                      : 'Dark',
                  style: const TextStyle(color: DesignTokens.textSecondary),
                ),
                const SizedBox(width: DesignTokens.spacingXS),
                Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeColor: DesignTokens.primaryColor,
                ),
              ],
            ),
            onTap: () => themeProvider.toggleTheme(),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.info_outline,
            label: 'About SyncSphere',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SyncSphere',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    '© 2024 SyncSphere. Collaborative Event Planning.',
              );
            },
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
    return const Divider(height: 1, color: DesignTokens.surfaceVariant);
  }
}
