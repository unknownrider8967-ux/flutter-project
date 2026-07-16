import 'package:flutter/material.dart';
import 'package:syncsphere/data/models/budget_model.dart';
import 'package:syncsphere/data/services/database_service.dart';

class BudgetProvider extends ChangeNotifier {
  List<BudgetEntry> _entries = [];
  BudgetSummary? _summary;
  bool _isLoading = false;
  
  List<BudgetEntry> get entries => _entries;
  BudgetSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  
  Future<void> loadBudgetEntries(int eventId) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      final results = await db.query(
        'budget_entries',
        where: 'event_id = ?',
        whereArgs: [eventId],
        orderBy: 'date DESC',
      );
      
      _entries = results.map((map) => BudgetEntry.fromMap(map)).toList();
      _calculateSummary();
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  Future<void> addBudgetEntry(BudgetEntry entry) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      final id = await db.insert('budget_entries', entry.toMap());
      final newEntry = entry.copyWith(id: id);
      _entries.add(newEntry);
      _calculateSummary();
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  Future<void> updateBudgetEntry(BudgetEntry entry) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      await db.update(
        'budget_entries',
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = entry;
        _calculateSummary();
      }
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  Future<void> deleteBudgetEntry(int id) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      await db.delete(
        'budget_entries',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      _entries.removeWhere((e) => e.id == id);
      _calculateSummary();
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  void _calculateSummary() {
    _summary = BudgetSummary.fromEntries(_entries);
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}