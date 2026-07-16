import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/event_model.dart';
import 'package:syncsphere/presentation/dashboard/providers/event_provider.dart';
import 'package:syncsphere/presentation/dashboard/screens/create_event_screen.dart';
import 'package:syncsphere/presentation/guest/screens/guest_list_screen.dart';
import 'package:syncsphere/presentation/task/screens/task_list_screen.dart';
import 'package:syncsphere/presentation/budget/screens/budget_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Event _event;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_event.name),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateEventScreen(event: _event),
                ),
              );
              if (updated == true || mounted) {
                // Reload event from provider
                final provider = context.read<EventProvider>();
                await provider.loadEvents();
                final fresh = provider.events
                    .where((e) => e.id == _event.id)
                    .toList();
                if (fresh.isNotEmpty && mounted) {
                  setState(() => _event = fresh.first);
                }
              }
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
            _buildDeleteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader() {
    Color statusColor;
    switch (_event.status) {
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

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      decoration: const BoxDecoration(
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
                  _event.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingS,
                    vertical: DesignTokens.spacingXS),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: DesignTokens.radiusS,
                ),
                child: Text(
                  _event.category,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Text(
            _event.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingS),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.white70),
              const SizedBox(width: DesignTokens.spacingXS),
              Text(
                '${_event.formattedStartDate} – ${_event.formattedEndDate}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingXS),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: Colors.white70),
              const SizedBox(width: DesignTokens.spacingXS),
              Expanded(
                child: Text(
                  _event.location,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
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
            style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: DesignTokens.spacingS),
          Text(
            _event.description.isEmpty
                ? 'No description provided.'
                : _event.description,
            style: const TextStyle(
                color: DesignTokens.textSecondary, height: 1.5),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Row(
            children: [
              _buildInfoChip(
                  'Max Guests',
                  _event.maxGuests?.toString() ?? 'TBD',
                  Icons.people_outline),
              const SizedBox(width: DesignTokens.spacingM),
              _buildInfoChip(
                  'Budget',
                  _event.budget != null
                      ? '\$${_event.budget!.toStringAsFixed(0)}'
                      : 'TBD',
                  Icons.attach_money),
              const SizedBox(width: DesignTokens.spacingM),
              _buildInfoChip(
                  'Duration',
                  '${_event.durationDays} day${_event.durationDays != 1 ? 's' : ''}',
                  Icons.schedule_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: DesignTokens.primaryColor),
          const SizedBox(height: DesignTokens.spacingXS),
          Text(
            value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: DesignTokens.textHint),
            textAlign: TextAlign.center,
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: DesignTokens.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                context,
                icon: Icons.people_outline,
                label: 'Guests',
                color: DesignTokens.primaryColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GuestListScreen(eventId: _event.id!),
                  ),
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: _buildActionTile(
                context,
                icon: Icons.assignment_outlined,
                label: 'Tasks',
                color: DesignTokens.secondaryColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TaskListScreen(eventId: _event.id!),
                  ),
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: _buildActionTile(
                context,
                icon: Icons.attach_money,
                label: 'Budget',
                color: DesignTokens.accentColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BudgetScreen(eventId: _event.id!),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SyncSphereCard(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: DesignTokens.spacingM),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: DesignTokens.spacingXS),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return SyncSphereButton(
      label: 'Delete Event',
      isOutlined: true,
      textColor: DesignTokens.error,
      backgroundColor: DesignTokens.error,
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Event'),
            content: const Text(
                'Are you sure you want to delete this event? This will also remove all associated guests, tasks, and budget entries.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await context
                      .read<EventProvider>()
                      .deleteEvent(_event.id!);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Delete',
                    style: TextStyle(color: DesignTokens.error)),
              ),
            ],
          ),
        );
      },
    );
  }
}
