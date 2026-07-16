import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/event_model.dart';
import 'package:syncsphere/presentation/dashboard/providers/event_provider.dart';
import 'package:syncsphere/presentation/dashboard/screens/event_detail_screen.dart';
import 'package:syncsphere/presentation/dashboard/screens/create_event_screen.dart';
import 'package:syncsphere/presentation/guest/screens/guest_list_screen.dart';
import 'package:syncsphere/presentation/task/screens/task_list_screen.dart';
import 'package:syncsphere/presentation/budget/screens/budget_screen.dart';
import 'package:syncsphere/presentation/profile/screens/profile_screen.dart';
import 'package:syncsphere/presentation/notification/screens/notification_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final events = eventProvider.events;
    final upcomingEvents =
        events.where((e) => e.status == 'published' || e.status == 'ongoing').toList();

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: Row(
                children: [
                  const Icon(Icons.event_note, color: DesignTokens.primaryColor),
                  const SizedBox(width: 8),
                  const Text('SyncSphere'),
                ],
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationScreen()),
                    );
                  },
                ),
              ],
            )
          : null,
      body: _buildBody(events, upcomingEvents),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CreateEventScreen()),
                );
                if (mounted) {
                  context.read<EventProvider>().loadEvents();
                }
              },
              backgroundColor: DesignTokens.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBody(List<Event> events, List<Event> upcomingEvents) {
    final firstEventId =
        events.isNotEmpty ? events.first.id! : 1;

    final pages = [
      _buildDashboardHome(events, upcomingEvents),
      GuestListScreen(eventId: firstEventId),
      TaskListScreen(eventId: firstEventId),
      BudgetScreen(eventId: firstEventId),
      const ProfileScreen(),
    ];

    return IndexedStack(
      index: _currentIndex,
      children: pages,
    );
  }

  Widget _buildDashboardHome(List<Event> events, List<Event> upcomingEvents) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary stats
          Row(
            children: [
              _buildStatChip(
                  '${events.length}', 'Total Events', DesignTokens.primaryColor),
              const SizedBox(width: DesignTokens.spacingM),
              _buildStatChip('${upcomingEvents.length}', 'Active',
                  DesignTokens.success),
              const SizedBox(width: DesignTokens.spacingM),
              _buildStatChip(
                  '${events.where((e) => e.status == 'draft').length}',
                  'Drafts',
                  DesignTokens.textHint),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingL),
          Row(
            children: [
              Text(
                'Upcoming Events',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              if (upcomingEvents.isNotEmpty)
                TextButton(
                  onPressed: () {},
                  child: const Text('See all'),
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingM),
          if (upcomingEvents.isEmpty)
            SyncSphereCard(
              child: const Padding(
                padding: EdgeInsets.all(DesignTokens.spacingL),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy_outlined,
                          size: 48, color: DesignTokens.textHint),
                      SizedBox(height: DesignTokens.spacingM),
                      Text(
                        'No active events yet',
                        style:
                            TextStyle(color: DesignTokens.textSecondary),
                      ),
                      SizedBox(height: DesignTokens.spacingXS),
                      Text(
                        'Tap + to create your first event.',
                        style: TextStyle(
                            color: DesignTokens.textHint, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Column(
              children: upcomingEvents.take(3).map((event) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: DesignTokens.spacingM),
                  child: _buildEventCard(event),
                );
              }).toList(),
            ),
          const SizedBox(height: DesignTokens.spacingL),
          Text(
            'All Events',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: DesignTokens.spacingM),
          if (events.isEmpty)
            const Center(
              child: Text(
                'No events created yet.',
                style: TextStyle(color: DesignTokens.textSecondary),
              ),
            )
          else
            Column(
              children: events.map((event) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: DesignTokens.spacingM),
                  child: _buildEventCard(event),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: DesignTokens.spacingM,
            horizontal: DesignTokens.spacingS),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: DesignTokens.radiusM,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11, color: DesignTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    Color statusColor;
    switch (event.status) {
      case 'published':
        statusColor = DesignTokens.success;
        break;
      case 'ongoing':
        statusColor = DesignTokens.info;
        break;
      default:
        statusColor = DesignTokens.textHint;
    }

    return SyncSphereCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event),
          ),
        ).then((_) => context.read<EventProvider>().loadEvents());
      },
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: DesignTokens.radiusXL,
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
                        event.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacingS,
                          vertical: DesignTokens.spacingXS),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: DesignTokens.radiusS,
                      ),
                      child: Text(
                        event.status.toUpperCase(),
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingXS),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: DesignTokens.textHint),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d').format(event.startDate),
                      style: const TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textSecondary),
                    ),
                    const SizedBox(width: DesignTokens.spacingM),
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: DesignTokens.textHint),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: const TextStyle(
                            fontSize: 12,
                            color: DesignTokens.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: DesignTokens.textHint),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      selectedItemColor: DesignTokens.primaryColor,
      unselectedItemColor: DesignTokens.textSecondary,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          activeIcon: Icon(Icons.group),
          label: 'Guests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_alt_outlined),
          activeIcon: Icon(Icons.task_alt),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Budget',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
