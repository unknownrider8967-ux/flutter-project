import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/event_model.dart';
import 'package:syncsphere/presentation/calendar/screens/calendar_screen.dart';
import 'package:syncsphere/presentation/dashboard/providers/event_provider.dart';
import 'package:syncsphere/presentation/dashboard/screens/event_detail_screen.dart';
import 'package:syncsphere/presentation/dashboard/screens/create_event_screen.dart';
import 'package:syncsphere/presentation/notification/screens/notification_screen.dart';
import 'package:syncsphere/presentation/profile/screens/profile_screen.dart';

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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          CalendarScreen(),
          NotificationScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CreateEventScreen()),
                );
                if (context.mounted) context.read<EventProvider>().loadEvents();
              },
              backgroundColor: DesignTokens.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────
// Home tab — all events + stats
// ─────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final events = eventProvider.events;
    final upcoming = events
        .where((e) => e.status == 'published' || e.status == 'ongoing')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.event_note, color: DesignTokens.primaryColor),
            SizedBox(width: 8),
            Text('SyncSphere'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: eventProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<EventProvider>().loadEvents(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(DesignTokens.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStats(events, upcoming),
                    const SizedBox(height: DesignTokens.spacingL),
                    if (upcoming.isNotEmpty) ...[
                      Text('Active Events',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: DesignTokens.spacingM),
                      ...upcoming.take(3).map(
                            (e) => _EventCard(event: e),
                          ),
                      const SizedBox(height: DesignTokens.spacingL),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('All Events',
                            style:
                                Theme.of(context).textTheme.headlineMedium),
                        Text('${events.length} total',
                            style: const TextStyle(
                                color: DesignTokens.textHint,
                                fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spacingM),
                    if (events.isEmpty)
                      EmptyStateWidget(
                        title: 'No Events Yet',
                        subtitle:
                            'Create your first event to get started.',
                        icon: Icons.event_available_outlined,
                        actionLabel: 'Create Event',
                        onActionPressed: () {
                          final provider = context.read<EventProvider>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CreateEventScreen()),
                          ).then((_) {
                            if (!context.mounted) return;
                            provider.loadEvents();
                          });
                        },
                      )
                    else
                      ...events.map((e) => _EventCard(event: e)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStats(List<Event> events, List<Event> upcoming) {
    return Row(
      children: [
        _StatChip(
            value: '${events.length}',
            label: 'Events',
            color: DesignTokens.primaryColor),
        const SizedBox(width: DesignTokens.spacingM),
        _StatChip(
            value: '${upcoming.length}',
            label: 'Active',
            color: DesignTokens.success),
        const SizedBox(width: DesignTokens.spacingM),
        _StatChip(
            value:
                '${events.where((e) => e.status == 'draft').length}',
            label: 'Drafts',
            color: DesignTokens.textHint),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatChip(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: DesignTokens.spacingM,
            horizontal: DesignTokens.spacingS),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: DesignTokens.radiusM,
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: DesignTokens.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (event.status) {
      case 'published':
        statusColor = DesignTokens.success;
        break;
      case 'ongoing':
        statusColor = DesignTokens.info;
        break;
      case 'completed':
        statusColor = DesignTokens.secondaryColor;
        break;
      default:
        statusColor = DesignTokens.textHint;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: SyncSphereCard(
        onTap: () {
          final provider = context.read<EventProvider>();
          provider.selectEvent(event);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EventDetailScreen(event: event)),
          ).then((_) {
            if (!context.mounted) return;
            provider.loadEvents();
          });
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
                        child: Text(event.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spacingS,
                            vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
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
                      Text(DateFormat('MMM d').format(event.startDate),
                          style: const TextStyle(
                              fontSize: 12,
                              color: DesignTokens.textSecondary)),
                      const SizedBox(width: DesignTokens.spacingM),
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: DesignTokens.textHint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(event.location,
                            style: const TextStyle(
                                fontSize: 12,
                                color: DesignTokens.textSecondary),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: DesignTokens.textHint),
          ],
        ),
      ),
    );
  }
}
