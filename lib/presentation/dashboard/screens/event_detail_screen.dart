import 'package:flutter/material.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/event_model.dart';
import 'package:syncsphere/presentation/guest/screens/guest_list_screen.dart';
import 'package:syncsphere/presentation/task/screens/task_list_screen.dart';
import 'package:syncsphere/presentation/budget/screens/budget_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;
  
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Navigate to edit event
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventHeader(),
            const SizedBox(height: DesignTokens.spacingL),
            _buildEventInfo(),
            const SizedBox(height: DesignTokens.spacingL),
            _buildQuickActions(context),
            const SizedBox(height: DesignTokens.spacingL),
            _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [DesignTokens.primaryColor, DesignTokens.primaryDark],
        ),
        borderRadius: DesignTokens.radiusL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingS,
                  vertical: DesignTokens.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: DesignTokens.radiusS,
                ),
                child: Text(
                  event.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                event.category,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Text(
            event.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingS),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: DesignTokens.spacingS),
              Text(
                '${event.formattedStartDate} - ${event.formattedEndDate}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingS),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: DesignTokens.spacingS),
              Text(
                event.location,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfo() {
    return SyncSphereCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About This Event',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingS),
          Text(
            event.description,
            style: TextStyle(
              color: DesignTokens.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Max Guests',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignTokens.textHint,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingXS),
                    Text(
                      event.maxGuests?.toString() ?? 'TBD',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignTokens.textHint,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingXS),
                    Text(
                      '\$${event.budget?.toStringAsFixed(0) ?? 'TBD'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignTokens.textHint,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingXS),
                    Text(
                      '${event.durationDays} days',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignTokens.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.people_outline,
                label: 'Guests',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GuestListScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: _buildActionButton(
                icon: Icons.assignment_outlined,
                label: 'Tasks',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TaskListScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: _buildActionButton(
                icon: Icons.attach_money,
                label: 'Budget',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BudgetScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SyncSphereCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.radiusL,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: DesignTokens.spacingM,
          ),
          child: Column(
            children: [
              Icon(icon, color: DesignTokens.primaryColor),
              const SizedBox(height: DesignTokens.spacingS),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: SyncSphereCard(
            child: Column(
              children: [
                Text(
                  'Guests',
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignTokens.textHint,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingXS),
                const Text(
                  '45',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingXS),
                const Text(
                  '32 confirmed',
                  style: TextStyle(
                    fontSize: 10,
                    color: DesignTokens.success,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.spacingM),
        Expanded(
          child: SyncSphereCard(
            child: Column(
              children: [
                Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignTokens.textHint,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingXS),
                const Text(
                  '18',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingXS),
                const Text(
                  '12 completed',
                  style: TextStyle(
                    fontSize: 10,
                    color: DesignTokens.success,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}