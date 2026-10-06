import 'package:flutter/material.dart';

import '../theme.dart';
import 'expense_form_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _addExpense() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ExpenseFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
        toolbarHeight: 44,
        titleSpacing: 16,
        title: Text(
          _index == 0 ? 'Expense Tracker' : 'Settings',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), SettingsScreen()],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: _addExpense,
              backgroundColor: isDark ? AppColors.softBlue : AppColors.blue,
              foregroundColor: isDark ? AppColors.navy : Colors.white,
              tooltip: 'New expense',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        height: 60,
        selectedIndex: _index,
        backgroundColor: scheme.surface,
        indicatorColor: isDark ? AppColors.blue : AppColors.tint,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
