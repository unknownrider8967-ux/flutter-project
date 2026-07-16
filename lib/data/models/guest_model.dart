import 'package:flutter/material.dart';

class Guest {
  final int? id;
  final int eventId;
  final String name;
  final String email;
  final String phone;
  final String rsvpStatus;
  final bool isPlusOne;
  final int? plusOneCount;
  final String? dietaryRestrictions;
  final String? notes;
  final DateTime? checkInTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  Guest({
    this.id,
    required this.eventId,
    required this.name,
    required this.email,
    required this.phone,
    this.rsvpStatus = 'pending',
    this.isPlusOne = false,
    this.plusOneCount,
    this.dietaryRestrictions,
    this.notes,
    this.checkInTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'name': name,
      'email': email,
      'phone': phone,
      'rsvp_status': rsvpStatus,
      'is_plus_one': isPlusOne ? 1 : 0,
      'plus_one_count': plusOneCount,
      'dietary_restrictions': dietaryRestrictions,
      'notes': notes,
      'check_in_time': checkInTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Guest.fromMap(Map<String, dynamic> map) {
    return Guest(
      id: map['id'],
      eventId: map['event_id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      rsvpStatus: map['rsvp_status'] ?? 'pending',
      isPlusOne: map['is_plus_one'] == 1,
      plusOneCount: map['plus_one_count'],
      dietaryRestrictions: map['dietary_restrictions'],
      notes: map['notes'],
      checkInTime: map['check_in_time'] != null
          ? DateTime.parse(map['check_in_time'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Guest copyWith({
    int? id,
    int? eventId,
    String? name,
    String? email,
    String? phone,
    String? rsvpStatus,
    bool? isPlusOne,
    int? plusOneCount,
    String? dietaryRestrictions,
    String? notes,
    DateTime? checkInTime,
    DateTime? updatedAt,
  }) {
    return Guest(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      isPlusOne: isPlusOne ?? this.isPlusOne,
      plusOneCount: plusOneCount ?? this.plusOneCount,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      notes: notes ?? this.notes,
      checkInTime: checkInTime ?? this.checkInTime,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String get rsvpLabel {
    switch (rsvpStatus) {
      case 'confirmed':
        return 'Confirmed';
      case 'declined':
        return 'Declined';
      case 'maybe':
        return 'Maybe';
      default:
        return 'Pending';
    }
  }

  Color get rsvpColor {
    switch (rsvpStatus) {
      case 'confirmed':
        return const Color(0xFF00B894);
      case 'declined':
        return const Color(0xFFFF6B6B);
      case 'maybe':
        return const Color(0xFFFDCB6E);
      default:
        return const Color(0xFFB2BEC3);
    }
  }
}