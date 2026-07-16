import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/presentation/guest/providers/guest_provider.dart';
import 'package:syncsphere/presentation/guest/screens/add_edit_guest_screen.dart';

class GuestListScreen extends StatefulWidget {
  const GuestListScreen({super.key});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'all';
  int _eventId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuestProvider>().loadGuests(_eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final guestProvider = context.watch<GuestProvider>();
    final guests = guestProvider.guests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guests'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditGuestScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingL),
            child: Row(
              children: [
                Expanded(
                  child: SyncSphereInputField(
                    hint: 'Search guests...',
                    controller: _searchController,
                    onChanged: (value) {
                      guestProvider.search(value);
                    },
                    prefixIcon: const Icon(
                      Icons.search,
                      color: DesignTokens.textHint,
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingM),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                    guestProvider.filterByStatus(value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'all',
                      child: Text('All'),
                    ),
                    const PopupMenuItem(
                      value: 'confirmed',
                      child: Text('Confirmed'),
                    ),
                    const PopupMenuItem(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                    const PopupMenuItem(
                      value: 'maybe',
                      child: Text('Maybe'),
                    ),
                    const PopupMenuItem(
                      value: 'declined',
                      child: Text('Declined'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (guestProvider.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (guests.isEmpty)
            const Expanded(
              child: EmptyStateWidget(
                title: 'No Guests Yet',
                subtitle: 'Add your first guest to get started.',
                actionLabel: 'Add Guest',
                icon: Icons.people_outline,
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(DesignTokens.spacingL),
                itemCount: guests.length,
                itemBuilder: (context, index) {
                  final guest = guests[index];
                  return _buildGuestCard(guest);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuestCard(guest) {
    return SyncSphereCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingM),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: DesignTokens.primaryColor.withOpacity(0.1),
              child: Text(
                guest.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: DesignTokens.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guest.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    guest.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingS,
                vertical: DesignTokens.spacingXS,
              ),
              decoration: BoxDecoration(
                color: guest.rsvpColor.withOpacity(0.1),
                borderRadius: DesignTokens.radiusS,
                border: Border.all(color: guest.rsvpColor),
              ),
              child: Text(
                guest.rsvpLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: guest.rsvpColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spacingS),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditGuestScreen(guest: guest),
                    ),
                  );
                } else if (value == 'delete') {
                  _showDeleteDialog(guest.id!);
                } else if (value.startsWith('rsvp_')) {
                  final status = value.replaceFirst('rsvp_', '');
                  context.read<GuestProvider>().updateRSVP(guest.id!, status);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: DesignTokens.spacingS),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'rsvp_confirmed',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 20, color: DesignTokens.success),
                      SizedBox(width: DesignTokens.spacingS),
                      Text('Confirm RSVP'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'rsvp_maybe',
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, size: 20, color: DesignTokens.warning),
                      SizedBox(width: DesignTokens.spacingS),
                      Text('Maybe'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'rsvp_declined',
                  child: Row(
                    children: [
                      Icon(Icons.cancel_outlined, size: 20, color: DesignTokens.error),
                      SizedBox(width: DesignTokens.spacingS),
                      Text('Decline'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: DesignTokens.error),
                      SizedBox(width: DesignTokens.spacingS),
                      Text('Delete', style: TextStyle(color: DesignTokens.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guest'),
        content: const Text('Are you sure you want to delete this guest?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GuestProvider>().deleteGuest(id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: DesignTokens.error),
            ),
          ),
        ],
      ),
    );
  }
}