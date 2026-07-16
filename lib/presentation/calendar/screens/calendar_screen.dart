import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/event_model.dart';
import 'package:syncsphere/presentation/dashboard/providers/event_provider.dart';
import 'package:syncsphere/presentation/dashboard/screens/event_detail_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  List<Event> _eventsForDay(List<Event> all, DateTime day) {
    return all.where((e) {
      final start = DateTime(
          e.startDate.year, e.startDate.month, e.startDate.day);
      final end =
          DateTime(e.endDate.year, e.endDate.month, e.endDate.day);
      final d = DateTime(day.year, day.month, day.day);
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = context.watch<EventProvider>().events;
    final selectedEvents = _selectedDay != null
        ? _eventsForDay(allEvents, _selectedDay!)
        : <Event>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2027, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _eventsForDay(allEvents, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: DesignTokens.primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: DesignTokens.primaryLight.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: DesignTokens.accentColor,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app_outlined,
                            size: 48, color: DesignTokens.textHint),
                        SizedBox(height: DesignTokens.spacingM),
                        Text(
                          'Tap a date to see events',
                          style:
                              TextStyle(color: DesignTokens.textSecondary),
                        ),
                      ],
                    ),
                  )
                : selectedEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.event_busy_outlined,
                                size: 48, color: DesignTokens.textHint),
                            const SizedBox(height: DesignTokens.spacingM),
                            Text(
                              'No events on ${DateFormat('MMM d, yyyy').format(_selectedDay!)}',
                              style: const TextStyle(
                                  color: DesignTokens.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(DesignTokens.spacingL),
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) =>
                            _buildEventCard(context, selectedEvents[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: SyncSphereCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: event)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: event.isActive
                    ? DesignTokens.success
                    : DesignTokens.primaryColor,
                borderRadius: DesignTokens.radiusXL,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.name,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: DesignTokens.spacingXS),
                  Text(
                    '${event.formattedTime} · ${event.location}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: DesignTokens.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingS,
                  vertical: DesignTokens.spacingXS),
              decoration: BoxDecoration(
                color: DesignTokens.primaryColor.withValues(alpha: 0.1),
                borderRadius: DesignTokens.radiusS,
              ),
              child: Text(
                event.category,
                style: const TextStyle(
                    fontSize: 10,
                    color: DesignTokens.primaryColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
