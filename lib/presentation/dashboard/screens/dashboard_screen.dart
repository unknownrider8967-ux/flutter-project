import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/presentation/dashboard/providers/event_provider.dart';
import 'package:syncsphere/presentation/dashboard/screens/event_detail_screen.dart';
import 'package:syncsphere/presentation/dashboard/screens/create_event_screen.dart';
import 'package:syncsphere/presentation/guest/screens/guest_list_screen.dart';
import 'package:syncsphere/presentation/task/screens/task_list_screen.dart';
import 'package:syncsphere/presentation/budget/screens/budget_screen.dart';
import 'package:syncsphere/presentation/profile/screens/profile_screen.dart';
import 'package:syncsphere/presentation/notification/screens/notification_screen.dart';
import 'package:syncsphere/presentation/task/providers/task_provider.dart';

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
    final upcomingEvents = events.where((e) => e.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',  // ← Your logo
              height: 30,
              width: 30,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.event_note);
              },
            ),
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
                  builder: (_) => const NotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(events, upcomingEvents),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateEventScreen(),
                  ),
                );
              },
              backgroundColor: DesignTokens.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(List events, List upcomingEvents) {
    final pages = [
      _buildDashboardHome(events, upcomingEvents),
      const GuestListScreen(),
      const TaskListScreen(),
      const BudgetScreen(),
      const ProfileScreen(),
    ];

    return IndexedStack(
      index: _currentIndex,
      children: pages,
    );
  }

  Widget _buildDashboardHome(List events, List upcomingEvents) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Events',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: DesignTokens.spacingM),
          if (upcomingEvents.isEmpty)
            const Text('No upcoming events. Create one to get started.')
          else
            Column(
              children: upcomingEvents.take(3).map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
                  child: SyncSphereCard(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignTokens.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title?.toString() ?? event.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spacingS),
                          Text(
                            event.description?.toString() ?? 'No description available',
                            style: TextStyle(
                              color: DesignTokens.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: DesignTokens.spacingL),
          SyncSphereCard(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Events Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: DesignTokens.spacingS),
                  Text(
                    'Total events: ${events.length}',
                    style: TextStyle(color: DesignTokens.textSecondary),
                  ),
                  const SizedBox(height: DesignTokens.spacingS),
                  Text(
                    'Upcoming events: ${upcomingEvents.length}',
                    style: TextStyle(color: DesignTokens.textSecondary),
                  ),
                ],
              ),
            ),
          ),
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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          label: 'Guests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_alt_outlined),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          label: 'Budget',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
