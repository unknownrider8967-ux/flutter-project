import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/presentation/budget/providers/budget_provider.dart';
import 'package:syncsphere/presentation/budget/screens/add_edit_budget_screen.dart';
import 'package:syncsphere/data/models/budget_model.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  int _eventId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgetEntries(_eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final entries = budgetProvider.entries;
    final summary = budgetProvider.summary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditBudgetScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (summary != null) _buildSummary(summary),
          const SizedBox(height: DesignTokens.spacingL),
          Expanded(
            child: budgetProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : entries.isEmpty
                    ? const EmptyStateWidget(
                        title: 'No Budget Entries',
                        subtitle: 'Add your first budget entry to track expenses.',
                        actionLabel: 'Add Entry',
                        icon: Icons.attach_money,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(DesignTokens.spacingL),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return _buildEntryCard(entry);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BudgetSummary summary) {
    return Container(
      margin: const EdgeInsets.all(DesignTokens.spacingL),
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [DesignTokens.primaryColor, DesignTokens.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: DesignTokens.radiusL,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Total Income',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingXS),
                Text(
                  '\$${summary.totalIncome.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Expenses',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingXS),
                Text(
                  '\$${summary.totalExpenses.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: DesignTokens.error,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Remaining',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingXS),
                Text(
                  '\$${summary.remaining.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: summary.remaining >= 0 ? Colors.white : DesignTokens.error,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(BudgetEntry entry) {
    return SyncSphereCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingM),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: entry.isIncome ? DesignTokens.success : DesignTokens.error,
                borderRadius: DesignTokens.radiusXL,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    entry.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(entry.date),
                    style: TextStyle(
                      fontSize: 10,
                      color: DesignTokens.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${entry.isIncome ? '+' : '-'}\$${entry.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: entry.isIncome ? DesignTokens.success : DesignTokens.error,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingS),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditBudgetScreen(entry: entry),
                    ),
                  );
                } else if (value == 'delete') {
                  _showDeleteDialog(entry.id!);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: DesignTokens.spacingS),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: DesignTokens.error),
                      SizedBox(width: DesignTokens.spacingS),
                      Text('Delete', style: TextStyle(color: DesignTokens.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this budget entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<BudgetProvider>().deleteBudgetEntry(id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: DesignTokens.error),
            ),
          ),
        ],
      ),
    );
  }
}