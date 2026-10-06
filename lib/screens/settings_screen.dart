import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../store.dart';
import '../utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    Widget section(String title, List<Widget> children) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: scheme.onSurface.withAlpha(170),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: scheme.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: children),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        section('APPEARANCE', [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            subtitle: Text(store.dark ? 'On' : 'Off'),
            value: store.dark,
            onChanged: (v) => store.setDark(v),
          ),
        ]),
        section('PREFERENCES', [
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency'),
            trailing: Text(
              store.currency,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            onTap: () => _pickCurrency(context, store),
          ),
          ListTile(
            leading: const Icon(Icons.savings_outlined),
            title: const Text('Monthly budget'),
            subtitle: Text(
              store.budget > 0
                  ? money(store.budget, store.currency)
                  : 'Not set',
            ),
            onTap: () => _editBudget(context, store),
          ),
        ]),
        section('DATA', [
          ListTile(
            leading: const Icon(Icons.copy_all_outlined),
            title: const Text('Export as CSV'),
            subtitle: const Text('Copy all expenses to clipboard'),
            onTap: () => _exportCsv(context, store),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: const Text(
              'Clear all data',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _confirmClear(context, store),
          ),
        ]),
        section('ABOUT', [
          const ListTile(
            leading: Icon(Icons.account_balance_wallet_outlined),
            title: Text('Expense Tracker'),
            subtitle: Text(
              'A lightweight app to log daily expenses. '
              'Your data stays on this device.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            trailing: Text(kAppVersion),
          ),
        ]),
        const SizedBox(height: 28),
        Center(
          child: Text(
            'Made with KN Builders',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: scheme.onSurface.withAlpha(150),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickCurrency(BuildContext context, ExpenseStore store) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Currency'),
        children: [
          for (final c in kCurrencies)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(c),
              child: Text(c, style: const TextStyle(fontSize: 20)),
            ),
        ],
      ),
    );
    if (picked != null) await store.setCurrency(picked);
  }

  Future<void> _editBudget(BuildContext context, ExpenseStore store) async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => _BudgetDialog(initial: store.budget, symbol: store.currency),
    );
    if (result != null) await store.setBudget(result);
  }

  Future<void> _exportCsv(BuildContext context, ExpenseStore store) async {
    final messenger = ScaffoldMessenger.of(context);
    if (store.expenses.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Nothing to export')));
      return;
    }
    String esc(String s) => '"${s.replaceAll('"', '""')}"';
    final buf = StringBuffer('Title,Amount,Category,Date,Note\n');
    for (final e in store.expenses) {
      buf.writeln(
        '${esc(e.title)},${e.amount.toStringAsFixed(2)},${esc(e.category)},'
        '${e.date.toIso8601String().substring(0, 10)},${esc(e.note)}',
      );
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    messenger.showSnackBar(
      SnackBar(content: Text('Copied ${store.expenses.length} expenses as CSV')),
    );
  }

  Future<void> _confirmClear(BuildContext context, ExpenseStore store) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will permanently delete all your expenses. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await store.clearAll();
      messenger.showSnackBar(const SnackBar(content: Text('All data cleared')));
    }
  }
}

class _BudgetDialog extends StatefulWidget {
  final double initial;
  final String symbol;
  const _BudgetDialog({required this.initial, required this.symbol});

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(
      text: widget.initial > 0 ? plainAmount(widget.initial) : '',
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Monthly budget'),
      content: TextField(
        controller: _c,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        decoration: InputDecoration(
          prefixText: '${widget.symbol} ',
          hintText: '0',
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (widget.initial > 0)
          TextButton(
            onPressed: () => Navigator.of(context).pop(0.0),
            child: const Text('Remove'),
          ),
        FilledButton(
          onPressed: () {
            final v = double.tryParse(_c.text.trim());
            if (v == null || v <= 0) return;
            Navigator.of(context).pop(v);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
