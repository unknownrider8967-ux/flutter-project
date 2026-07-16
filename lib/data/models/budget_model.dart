class BudgetEntry {
  final int? id;
  final int eventId;
  final String category;
  final String description;
  final double amount;
  final bool isIncome;
  final DateTime date;
  final String? paidBy;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetEntry({
    this.id,
    required this.eventId,
    required this.category,
    required this.description,
    required this.amount,
    this.isIncome = false,
    required this.date,
    this.paidBy,
    this.receiptUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'category': category,
      'description': description,
      'amount': amount,
      'is_income': isIncome ? 1 : 0,
      'date': date.toIso8601String(),
      'paid_by': paidBy,
      'receipt_url': receiptUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BudgetEntry.fromMap(Map<String, dynamic> map) {
    return BudgetEntry(
      id: map['id'],
      eventId: map['event_id'],
      category: map['category'],
      description: map['description'],
      amount: map['amount'].toDouble(),
      isIncome: map['is_income'] == 1,
      date: DateTime.parse(map['date']),
      paidBy: map['paid_by'],
      receiptUrl: map['receipt_url'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  BudgetEntry copyWith({
    int? id,
    int? eventId,
    String? category,
    String? description,
    double? amount,
    bool? isIncome,
    DateTime? date,
    String? paidBy,
    String? receiptUrl,
    DateTime? updatedAt,
  }) {
    return BudgetEntry(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      date: date ?? this.date,
      paidBy: paidBy ?? this.paidBy,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class BudgetSummary {
  final double totalIncome;
  final double totalExpenses;
  final double remaining;

  BudgetSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.remaining,
  });

  factory BudgetSummary.fromEntries(List<BudgetEntry> entries) {
    double income = 0;
    double expenses = 0;
    
    for (var entry in entries) {
      if (entry.isIncome) {
        income += entry.amount;
      } else {
        expenses += entry.amount;
      }
    }
    
    return BudgetSummary(
      totalIncome: income,
      totalExpenses: expenses,
      remaining: income - expenses,
    );
  }
}