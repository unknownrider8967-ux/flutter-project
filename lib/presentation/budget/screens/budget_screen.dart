import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncsphere/core/theme/design_tokens.dart';
import 'package:syncsphere/core/widgets/reusable_widgets.dart';
import 'package:syncsphere/data/models/budget_model.dart';
import 'package:syncsphere/presentation/budget/providers/budget_provider.dart';
import 'package:syncsphere/presentation/budget/screens/add_edit_budget_screen.dart';

class BudgetScreen extends StatefulWidget {
  final int eventId;

  const BudgetScreen({super.key, required this.eventId});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgetEntries(widget.eventId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddEditBudgetScreen(eventId: widget.eventId),
                ),
              );
              if (mounted) {
                context
                    .read<BudgetProvider>()
                    .loadBudgetEntries(widget.eventId);
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: DesignTokens.primaryColor,
          unselectedLabelColor: DesignTokens.textSecondary,
          indicatorColor: DesignTokens.primaryColor,
          tabs: const [
            Tab(text: 'Entries'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (summary != null) _buildSummaryCard(summary),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEntriesTab(budgetProvider, entries),
                _buildAnalyticsTab(entries),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BudgetSummary summary) {
    return Container(
      margin: const EdgeInsets.all(DesignTokens.spacingL),
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [DesignTokens.primaryColor, DesignTokens.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: DesignTokens.radiusL,
      ),
      child: Row(
        children: [
          _summaryItem('Income',
              '\$${summary.totalIncome.toStringAsFixed(0)}', Colors.white),
          _verticalDivider(),
          _summaryItem('Expenses',
              '\$${summary.totalExpenses.toStringAsFixed(0)}', DesignTokens.accentColor),
          _verticalDivider(),
          _summaryItem(
            'Remaining',
            '\$${summary.remaining.toStringAsFixed(0)}',
            summary.remaining >= 0 ? Colors.white : DesignTokens.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: DesignTokens.spacingXS),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildEntriesTab(BudgetProvider provider, List<BudgetEntry> entries) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (entries.isEmpty) {
      return EmptyStateWidget(
        title: 'No Budget Entries',
        subtitle: 'Add income or expense entries to track your budget.',
        actionLabel: 'Add Entry',
        icon: Icons.attach_money,
        onActionPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditBudgetScreen(eventId: widget.eventId),
            ),
          ).then((_) => context
              .read<BudgetProvider>()
              .loadBudgetEntries(widget.eventId));
        },
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      itemCount: entries.length,
      itemBuilder: (context, index) => _buildEntryCard(entries[index]),
    );
  }

  Widget _buildEntryCard(BudgetEntry entry) {
    return SyncSphereCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: entry.isIncome ? DesignTokens.success : DesignTokens.error,
              borderRadius: DesignTokens.radiusXL,
            ),
          ),
          const SizedBox(width: DesignTokens.spacingM),
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacingS),
            decoration: BoxDecoration(
              color: (entry.isIncome ? DesignTokens.success : DesignTokens.error)
                  .withOpacity(0.1),
              borderRadius: DesignTokens.radiusS,
            ),
            child: Icon(
              entry.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: entry.isIncome ? DesignTokens.success : DesignTokens.error,
              size: 16,
            ),
          ),
          const SizedBox(width: DesignTokens.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  entry.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.textSecondary,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(entry.date),
                  style: const TextStyle(
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
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: entry.isIncome ? DesignTokens.success : DesignTokens.error,
            ),
          ),
          const SizedBox(width: DesignTokens.spacingXS),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditBudgetScreen(
                        entry: entry, eventId: widget.eventId),
                  ),
                ).then((_) => context
                    .read<BudgetProvider>()
                    .loadBudgetEntries(widget.eventId));
              } else if (value == 'delete') {
                _showDeleteDialog(entry.id!);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline,
                      size: 18, color: DesignTokens.error),
                  SizedBox(width: 8),
                  Text('Delete',
                      style: TextStyle(color: DesignTokens.error)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(List<BudgetEntry> entries) {
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No data yet — add budget entries to see analytics.',
          style: TextStyle(color: DesignTokens.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Group expenses by category
    final expensesByCategory = <String, double>{};
    for (final e in entries.where((e) => !e.isIncome)) {
      expensesByCategory[e.category] =
          (expensesByCategory[e.category] ?? 0) + e.amount;
    }

    if (expensesByCategory.isEmpty) {
      return const Center(
        child: Text(
          'No expense entries yet.',
          style: TextStyle(color: DesignTokens.textSecondary),
        ),
      );
    }

    final colors = [
      DesignTokens.primaryColor,
      DesignTokens.accentColor,
      DesignTokens.secondaryColor,
      DesignTokens.warning,
      DesignTokens.info,
      DesignTokens.primaryLight,
    ];

    final cats = expensesByCategory.keys.toList();
    final total = expensesByCategory.values.fold(0.0, (a, b) => a + b);

    final sections = cats.asMap().entries.map((entry) {
      final idx = entry.key;
      final cat = entry.value;
      final amount = expensesByCategory[cat]!;
      final pct = amount / total * 100;
      return PieChartSectionData(
        color: colors[idx % colors.length],
        value: amount,
        title: '${pct.round()}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spacingL),
      child: Column(
        children: [
          SyncSphereCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expenses by Category',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: DesignTokens.spacingL),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingL),
                ...cats.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final cat = entry.value;
                  final amount = expensesByCategory[cat]!;
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: DesignTokens.spacingS),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[idx % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spacingS),
                        Expanded(child: Text(cat)),
                        Text(
                          '\$${amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
            'Are you sure you want to delete this budget entry?'),
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
            child: const Text('Delete',
                style: TextStyle(color: DesignTokens.error)),
          ),
        ],
      ),
    );
  }
}
