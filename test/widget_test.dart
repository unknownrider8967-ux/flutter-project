import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/theme/theme_provider.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/event_model.dart';
import 'package:syncsphere/data/models/guest_model.dart';
import 'package:syncsphere/data/models/task_model.dart';
import 'package:syncsphere/data/models/budget_model.dart';
import 'package:syncsphere/data/models/user_model.dart';

// ------------------------------------------------------------------
// Unit tests — models
// ------------------------------------------------------------------

void main() {
  group('Event model', () {
    test('fromMap / toMap round-trips correctly', () {
      final event = Event(
        id: 1,
        name: 'Test Event',
        description: 'A description',
        startDate: DateTime(2024, 5, 15, 9, 0),
        endDate: DateTime(2024, 5, 17, 18, 0),
        location: 'Test Venue',
        category: 'Conference',
        status: 'published',
        maxGuests: 100,
        budget: 5000.0,
      );

      final map = event.toMap();
      final restored = Event.fromMap(map);

      expect(restored.name, event.name);
      expect(restored.location, event.location);
      expect(restored.status, event.status);
      expect(restored.budget, event.budget);
    });

    test('isActive returns true for published and ongoing', () {
      final published = Event(
        name: 'E',
        description: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        location: 'L',
        category: 'C',
        status: 'published',
      );
      final draft = published.copyWith(status: 'draft');

      expect(published.isActive, isTrue);
      expect(draft.isActive, isFalse);
    });

    test('durationDays is correct', () {
      final event = Event(
        name: 'E',
        description: '',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 3),
        location: 'L',
        category: 'C',
      );
      expect(event.durationDays, 3);
    });
  });

  group('Guest model', () {
    test('rsvpLabel returns correct labels', () {
      final guest = Guest(
        eventId: 1,
        name: 'Alice',
        email: 'alice@example.com',
        phone: '555-0000',
        rsvpStatus: 'confirmed',
      );
      expect(guest.rsvpLabel, 'Confirmed');

      final pending = guest.copyWith(rsvpStatus: 'pending');
      expect(pending.rsvpLabel, 'Pending');

      final maybe = guest.copyWith(rsvpStatus: 'maybe');
      expect(maybe.rsvpLabel, 'Maybe');

      final declined = guest.copyWith(rsvpStatus: 'declined');
      expect(declined.rsvpLabel, 'Declined');
    });

    test('fromMap / toMap round-trips correctly', () {
      final guest = Guest(
        id: 1,
        eventId: 1,
        name: 'Bob',
        email: 'bob@example.com',
        phone: '555-1111',
        rsvpStatus: 'confirmed',
        isPlusOne: true,
        plusOneCount: 1,
        dietaryRestrictions: 'Vegan',
      );

      final map = guest.toMap();
      final restored = Guest.fromMap(map);

      expect(restored.name, guest.name);
      expect(restored.rsvpStatus, guest.rsvpStatus);
      expect(restored.isPlusOne, guest.isPlusOne);
      expect(restored.dietaryRestrictions, guest.dietaryRestrictions);
    });
  });

  group('Task model', () {
    test('priorityLabel and statusLabel', () {
      final task = Task(
        eventId: 1,
        title: 'Test task',
        description: '',
        priority: 'high',
        status: 'in_progress',
      );

      expect(task.priorityLabel, 'High');
      expect(task.statusLabel, 'In Progress');
      expect(task.isCompleted, isFalse);
    });

    test('isCompleted true when status is done', () {
      final task = Task(
        eventId: 1,
        title: 'Done task',
        description: '',
        status: 'done',
      );
      expect(task.isCompleted, isTrue);
    });
  });

  group('BudgetSummary', () {
    test('calculates income, expenses, and remaining correctly', () {
      final entries = [
        BudgetEntry(
          eventId: 1,
          category: 'Sponsor',
          description: 'Main sponsor',
          amount: 10000,
          isIncome: true,
          date: DateTime.now(),
        ),
        BudgetEntry(
          eventId: 1,
          category: 'Venue',
          description: 'Hall rental',
          amount: 4000,
          isIncome: false,
          date: DateTime.now(),
        ),
        BudgetEntry(
          eventId: 1,
          category: 'Catering',
          description: 'Food',
          amount: 2000,
          isIncome: false,
          date: DateTime.now(),
        ),
      ];

      final summary = BudgetSummary.fromEntries(entries);

      expect(summary.totalIncome, 10000);
      expect(summary.totalExpenses, 6000);
      expect(summary.remaining, 4000);
    });
  });

  group('AppUser model', () {
    test('fromMap / toMap round-trips correctly', () {
      final user = AppUser(id: 'u1', name: 'Alice', email: 'alice@test.com');
      final map = user.toMap();
      final restored = AppUser.fromMap(map);

      expect(restored.id, user.id);
      expect(restored.name, user.name);
      expect(restored.email, user.email);
    });
  });

  // ------------------------------------------------------------------
  // Widget tests — reusable components
  // ------------------------------------------------------------------

  group('SyncSphereButton widget', () {
    testWidgets('renders label and calls onPressed', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncSphereButton(
              label: 'Click Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('shows CircularProgressIndicator when isLoading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncSphereButton(
              label: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });
  });

  group('EmptyStateWidget widget', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'Nothing Here',
              subtitle: 'Add something to get started.',
              icon: Icons.inbox_outlined,
            ),
          ),
        ),
      );

      expect(find.text('Nothing Here'), findsOneWidget);
      expect(find.text('Add something to get started.'), findsOneWidget);
    });

    testWidgets('shows action button when provided', (tester) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'Empty',
              subtitle: 'Subtitle',
              icon: Icons.inbox_outlined,
              actionLabel: 'Add Item',
              onActionPressed: () => actionPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
      await tester.tap(find.text('Add Item'));
      expect(actionPressed, isTrue);
    });
  });

  group('DesignTokens', () {
    test('primary color is correct', () {
      expect(DesignTokens.primaryColor.value, const Color(0xFF6C5CE7).value);
    });

    test('spacing values are positive', () {
      expect(DesignTokens.spacingXS, greaterThan(0));
      expect(DesignTokens.spacingM, greaterThan(DesignTokens.spacingS));
      expect(DesignTokens.spacingL, greaterThan(DesignTokens.spacingM));
    });
  });

  group('ThemeProvider', () {
    test('starts in light mode and toggles to dark', () {
      final provider = ThemeProvider();
      expect(provider.themeMode, ThemeMode.light);
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);
    });
  });
}
