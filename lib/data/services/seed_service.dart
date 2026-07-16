import 'package:sqflite/sqflite.dart';
import 'package:syncsphere/data/services/database_service.dart';
import 'package:syncsphere/data/models/event_model.dart';
import 'package:syncsphere/data/models/guest_model.dart';
import 'package:syncsphere/data/models/task_model.dart';
import 'package:syncsphere/data/models/budget_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeedService {
  static final SeedService instance = SeedService._init();
  SeedService._init();
  
  static const String _seedKey = 'data_seeded';
  
  Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_seedKey) ?? false;
    
    if (!alreadySeeded) {
      await _seedData();
      await prefs.setBool(_seedKey, true);
    }
  }
  
  Future<void> _seedData() async {
    final db = await DatabaseService.instance.database;
    
    final events = [
      Event(
        name: 'Tech Summit 2024',
        description: 'Annual technology conference featuring industry leaders, workshops, and networking opportunities.',
        startDate: DateTime(2024, 5, 15, 9, 0),
        endDate: DateTime(2024, 5, 17, 18, 0),
        location: 'San Francisco Convention Center',
        category: 'Conference',
        status: 'published',
        maxGuests: 500,
        budget: 50000,
      ),
      Event(
        name: 'Product Launch: Nova X',
        description: 'Exclusive launch event for our latest flagship product.',
        startDate: DateTime(2024, 6, 5, 18, 0),
        endDate: DateTime(2024, 6, 5, 22, 0),
        location: 'The Ritz-Carlton, New York',
        category: 'Product Launch',
        status: 'ongoing',
        maxGuests: 200,
        budget: 25000,
      ),
      Event(
        name: 'Summer Music Festival',
        description: 'Outdoor music festival featuring local and international artists.',
        startDate: DateTime(2024, 7, 20, 12, 0),
        endDate: DateTime(2024, 7, 22, 23, 0),
        location: 'Central Park Amphitheater',
        category: 'Festival',
        status: 'draft',
        maxGuests: 1000,
        budget: 75000,
      ),
    ];
    
    for (var event in events) {
      final eventId = await db.insert('events', event.toMap());
      await _seedGuests(db, eventId);
      await _seedTasks(db, eventId);
      await _seedBudget(db, eventId, event.budget!);
    }
  }
  
  Future<void> _seedGuests(Database db, int eventId) async {
    final guests = [
      Guest(
        eventId: eventId,
        name: 'Alice Johnson',
        email: 'alice@example.com',
        phone: '+1 (555) 123-4567',
        rsvpStatus: 'confirmed',
        isPlusOne: true,
        plusOneCount: 1,
        dietaryRestrictions: 'Vegetarian',
      ),
      Guest(
        eventId: eventId,
        name: 'Bob Smith',
        email: 'bob@example.com',
        phone: '+1 (555) 234-5678',
        rsvpStatus: 'confirmed',
        isPlusOne: false,
        dietaryRestrictions: 'Gluten-free',
      ),
      Guest(
        eventId: eventId,
        name: 'Carol Davis',
        email: 'carol@example.com',
        phone: '+1 (555) 345-6789',
        rsvpStatus: 'pending',
        isPlusOne: false,
      ),
      Guest(
        eventId: eventId,
        name: 'David Wilson',
        email: 'david@example.com',
        phone: '+1 (555) 456-7890',
        rsvpStatus: 'declined',
        isPlusOne: false,
      ),
    ];
    
    for (var guest in guests) {
      await db.insert('guests', guest.toMap());
    }
  }
  
  Future<void> _seedTasks(Database db, int eventId) async {
    final tasks = [
      Task(
        eventId: eventId,
        title: 'Finalize venue booking',
        description: 'Confirm contract and deposit for venue.',
        priority: 'high',
        status: 'done',
        assignedTo: 'Sarah M.',
        dueDate: DateTime.now().add(const Duration(days: 7)),
      ),
      Task(
        eventId: eventId,
        title: 'Design invitation cards',
        description: 'Create digital and physical invitation designs.',
        priority: 'medium',
        status: 'in_progress',
        assignedTo: 'James K.',
        dueDate: DateTime.now().add(const Duration(days: 14)),
      ),
      Task(
        eventId: eventId,
        title: 'Coordinate with vendors',
        description: 'Contact and negotiate with all service providers.',
        priority: 'high',
        status: 'todo',
        assignedTo: 'Lisa R.',
        dueDate: DateTime.now().add(const Duration(days: 10)),
      ),
    ];
    
    for (var task in tasks) {
      await db.insert('tasks', task.toMap());
    }
  }
  
  Future<void> _seedBudget(Database db, int eventId, double totalBudget) async {
    final entries = [
      BudgetEntry(
        eventId: eventId,
        category: 'Venue',
        description: 'Venue rental and facilities',
        amount: totalBudget * 0.3,
        isIncome: false,
        date: DateTime.now().subtract(const Duration(days: 10)),
      ),
      BudgetEntry(
        eventId: eventId,
        category: 'Catering',
        description: 'Food and beverage services',
        amount: totalBudget * 0.25,
        isIncome: false,
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      BudgetEntry(
        eventId: eventId,
        category: 'Marketing',
        description: 'Advertising and promotion',
        amount: totalBudget * 0.15,
        isIncome: false,
        date: DateTime.now().add(const Duration(days: 3)),
      ),
    ];
    
    for (var entry in entries) {
      await db.insert('budget_entries', entry.toMap());
    }
  }
}