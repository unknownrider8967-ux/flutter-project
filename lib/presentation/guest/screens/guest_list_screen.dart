import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/guest_model.dart';
import 'package:syncsphere/presentation/guest/providers/guest_provider.dart';
import 'package:syncsphere/presentation/guest/screens/add_edit_guest_screen.dart';

class GuestListScreen extends StatefulWidget {
  final int eventId;

  const GuestListScreen({super.key, required this.eventId});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuestProvider>().loadGuests(widget.eventId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddEditGuestScreen(eventId: widget.eventId),
                ),
              );
              if (context.mounted) {
                context.read<GuestProvider>().loadGuests(widget.eventId);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                DesignTokens.spacingS,
                DesignTokens.spacingL,
                DesignTokens.spacingS),
            child: Row(
              children: [
                Expanded(
                  child: SyncSphereInputField(
                    hint: 'Search guests...',
                    controller: _searchController,
                    onChanged: (value) => guestProvider.search(value),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: DesignTokens.textHint,
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingM),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter by RSVP',
                  onSelected: (value) =>
                      guestProvider.filterByStatus(value),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'all', child: Text('All')),
                    PopupMenuItem(
                        value: 'confirmed', child: Text('Confirmed')),
                    PopupMenuItem(value: 'pending', child: Text('Pending')),
                    PopupMenuItem(value: 'maybe', child: Text('Maybe')),
                    PopupMenuItem(
                        value: 'declined', child: Text('Declined')),
                  ],
                ),
              ],
            ),
          ),
          // RSVP summary row
          if (guests.isNotEmpty) _buildRsvpSummary(guests),
          if (guestProvider.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (guests.isEmpty)
            Expanded(
              child: EmptyStateWidget(
                title: 'No Guests Yet',
                subtitle:
                    'Add your first guest to get started with your event.',
                actionLabel: 'Add Guest',
                icon: Icons.people_outline,
                onActionPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditGuestScreen(eventId: widget.eventId),
                    ),
                  ).then((_) {
                    if (!context.mounted) return;
                    context.read<GuestProvider>().loadGuests(widget.eventId);
                  });
                },
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(DesignTokens.spacingL),
                itemCount: guests.length,
                itemBuilder: (context, index) =>
                    _buildGuestCard(guests[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRsvpSummary(List<Guest> guests) {
    final confirmed =
        guests.where((g) => g.rsvpStatus == 'confirmed').length;
    final pending = guests.where((g) => g.rsvpStatus == 'pending').length;
    final declined =
        guests.where((g) => g.rsvpStatus == 'declined').length;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingXS),
      child: Row(
        children: [
          _summaryChip('$confirmed', 'Confirmed', DesignTokens.success),
          const SizedBox(width: DesignTokens.spacingS),
          _summaryChip('$pending', 'Pending', DesignTokens.warning),
          const SizedBox(width: DesignTokens.spacingS),
          _summaryChip('$declined', 'Declined', DesignTokens.error),
          const SizedBox(width: DesignTokens.spacingS),
          _summaryChip('${guests.length}', 'Total', DesignTokens.primaryColor),
        ],
      ),
    );
  }

  Widget _summaryChip(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingXS),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: DesignTokens.radiusS,
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: color, fontSize: 16),
            ),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 9, color: DesignTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCard(Guest guest) {
    return SyncSphereCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: DesignTokens.primaryColor.withValues(alpha: 0.1),
            child: Text(
              guest.name.isNotEmpty
                  ? guest.name[0].toUpperCase()
                  : '?',
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  guest.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.textSecondary,
                  ),
                ),
                if (guest.dietaryRestrictions != null &&
                    guest.dietaryRestrictions!.isNotEmpty)
                  Text(
                    guest.dietaryRestrictions!,
                    style: const TextStyle(
                        fontSize: 11, color: DesignTokens.textHint),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingS,
                  vertical: DesignTokens.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: guest.rsvpColor.withValues(alpha: 0.1),
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
              if (guest.isPlusOne)
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text('+1',
                      style: TextStyle(
                          fontSize: 10,
                          color: DesignTokens.textHint)),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) {
              if (value == 'edit') {
                final guestProvider = context.read<GuestProvider>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditGuestScreen(
                        guest: guest, eventId: widget.eventId),
                  ),
                ).then((_) {
                  if (!context.mounted) return;
                  guestProvider.loadGuests(widget.eventId);
                });
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
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ]),
              ),
              const PopupMenuItem(
                value: 'rsvp_confirmed',
                child: Row(children: [
                  Icon(Icons.check_circle_outline,
                      size: 18, color: DesignTokens.success),
                  SizedBox(width: 8),
                  Text('Mark Confirmed'),
                ]),
              ),
              const PopupMenuItem(
                value: 'rsvp_maybe',
                child: Row(children: [
                  Icon(Icons.help_outline,
                      size: 18, color: DesignTokens.warning),
                  SizedBox(width: 8),
                  Text('Mark Maybe'),
                ]),
              ),
              const PopupMenuItem(
                value: 'rsvp_declined',
                child: Row(children: [
                  Icon(Icons.cancel_outlined,
                      size: 18, color: DesignTokens.error),
                  SizedBox(width: 8),
                  Text('Mark Declined'),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline,
                      size: 18, color: DesignTokens.error),
                  SizedBox(width: 8),
                  Text('Delete',
                      style: TextStyle(color: DesignTokens.error)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guest'),
        content:
            const Text('Are you sure you want to remove this guest?'),
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
            child: const Text('Delete',
                style: TextStyle(color: DesignTokens.error)),
          ),
        ],
      ),
    );
  }
}
