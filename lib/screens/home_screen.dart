import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import 'expense_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _filter;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final q = _query.trim().toLowerCase();
    final items = store.expenses.where((e) {
      final okCat = _filter == null || e.category == _filter;
      final okQuery = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.note.toLowerCase().contains(q);
      return okCat && okQuery;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                SummaryCard(store: store),
                if (store.monthTotal > 0) ...[
                  const SizedBox(height: 12),
                  BreakdownCard(store: store),
                ],
              ],
            ),
          ),
        ),
        if (store.expenses.isNotEmpty)
          SliverToBoxAdapter(child: _buildSearchAndFilters(context)),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(hasAny: store.expenses.isNotEmpty),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, i) =>
                  ExpenseTile(expense: items[i], store: store),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search expenses',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: scheme.surface,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 58,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
              ),
              for (final c in kCategories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(c.icon, size: 16, color: c.color),
                    label: Text(c.name),
                    selected: _filter == c.name,
                    onSelected: (_) => setState(() => _filter = c.name),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final ExpenseStore store;
  const SummaryCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final sym = store.currency;
    final hasBudget = store.budget > 0;
    final over = hasBudget && store.monthTotal > store.budget;
    final progress =
        hasBudget ? (store.monthTotal / store.budget).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spent this month',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            money(store.monthTotal, sym),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (hasBudget) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white24,
                color: over ? Colors.redAccent : AppColors.softBlue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              over
                  ? 'Over budget by ${money(store.monthTotal - store.budget, sym)}'
                  : '${money(store.budget - store.monthTotal, sym)} left of ${money(store.budget, sym)}',
              style: TextStyle(
                color: over ? Colors.redAccent.shade100 : Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(label: 'All time', value: money(store.total, sym)),
              const SizedBox(width: 24),
              _Stat(label: 'Entries', value: '${store.expenses.length}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class BreakdownCard extends StatelessWidget {
  final ExpenseStore store;
  const BreakdownCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entries = store.monthByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = store.monthTotal;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'By category',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    for (final e in entries)
                      Expanded(
                        flex: _flex(e.value, total),
                        child: Container(color: categoryOf(e.key).color),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                for (final e in entries)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: categoryOf(e.key).color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${e.key}  ${money(e.value, store.currency)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _flex(double value, double total) {
    if (total <= 0) return 1;
    final f = (value / total * 1000).round();
    return f < 1 ? 1 : f;
  }
}

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final ExpenseStore store;
  const ExpenseTile({super.key, required this.expense, required this.store});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cat = categoryOf(expense.category);
    final messenger = ScaffoldMessenger.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(expense.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        onDismissed: (_) {
          store.remove(expense.id);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Deleted "${expense.title}"'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () => store.add(expense),
              ),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: scheme.surface,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ExpenseFormScreen(expense: expense),
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: cat.color.withAlpha(45),
              foregroundColor: cat.color,
              child: Icon(cat.icon, size: 20),
            ),
            title: Text(
              expense.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${expense.category} · ${relativeDate(expense.date)}'),
            trailing: Text(
              money(expense.amount, store.currency),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasAny;
  const _EmptyState({required this.hasAny});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasAny ? Icons.search_off : Icons.receipt_long_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
          ),
          const SizedBox(height: 12),
          Text(
            hasAny ? 'No matching expenses' : 'No expenses yet',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            hasAny ? 'Try a different search or filter.' : 'Tap + to add your first expense.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
