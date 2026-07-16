import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _taskReminders = true;
  bool _guestRsvpAlerts = true;
  bool _budgetAlerts = true;
  String _defaultView = 'dashboard';
  String _dateFormat = 'MMM d, yyyy';

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          _sectionHeader('Appearance'),
          _buildSwitchTile(
            icon: themeProvider.themeMode == ThemeMode.dark
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark themes',
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          _sectionHeader('Notifications'),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            subtitle: 'Receive event updates by email',
            value: _emailNotifications,
            onChanged: (v) => setState(() => _emailNotifications = v),
          ),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'In-app alerts and reminders',
            value: _pushNotifications,
            onChanged: (v) => setState(() => _pushNotifications = v),
          ),
          _buildSwitchTile(
            icon: Icons.task_alt_outlined,
            title: 'Task Reminders',
            subtitle: 'Get reminded about upcoming task due dates',
            value: _taskReminders,
            onChanged: (v) => setState(() => _taskReminders = v),
          ),
          _buildSwitchTile(
            icon: Icons.people_outlined,
            title: 'Guest RSVP Alerts',
            subtitle: 'Notify when guests respond to invitations',
            value: _guestRsvpAlerts,
            onChanged: (v) => setState(() => _guestRsvpAlerts = v),
          ),
          _buildSwitchTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Budget Alerts',
            subtitle: 'Warn when spending approaches budget limit',
            value: _budgetAlerts,
            onChanged: (v) => setState(() => _budgetAlerts = v),
          ),
          _sectionHeader('Preferences'),
          _buildDropdownTile(
            icon: Icons.dashboard_outlined,
            title: 'Default View',
            value: _defaultView,
            items: const {
              'dashboard': 'Dashboard',
              'calendar': 'Calendar',
              'timeline': 'Timeline',
            },
            onChanged: (v) => setState(() => _defaultView = v!),
          ),
          _buildDropdownTile(
            icon: Icons.calendar_today_outlined,
            title: 'Date Format',
            value: _dateFormat,
            items: const {
              'MMM d, yyyy': 'Jan 15, 2024',
              'dd/MM/yyyy': '15/01/2024',
              'MM/dd/yyyy': '01/15/2024',
              'yyyy-MM-dd': '2024-01-15',
            },
            onChanged: (v) => setState(() => _dateFormat = v!),
          ),
          _sectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined,
                color: DesignTokens.error),
            title: const Text('Clear App Data'),
            subtitle: const Text('Reset all events and settings'),
            onTap: () => _showClearDataDialog(context),
          ),
          const SizedBox(height: DesignTokens.spacingXL),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          DesignTokens.spacingL,
          DesignTokens.spacingL,
          DesignTokens.spacingL,
          DesignTokens.spacingS),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: DesignTokens.textHint,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: DesignTokens.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: DesignTokens.textSecondary)),
      value: value,
      onChanged: onChanged,
      activeColor: DesignTokens.primaryColor,
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: DesignTokens.primaryColor),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.entries
            .map((e) =>
                DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear App Data'),
        content: const Text(
            'This will permanently delete all events, guests, tasks, and budget entries. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('App data cleared.'),
                  backgroundColor: DesignTokens.error,
                ),
              );
            },
            child: const Text('Clear',
                style: TextStyle(color: DesignTokens.error)),
          ),
        ],
      ),
    );
  }
}
