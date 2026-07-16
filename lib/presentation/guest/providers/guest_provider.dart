import 'package:flutter/material.dart';
import 'package:syncsphere/data/models/guest_model.dart';
import 'package:syncsphere/data/services/database_service.dart';

class GuestProvider extends ChangeNotifier {
  List<Guest> _guests = [];
  List<Guest> _filteredGuests = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterStatus = 'all';
  
  List<Guest> get guests => _filteredGuests;
  bool get isLoading => _isLoading;
  
  Future<void> loadGuests(int eventId) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      final results = await db.query(
        'guests',
        where: 'event_id = ?',
        whereArgs: [eventId],
        orderBy: 'name ASC',
      );
      
      _guests = results.map((map) => Guest.fromMap(map)).toList();
      _applyFilters();
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  Future<void> addGuest(Guest guest) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      final id = await db.insert('guests', guest.toMap());
      final newGuest = guest.copyWith(id: id);
      _guests.add(newGuest);
      _applyFilters();
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  Future<void> updateGuest(Guest guest) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      await db.update(
        'guests',
        guest.toMap(),
        where: 'id = ?',
        whereArgs: [guest.id],
      );
      
      final index = _guests.indexWhere((g) => g.id == guest.id);
      if (index != -1) {
        _guests[index] = guest;
        _applyFilters();
      }
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  Future<void> deleteGuest(int id) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      await db.delete(
        'guests',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      _guests.removeWhere((g) => g.id == id);
      _applyFilters();
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  Future<void> updateRSVP(int id, String status) async {
    final guest = _guests.firstWhere((g) => g.id == id);
    final updatedGuest = guest.copyWith(rsvpStatus: status);
    await updateGuest(updatedGuest);
  }
  
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }
  
  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilters();
  }
  
  void _applyFilters() {
    _filteredGuests = _guests.where((guest) {
      final matchesSearch = _searchQuery.isEmpty ||
          guest.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          guest.email.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesFilter = _filterStatus == 'all' ||
          guest.rsvpStatus == _filterStatus;
      
      return matchesSearch && matchesFilter;
    }).toList();
    
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}