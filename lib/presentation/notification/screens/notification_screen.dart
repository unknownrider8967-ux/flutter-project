import 'package:flutter/material.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Event Reminder',
        'message': 'Tech Summit 2024 starts tomorrow at 9 AM.',
        'time': '2 hours ago',
        'read': false,
        'icon': Icons.event_available,
      },
      {
        'title': 'Task Update',
        'message': 'James K. completed "Design invitation cards".',
        'time': '5 hours ago',
        'read': false,
        'icon': Icons.assignment_turned_in,
      },
      {
        'title': 'Guest RSVP',
        'message': 'Alice Johnson confirmed attendance for Product Launch.',
        'time': '1 day ago',
        'read': true,
        'icon': Icons.people,
      },
      {
        'title': 'Budget Alert',
        'message': 'You\'re at 85% of your budget for Summer Music Festival.',
        'time': '3 days ago',
        'read': true,
        'icon': Icons.attach_money,
      },
      {
        'title': 'New Feature',
        'message': 'Check out the new calendar view for your events.',
        'time': '1 week ago',
        'read': true,
        'icon': Icons.new_releases,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(
            title: notification['title'] as String,
            message: notification['message'] as String,
            time: notification['time'] as String,
            read: notification['read'] as bool,
            icon: notification['icon'] as IconData,
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String message,
    required String time,
    required bool read,
    required IconData icon,
  }) {
    return SyncSphereCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: read
                  ? DesignTokens.surfaceVariant
                  : DesignTokens.primaryColor.withOpacity(0.1),
              borderRadius: DesignTokens.radiusM,
            ),
            child: Icon(
              icon,
              color: read ? DesignTokens.textHint : DesignTokens.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: DesignTokens.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: read ? FontWeight.w400 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!read)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: DesignTokens.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingXS),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: read ? DesignTokens.textSecondary : DesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingXS),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}