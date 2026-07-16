import 'package:flutter/material.dart';
import 'package:syncsphere/data/models/task_model.dart';
import 'package:syncsphere/data/services/database_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = false;
  String _filterStatus = 'all';
  String _filterPriority = 'all';
  
  List<Task> get tasks => _filteredTasks;
  bool get isLoading => _isLoading;
  
  Future<void> loadTasks(int eventId) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      final results = await db.query(
        'tasks',
        where: 'event_id = ?',
        whereArgs: [eventId],
        orderBy: 'due_date ASC',
      );
      
      _tasks = results.map((map) => Task.fromMap(map)).toList();
      _applyFilters();
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  Future<void> addTask(Task task) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      final id = await db.insert('tasks', task.toMap());
      final newTask = task.copyWith(id: id);
      _tasks.add(newTask);
      _applyFilters();
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  Future<void> updateTask(Task task) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        _applyFilters();
      }
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  Future<void> deleteTask(int id) async {
    _setLoading(true);
    
    try {
      final db = await DatabaseService.instance.database;
      await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      _tasks.removeWhere((t) => t.id == id);
      _applyFilters();
    } catch (e) {
      // Handle error
    }
    
    _setLoading(false);
  }
  
  Future<void> updateTaskStatus(int id, String status) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    final updatedTask = task.copyWith(
      status: status,
      completedAt: status == 'done' ? DateTime.now() : null,
    );
    await updateTask(updatedTask);
  }
  
  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilters();
  }
  
  void filterByPriority(String priority) {
    _filterPriority = priority;
    _applyFilters();
  }
  
  void _applyFilters() {
    _filteredTasks = _tasks.where((task) {
      final matchesStatus = _filterStatus == 'all' ||
          task.status == _filterStatus;
      
      final matchesPriority = _filterPriority == 'all' ||
          task.priority == _filterPriority;
      
      return matchesStatus && matchesPriority;
    }).toList();
    
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}