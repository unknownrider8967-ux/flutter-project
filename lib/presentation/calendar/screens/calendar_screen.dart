import 'package:flutter/material.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: DesignTokens.primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: DesignTokens.primaryLight,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingL),
          Expanded(
            child: _selectedDay != null
                ? ListView.builder(
                    padding: const EdgeInsets.all(DesignTokens.spacingL),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return SyncSphereCard(
                        margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
                        child: Padding(
                          padding: const EdgeInsets.all(DesignTokens.spacingM),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Event ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: DesignTokens.spacingXS),
                              Text(
                                'Sample event on ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                                style: TextStyle(
                                  color: DesignTokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'Select a date to see events',
                      style: TextStyle(
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}