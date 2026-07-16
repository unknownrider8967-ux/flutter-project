import 'package:flutter/material.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';

class _NotificationItem {
  final String title;
  final String message;
  final String time;
  bool read;
  final IconData icon;
  final Color color;

  _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.read,
    required this.icon,
    required this.color,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<_NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      _NotificationItem(
        title: 'Event Reminder',
        message: 'Tech Summit 2024 starts tomorrow at 9 AM.',
        time: '2 hours ago',
        read: false,
        icon: Icons.event_available,
        color: DesignTokens.primaryColor,
      ),
      _NotificationItem(
        title: 'Task Completed',
        message: 'James K. completed "Design invitation cards".',
        time: '5 hours ago',
        read: false,
        icon: Icons.assignment_turned_in,
        color: DesignTokens.success,
      ),
      _NotificationItem(
        title: 'Guest RSVP',
        message: 'Alice Johnson confirmed attendance for Product Launch.',
        time: '1 day ago',
        read: true,
        icon: Icons.people,
        color: DesignTokens.secondaryColor,
      ),
      _NotificationItem(
        title: 'Budget Alert',
        message:
            'You\'re at 85% of your budget for Summer Music Festival.',
        time: '3 days ago',
        read: true,
        icon: Icons.account_balance_wallet_outlined,
        color: DesignTokens.warning,
      ),
      _NotificationItem(
        title: 'Task Due Soon',
        message: 'Coordinate with vendors is due in 2 days.',
        time: '4 days ago',
        read: true,
        icon: Icons.timer_outlined,
        color: DesignTokens.accentColor,
      ),
      _NotificationItem(
        title: 'New Guest Added',
        message: 'Carol Davis was added to Summer Music Festival.',
        time: '1 week ago',
        read: true,
        icon: Icons.person_add_outlined,
        color: DesignTokens.info,
      ),
    ];
  }

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.read = true;
      }
    });
  }

  void _markRead(int index) {
    setState(() {
      _notifications[index].read = true;
    });
  }

  void _dismiss(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.read).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (unread > 0) ...[
              const SizedBox(width: DesignTokens.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingS, vertical: 2),
                decoration: const BoxDecoration(
                  color: DesignTokens.primaryColor,
                  borderRadius: DesignTokens.radiusXL,
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: DesignTokens.primaryColor),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const EmptyStateWidget(
              title: 'All caught up!',
              subtitle:
                  'No new notifications. You\'re up to date with everything.',
              icon: Icons.notifications_none_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(DesignTokens.spacingL),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final n = _notifications[index];
                return Dismissible(
                  key: Key('$index-${n.title}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: DesignTokens.spacingL),
                    decoration: const BoxDecoration(
                      color: DesignTokens.error,
                      borderRadius: DesignTokens.radiusL,
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white),
                  ),
                  onDismissed: (_) => _dismiss(index),
                  child: GestureDetector(
                    onTap: () => _markRead(index),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: DesignTokens.spacingM),
                      child: SyncSphereCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: n.read
                                    ? DesignTokens.surfaceVariant
                                    : n.color.withValues(alpha: 0.1),
                                borderRadius: DesignTokens.radiusM,
                              ),
                              child: Icon(
                                n.icon,
                                color: n.read
                                    ? DesignTokens.textHint
                                    : n.color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: DesignTokens.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n.title,
                                          style: TextStyle(
                                            fontWeight: n.read
                                                ? FontWeight.w400
                                                : FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (!n.read)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color:
                                                DesignTokens.primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: DesignTokens.spacingXS),
                                  Text(
                                    n.message,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: n.read
                                          ? DesignTokens.textSecondary
                                          : DesignTokens.textPrimary,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: DesignTokens.spacingXS),
                                  Text(
                                    n.time,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: DesignTokens.textHint),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
