import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;
  const ExpenseCategory(this.name, this.icon, this.color);
}

const List<ExpenseCategory> kCategories = [
  ExpenseCategory('Food', Icons.restaurant, Color(0xFFFF8A65)),
  ExpenseCategory('Transport', Icons.directions_bus, Color(0xFF4FC3F7)),
  ExpenseCategory('Shopping', Icons.shopping_bag_outlined, Color(0xFFBA68C8)),
  ExpenseCategory('Bills', Icons.receipt_long, Color(0xFFFFD54F)),
  ExpenseCategory('Health', Icons.medical_services_outlined, Color(0xFF81C784)),
  ExpenseCategory('Entertainment', Icons.movie_outlined, Color(0xFFF06292)),
  ExpenseCategory('Education', Icons.school_outlined, Color(0xFF7986CB)),
  ExpenseCategory('Other', Icons.category_outlined, Color(0xFF90A4AE)),
];

ExpenseCategory categoryOf(String name) {
  for (final c in kCategories) {
    if (c.name == name) return c;
  }
  return kCategories.last;
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String note;
  final int createdAt;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'note': note,
        'createdAt': createdAt,
      };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] as String,
        title: j['title'] as String,
        amount: (j['amount'] as num).toDouble(),
        category: (j['category'] as String?) ?? 'Other',
        date: DateTime.parse(j['date'] as String),
        note: (j['note'] as String?) ?? '',
        createdAt: (j['createdAt'] as num?)?.toInt() ?? 0,
      );
}
