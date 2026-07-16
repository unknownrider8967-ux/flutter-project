import 'package:flutter/material.dart';

class Task {
  final int? id;
  final int eventId;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String? assignedTo;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    this.id,
    required this.eventId,
    required this.title,
    required this.description,
    this.priority = 'medium',
    this.status = 'todo',
    this.assignedTo,
    this.dueDate,
    this.completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'assigned_to': assignedTo,
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      eventId: map['event_id'],
      title: map['title'],
      description: map['description'],
      priority: map['priority'] ?? 'medium',
      status: map['status'] ?? 'todo',
      assignedTo: map['assigned_to'],
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'])
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Task copyWith({
    int? id,
    int? eventId,
    String? title,
    String? description,
    String? priority,
    String? status,
    String? assignedTo,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String get priorityLabel {
    switch (priority) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      default:
        return 'Low';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 'high':
        return const Color(0xFFFF6B6B);
      case 'medium':
        return const Color(0xFFFDCB6E);
      default:
        return const Color(0xFF00B894);
    }
  }

  String get statusLabel {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'review':
        return 'Review';
      case 'done':
        return 'Done';
      default:
        return 'To Do';
    }
  }

  bool get isCompleted => status == 'done';
}