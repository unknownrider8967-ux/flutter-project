import 'package:intl/intl.dart';

class Event {
  final int? id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String category;
  final String status;
  final String? imageUrl;
  final int? maxGuests;
  final double? budget;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.category,
    this.status = 'draft',
    this.imageUrl,
    this.maxGuests,
    this.budget,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'location': location,
      'category': category,
      'status': status,
      'image_url': imageUrl,
      'max_guests': maxGuests,
      'budget': budget,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      location: map['location'],
      category: map['category'],
      status: map['status'] ?? 'draft',
      imageUrl: map['image_url'],
      maxGuests: map['max_guests'],
      budget: map['budget']?.toDouble(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Event copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? category,
    String? status,
    String? imageUrl,
    int? maxGuests,
    double? budget,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      category: category ?? this.category,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      maxGuests: maxGuests ?? this.maxGuests,
      budget: budget ?? this.budget,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String get formattedStartDate => DateFormat('MMM d, yyyy').format(startDate);
  String get formattedEndDate => DateFormat('MMM d, yyyy').format(endDate);
  String get formattedTime => DateFormat('h:mm a').format(startDate);
  int get durationDays => endDate.difference(startDate).inDays + 1;
  bool get isActive => status == 'published' || status == 'ongoing';
}