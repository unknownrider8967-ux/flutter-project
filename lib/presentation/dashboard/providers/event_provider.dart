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
  
  Future<void> loadEvents() async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      final results = await db.query(
        'events',
        orderBy: 'start_date ASC',
      );
      
      _events = results.map((map) => Event.fromMap(map)).toList();
    } catch (e) {
      // Handle error
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
    } catch (e) {
      // Handle error
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
      if (index != -1) {
        _events[index] = event;
      }
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  Future<void> deleteEvent(int id) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      await db.delete(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      _events.removeWhere((e) => e.id == id);
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  void selectEvent(int id) {
    _selectedEvent = _events.firstWhere((e) => e.id == id);
    notifyListeners();
  }
  
  void clearSelection() {
    _selectedEvent = null;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}