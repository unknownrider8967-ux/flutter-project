import 'package:flutter/material.dart';
import 'package:syncsphere/data/models/event_model.dart';
import 'package:syncsphere/data/services/database_service.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  Event? _selectedEvent;
  bool _isLoading = false;

  List<Event> get events => _events;
  Event? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;

  void selectEvent(Event event) {
    _selectedEvent = event;
    notifyListeners();
  }

  Future<void> loadEvents() async {
    _setLoading(true);

    try {
      final db = await DatabaseService.instance.database;
      final results = await db.query(
        'events',
        orderBy: 'start_date ASC',
      );
      _events = results.map((map) => Event.fromMap(map)).toList();
      // Auto-select the first event if none selected yet
      if (_selectedEvent == null && _events.isNotEmpty) {
        _selectedEvent = _events.first;
      }
      // Re-sync selectedEvent in case it was updated
      if (_selectedEvent != null) {
        final fresh =
            _events.where((e) => e.id == _selectedEvent!.id).toList();
        if (fresh.isNotEmpty) _selectedEvent = fresh.first;
      }
    } catch (e) {
      debugPrint('EventProvider.loadEvents error: $e');
    }

    _setLoading(false);
  }

  Future<void> createEvent(Event event) async {
    _setLoading(true);
    try {
      final db = await DatabaseService.instance.database;
      final id = await db.insert('events', event.toMap());
      final newEvent = event.copyWith(id: id);
      _events.add(newEvent);
      _selectedEvent = newEvent;
    } catch (e) {
      debugPrint('EventProvider.createEvent error: $e');
    }
    _setLoading(false);
  }

  Future<void> updateEvent(Event event) async {
    _setLoading(true);
    try {
      final db = await DatabaseService.instance.database;
      await db.update(
        'events',
        event.toMap(),
        where: 'id = ?',
        whereArgs: [event.id],
      );
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) _events[index] = event;
      if (_selectedEvent?.id == event.id) _selectedEvent = event;
    } catch (e) {
      debugPrint('EventProvider.updateEvent error: $e');
    }
    _setLoading(false);
  }

  Future<void> deleteEvent(int id) async {
    _setLoading(true);
    try {
      final db = await DatabaseService.instance.database;
      await db.delete('events', where: 'id = ?', whereArgs: [id]);
      _events.removeWhere((e) => e.id == id);
      if (_selectedEvent?.id == id) {
        _selectedEvent = _events.isNotEmpty ? _events.first : null;
      }
    } catch (e) {
      debugPrint('EventProvider.deleteEvent error: $e');
    }
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
