import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class ExpenseStore extends ChangeNotifier {
  SharedPreferences? _prefs;
  List<Expense> _expenses = [];
  bool _dark = false;
  String _currency = '₹';
  double _budget = 0;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get dark => _dark;
  String get currency => _currency;
  double get budget => _budget;

  double get total => _expenses.fold<double>(0, (s, e) => s + e.amount);

  List<Expense> get _thisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
  }

  double get monthTotal => _thisMonth.fold<double>(0, (s, e) => s + e.amount);

  int get monthCount => _thisMonth.length;

  Map<String, double> get monthByCategory {
    final map = <String, double>{};
    for (final e in _thisMonth) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _prefs = p;
    _dark = p.getBool('dark') ?? false;
    _currency = p.getString('currency') ?? '₹';
    _budget = p.getDouble('budget') ?? 0;
    final raw = p.getString('expenses_v1');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _expenses = list
            .map((e) => Expense.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        _expenses = [];
      }
    }
    _sort();
    notifyListeners();
  }

  void _sort() {
    _expenses.sort((a, b) {
      final c = b.date.compareTo(a.date);
      return c != 0 ? c : b.createdAt.compareTo(a.createdAt);
    });
  }

  Future<void> _save() async {
    await _prefs?.setString(
      'expenses_v1',
      jsonEncode(_expenses.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> add(Expense e) async {
    _expenses.add(e);
    _sort();
    notifyListeners();
    await _save();
  }

  Future<void> update(Expense e) async {
    final i = _expenses.indexWhere((x) => x.id == e.id);
    if (i == -1) return;
    _expenses[i] = e;
    _sort();
    notifyListeners();
    await _save();
  }

  Future<void> remove(String id) async {
    _expenses.removeWhere((x) => x.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> clearAll() async {
    _expenses = [];
    notifyListeners();
    await _save();
  }

  Future<void> setDark(bool v) async {
    _dark = v;
    notifyListeners();
    await _prefs?.setBool('dark', v);
  }

  Future<void> setCurrency(String c) async {
    _currency = c;
    notifyListeners();
    await _prefs?.setString('currency', c);
  }

  Future<void> setBudget(double b) async {
    _budget = b;
    notifyListeners();
    await _prefs?.setDouble('budget', b);
  }
}

class StoreScope extends InheritedNotifier<ExpenseStore> {
  const StoreScope({
    super.key,
    required ExpenseStore store,
    required super.child,
  }) : super(notifier: store);

  /// Rebuilds the caller when the store changes. Use inside build().
  static ExpenseStore of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StoreScope>()!
        .notifier!;
  }

  /// Does not subscribe. Use inside callbacks / initState.
  static ExpenseStore read(BuildContext context) {
    final w = context
        .getElementForInheritedWidgetOfExactType<StoreScope>()!
        .widget as StoreScope;
    return w.notifier!;
  }
}
